public class CloseSupportCase {

    public class MyException extends Exception {} 
    
    @AuraEnabled
    public static List<Customer_Inquiry__c> getOpenChildInquiries(Id recordId){
        return [SELECT Id, Call_Type__c, Call_Bucket__c, Vin_Last_6__c, Status__c FROM Customer_Inquiry__c WHERE Support_Case__c = :recordId AND Status__c != 'Closed'];
    }

    @AuraEnabled
    public static void closeChildInquiries(List<Customer_Inquiry__c> openInquiries){
        for (Customer_Inquiry__c ci : openInquiries) {
            ci.Status__c = 'Closed';
        }
        try {
            update openInquiries;
        } 
        catch (DmlException e) {
            throw new MyException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            throw new MyException(e.getMessage());
        }
    }
}