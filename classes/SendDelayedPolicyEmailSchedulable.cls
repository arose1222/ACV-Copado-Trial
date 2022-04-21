/**
 * Schedulable class to send policy email upon custom lead conversion with a delay.
 * @author Jyothsna P
 * @since 09/24/21
 */
public class SendDelayedPolicyEmailSchedulable extends SchedulingInterface {

    private final Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    public SendDelayedPolicyEmailSchedulable(){
    }

    public override void executeScheduledLogic(){

        // Select contacts converted from org leads with 'Policy Email Sent' equal to 'false' 
        List<Contact> cList = [ SELECT Id, IST_Account_Manager_Email__c FROM Contact WHERE Lead_Convert_Status__c != '' 
                                and Lead_Created_Contact__c= true and RecordTypeid=:acvuserRecordTypeId and Policy_Email_Status__c='Policy Email Not Sent'];

        // update "Send Policy Email" to true. This is used in 'Organization Lead Converted Policy Email With Delay' work flow rule.                       
        for( Contact c : cList){  
            c.Policy_Email_Status__c= 'Send Policy Email';
        }

        update cList;
    }

}