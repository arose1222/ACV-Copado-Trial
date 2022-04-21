public class AutoFillAddressOnServiceAppointment extends TriggerInterface {
    public override void beforeInsert( List<SObject> newList ) {     
        Set<Id> acctIdSet = new Set<Id>();
        List<ServiceAppointment> saToReviewLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : (List<ServiceAppointment>) newList ) {  
            if ( saRec.Account__c != null &&
                ( String.isBlank( saRec.Street ) || String.isBlank( saRec.City ) || String.isBlank( saRec.PostalCode ) || String.isBlank( saRec.State ) || String.isBlank( saRec.Country ) ) ) {
                    acctIdSet.add( saRec.Account__c );
                    saToReviewLst.add( saRec );
            }
        }

        if ( !acctIdSet.isEmpty() ) {
            Set<String> modifiedRecordKeySet = new Set<String>();

            Map<Id, Account> acctMap = new Map<Id, Account>( [ SELECT Id, Dealership_Id__c, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry FROM Account WHERE Id IN :acctIdSet ] );        
            for ( ServiceAppointment saRec : saToReviewLst ) {  
                modifiedRecordKeySet.add( 
                    acctMap.get( saRec.Account__c )?.Dealership_Id__c + ':' + saRec.ParentRecordId 
                );
                saRec.Street = acctMap.get( saRec.Account__c )?.BillingStreet;
                saRec.City = acctMap.get( saRec.Account__c )?.BillingCity;
                saRec.PostalCode = acctMap.get( saRec.Account__c )?.BillingPostalCode;
                saRec.State = acctMap.get( saRec.Account__c )?.BillingState;
                saRec.Country = acctMap.get( saRec.Account__c )?.BillingCountry;                 
            }

            // Send Results to Splunk for record keeping & R&I Reference
           /* if ( !modifiedRecordKeySet.isEmpty() ) {
                SplunkHelper.Log infoLog = new SplunkHelper.Log();
                infoLog.version = 'v1'; // We don't have versions yet
                infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
                infoLog.location = 'AutoFillAddressOnServiceAppointment:' + ACVUtility.currentLineNumber();
                infoLog.message = 'At least one Service Appointment was created without an address or with a partial address, those records have been overwritten by the associated Account\'s Billing Address';
                infoLog.stackTrace = 'AutoFillAddressOnServiceAppointment:' + ACVUtility.currentLineNumber();
                infoLog.sfRecordId = UserInfo.getUserId();
                infoLog.componentName = 'AutoFillAddressOnServiceAppointment';
                infoLog.sfObject = 'ServiceAppointment';
                infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES, SplunkHelper.DOMAIN.SUPPLY, SplunkHelper.DOMAIN.CAPITAL };
        
                SplunkHelper.buildandProcessLog( infoLog, new List<SplunkHelper.SFErrorRecord>(), modifiedRecordKeySet );
            }*/
        }
    }
}