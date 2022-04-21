/**
 * @description Stamp Service Appointment with Location formatted DateTimes
 */
public with sharing class trac_ServiceAppointmentTimeConv extends TriggerInterface{

    public override void beforeInsert(List<SObject> newList){
        execute((List < ServiceAppointment >)newList);
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        execute((List < ServiceAppointment >)newMap.values(),oldMap);
    }

    private static final Map < String, String > localTimeFieldToActualTimeFieldMap = new Map < String, String >{
//            'Local_Earliest_Start_Permitted__c' => 'EarliestStartTime',
//            'Local_Actual_End_Time__c' => 'ActualEndTime',
//            'Local_Actual_Start_Time__c' => 'ActualStartTime',
//            'Local_Arrival_Window_End_Time__c' => 'ArrivalWindowEndTime',
//            'Local_Arrival_Window_Start_Time__c' => 'ArrivalWindowStartTime',
//            'Local_Scheduled_End_Time__c' => 'SchedEndTime',
            'Local_Scheduled_Start_Time__c' => 'SchedStartTime'
    };

    /**
     * @description Converts Date into String format in specified timezone
     * @return String value of Datetime in specified Timezone
     */
    public static String convertDateTimetoGMTDateTimeString(DateTime inputDateTime, String toTimeZone) {
        return inputDateTime.format('MMM dd yyyy hh:mm aaa', toTimeZone);
    }

    /**
     * @description Convert date time from GMT to specified timezone, and save this value as a string in the localtimefield
     * @param serviceApp Service Appointment to convert date time for
     * @param timezone Which time zone to convert from
     * @param localTimeField The field that should hold the local time string value
     * @param inputField The date field that should be converted
     */
    private static void convertServiceAppointmentDatetoGMTStringInstance(ServiceAppointment serviceApp, String timezone, String localTimeField, String inputField) {
        if (serviceApp.get(inputField) != null) {
            serviceApp.put(localTimeField, convertDateTimetoGMTDateTimeString((DateTime) serviceApp.get(inputField), timezone));
        }else{
            serviceApp.put(localTimeField, null);
        }
    }

    /**
     * @description compares old and new values of all related fields and returns records with changed time fields
     * @param newServiceAppointments list of Service Appointments to convert datetime fields for
     * @param oldServiceAppointmentMap map of old values from trigger
     */
    private static List < ServiceAppointment > filterAppointments(List < ServiceAppointment > unfilteredServiceAppointments, Map < id, SObject > oldServiceAppointmentMap) {
        List < ServiceAppointment > filteredAppointments = new List < ServiceAppointment > ();
        for (ServiceAppointment serviceAppointment : unfilteredServiceAppointments) {
            ServiceAppointment oldServiceAppointment = (ServiceAppointment) oldServiceAppointmentMap.get(serviceAppointment.Id);
            for (String filterField : localTimeFieldToActualTimeFieldMap.values()) {
                if (oldServiceAppointment.get(filterField) != serviceAppointment.get(filterField)) {
                    filteredAppointments.add((ServiceAppointment) serviceAppointment);
                    break;
                }
            }
        }

        return filteredAppointments;
    }

    /**
     * @description removes service appointments with null dates on insert that dont need processing
     * @param newServiceAppointments list of Service Appointments to convert datetime fields for
     */
    private static List < ServiceAppointment > filterNullDateAppointments(List < ServiceAppointment > unfilteredServiceAppointments) {
        List < ServiceAppointment > filteredAppointments = new List < ServiceAppointment > ();
        for (ServiceAppointment serviceAppointment : unfilteredServiceAppointments) {
            for (String filterField : localTimeFieldToActualTimeFieldMap.values()) {
                if (serviceAppointment.get(filterField) != null) {
                    filteredAppointments.add((ServiceAppointment) serviceAppointment);
                    break;
                }
            }
        }
        return filteredAppointments;
    }

    /**
     * @description stamps the date time fields into the associated local rate fields for a list of Service appointments
     * @param newServiceAppointments list of Service Appointments to convert datetime fields for
     * @param oldServiceAppointmentMap map of old values from trigger
     */
    public static void execute(List < ServiceAppointment > newServiceAppointments, Map < id, SObject > oldServiceAppointmentMap) {
        System.debug(newServiceAppointments);
        System.debug(oldServiceAppointmentMap);


        localTimeConvert(filterAppointments(newServiceAppointments, oldServiceAppointmentMap));
    }

    /**
     * @description stamps the date time fields into the associated local rate fields for a list of Service appointments
     * @param newServiceAppointments list of Service Appointments to convert datetime fields for
     */
    public static void execute(List < ServiceAppointment > newServiceAppointments) {
        System.debug(newServiceAppointments);

        localTimeConvert(filterNullDateAppointments(newServiceAppointments));
    }

    /**
     * @description compares old and new values of all related fields and returns records with changed time fields
     * @param newServiceAppointments list of Service Appointments to convert datetime fields for
     */
    public static void localTimeConvert(List < ServiceAppointment > newServiceAppointments) {
        if (newServiceAppointments.size() > 0) {

            Set < Id > serviceTerritoryIds = new Set < Id > ();
            for (ServiceAppointment serviceAppointmentInstance : newServiceAppointments) {

                serviceTerritoryIds.add(serviceAppointmentInstance.ServiceTerritoryId);
            }
            Map < Id, ServiceTerritory > serviceTerritoryMap = new Map < Id, ServiceTerritory > ([
                    Select Id, OperatingHours.TimeZone
                    from ServiceTerritory
                    where Id in:serviceTerritoryIds
            ]);
            for (ServiceAppointment serviceAppointmentInstance : newServiceAppointments) {
                if (serviceTerritoryMap.get(serviceAppointmentInstance.ServiceTerritoryId) != null) {
                    String opperatingHourTimeZone = (String) serviceTerritoryMap.get(serviceAppointmentInstance.ServiceTerritoryId).OperatingHours.TimeZone;
                    for (String localField : localTimeFieldToActualTimeFieldMap.keySet()) {
                        String actualTimeField = localTimeFieldToActualTimeFieldMap.get(localField);
                        convertServiceAppointmentDatetoGMTStringInstance(serviceAppointmentInstance, opperatingHourTimeZone, localField, actualTimeField);
                    }
                }
            }
        }
    }
}