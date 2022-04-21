public with sharing class TransferTicketController {

   //*********************************************************************

   // Wrapper class for Jira Board Info
   public class JIRAProject {
        public String name;
        public String key;
        public List<String> issueTypeKeyLst;

        public JIRAProject( String name, String key, List<String> issueTypeKeyLst) {
            this.name = name;
            this.key = key;
            this.issueTypeKeyLst = issueTypeKeyLst;
        }
    }
    //*********************************************************************

    // Wrapper class for Jira Ticket Info
    public class JIRATicketProject {
        public String summary; //title
        public String description;
        public String name; //issuetype
        public List<JIRACommentProject> jiraCommentProjectLst;
        public String jiraAssignee;

        public JIRATicketProject(String summary, String description, String name, List<JIRACommentProject> jiraCommentProjectLst, String jiraAssignee) {
            this.summary = summary;
            this.description = description;
            this.name = name;
            this.jiraCommentProjectLst=jiraCommentProjectLst;
            this.jiraAssignee = jiraAssignee;
        }
    }
    //*********************************************************************

    public class JIRACommentProject {
        public String comment;
        public String author;

        public JIRACommentProject(String comment, String author) {
            this.comment = comment;
            this.author = author;
        }
    }

    //*********************************************************************

    // API Request for Jira Board name, key, and associated issuetypes
    @AuraEnabled(cacheable=true)
    public static String getBoards(){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACVJira/createmeta');
        req.setMethod('GET'); 
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            BoardInfo response = (BoardInfo)System.JSON.deserialize(res.getBody(),BoardInfo.class);
            List<BoardInfo.projects> projectLst = response.projects;

            // Populate JIRA Project Wrapper Object
            List<JIRAProject> jiraProjectLst = new List<JIRAProject>();
            for ( BoardInfo.projects currentProject : projectLst ) {
                List<String> issueTypeLst = new List<String>();
                for ( BoardInfo.IssueTypes issueTypeRec : currentProject.issueTypes ) {
                    issueTypeLst.add( issueTypeRec.name );
                }
                jiraProjectLst.add(
                    new JIRAProject(
                        currentProject.name,
                        currentProject.key,
                        issueTypeLst
                    )
                );
            }
            return JSON.serialize(jiraProjectLst);
        }
        else{
            return 'Jira endpoint not reached';
        }
        
    }
    //*********************************************************************

    //Gets Salesforce ticket field info and chatter comments and creates new Jira ticket
    //API Post Request and updates Jira_Link__c field with link to created Jira ticket
    @AuraEnabled(cacheable=false)
    public static Integer postToBoard(String inputId, String inputOption, String inputIssue){
        Salesforce_Request__c SFInfo = [SELECT 
                                        Name, Additional_Details_Regarding_My_Request__c, Status__c, Assigned_To__c, Owner_Full_Name__c, 
                                        Case__c, Auction__c, Related_Vehicle__c, Related_Account__c, System_Admin_Notes__c, Jira_Link__c
                                        FROM Salesforce_Request__c 
                                        WHERE Id =:inputId];

        List<FeedItem> feedWithComments = [SELECT Body, (SELECT CommentBody FROM FeedComments) FROM FeedItem WHERE ParentId=:inputId];
        String listOfComments = 'Chatter Comments: ';
        if(feedWithComments.size()<1){
            listOfComments = '';
        }
        else{
            for(Integer i=0; i < feedWithComments.size(); i++){
                listOfComments = listOfComments + '\n ' + feedWithComments[i].Body;   
            }
        }

        String backlash = '\n';
        String backlashReplacement = '---n';
        listOfComments = listOfComments.replaceAll(backlash, backlashReplacement);
        listOfComments = listOfComments.stripHtmlTags();
        listOfComments = listOfComments.replaceAll(backlashReplacement, backlash);
        
        //Related Records
        String caseLink = '';
        String auctionLink = '';
        String relatedVehicleLink = '';
        String relatedAccountLink = '';
        String relatedRecords = 'Related Records: \n ';
        String currentBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();

        if(SFInfo.Case__c != null){
            caseLink = 'Case: \n ' + currentBaseURL + '/lightning/r/Case/' + SFInfo.Case__c + '/view \n ';
            relatedRecords += caseLink;
        }
        if(SFInfo.Auction__c != null){
            auctionLink = 'Auction: \n ' + currentBaseURL + '/lightning/r/Auction__c/' + SFInfo.Auction__c + '/view \n ';
            relatedRecords += auctionLink;
        }
        if(SFInfo.Related_Vehicle__c != null){
            relatedVehicleLink = 'Vehicle: \n ' + currentBaseURL + '/lightning/r/Vehicle__c/' + SFInfo.Related_Vehicle__c + '/view \n ';
            relatedRecords += relatedVehicleLink;
        }
        if(SFInfo.Related_Account__c != null){
            relatedAccountLink = 'Account: \n ' + currentBaseURL + '/lightning/r/Account/' + SFInfo.Related_Account__c + '/view \n ';
            relatedRecords += relatedAccountLink;
        }
        if(SFInfo.Case__c == null && SFInfo.Auction__c == null && SFInfo.Related_Vehicle__c == null && SFInfo.Related_Account__c == null){relatedRecords = '';}
        
        String sfUrl = 'Salesforce Link: \n ' + currentBaseURL + '/lightning/r/Salesforce_Request__c/' + inputId + '/view';
        String sfOwner = SFInfo.Owner_Full_Name__c;
        String adminNotes = '';
        adminNotes = adminNotes.stripHtmlTags();
        String salesforceDescription = SFInfo.Additional_Details_Regarding_My_Request__c;
        salesforceDescription = salesforceDescription.stripHtmlTags();
        if(SFInfo.System_Admin_Notes__c!= null){adminNotes = 'Admin Notes: ' + SFInfo.System_Admin_Notes__c;}
        String fullDescription = sfOwner + ' submit on Salesforce: \n \n' +  salesforceDescription + '\n \n ' + adminNotes + '\n \n ' + listOfComments + '\n \n ' + relatedRecords + '\n \n ' + sfUrl;
        JiraTicket newJiraTicket = new JiraTicket();
        newJiraTicket.Fields = new JiraTicket.Fields();
        newJiraTicket.Fields.Project = new JiraTicket.Project();
        newJiraTicket.Fields.Issuetype = new JiraTicket.Issuetype();

        //Assign fields
        newJiraTicket.Fields.Project.key = inputOption; 
        newJiraTicket.Fields.summary = SFInfo.Name; //Title
        newJiraTicket.Fields.description = fullDescription; //Description
        newJiraTicket.Fields.Issuetype.name = inputIssue;
        
        //Post:
        String jsonForJira = JiraTicket.compose(newJiraTicket);        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACVJira');
        req.setMethod('POST');       
        req.setHeader('Content-Type', 'application/json');       
        Http http = new Http();
        req.setBody(jsonForJira);
        HTTPResponse res = http.send(req);
        JiraPostResponse postResponse = (JiraPostResponse)System.JSON.deserialize(res.getBody(),JiraPostResponse.class);
        String postURL = 'https://acvauctions.atlassian.net/browse/' + postResponse.key;
        SFInfo.Jira_Link__c = postUrl;
        if(res.getStatusCode()==200 || res.getStatusCode()==201){
            update SFInfo;
        }
        return res.getStatusCode();
    }
    //*********************************************************************

    //Grabs Status, Assignee, Comments from Jira for automatic update in Salesforce. Summary and Description is also grabbed for import button to updated fields when clicked.
    @AuraEnabled(cacheable=false)
    public static String getStatus(String inputId, String inputKey){
        Salesforce_Request__c NSFInfo = [SELECT 
                                        Name, Additional_Details_Regarding_My_Request__c, Status__c, Assigned_To__c, Owner_Full_Name__c, 
                                        Case__c, Auction__c, Related_Vehicle__c, Related_Account__c, System_Admin_Notes__c, Jira_Link__c, Jira_Status__c
                                        FROM Salesforce_Request__c 
                                        WHERE Id =:inputId];

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACVJira/' + inputKey);
        req.setMethod('GET');       
        Http http = new Http();
        HTTPResponse res = http.send(req);
        JiraUpdate ticketResponse = (JiraUpdate)System.JSON.deserialize(res.getBody(),JiraUpdate.class);
        String ticketStatus = ticketResponse.fields.status.statusCategory.name; 
        String jiraAssignee = '';

        if(ticketResponse.fields.assignee==null){
            jiraAssignee = 'Unassigned';
        }
        else{
            jiraAssignee = ticketResponse.fields.assignee.displayName;
        }
        List<JIRATicketProject> jiraTicketProjectLst = new List<JIRATicketProject>();
        List<JiraUpdate.Comments> commentLst = ticketResponse.fields.comment.comments;
        List<JIRACommentProject> jiraCommentProjectLst = new List<JIRACommentProject>();
        for(JiraUpdate.Comments currentComment : commentLst){
            jiraCommentProjectLst.add(
                    new JIRACommentProject(
                        currentComment.body,
                        currentComment.author.displayName
                    )
                );
        }

        jiraTicketProjectLst.add(
            new JIRATicketProject(
                ticketResponse.fields.summary,
                ticketResponse.fields.description,
                ticketResponse.fields.status.statusCategory.name,
                jiraCommentProjectLst,
                jiraAssignee
            )
        );
        NSFInfo.Jira_Status__c = ticketStatus;
        if(res.getStatusCode()==200 || res.getStatusCode()==201){
        update NSFInfo;
        }
        return JSON.serialize(jiraTicketProjectLst);        
    }
    //*********************************************************************

    //API Post request for comment from Salesforce to Jira ticket
    @AuraEnabled(cacheable=false)
    public static String postComment(String inputKey, String commentText){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ACVJira/' + inputKey + '/comment');
        req.setMethod('POST');       
        req.setHeader('Content-Type', 'application/json');
        JiraComment newJiraComment = new JiraComment();
        newJiraComment.body = commentText;
        String jsonCommentForJira = JiraComment.compose(newJiraComment);       
        Http http = new Http();
        req.setBody(jsonCommentForJira);
        HTTPResponse res = http.send(req);
        String failPost = 'Failed to post comment';
        String successPost = 'Comment Posted';
        if(res.getStatusCode()==404){
            return failPost;
        }
        else{return successPost;}
    }

}