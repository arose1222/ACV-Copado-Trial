public class RevolvingCleaner {

    public final static Set<String> REMOVE_STATUS_CATEGORY_SET {
        get {
            if ( REMOVE_STATUS_CATEGORY_SET == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Revolving Appt - Clean Status Category' LIMIT 1 ];
                REMOVE_STATUS_CATEGORY_SET = new Set<String>( setting.Value__c.split( ';' ) );
            }
            return REMOVE_STATUS_CATEGORY_SET;
        }
        set;
    }

    public static List<String> removeInactiveRecords(List<Occurrence__c> occurrenceList){

        List<Occurrence__c> occurrencesToDelete = new List<Occurrence__c>();
        List<String> returnDebug = new List<String>();

        for(Occurrence__c occ : occurrenceList){
            if(occ.Timeline__c == null || occ.Is_Active__c == false){
                occurrencesToDelete.add(occ);
            }
        }
        //remove all inactive Occurrences or orphaned Occurrences

        List<String> occErrors = RevolvingUtility.processDeleteResults(Database.delete(occurrencesToDelete, false));
        returnDebug.add((occurrencesToDelete.size() - occErrors.size()) + ' Occurrences successfully deleted');
        returnDebug.addAll(occErrors);
        return returnDebug;
    }


    public static List<String> deleteChangedRecords(List<Occurrence__c> occurrenceList) {
        List<String> returnDebug = new List<String>();


        //all the occurrences that have been modified, including all active and inactive ones
        Set<Occurrence__c> occSet = new Set<Occurrence__c>(occurrenceList);
        for(Occurrence__c occ : occSet){
            if(occ == null){
                throw new CustomException('Null value for Occurrence in cleanup class. Batch has failed');
            }
        }

        //Query for all Work-Order generated for this Occurrence and delete all the ones after this day.
        List<WorkOrder> wos = [
                SELECT Id
                FROM WorkOrder
                WHERE Occurrence__c IN :occSet
                //AND StartDate >= TODAY]; - Removed due to wanting to delete past records
                AND StatusCategory IN :REMOVE_STATUS_CATEGORY_SET ];



        List<ServiceAppointment> serviceAppointments = [SELECT Id
                                                        FROM ServiceAppointment
                                                        WHERE Work_Order__c IN :wos];

        List<String> saErrors = RevolvingUtility.processDeleteResults(Database.delete(serviceAppointments, false));
        returnDebug.add((serviceAppointments.size() - saErrors.size()) + ' Service Appointments successfully deleted');
        returnDebug.addAll(saErrors);


        List<String> woErrors = RevolvingUtility.processDeleteResults(Database.delete(wos, false));
        returnDebug.add((wos.Size() - woErrors.size()) + ' Work Orders successfully deleted');
        returnDebug.addAll(woErrors);

        for (Occurrence__c occ : occurrenceList){
            occ.Farthest_Date_Generated__c = RevolvingUtility.NOW; //Change current data generation day to today
            occ.Most_Recent_Batch__c  = System.now().addMinutes(5);
            occ.Cleanup_Marker__c = false;
        }

        List<String> occErrors = RevolvingUtility.processSaveResults(Database.update(occurrenceList, false));
        returnDebug.add((occurrenceList.size() - occErrors.size()) + ' Occurrences successfully updated after deleting related Work Orders and Service Appointments');
        returnDebug.addAll(occErrors);

        return returnDebug;
    }
}