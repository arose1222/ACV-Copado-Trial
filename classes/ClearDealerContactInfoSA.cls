public class ClearDealerContactInfoSA extends TriggerInterface {
    private static final Set<String> CLEAR_CONTACT_WORK_TYPE_SET = new Set<String>{ 'fbi', 'acvhome' };

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Set<Id> workIdSet = new Set<Id>();
        List<ServiceAppointment> processSALst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( ( sa.WorkTypeId != oldSA.WorkTypeId )  && sa.Work_Order__c != null ) {
                processSALst.add( sa );
                workIdSet.add( sa.Work_Order__c );
            }
        }

        if ( !processSALst.isEmpty() ) {
            stripContact( processSALst, workIdSet );
        }
    }

    public override void afterinsert(List<SObject> newList) {
        Set<Id> workIdSet = new Set<Id>();
        List<ServiceAppointment> processSALst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newList ) {
            if ( sa.Work_Order__c != null ) {
                processSALst.add( sa );
                workIdSet.add( sa.Work_Order__c );
            }
        } 

        if ( !processSALst.isEmpty() ) {
            stripContact( processSALst, workIdSet );
        }
    }

    public static void stripContact( List<ServiceAppointment> saLst, Set<Id> woIdSet ) {
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>( [ SELECT Id, WorkTypeId FROM WorkOrder WHERE Id IN :woIdSet ] );

        List<ServiceAppointment> updateSALst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : saLst ) {
            if ( CLEAR_CONTACT_WORK_TYPE_SET.contains( FSLWorkProcessUtility.workTypeIdMap?.get( woMap.get( sa.Work_Order__c )?.WorkTypeId )?.Work_Type_Unique_Id__c ) ) {    
                updateSALst.add( new ServiceAppointment(
                    ContactId = null,
                    Id = sa.Id
                ) );
            }
        }

        if ( !updateSALst.isEmpty() ) {
            update updateSALst;
        }
    }
}