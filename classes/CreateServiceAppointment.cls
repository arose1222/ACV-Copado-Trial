public class CreateServiceAppointment extends TriggerInterface {

    public static Map<String,ServiceAppointment> SAOverrideMap = new Map<String,ServiceAppointment>();
    public static boolean skipAppointmentCreation = FALSE;
    public static DateTime currentDT = DateTime.now();
    private final static String saStatus = 'New';
    private static BusinessHours acvBusinessHours{
        get{
            if ( acvBusinessHours == null ) {
                acvBusinessHours = [ SELECT Id FROM BusinessHours WHERE Name = '48 Hour Expiration Date Hours' LIMIT 1 ];
            }
            return acvBusinessHours;
        }
        set;
    }

    private static Map<String, Service_Appt_Date_Range_by_Work_Type__mdt> dateRangeMap {
        get {
            if(dateRangeMap == null) {
                dateRangeMap = new Map<String, Service_Appt_Date_Range_by_Work_Type__mdt>();
                for ( Service_Appt_Date_Range_by_Work_Type__mdt rec : [ SELECT Label, Date_Range__c, Only_Use_Business_Days__c FROM Service_Appt_Date_Range_by_Work_Type__mdt ] ) {
                    dateRangeMap.put(rec.Label, rec);
                }
            }
            return dateRangeMap;
        }
        set;
    }

    public override void afterInsert( Map<Id, SObject> newMap ) {
        if ( !CreateServiceAppointment.skipAppointmentCreation ) {

            List<ServiceAppointment> createSALst = new List<ServiceAppointment>();

            Integer daysBetween;
            for ( WorkOrder woRec : [ SELECT Id, Service_Appt_Map_Id__c, WorkTypeId, WorkType.Work_Type_Unique_ID__c, Inspection_Number_Of_Vehicles__c, ServiceTerritoryId, AccountId, Duration, DurationType, Account.Name, OwnerId, Subject, Description, Street, City, PostalCode, State, Country FROM WorkOrder WHERE Id IN :newMap.keySet() FOR REFERENCE ] ) {
                Service_Appt_Date_Range_by_Work_Type__mdt dateRangeRecord = (woRec.WorkTypeId != null && dateRangeMap.containsKey(woRec.WorkType.Work_Type_Unique_ID__c) ? dateRangeMap.get(woRec.WorkType.Work_Type_Unique_ID__c) : dateRangeMap.get('Default'));
                daysBetween = (Integer) dateRangeRecord.Date_Range__c;
                if(dateRangeRecord.Only_Use_Business_Days__c) {
                    createSALst.add( ServiceAppointmentUtility.createAppointmentFromWorkOrder( woRec, saStatus, currentDT, ACVUtility.addBusinessDays(currentDT, daysBetween, acvBusinessHours), SAOverrideMap));
                }
                else {
                    createSALst.add( ServiceAppointmentUtility.createAppointmentFromWorkOrder( woRec, saStatus, currentDT, currentDT.addDays( daysBetween ), SAOverrideMap));
                }

            }
            insert createSALst;
        }
    }

    public static String getUniqueId() {
        return ACVUtility.NewGuid();
    }
}