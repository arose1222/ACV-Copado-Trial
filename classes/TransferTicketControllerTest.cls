@isTest
public class TransferTicketControllerTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //Case__c, Auction__c, Related_Vehicle__c, Related_Account__c, Jira_Link__c
        Vehicle__c vech = TestUtility.createVehicle();
        insert vech;
        Account acct = TestUtility.createAccount();
        insert acct;
        Contact con = TestUtility.createContact( acct );
        insert con;
        Auction__c auct = TestUtility.createAuction( acct, con, vech );
        insert auct;
        Case titleCase = TestUtility.createTitleCase( auct, acct, con );
        titleCase.ACV_Titles_External_ID__c = '123456789';
        insert titleCase;

        System.debug(Schema.SObjectType.Salesforce_Request__c.getRecordTypeInfosByName().get('Salesforce Request').getRecordTypeId());
        String recType = '0120a0000010QGsAAM';
        Salesforce_Request__c SFticket = new Salesforce_Request__c( Name = 'NameemaN', 
                                                                    Additional_Details_Regarding_My_Request__c = 'addDetails', 
                                                                    System_Admin_Notes__c = 'sysadnotes',
                                                                    My_Request_Is_Related_To__c = 'Error message or bug',
                                                                    RecordTypeId = recType,
                                                                    Case__c = titleCase.Id,
                                                                    Auction__c = auct.Id,
                                                                    Related_Vehicle__c = vech.Id,
                                                                    Related_Account__c = acct.Id
                                                                    );
        insert SFticket;
        
    }
    //********************************************************************************

    //Good Call for getBoards 
    @isTest
    static void testGettingBoardData() {
        System.debug('testGettingBoardData');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutGoodCall());
        String actualValue = TransferTicketController.getBoards();
        String expectedValue = '[{"name":"A Vue to a Kill (Angular)","key":"VUE","issueTypeKeyLst":["Story","Epic","Task","Bug","Subtask","Incident"]},{"name":"Abandoned Vehicles Solution","key":"AVS","issueTypeKeyLst":["Task","Sub-task","Story","Bug","Epic"]}]';
        Test.stopTest();
        System.assertEquals(actualValue, expectedValue);
        
    }

    //Bad Call for getBoards
    @isTest 
    static void testNotGettingBoardData(){
        System.debug('testNotGettingBoardData');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutBadCall());
        String actualValue = TransferTicketController.getBoards();
        String expectedValue = 'Jira endpoint not reached';
        Test.stopTest();
        System.assertEquals(actualValue, expectedValue);
    }

    //Test for postToBoards
    @isTest 
    static void testPostToBoard(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutGoodPost());
        String recordId = [SELECT Id FROM Salesforce_Request__c LIMIT 1].Id;
        String selectedOption = 'TB';
        String selectedIssue = 'Bug';
        Test.startTest();  
        TransferTicketController.postToBoard(recordId, selectedOption, selectedIssue);
        String popJiraLink = [SELECT Jira_Link__c FROM Salesforce_Request__c LIMIT 1].Jira_Link__c;
        String expectedLink = 'https://acvauctions.atlassian.net/browse/TB-33';
        Test.stopTest();
        System.assertEquals(popJiraLink, expectedLink);         
    }

    @isTest 
    static void testBadKeyPostToBoard(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutBadKeyPost());
        Integer expected = 400;
        String recordId = [SELECT Id FROM Salesforce_Request__c LIMIT 1].Id;
        String selectedOption = 'BADKEY';
        String selectedIssue = 'Bug';
        Test.startTest();
        Integer response = TransferTicketController.postToBoard(recordId, selectedOption, selectedIssue);
        System.assertEquals(expected, response);
        Test.stopTest();
    }

    @isTest 
    static void testBadIssuetypePostToBoard(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutBadIssuePost());
        Integer expected = 400;
        String recordId = [SELECT Id FROM Salesforce_Request__c LIMIT 1].Id;
        String selectedOption = 'TB';
        String selectedIssue = 'BADISSUE';
        Test.startTest();
        Integer response = TransferTicketController.postToBoard(recordId, selectedOption, selectedIssue);
        System.assertEquals(expected, response);
        Test.stopTest();
    }

    //Test for getStatus
    @isTest 
    static void testGetStatus(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutGoodTicketCall());
        Salesforce_Request__c ticketInfo = [SELECT Id, Jira_Status__c FROM Salesforce_Request__c LIMIT 1];
        String recordId = ticketInfo.Id;
        String selectedKey = 'TB-31';
        System.assertEquals(null, ticketInfo.Jira_Status__c);
        Test.startTest();
        String response = TransferTicketController.getStatus(recordId, selectedKey);
        Test.stopTest();
        String actualStatus = [SELECT Jira_Status__c FROM Salesforce_Request__c LIMIT 1].Jira_Status__c;
        String expectedStatus = 'To Do';
        System.assertEquals(expectedStatus, actualStatus);
    }

    //Good test for postComment
    @isTest 
    static void testGoodPostComment(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutGoodPostComment());
        String selectedKey = 'TB-30';
        String enteredText = 'This is a comment regarding the quality of the response.';
        Test.startTest();
        String response = TransferTicketController.postComment(selectedKey, enteredText);
        System.debug(response);
        String expectedResponse = 'Comment Posted';
        System.assertEquals(expectedResponse, response);
        Test.stopTest();
    }
    //Bad test for postComment
    @isTest 
    static void testBadPostComment(){
        Test.setMock(HttpCalloutMock.class, new TransferTicketMockCalloutBadPostComment());
        String selectedKey = 'BadKey';
        String enteredText = 'This is a comment regarding the quality of the response.';
        Test.startTest();
        String response = TransferTicketController.postComment(selectedKey, enteredText);
        System.debug(response);
        String expectedResponse = 'Failed to post comment';
        System.assertEquals(expectedResponse, response);
        Test.stopTest();
    }

    //********************************************************************************


    private class TransferTicketMockCalloutGoodCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processGoodResponse( req );
        }
    }

    private class TransferTicketMockCalloutBadCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processBadResponse( req );
        }
    }

    private class TransferTicketMockCalloutGoodPost implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processGoodNewTicketResponse( req );
        }
    }

    private class TransferTicketMockCalloutBadKeyPost implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processBadKeyNewTicketResponse( req );
        }
    }

    private class TransferTicketMockCalloutBadIssuePost implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processBadIssueNewTicketResponse( req );
        }
    }

    private class TransferTicketMockCalloutGoodTicketCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processGoodTicketStatusResponse( req );
        }
    }

    private class TransferTicketMockCalloutGoodPostComment implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processGoodTicketCommentResponse( req );
        }
    }

    private class TransferTicketMockCalloutBadPostComment implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TransferTicketControllerTest.processBadTicketCommentResponse( req );
        }
    }
    //********************************************************************************

    public static HTTPResponse processGoodResponse( HTTPRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"expand":"projects","projects":[{"self":"https://acvauctions.atlassian.net/rest/api/2/project/13250","id":"13250","key":"VUE","name":"A Vue to a Kill (Angular)","avatarUrls":{"48x48":"https://acvauctions.atlassian.net/secure/projectavatar?pid=13250&avatarId=13440","24x24":"https://acvauctions.atlassian.net/secure/projectavatar?size=small&s=small&pid=13250&avatarId=13440","16x16":"https://acvauctions.atlassian.net/secure/projectavatar?size=xsmall&s=xsmall&pid=13250&avatarId=13440","32x32":"https://acvauctions.atlassian.net/secure/projectavatar?size=medium&s=medium&pid=13250&avatarId=13440"},"issuetypes":[{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10518","id":"10518","description":"Stories track functionality or features expressed as user goals.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10315&avatarType=issuetype","name":"Story","subtask":false,"scope":{"type":"PROJECT","project":{"id":"13250"}}},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10519","id":"10519","description":"Track large pieces of work.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10307&avatarType=issuetype","name":"Epic","subtask":false,"scope":{"type":"PROJECT","project":{"id":"13250"}}},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10521","id":"10521","description":"Tasks track small, distinct pieces of work.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10318&avatarType=issuetype","name":"Task","subtask":false,"scope":{"type":"PROJECT","project":{"id":"13250"}}},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10583","id":"10583","description":"Bugs track problems or errors.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10303&avatarType=issuetype","name":"Bug","subtask":false,"scope":{"type":"PROJECT","project":{"id":"13250"}}},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10587","id":"10587","description":"Subtasks track small pieces of work.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10316&avatarType=issuetype","name":"Subtask","subtask":true,"scope":{"type":"PROJECT","project":{"id":"13250"}}},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10614","id":"10614","description":"","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10304&avatarType=issuetype","name":"Incident","subtask":false,"scope":{"type":"PROJECT","project":{"id":"13250"}}}]},{"self":"https://acvauctions.atlassian.net/rest/api/2/project/13218","id":"13218","key":"AVS","name":"Abandoned Vehicles Solution","avatarUrls":{"48x48":"https://acvauctions.atlassian.net/secure/projectavatar?avatarId=10703","24x24":"https://acvauctions.atlassian.net/secure/projectavatar?size=small&s=small&avatarId=10703","16x16":"https://acvauctions.atlassian.net/secure/projectavatar?size=xsmall&s=xsmall&avatarId=10703","32x32":"https://acvauctions.atlassian.net/secure/projectavatar?size=medium&s=medium&avatarId=10703"},"issuetypes":[{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/3","id":"3","description":"A task that needs to be done.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10318&avatarType=issuetype","name":"Task","subtask":false},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/5","id":"5","description":"The sub-task of the issue","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10316&avatarType=issuetype","name":"Sub-task","subtask":true},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10001","id":"10001","description":"gh.issue.story.desc","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10315&avatarType=issuetype","name":"Story","subtask":false},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/1","id":"1","description":"A problem which impairs or prevents the functions of the product.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10303&avatarType=issuetype","name":"Bug","subtask":false},{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10000","id":"10000","description":"gh.issue.epic.desc","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10307&avatarType=issuetype","name":"Epic","subtask":false}]}]}');
        res.setStatusCode(201);
        return res;
    }

    public static HTTPResponse processBadResponse( HTTPRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"errorMessages":["Issue does not exist or you do not have permission to see it."],"errors":{}}');
        res.setStatusCode(404);
        return res;
    }

    public static HTTPResponse processGoodNewTicketResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"id":"53226","key":"TB-33","self":"https://acvauctions.atlassian.net/rest/api/latest/issue/53226"}');
        res.setStatusCode(201);
        return res;
    }

    public static HTTPResponse processBadKeyNewTicketResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"errorMessages":[],"errors":{"project":"project is required"}}');
        res.setStatusCode(400);
        return res;
    }

    public static HTTPResponse processBadIssueNewTicketResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"errorMessages":[],"errors":{"issuetype":"issue type is required"}}');
        res.setStatusCode(400);
        return res;
    }

    public static HTTPResponse processGoodTicketStatusResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"expand":"renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations","id":"52834","self":"https://acvauctions.atlassian.net/rest/api/latest/issue/52834","key":"TB-31","fields":{"statuscategorychangedate":"2019-10-18T14:11:27.976-0400","fixVersions":[],"customfield_11200":null,"resolution":null,"customfield_11720":null,"customfield_10500":null,"customfield_11719":null,"lastViewed":null,"priority":{"self":"https://acvauctions.atlassian.net/rest/api/2/priority/3","iconUrl":"https://acvauctions.atlassian.net/images/icons/priorities/medium.svg","name":"Medium","id":"3"},"labels":[],"customfield_11700":null,"customfield_11702":null,"customfield_11701":null,"timeestimate":null,"aggregatetimeoriginalestimate":null,"customfield_11704":null,"versions":[],"customfield_11703":null,"customfield_11705":null,"issuelinks":[],"assignee":null,"status":{"self":"https://acvauctions.atlassian.net/rest/api/2/status/11724","description":"","iconUrl":"https://acvauctions.atlassian.net/","name":"To Do","id":"11724","statusCategory":{"self":"https://acvauctions.atlassian.net/rest/api/2/statuscategory/2","id":2,"key":"new","colorName":"blue-gray","name":"To Do"}},"components":[],"customfield_11421":null,"customfield_11300":null,"customfield_11420":null,"customfield_11423":null,"customfield_11422":null,"customfield_11414":null,"customfield_11413":null,"customfield_10600":{"hasEpicLinkFieldDependency":false,"showField":false,"nonEditableReason":{"reason":"EPIC_LINK_SHOULD_BE_USED","message":"To set an epic as the parent, use the epic link instead"}},"customfield_11416":null,"customfield_11415":null,"aggregatetimeestimate":null,"customfield_11418":null,"customfield_11417":null,"customfield_11419":null,"creator":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5c82eb8903a1f86544381adc","name":"integration","key":"integration","accountId":"5c82eb8903a1f86544381adc","emailAddress":"integration@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=32&s=32"},"displayName":"Salesforce Integration","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"subtasks":[],"reporter":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5c82eb8903a1f86544381adc","name":"integration","key":"integration","accountId":"5c82eb8903a1f86544381adc","emailAddress":"integration@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=32&s=32"},"displayName":"Salesforce Integration","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"aggregateprogress":{"progress":0,"total":0},"customfield_11410":null,"customfield_11412":null,"customfield_11411":null,"customfield_11403":null,"customfield_11402":null,"customfield_11405":null,"customfield_11404":null,"customfield_11407":null,"customfield_11406":null,"customfield_11409":null,"customfield_11408":null,"progress":{"progress":0,"total":0},"votes":{"self":"https://acvauctions.atlassian.net/rest/api/2/issue/TB-31/votes","votes":0,"hasVoted":false},"worklog":{"startAt":0,"maxResults":20,"total":0,"worklogs":[]},"issuetype":{"self":"https://acvauctions.atlassian.net/rest/api/2/issuetype/10566","id":"10566","description":"A task that needs to be done.","iconUrl":"https://acvauctions.atlassian.net/secure/viewavatar?size=medium&avatarId=10318&avatarType=issuetype","name":"Task","subtask":false,"avatarId":10318,"entityId":"4cb100a3-af6e-4d42-a36e-4aa02f46d35d"},"timespent":null,"project":{"self":"https://acvauctions.atlassian.net/rest/api/2/project/13271","id":"13271","key":"TB","name":"test_board","projectTypeKey":"software","simplified":true,"avatarUrls":{"48x48":"https://acvauctions.atlassian.net/secure/projectavatar?avatarId=10703","24x24":"https://acvauctions.atlassian.net/secure/projectavatar?size=small&s=small&avatarId=10703","16x16":"https://acvauctions.atlassian.net/secure/projectavatar?size=xsmall&s=xsmall&avatarId=10703","32x32":"https://acvauctions.atlassian.net/secure/projectavatar?size=medium&s=medium&avatarId=10703"}},"aggregatetimespent":null,"customfield_11401":null,"customfield_11400":[],"customfield_10700":"{}","resolutiondate":null,"workratio":-1,"watches":{"self":"https://acvauctions.atlassian.net/rest/api/2/issue/TB-31/watchers","watchCount":2,"isWatching":true},"created":"2019-10-18T14:11:27.728-0400","customfield_11753":null,"customfield_11502":null,"customfield_11501":null,"customfield_11746":null,"customfield_11504":null,"customfield_11745":null,"customfield_11503":null,"customfield_11748":null,"customfield_11747":null,"customfield_11505":null,"customfield_11749":null,"updated":"2019-11-04T11:36:49.556-0500","timeoriginalestimate":null,"description":"<p>Additional made up details regarding my request.</p>\\n \\n Admin Notes: null\\n \\n Chatter Comments: \\n <p>A second comment</p>\\n <p>@Gavin DiMaria​ fake update #1</p>\\n \\n Related Records: \\n Case: https://acvauctions--dimariadev.lightning.force.com/lightning/r/Case/5005C0000044VQOQA2/view\\n Auction: https://acvauctions--dimariadev.lightning.force.com/lightning/r/Auction__c/a0d5C000000KUsKQAW/view\\n Vehicle: https://acvauctions--dimariadev.lightning.force.com/lightning/r/Account/0015C00000QRWAjQAP/view\\n Account: https://acvauctions--dimariadev.lightning.force.com/lightning/r/Account/0015C00000QRWAjQAP/view\\n ","customfield_11100":null,"customfield_11500":null,"customfield_10014":"2|hzzybz:","timetracking":{},"customfield_10005":null,"customfield_10007":null,"security":null,"customfield_10008":null,"customfield_10800":null,"attachment":[],"summary":"Something For Jira","customfield_10000":"2019-11-04T11:36:49.556-0500","customfield_10001":null,"customfield_10003":null,"customfield_10400":null,"customfield_10004":null,"customfield_11722":null,"customfield_11721":null,"customfield_11600":null,"environment":null,"customfield_11723":null,"duedate":null,"comment":{"comments":[{"self":"https://acvauctions.atlassian.net/rest/api/2/issue/52834/comment/54897","id":"54897","author":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5d5dac4c5b488e0cfff9887b","name":"gdimaria","key":"gdimaria","accountId":"5d5dac4c5b488e0cfff9887b","emailAddress":"gdimaria@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=32&s=32"},"displayName":"Gavin DiMaria","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"body":"Commenttt","updateAuthor":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5d5dac4c5b488e0cfff9887b","name":"gdimaria","key":"gdimaria","accountId":"5d5dac4c5b488e0cfff9887b","emailAddress":"gdimaria@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6d7bedec73c35345bf85d72ae11e16bb?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FGD-1.png&size=32&s=32"},"displayName":"Gavin DiMaria","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"created":"2019-11-04T11:36:49.556-0500","updated":"2019-11-04T11:36:49.556-0500","jsdPublic":true}],"maxResults":1,"total":1,"startAt":0}}}');
        res.setStatusCode(200);
        return res;
    }

    public static HTTPResponse processGoodTicketCommentResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"self":"https://acvauctions.atlassian.net/rest/api/2/issue/52830/comment/54929","id":"54929","author":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5c82eb8903a1f86544381adc","name":"integration","key":"integration","accountId":"5c82eb8903a1f86544381adc","emailAddress":"integration@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=32&s=32"},"displayName":"Salesforce Integration","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"body":"This is a comment regarding the quality of the response.","updateAuthor":{"self":"https://acvauctions.atlassian.net/rest/api/2/user?accountId=5c82eb8903a1f86544381adc","name":"integration","key":"integration","accountId":"5c82eb8903a1f86544381adc","emailAddress":"integration@acvauctions.com","avatarUrls":{"48x48":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=48&s=48","24x24":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=24&s=24","16x16":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=16&s=16","32x32":"https://secure.gravatar.com/avatar/6ee72a8a9f7da40412de070a2653eba2?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FSI-3.png&size=32&s=32"},"displayName":"Salesforce Integration","active":true,"timeZone":"America/New_York","accountType":"atlassian"},"created":"2019-11-05T11:12:58.840-0500","updated":"2019-11-05T11:12:58.840-0500","jsdPublic":true}');
        res.setStatusCode(201);
        return res;
    }  

    public static HTTPResponse processBadTicketCommentResponse( HttpRequest req ) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"errorMessages":["Issue does not exist or you do not have permission to see it."],"errors":{}}');
        res.setStatusCode(404);
        return res;
    }   

}