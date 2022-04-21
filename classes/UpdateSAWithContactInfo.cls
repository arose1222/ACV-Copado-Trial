public class UpdateSAWithContactInfo extends TriggerInterface {
    public override void afterInsert( List<SObject> newList ) {
        Map<Id, WorkOrderLineItem> woliInfoMap = new Map<Id, WorkOrderLineItem>();
        for ( WorkOrderLineItem woli : (List<WorkOrderLineItem>) newList ) {
            woliInfoMap.put( woli.WorkOrderId, woli );
        }

        if ( !woliInfoMap.isEmpty() ) {
            UpdateSAWithLineItemContactInfo( woliInfoMap );
        }
    }

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Map<Id, WorkOrderLineItem> woliFilterMap = new Map<Id, WorkOrderLineItem>();
        for ( WorkOrderLineItem newWoli : (List<WorkOrderLineItem>) newMap.values() ) {
            WorkOrderLineItem oldWoli = (WorkOrderLineItem) oldMap.get( newWoli.Id );
            if ( newWoli.Customer_Email__c != oldWoli.Customer_Email__c ||
            newWoli.Driving_Directions__c != oldWoli.Driving_Directions__c ||
            newWoli.Contact_Name__c != oldWoli.Contact_Name__c ||
            newWoli.Contact_Phone_Number__c != oldWoli.Contact_Phone_Number__c ||
            newWoli.Contact_Mobile_Number__c != oldWoli.Contact_Mobile_Number__c ||
            newWoli.Contact_Email__c != oldWoli.Contact_Email__c ||
            newWoli.External_Assignment_Id__c != oldWoli.External_Assignment_Id__c ||
            newWoli.External_Link__c != oldWoli.External_Link__c ||
            newWoli.External_Link_Code__c != oldWoli.External_Link_Code__c ||
            newWoli.Description != oldWoli.Description ||
            newWoli.Dealership_Name__c != oldWoli.Dealership_Name__c
            ) {
                woliFilterMap.put( newWoli.WorkOrderId, newWoli );
            }
        }

        if ( !woliFilterMap.isEmpty() ) {
            UpdateSAWithLineItemContactInfo( woliFilterMap );
        }
    }

    public static void UpdateSAWithLineItemContactInfo( Map<Id, WorkOrderLineItem> workToLineMap ) {
        List<ServiceAppointment> saLst = [ SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Work_Order__c IN :workToLineMap.keyset() ];

        for ( ServiceAppointment sa : saLst ) {
            if ( workToLineMap.get( sa.Work_Order__c ) != null ) {
                sa.Customer_Email__c = workToLineMap.get( sa.Work_Order__c ).Customer_Email__c;
                sa.Driving_Directions__c = workToLineMap.get( sa.Work_Order__c ).Driving_Directions__c;
                sa.Contact_Name__c = workToLineMap.get( sa.Work_Order__c ).Contact_Name__c;
                sa.Contact_Phone_Number__c = workToLineMap.get( sa.Work_Order__c ).Contact_Phone_Number__c;
                sa.Contact_Mobile_Number__c = workToLineMap.get( sa.Work_Order__c ).Contact_Mobile_Number__c;
                sa.Contact_Email__c = workToLineMap.get( sa.Work_Order__c ).Contact_Email__c;
                sa.External_Assignment_Id__c = workToLineMap.get( sa.Work_Order__c ).External_Assignment_Id__c;
                sa.External_Link__c = workToLineMap.get( sa.Work_Order__c ).External_Link__c;
                sa.External_Link_Code__c = workToLineMap.get( sa.Work_Order__c ).External_Link_Code__c;
                sa.Inspection_Notes__c = workToLineMap.get( sa.Work_Order__c ).Description;
                sa.Dealership_Name__c = workToLineMap.get( sa.Work_Order__c ).Dealership_Name__c;
            }
        }

        update saLst;
    }
}