public class HaltTrue360Appointments extends TriggerInterface {

    private final String[] statusList = new String[]{'New','Scheduled','Dispatched','Cannot Complete'};

    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Account> newAccountList = (List<Account>)newList;
        List<Account> oldAccountList = (List<Account>)oldList;
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccountList);
        Map<Id, Account> acctsToCancelTrue360Appts = new Map<Id, Account>();
        Map<Id, Account> acctsTrue360PermissionChanged = new Map<Id, Account>();

        for (Account a : newAccountList) {
            Account oldAcct = oldAccountMap.get(a.Id);

            if (a.Halt_True360_Appointments__c != oldAcct.Halt_True360_Appointments__c) {
                acctsTrue360PermissionChanged.put(a.Id, a);
                if(a.Halt_True360_Appointments__c) {
                    acctsToCancelTrue360Appts.put(a.Id, a);
                }
            }
        }

        if(!acctsTrue360PermissionChanged.isEmpty()) {
            changeTrue360Appts(acctsTrue360PermissionChanged, acctsToCancelTrue360Appts);
        }
    }

    public void changeTrue360Appts(Map<Id, Account> acctsTrue360PermissionChanged, Map<Id, Account> acctsToCancelTrue360Appts) {
        List<Timeline__c> revolvingApptsToUpdate = new List<Timeline__c>();
        List<Occurrence__c> occsToUpdate = new List<Occurrence__c>();
        List<Timeline__c> revolvingAppointmentList = [SELECT Id, Name, Account__c, Is_Active__c, Work_Type__c, Work_Type__r.Work_Type_Unique_ID__c, Deactivated_by_Halt_True360_Checkbox__c,
                                                (SELECT Id, Is_Active__c FROM Occurrences__r ORDER BY CreatedDate DESC LIMIT 1) FROM Timeline__c 
                                                WHERE Account__c IN :acctsTrue360PermissionChanged.keySet() AND Work_Type__r.Work_Type_Unique_ID__c = 'true360'];

        for(Timeline__c ra : revolvingAppointmentList) {
            Boolean true360Halted = acctsTrue360PermissionChanged.get(ra.Account__c).Halt_True360_Appointments__c;
            if(true360Halted && ra.Is_Active__c) {
                ra.Is_Active__c = false;
                ra.Deactivated_by_Halt_True360_Checkbox__c = true;
                revolvingApptsToUpdate.add(ra);
            }
            else if(!true360Halted && !ra.Is_Active__c && ra.Deactivated_by_Halt_True360_Checkbox__c) {
                ra.Is_Active__c = true;
                ra.Deactivated_by_Halt_True360_Checkbox__c = false;
                revolvingApptsToUpdate.add(ra);
                if(ra.Occurrences__r.size() == 1) {
                    Occurrence__c occ = ra.Occurrences__r[0];
                    occ.Is_Active__c = true;
                    occsToUpdate.add(occ);
                }
            }
        }
        
        if(!revolvingApptsToUpdate.isEmpty()) {
            update revolvingApptsToUpdate;
        }

        if(!occsToUpdate.isEmpty()) {
            update occsToUpdate;
        }

        List<ServiceAppointment> serviceAppointmentList = [SELECT Id, Work_Type_Unique_ID__c, Status, AccountId FROM ServiceAppointment 
                                                WHERE AccountId IN :acctsToCancelTrue360Appts.keySet() AND Status IN :statusList AND Work_Type_Unique_ID__c = 'true360' AND DueDate >= :System.today()];
        for(ServiceAppointment sa : serviceAppointmentList) {
            sa.Status = 'Canceled';
        }

        update serviceAppointmentList;
    }

    @AuraEnabled(Cacheable=true)
    public static String getTrue360Id() {
        WorkType true360 = [SELECT Id, Name FROM WorkType WHERE Work_Type_Unique_ID__c='true360' LIMIT 1];
        if(true360 != null) {
            return true360.Id;
        }
        else {
            return null;
        }
    }

}