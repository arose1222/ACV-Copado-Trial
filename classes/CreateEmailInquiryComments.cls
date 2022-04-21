public class CreateEmailInquiryComments extends TriggerInterface {

    public override void afterUpdate( List<SObject> oldList,List<SObject> newList ){
        createComments((List<EmailMessage>)newList);      
    }
    
    public static void createComments(List<EmailMessage> emailList){
        Map<id,EmailMessage> msgMap = new Map<id,EmailMessage>();
        List<Inquiry_Comment__c> icList = new List<Inquiry_Comment__c>();
        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();

        if(emailList.size()>0){
            for(EmailMessage e:emailList){
                // Status of 3 = a sent email
                if(e.ParentId != null && e.Status == '3'){
                    msgMap.put(e.ParentId,e);
                }
            }
        }
        // Query for customer inquiries that are related to titles ops case and the email
        if(msgmap.size()>0){
            ciList = [SELECT Id, Ops_Case__c FROM Customer_Inquiry__c WHERE Ops_Case__c IN :msgMap.keySet() AND Ops_Case__r.RecordType.DeveloperName = 'Title_Information' AND Status__c != 'Closed']; 
        }
        if(ciList.size()>0){
            for(Customer_Inquiry__c ci:ciList){
                Inquiry_Comment__c ic = new Inquiry_Comment__c();
                // trim the textBody string so that it only shows the current email and not past messages
                if ((msgMap.get(ci.Ops_Case__c).TextBody).contains('- Original Message -')) {
                    List<String> msg = (msgMap.get(ci.Ops_Case__c).TextBody).split('--------------- Original Message ---------------');
                    ic.Inquiry_Notes__c = msg[0];  
                }
                else {
                    ic.Inquiry_Notes__c = msgMap.get(ci.Ops_Case__c).TextBody; 
                }

                ic.Ops_Case__c = ci.Ops_Case__c;
                ic.Customer_Inquiry__c = ci.id;
                ic.Feed_Task_Created__c = true;
                icList.add(ic);
            }
        }
        insert icList;
    }
}