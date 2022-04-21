public class GenerateInvoice extends TriggerInterface {

    public override void afterInsert( List<SObject> newLst ) {
        Set<Id> woliQuerySet = new Set<Id>();
        Set<String> invoiceIdSet = new Set<String>();

        for ( WorkOrderLineItem woliCheckRec : (List<WorkOrderLineItem>) newLst ) {
            if ( !String.isBlank( woliCheckRec.External_Invoice_Id__c ) ) {
                woliQuerySet.add( woliCheckRec.Id );
                invoiceIdSet.add( woliCheckRec.External_Invoice_Id__c );
            }
        }

        if ( !woliQuerySet.isEmpty() ) {
            generateInvoices( [ SELECT Id, External_Invoice_Id__c, WorkOrder.AccountId FROM WorkOrderLineItem WHERE Id IN :woliQuerySet ], invoiceIdSet );
        }
    }

    private static void generateInvoices( List<WorkOrderLineItem> woliLst, Set<String> invoiceIdSet ) {
        List<Invoice__c> upsertInvoiceLst = new List<Invoice__c>();

        Set<String> existingInvoiceSet = new Set<String>();
        for ( Invoice__c invoiceRec : [ SELECT Invoice_Id__c FROM Invoice__c WHERE Invoice_Id__c IN :invoiceIdSet ] ) {
            existingInvoiceSet.add( invoiceRec.Invoice_Id__c );
        }
        
        for ( WorkOrderLineItem currentWOLI : woliLst ) {
            if ( !existingInvoiceSet.contains( currentWOLI.External_Invoice_Id__c ) ) {
                Invoice__c associatedInvoice = new Invoice__c(
                    Name = currentWOLI.External_Invoice_Id__c,
                    Invoice_Id__c = currentWOLI.External_Invoice_Id__c,
                    Account__c = currentWOLI.WorkOrder.AccountId
                );
                upsertInvoiceLst.add( associatedInvoice );
            }

            currentWOLI.Invoice__r = new Invoice__c( Invoice_Id__c = currentWOLI.External_Invoice_Id__c );
        }

        insert upsertInvoiceLst;
        update woliLst;
    }
}