@IsTest
public class SlackAlertTest {
    
    @IsTest
    static void callAPI() {
        Test.setMock( HTTPCalloutMock.class, new SlackAPIMock() );

        Release_Survey__c requestRec = new Release_Survey__c(
            Release_Date__c = Date.today().addDays(1),
            Team__c = 'Enterprise Applications Core Team',
            Lines_Of_Code__c = '101 - 250',
            Number_Of_Components__c = '2 - 10',
            Brief_Functionality_Description__c = 'This is the best functionality we have ever added to the system, ever.',
            Functionality_Age__c = 'New & Existing',
            Includes_Code__c = TRUE,
            Includes_Process_Builders__c = TRUE,
            Includes_Visualforce__c = TRUE,
            Includes_Lightning_Components__c = TRUE,
            Includes_LWC__c = TRUE,
            Includes_Flows__c = TRUE,
            Is_a_backfill_required__c = TRUE,
            Includes_Integration_Functionality__c = TRUE,
            Change_set_Link__c = 'https://google.com/',
            Training__c = 'Training not required',
            Alert_Salesforce_Slack_Channel__c = TRUE,
            Schema_Changes__c = 'New Field',
            Atlassian_link__c = 'some link'
        );

        Test.startTest();
            insert new List<Release_Survey__c>{ requestRec };
        Test.stopTest();
    }

    public class SlackAPIMock implements HTTPCalloutMock {
        public HTTPResponse respond( HttpRequest req ) {
            HTTPResponse res = new HttpResponse();
            res.setHeader( 'Content-Type', 'application-json' );
            res.setBody( '{ success }' );
            res.setStatusCode( 200 );

            return res;
        }
    }
}