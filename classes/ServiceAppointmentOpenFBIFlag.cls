public class ServiceAppointmentOpenFBIFlag extends TriggerInterface {

    public override void beforeInsert(List<sObject> newList) {

        List<ServiceAppointment> newsaList = (List<ServiceAppointment>)newList;

        // Loop through New Service Appointment values.  Need to check field values in order to set the FSL__InJeopardy__c flag.
        for (ServiceAppointment saLoop : newsaList) {

            if ( saLoop.Work_Type_Name__c == 'FBI' && saLoop.Status == 'New' ) {
                
                saLoop.FSL__InJeopardy__c = true;
            
            }
        }
    }


    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {

        List<ServiceAppointment> newsaList = (List<ServiceAppointment>)newMap.values();

        for (ServiceAppointment saLoop : newsaList) {

            ServiceAppointment oldsa = (ServiceAppointment) oldMap.get(saLoop.Id);

            if ( saLoop.Work_Type_Name__c == 'FBI' && oldsa.Status != saLoop.Status && saLoop.Status == 'New' ) {
                
                saLoop.FSL__InJeopardy__c = true;
            
            } else if ( saLoop.Work_Type_Name__c == 'FBI' && oldsa.Status != saLoop.Status && saLoop.Status != 'New' ) {

                saLoop.FSL__InJeopardy__c = false;
            }
        }
    }
}