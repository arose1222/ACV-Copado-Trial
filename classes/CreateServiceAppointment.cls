public class CreateServiceAppointment extends TriggerInterface {
    
    public static boolean skipAppointmentCreation = FALSE;
    private final static String saStatus = 'New';
    private static Integer dateRange {
        get { 
            if ( dateRange == null ) {
                for ( Salesforce_Setting__mdt rec : [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Service_Appointment_Range' LIMIT 1 ] ) {
                    dateRange = Integer.valueOf( rec.Value__c );
                }
            }
            return dateRange;
        }
        set;
    } 

    public override void afterInsert( Map<Id, SObject> newMap ) {
        if ( !CreateServiceAppointment.skipAppointmentCreation ) {
            List<ServiceAppointment> createSALst = new List<ServiceAppointment>();

            DateTime currentDT = DateTime.now();
            for ( WorkOrder woRec : [ SELECT Id, WorkTypeId, Inspection_Number_Of_Vehicles__c, ServiceTerritoryId, AccountId, Duration, DurationType, Account.Name, OwnerId, Subject, Description, Street, City, PostalCode, State, Country FROM WorkOrder WHERE Id IN :newMap.keySet() FOR REFERENCE ] ) {
                createSALst.add( 
                    ServiceAppointmentUtility.createAppointmentFromWorkOrder( woRec, saStatus, currentDT, currentDT.addDays( dateRange ) )
                );
            }
            insert createSALst;
        }
    }
}