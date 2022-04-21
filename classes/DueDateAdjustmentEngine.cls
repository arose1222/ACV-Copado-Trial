public class DueDateAdjustmentEngine extends TriggerInterface {

    public enum DueDateEngineConfig { DEALER_ID, DEALER_TYPE, USER_ID }

    @TestVisible private static Map<DueDateEngineConfig, Map<String, FSL_Due_Date_Rule__mdt>> dueDateConfigMap {
        get {
            if ( dueDateConfigMap == null ) {
                dueDateConfigMap = new Map<DueDateEngineConfig, Map<String, FSL_Due_Date_Rule__mdt>>();
                for ( FSL_Due_Date_Rule__mdt ruleRec : [ SELECT Label, Due_Date_Setting__c, Applicable_Work_Types__c, Dealer_Type__c, Dealer_Id__c, User_Id__c FROM FSL_Due_Date_Rule__mdt ] ) {
                    if ( ruleRec.Dealer_Id__c != null ) {
                        dueDateConfigMap = utilityCheckAndSet( dueDateConfigMap, DueDateEngineConfig.DEALER_ID, ruleRec.Dealer_Id__c, ruleRec );
                    } else if ( ruleRec.Dealer_Type__c != null ) {
                        dueDateConfigMap = utilityCheckAndSet( dueDateConfigMap, DueDateEngineConfig.DEALER_TYPE, ruleRec.Dealer_Type__c, ruleRec );
                    } else if ( ruleRec.User_Id__c != null ) {
                        dueDateConfigMap = utilityCheckAndSet( dueDateConfigMap, DueDateEngineConfig.USER_ID, ruleRec.User_Id__c, ruleRec );
                    }
                }
            }
            return dueDateConfigMap;
        }
        set;
    }

    private static Map<DueDateEngineConfig, Map<String, FSL_Due_Date_Rule__mdt>> utilityCheckAndSet( Map<DueDateEngineConfig, Map<String, FSL_Due_Date_Rule__mdt>> checkMap, DueDateEngineConfig enumVal, String key, FSL_Due_Date_Rule__mdt val ) {
        if ( checkMap.get( enumVal ) == null ) {
            checkMap.put( enumVal, new Map<String, FSL_Due_Date_Rule__mdt>() );
        }
        checkMap.get( enumVal ).put( key, val );
        return checkMap;
    }

    public override void beforeInsert( List<SObject> newLst ) {
        Set<Id> selectedAcctIdSet = new Set<Id>();
        Set<Id> workOrderIdSet = new Set<Id>();
        List<ServiceAppointment> saToProcessLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : (List<ServiceAppointment>) newLst ) {
            if ( saRec.EarliestStartTime != null && !saRec.DueDate_Adjustment_Engine_Bypass__c) {
                selectedAcctIdSet.add( saRec.Account__c );
                saToProcessLst.add( saRec );
                workOrderIdSet.add( saRec.Work_Order__c );
            }
        }

        if ( !saToProcessLst.isEmpty() ) {
            processAppointments( saToProcessLst, selectedAcctIdSet, workOrderIdSet );
        }
    }

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Id> selectedAcctIdSet = new Set<Id>();
        Set<Id> workOrderIdSet = new Set<Id>();
        List<ServiceAppointment> saToProcessLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSARec = (ServiceAppointment) oldMap.get( saRec.Id );
            if ( saRec.EarliestStartTime != null && saRec.EarliestStartTime != oldSARec.EarliestStartTime && !saRec.DueDate_Adjustment_Engine_Bypass__c) {
                selectedAcctIdSet.add( saRec.Account__c );
                saToProcessLst.add( saRec );
                workOrderIdSet.add( saRec.Work_Order__c );
            }
        }

        if ( !saToProcessLst.isEmpty() ) {
            processAppointments( saToProcessLst, selectedAcctIdSet, workOrderIdSet );
        }
    }

    public static void processAppointments( List<ServiceAppointment> saLst, Set<Id> acctIdSet, Set<Id> workOrderIdSet ) {
        Map<Id, Account> acctMap = new Map<Id, Account>( [ SELECT Id, Dealership_Id__c, Dealer_Type__c FROM Account WHERE Id IN :acctIdSet ] );
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>( [ SELECT Id, WorkTypeId, WorkType.Work_Type_Unique_ID__c FROM WorkOrder WHERE Id IN :workOrderIdSet ] );

        for ( ServiceAppointment saRec : saLst ) {
            processNewDueDate( saRec, acctMap.get( saRec.Account__c ), workOrderMap );
        }
    }

    private static Integer getAdjustedDate( Account serviceAcct, WorkOrder woRec ) {
        Map<Id, WorkType> workTypeNameMap = FSLWorkProcessUtility.workTypeIdMap;
        Integer adjustDateNum;

        // Start by checking for Dealer-Specific Configuration, take any provided value
        if ( serviceAcct != null && woRec != null ) {
            FSL_Due_Date_Rule__mdt adjustData;
            if ( UserInfo.getUserId() != null ) {
                adjustData = dueDateConfigMap?.get( DueDateEngineConfig.USER_ID )?.get( UserInfo.getUserId() );
            }

            // Only check for Dealer Id if it is not already set
            if ( adjustData == null && serviceAcct?.Dealership_ID__c != null ) {
                adjustData = dueDateConfigMap?.get( DueDateEngineConfig.DEALER_ID )?.get( serviceAcct.Dealership_ID__c );
            }

            // Only check for DealerType if it is not already set
            if ( adjustData == null && !String.isBlank( serviceAcct.Dealer_Type__c ) ) {
                adjustData = dueDateConfigMap?.get( DueDateEngineConfig.DEALER_TYPE )?.get( serviceAcct.Dealer_Type__c );
            }

            if ( adjustData != null ) {
                if ( !String.isBlank( adjustData.Applicable_Work_Types__c ) ) {
                    // Get Work Type Names
                    Set<String> splitWorkTypeNameSet = new Set<String>( adjustData.Applicable_Work_Types__c.split( ',' ) );
                    // Get Work Type Data for Service Appointment
                    if ( splitWorkTypeNameSet != null && !splitWorkTypeNameSet.isEmpty() ) {
                        WorkType workTypeRec = workTypeNameMap.get( woRec.WorkTypeId );
                        if ( workTypeRec != null ) {
                            String workTypeName = workTypeRec.Work_Type_Unique_ID__c;
                            if ( splitWorkTypeNameSet.contains( workTypeName ) ) { // Only if it is on the metadata, do we take the value
                                adjustDateNum = Integer.valueOf( adjustData.Due_Date_Setting__c );
                            }
                        }
                    }
                } else {
                    adjustDateNum = Integer.valueOf( adjustData.Due_Date_Setting__c );
                }
            }
        }
        return adjustDateNum;
    }

    private static void processNewDueDate( ServiceAppointment providedRec, Account apptAcct, Map<Id, WorkOrder> woRecMap ) {
        Integer adjustDateNumber = getAdjustedDate( apptAcct, woRecMap.get( providedRec.Work_Order__c ) );

        // Only continue if a value is found
        if ( adjustDateNumber != null ) {
            Integer businessDays = 0;
            Integer actualDaysToAdd = 0;
            DateTime currentDate = providedRec.EarliestStartTime;
            // We need to keep counting until we get to adjustDateNumber of Business Days
            do {
                currentDate = currentDate.addDays(1);
                actualDaysToAdd++;
                // Only progress if the date is not a holiday and is a weekday
                if ( !ACVUtility.isStandardHoliday( currentDate ) && ACVUtility.isWeekday( currentDate ) ) {
                    businessDays++;
                }
            } while ( businessDays != adjustDateNumber );

            providedRec.DueDate = providedRec.EarliestStartTime.addDays( actualDaysToAdd );
        }
    }
}