/**
 * This class holds the action logic for the Post Refresh Apex Script
 * @author James LaCour
 */
public class ACVSandboxRefreshScriptQueueable implements Queueable, Database.AllowsCallouts{
    /****************Class Variables************************/
    @TestVisible private static final String EMAIL_SUFFIX_REMOVAL = '.invalid';                      //suffix to remove from the end of emails
    @TestVisible private static User testUser = null;                                                //Used in test classes for Update All Flagged Users
    @TestVisible private static final String API_ONLY_PERMISSION_SET_NAME = 'API_Only_User';         //API Name of the Permission set we need to remove

    private SandboxContext scContext;
    private String slackBody;
    private String webhook;
    private List<String> refreshActions;
    private Integer numberOfActions;
    /****************Constructors***************************/
    /**
     * Intialization of a ACVSandboxRefreshScriptQueueable
     * @param sc - Sandbox Context coming in from the Apex Refresh Class
     * @param refreshActions - List of actions needed to take for this sandbox refresh. Dependent on the Refresh Setting
     * @param toEmailAddress - grabbed from the Refresh Setting. Who the status email will go to
     * @param slackBody - Run list for status message that will be the email body.
     * @return void
     */
    public ACVSandboxRefreshScriptQueueable( SandboxContext sc, List<String> refreshActions, String webhook, String slackBody, Integer numberOfActions ){
        this.slackBody = slackBody;
        this.webhook = webhook;
        this.refreshActions = refreshActions;
        this.scContext = sc;
        this.numberOfActions = numberOfActions;
    }
    /****************Main Methods***************************/
    /**
     * automatically runs when called by System.enqueueJob();
     * @param context - standard Queueable Context
     * @return void
     */
    public void execute(QueueableContext context){
        //If just start is all the actions, don't send a message. 
        if( numberOfActions == 1 && !Test.isRunningTest() ) return;
        //Plucks this currnet action out
        String currentAction = refreshActions.size() > 0 ? refreshActions.remove(0) : 'finish';
        Boolean enqueueNext = true;
        //Action Handler
        switch on currentAction {
            when 'start'{
                String startBody = '{"blocks": [{"type": "section","text": {"type": "plain_text","text": "The Apex Refresh Script has started. Here are the actions that will be happening for the ' + scContext.sandboxName() + ' sandbox","emoji": true}},{"type": "divider"},{"type": "section","text": {"type": "mrkdwn","text": "';
                for(String action : refreshActions){
                    if( action != 'start' ) startBody += '• ' + action + '\n';
                }
                startBody.removeEnd('\n');
                startBody += '"}}]}';
                postSlackMessage(webhook, startBody);
            }
            when 'Update Environment Information'{
                slackBody = createSlackSection(currentAction, environmentInformationUpdate(scContext), slackBody);
            }
            when 'Update All Flagged Users'{
                slackBody = createSlackSection(currentAction, updateAllFlaggedUsers(scContext.sandboxName()), slackBody);
            }
            when 'Create FSL Required Data'{
                slackBody = createSlackSection(currentAction, createFSLRequiredData(), slackBody);
            }
            when 'Remove API Only User From All Users'{
                slackBody = createSlackSection(currentAction, removeApiPermissionSet(), slackBody);
            }
            when 'finish'{
                slackBody = '{"blocks": [{"type": "section","text": {"type": "plain_text","text": "The Apex Refresh Script has completed for ' + scContext.sandboxName() + '. Here is a status report based on the actions completed.","emoji": true}},{"type": "divider"}' + slackBody;
                if( scContext.sandboxName() == 'staging' ) slackBody += ',{"type": "divider"},{"type": "section","text": {"type": "mrkdwn","text": "Please complete the after deployment actions found here: <https://acvauctions.atlassian.net/wiki/spaces/SAL/pages/680984577/How-To+Staging+Environment+Setup|Staging Refresh Steps>"}}';
                slackBody += ']}';
                postSlackMessage(webhook, slackBody);
                enqueueNext = false;
            }
        }
        if( enqueueNext && !Test.isRunningTest() ) System.enqueueJob(new ACVSandboxRefreshScriptQueueable(scContext,refreshActions, webhook, slackBody, numberOfActions));
    }
    /****************Helper Methods*************************/
    /**
     * Creates each section of a Slack Message
     * @param actionName - The current action that just ran
     * @param status - whether it passed or failed (and error message if failed)
     * @param slackBody - current body of the slack message taht we will append to
     * @return new slack body
     */
    public static String createSlackSection( String actionName, String status, String slackBody ){
        slackBody += ',{"type": "section","text": {"type": "mrkdwn","text": "*' + actionName + '*\nStatus: ' + status + '\n"}}';
        return slackBody;
    }
    /**
     * Post Slack Message at the start and finish of entire Queueable process
     * @param webhook - the webhook to the slack channel we are posting the message to
     * @param body - body of the slack message
     * @return status message of whether it was successful or failed
     */
    public static String postSlackMessage( String webhook, String body ){
        //Send Status Email
        try{
            //If this fails theres actually nothing to do as this is the message to post when it fails so just sending straight to API.
            //We still catch error though as we want the rest of the queueables to happen regardless if the slack message fails
            HttpResponse req = new Http().send( ACVUtility.createSlackPost(webhook, body) );
            return 'SUCCESS';
        }catch(Exception ex){
            return 'ERROR: ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
        }
    }
    /**
     * Updates the Custom Setting with the data you can only
     * get during a post refresh run
     * @param newList - List of new Condition Reports created
     * @return void
     */
    public static String environmentInformationUpdate( SandboxContext context ){
        String resultMessage = '';
        try{
            Environment_Information__c ei = Environment_Information__c.getOrgDefaults();
            ei.Sandbox_Name__c = context.sandboxName();
            ei.Organization_Id__c = context.organizationId();
            ei.Sandbox_Id__c = context.sandboxId();
            update ei;
            resultMessage = 'SUCCESS';
        }catch(Exception ex){
            resultMessage = 'ERROR: ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
        }
        return resultMessage;
    }
    /**
     * Updates users indicated in the Refresh User Setting List
     * Removes .invalid
     * Updates profile if indicated
     * @param sandboxName - name of this sandbox. Used to query for users.
     * @return status message of whether it was successful or failed
     */
    public static String updateAllFlaggedUsers( String sandboxName ){
        String resultMessage = '';
        try{
            Map<String,Refresh_User_Setting__mdt> usernamesToUserSettingMap= new Map<String,Refresh_User_Setting__mdt>();
            Map<String,Id> apiNameToProfileIdMap = new Map<String,Id>();
            //Gather users from Metadata
            if( Test.isRunningTest() ){
                Refresh_User_Setting__mdt rus = new Refresh_User_Setting__mdt(Username__c = testUser.Username, Profile_Name__c = 'System Administrator');
                usernamesToUserSettingMap.put( testUser.Username, rus );
                apiNameToProfileIdMap.put( 'System Administrator', null );
            }else{
                for( Refresh_User_Setting__mdt rus : [ SELECT Id, Username__c, Profile_Name__c FROM Refresh_User_Setting__mdt ] ){
                    usernamesToUserSettingMap.put( rus.Username__c + '.' + sandboxName, rus );
                    if( String.isNotBlank(rus.Profile_Name__c) ) apiNameToProfileIdMap.put( rus.Profile_Name__c, null );
                }
            }
            if( usernamesToUserSettingMap.size() == 0 ){
                resultMessage = 'There were no Users found in Refresh User Setting';
            }else{
                //If updating Profile, query profiles to get the Id
                if( apiNameToProfileIdMap.size() > 0 ){
                    for( Profile p : [ SELECT Id, Name FROM Profile WHERE Name IN :apiNameToProfileIdMap.keySet() ] ){
                        apiNameToProfileIdMap.put( p.Name, p.Id );
                    }
                }
                List<User> usersToUpdate = new List<User>();
                //Update user by removing EMAIL_SUFFIX_REMOVAL. This will send them an email change email
                //If updating profile, we will update tha there as well.
                for( User u : [ SELECT Id, ProfileId, Email, Username FROM User WHERE Username IN :usernamesToUserSettingMap.keySet() AND isActive = true ] ){
                    u.Email = u.Email.removeEnd(EMAIL_SUFFIX_REMOVAL);
                    if( usernamesToUserSettingMap.get(u.Username) != null && 
                        String.isNotBlank(usernamesToUserSettingMap.get(u.Username).Profile_Name__c) && 
                        apiNameToProfileIdMap.get(usernamesToUserSettingMap.get(u.Username).Profile_Name__c) != null )
                    {
                        u.ProfileId = apiNameToProfileIdMap.get(usernamesToUserSettingMap.get(u.Username).Profile_Name__c);
                    }
                    usersToUpdate.add(u);
                }
                //Catch dml errors
                if( usersToUpdate.size() > 0 ){
                    Boolean hasError = false;
                    String errorMessage = '';
                    List<Database.SaveResult> updateResults = Database.update(usersToUpdate, false);
                    for( Database.SaveResult sr : updateResults ){
                        if( !sr.isSuccess() ){
                            hasError = true;
                            errorMessage += 'User Id: ' + sr.getId() + '\nError: ' + sr.getErrors() + '\n';
                        }
                    }
                    if( hasError ){
                        resultMessage = 'There were issues with the following users ids. All other users were properly updated:\n' + errorMessage;
                    }else{
                        resultMessage = 'SUCCESS';
                    }
                }else{
                    resultMessage = 'No users found when querying to update.';
                }
            }
        }catch(Exception ex){
            resultMessage = 'ERROR: ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
        }
        return resultMessage;
    }
    /**
     * Creates Required FSL Data
     * @return status message of whether it was successful or failed
     */
    public static String createFSLRequiredData(){
        String resultMessage = '';
        try{
            List<WorkType> createWTLst = new List<WorkType>();
            createWTLst.add( new WorkType(
                Name = 'Asset Verification',
                EstimatedDuration = 5,
                DurationType = 'Minutes'
            ) );
            createWTLst.add( new WorkType(
                Name = 'Dealership Visit - Asset Verification',
                Description = 'Represents a dealership visit with the intent of verifying the presence of a (possibly unknown) number of vehicles.',
                EstimatedDuration = 1,
                ShouldAutoCreateSvcAppt = TRUE,
                DurationType = 'Hours'
            ) );
            createWTLst.add( new WorkType(
                Name = 'Dealership Visit - Inspections',
                Description = 'Represents a general dealership visit with the intent of inspecting a (possibly unknown) number of vehicles.',
                EstimatedDuration = 1,
                ShouldAutoCreateSvcAppt = TRUE,
                DurationType = 'Hours'
            ) );
            createWTLst.add( new WorkType(
                Name = 'Standard Inspection',
                EstimatedDuration = 20,
                DurationType = 'Minutes'
            ) );        
            insert createWTLst;
            resultMessage = 'SUCCESS';
        }catch(Exception ex){
            resultMessage = 'ERROR: ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
        }
        return resultMessage;
    }
    /**
     * Removes the API Only User Permission set from All Users
     * @return status message of whether it was successful or failed
     */
    public static String removeApiPermissionSet(){
        String resultMessage = '';
        try{
            //Get Permission Set and assignee's
            List<PermissionSet> apiOnlyPermissionSet = new List<PermissionSet>([ SELECT Id FROM PermissionSet WHERE Name = :API_ONLY_PERMISSION_SET_NAME LIMIT 1 ]);
            if( apiOnlyPermissionSet.size() == 1 ){
                List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>([ SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :apiOnlyPermissionSet[0].Id LIMIT 10000]);
                if( psaList.size() > 0 ){
                    Boolean hasError = false;
                    String errorMessage = '';
                    List<Database.DeleteResult> deleteResults = Database.delete(psaList, false);
                    for( Database.DeleteResult dr : deleteResults ){
                        if( !dr.isSuccess() ){
                            hasError = true;
                            errorMessage += 'PermissionSetAssignment Id: ' + dr.getId() + '\nError: ' + dr.getErrors() + '\n';
                        }
                    }
                    if( hasError ){
                        resultMessage = 'There were issues with the following users ids. All other users were properly updated:\n' + errorMessage;
                    }else{
                        resultMessage = 'SUCCESS';
                    }
                }else{
                    resultMessage = 'No users were found to remove the Permission Set from.';
                }
            }else{
                resultMessage = 'ERROR: The Permission Set \'Api Only User\' was not found';
            }
        }catch( Exception ex ){
            resultMessage = 'ERROR: ' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
        }
        return resultMessage;
    }
}