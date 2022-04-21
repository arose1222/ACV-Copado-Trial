public class CapitalTestUtility {
    public static Invoice__c createInvoice( string invoiceId, string status, Id accountId ) {
        return new Invoice__c(
            Name = invoiceId,
            Invoice_Id__c = invoiceId,
            Account__c = accountId,
            Status__c = status
        );
    }

    public static Invoice__c createInvoice( string invoiceId, Id accountId ) {
        return createInvoice( invoiceId, 'Open', accountId );
    }
}