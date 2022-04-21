/**
 * This class holds the logic for the Post-Refresh Script
 * @author Gerald McEvoy
 */
global class ACVSandboxRefreshScript implements SandboxPostCopy {
    /****************Class Variables************************/
    global static final String DEFAULT_SETTING_NAME = 'ACV_Default_Refresh_Setting';
    global static List<String> refreshActions = new List<String>();
    /****************Main Methods***************************/
    /**
     * This is the method that runs by default when this class
     * is called via the Sandbox Refresh Screen (the class name has to be indicated)
     * @param context - this is hte Sandbox context that contains the name and id of this sandbox being refreshed
     * @return void
     */
    global void runApexClass( SandboxContext context ) {
        refreshActions.add('start');
        Set<String> environmentNames = new Set<String>{DEFAULT_SETTING_NAME, context.sandboxName()};
        Refresh_Sandbox_Setting__mdt thisSetting = null;
        List<Refresh_Sandbox_Setting__mdt> rssList = new List<Refresh_Sandbox_Setting__mdt>();
        if(Test.isRunningTest()){
            rssList.add( new Refresh_Sandbox_Setting__mdt(Slack_Webhook__c='https://testWebhook.test') );
        }else{
            rssList = [ SELECT Id, DeveloperName, Slack_Webhook__c, Update_All_Flagged_Users__c, Create_FSL_Required_Data__c, Remove_API_Only_User_From_All_Users__c FROM Refresh_Sandbox_Setting__mdt WHERE DeveloperName IN :environmentNames LIMIT 2 ];
        }
        //If no Refresh Sandbox Setting is made for the sandbox being refreshed, we will use the Default
            for( Refresh_Sandbox_Setting__mdt rss : rssList )
            {
                if( rss.DeveloperName == DEFAULT_SETTING_NAME && thisSetting != null ) continue;
                thisSetting = rss;
            }
        //Actions that will happen in every refresh no matter the environment
        refreshActions.add('Update Environment Information');
        //Actions dependent on the Refresh Sandbox Setting
        //Start Jobs
        if(thisSetting.Update_All_Flagged_Users__c) refreshActions.add('Update All Flagged Users');
        if(thisSetting.Create_FSL_Required_Data__c) refreshActions.add('Create FSL Required Data');
        if(thisSetting.Remove_API_Only_User_From_All_Users__c) refreshActions.add('Remove API Only User From All Users');
        System.enqueueJob(new ACVSandboxRefreshScriptQueueable(context,refreshActions,thisSetting.Slack_Webhook__c,'',refreshActions.size()));
    }
}