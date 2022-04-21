/**
 * This class holds the logic to post an alert to the Salesforce Release Slack Chanel
 * It has been moved to the new Trigger Framework and was previously in the ReleaseSurveyTriggerHandler class on the old framework
 * Originally Created by Gerald McEvoy
 * @author James Andre LaCour
 */
public class SlackAlert extends TriggerInterface{
    /****************Context Methods************************/
	public override void afterInsert( Map<Id, SObject> newMap ){
        for ( Release_Survey__c rec : (List<Release_Survey__c>) newMap.values() ) {
            if ( rec.Alert_Salesforce_Slack_Channel__c ) {
                SlackAlert.callout( rec.Id );
            }
        }
	}
    /****************Helper Methods*************************/
    /**
     * On creation of a Release Survey, a callout is made to post
     * information into the Salesforce Release slack channel
     * @param newMap - Map of Id-->Resolution new values
     * @return void
     */
    @future(callout=true)
    public static void callout( Id requestSurveyId ) {

        Release_Survey__c reqSurveyRec = [ SELECT Id, Change_Set_Link__c, Release_Date__c, Owner.Name,
                                            Includes_Code__c, Includes_Lightning_Components__c, Includes_Visualforce__c,
                                            Includes_Process_Builders__c, Includes_Flows__c, Includes_LWC__c,
                                            Includes_Integration_Functionality__c, Is_a_backfill_required__c,
                                            Brief_Functionality_Description__c, backfilled_object__c, Schema_Changes__c
                                                FROM Release_Survey__c WHERE Id = :requestSurveyId ];

        final String WEBHOOK = 'https://hooks.slack.com/services/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';
        String body = '{ "text":"There is a new scheduled Salesforce Release!", "blocks":[ { "type": "section", "text": { "type": "mrkdwn", "text": "*There is a new scheduled Salesforce Release!*';
        body += '\n<' + URL.getOrgDomainUrl().toExternalForm() + '/' + reqSurveyRec.Id;
        body += '|Link to Release Survey>';
        
        if  ( reqSurveyRec.Change_Set_Link__c != null ) {
            body += '\nLink to the provided change set for review: <';
            body += reqSurveyRec.Change_Set_Link__c;
            body += '|Link to Change Set>';
        }

        if ( !String.isBlank( reqSurveyRec.Brief_Functionality_Description__c ) ) {
            body += '\n Description: _' + reqSurveyRec.Brief_Functionality_Description__c.replace( '"', '\\"' ) + '_';
        }

        body += '\n Created by: _';
        body += reqSurveyRec.Owner.Name;
        body += '_"';

        body += ' } }, { "type": "divider" }, { "type": "section", "text": { "type": "mrkdwn", "text": ":fonzie: *Do you have any issue with the planned release?*\nThe release is tenatively planned for ';
        
        body += reqSurveyRec.Release_Date__c.month() + '/' + reqSurveyRec.Release_Date__c.day() + '/' + reqSurveyRec.Release_Date__c.year();

        body += '" } }';
        
        if ( reqSurveyRec.Includes_Code__c || reqSurveyRec.Includes_Lightning_Components__c || reqSurveyRec.Includes_Visualforce__c || reqSurveyRec.Includes_Process_Builders__c || reqSurveyRec.Includes_Flows__c || reqSurveyRec.Includes_LWC__c || reqSurveyRec.Includes_Integration_Functionality__c || reqSurveyRec.Is_a_backfill_required__c ) {
            body += ',{ "type":"divider"},';
            body += '{"type": "section", "text": { "type": "mrkdwn", "text":"';
            body += '*The deployment contains some of the following items:*';

            if ( reqSurveyRec.Includes_Code__c ) {
                body += '\n - Code';
            }
            if ( reqSurveyRec.Includes_Lightning_Components__c ) {
                body += '\n - Lightning Components';
            }
            if ( reqSurveyRec.Includes_Visualforce__c ) {
                body += '\n - Visualforce';
            }
            if ( reqSurveyRec.Includes_Process_Builders__c ) {
                body += '\n - Process Builders';
            }
            if ( reqSurveyRec.Includes_Flows__c ) {
                body += '\n - Flows';
            }
            if ( reqSurveyRec.Includes_LWC__c ) {
                body += '\n - Lightning Web Components';
            }
            if ( reqSurveyRec.Includes_Integration_Functionality__c ) {
                body += '\n - Modifications directly to Integrations';
            }
            if ( reqSurveyRec.Is_a_backfill_required__c ) {
                body += '\n - A backfill requirement is indicated on the following object(s): ';
                body += reqSurveyRec.backfilled_object__c;
            }
            if(!String.isBlank(reqSurveyRec.Schema_Changes__c) && reqSurveyRec.Schema_Changes__c != 'No'){
                body += '\n - Schema Changes - NOTIFY ANALYTICS: ';
                body += reqSurveyRec.Schema_Changes__c;
            }
 
            body += '"}}';
        }

        body += '] }';      

        HTTPRequest request = new HTTPRequest();
        request.setMethod( 'POST' );
        request.setEndpoint( WEBHOOK ); 
        request.setBody( BODY );
        request.setHeader( 'Content-Type', 'application/json' );

        // It doesn't matter if it failed or not, as there is no action to take on a failure
        new HTTP().send( request );
    }
}