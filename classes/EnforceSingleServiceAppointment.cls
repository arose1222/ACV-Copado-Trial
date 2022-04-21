public class EnforceSingleServiceAppointment extends TriggerInterface {
    public override void afterInsert( List<SObject> newList ) {
        Set<Id> workOrderIdSet = new Set<Id>();
        List<ServiceAppointment> loopLst = new List<ServiceAppointment>();
        Set<Id> apptIdSet = new Set<Id>();
        for ( ServiceAppointment apptRec : (List<ServiceAppointment>) newList ) {         
            if ( apptRec.ParentRecordId != null && apptRec.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType ) {
                workOrderIdSet.add( apptRec.ParentRecordId );
                loopLst.add( apptRec );
                apptIdSet.add( apptRec.Id );
            }
        }

        if ( !workOrderIdSet.isEmpty() ) {
            Map<Id, List<ServiceAppointment>> workToNumApptsMap = new Map<Id, List<ServiceAppointment>>();
            for ( WorkOrder woRec : [ SELECT Id, ( SELECT Id FROM ServiceAppointments ) FROM WorkOrder WHERE Id IN :workOrderIdSet ] ) {
                workToNumApptsMap.put( woRec.Id, new List<ServiceAppointment>() );
                if ( woRec.ServiceAppointments != null && !woRec.ServiceAppointments.isEmpty() ) {
                    workToNumApptsMap.put( woRec.Id, woRec.ServiceAppointments );
                }
            }   

            List<ServiceAppointment> apptsToRemoveLst = new List<ServiceAppointment>();
            
            for ( ServiceAppointment checkApptRec : loopLst ) { 
                if ( workToNumApptsMap.get( checkApptRec.ParentRecordId ) != null && workToNumApptsMap.get( checkApptRec.ParentRecordId ).size() > 1 ) {
                    for ( ServiceAppointment saRec : workToNumApptsMap.get( checkApptRec.ParentRecordId ) ) {
                        if ( !apptIdSet.contains( saRec.Id ) ) {
                            apptsToRemoveLst.add( new ServiceAppointment( 
                                Id = saRec.Id 
                            ) );
                        }
                    }
                }
            }        
            
            if ( !apptsToRemoveLst.isEmpty() ) {
                delete apptsToRemoveLst;
            }
        }
    }
}