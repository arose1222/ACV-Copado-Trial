public class CaseTransportationProcesses {
    private static boolean beforeInsertProcessed = false;
    private static boolean afterInsertProcessed = false;
    private static boolean beforeUpdateProcessed = false;
    private static boolean afterUpdateProcessed = false;
    public static boolean transportationFlag = false;

    public static void beforeInsert(List<Case> newCaseList){
        if(beforeInsertProcessed == false){
            List<Case> filteredList = filter(newCaseList);

            if(filteredList.size() > 0){
                beforeInsertProcessed = true;
                stampAddressInfoOnCase(filteredList);
                setPostedPrice(filteredList);
                releaseAvailableStatusChange(filteredList);
                System.debug('Before Insert processes for Transportation Cases executed.');
            }
        } else{
            System.debug('Recursion on Before Insert on Transportation Cases blocked. Use TransportationCaseProcesses.beforeInsertToggle() to step in.');
        }
    }

    public static void afterInsert(Map<Id,SobJect> newCaseMap, Map<Id,SobJect> oldCaseMap){
        if(afterInsertProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>)newCaseMap);
            if(filteredMap.size() > 0){
                afterInsertProcessed = true;
                CreateRelatedTDR.create((List<Case>) filteredMap.values());
                TransportationDispatchRequestHandler.run(filteredMap);
                //CalcDriveDistance.run((List<Case>) filteredMap.values());
                updateUnwindTransportStatus((Map<Id,Case>)newcaseMap);
                System.debug('After Insert processes for Transportation Cases executed.');
            }
        } else{
            System.debug('Recursion on After Insert on Transportation Cases blocked. Use TransportationCaseProcesses.afterInsertToggle() to step in.');
        }    
    }

    public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(beforeUpdateProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>)newCaseMap);
            if(filteredMap.size() > 0){
                beforeUpdateProcessed = true;
                stampAddressInfoOnCase(filteredMap.values());
                updateTransporterInformation(filteredMap, oldCaseMap);                
                preventEditOnceTransportationFinal( filteredMap, oldCaseMap );
                setPostedPrice(filteredMap, oldCaseMap);
                releaseAvailableStatusChange(filteredMap.values());
                System.debug('Before Update processes for Transportation Cases executed.');
            }
        } else{
            System.debug('Recursion on Before Update for Transportation Cases blocked. Use TransportationCaseProcesses.beforeInsertToggle() to step in.');
        }
    }
    

    public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        Map<Id,Case> filteredMap = filter((Map<Id,Case>)newCaseMap);
        if(filteredMap.size() > 0){
            //System.Debug(filteredMap);
            CreateRelatedTDR.create((List<Case>) filteredMap.values());
            TransportationDispatchRequestHandler.run(filteredMap);
            if(afterUpdateProcessed == false){
                afterUpdateProcessed = true;
                updateUnwindTransportStatus((Map<Id,Case>)newcaseMap);
                //CalcDriveDistance.run(filteredMap, oldCaseMap);
                System.debug('After Update processes for Transportation Cases executed.');
            }
        } else{
            System.debug('Recursion on After Update on Transportation Cases blocked. Use TransportationCaseProcesses.afterUpdateToggle() to step in.');
        }
    }

    public static void setPostedPrice(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        Map<id,case> newCaseMap = (Map<id,case>)incomingNewMap;
        Map<id,case> oldCaseMap = (Map<id,case>)incomingOldMap;

        List<Case> changedCases = new List<Case>();
        for(Case c :newCaseMap.values()){
            if(c.Posted_Price__c == null && c.Buyer_Price__c != null){
                changedCases.add(c);
            }
        }

        if(changedCases.size() > 0){
            setPostedPrice((List<sObject>)changedCases);
        }
    }

    public static void setPostedPrice(List<Case> incomingList){
        List<Case> caseList = (List<Case>)incomingList;
        
        List<Transport_Pricing__mdt> pricingList = [select Percent_Adjustment__c from Transport_Pricing__mdt where MasterLabel = 'First Posted Price'];
        if(pricingList.size() > 0){
            for(Case c :caseList){
                if(c.Price_Pre_Promotion__c != null){
                    c.Posted_Price__c = c.Price_Pre_Promotion__c * (pricingList[0].Percent_Adjustment__c/100);
                } else {
                    c.Price_Pre_Promotion__c = c.Buyer_Price__c;
                    c.Posted_Price__c = c.Price_Pre_Promotion__c * (pricingList[0].Percent_Adjustment__c/100);
                }
            }
        }
    }

    public static void updateTransporterInformation(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        Map<id,case> newCaseMap = (Map<id,case>)incomingNewMap;
        Map<id,case> oldCaseMap = (Map<id,case>)incomingOldMap;

        Set<Id> transporterIdSet = new Set<Id>();
        for(Case c :newCaseMap.values()){
            if( c.Transporter_Account__c != null && c.Transporter_Account__c != oldCaseMap.get(c.id).Transporter_Account__c){
                transporterIdSet.add(c.Transporter_Account__c);
            }
        }
        transporterIdSet.remove(null);
        
        if(transporterIdSet.isEmpty()){
            return;
        }

        Map<Id,Account> transporterMap = new Map<Id,Account>([Select Id, Name, Email__c, Phone from Account Where Id in :transporterIdSet]);
        for(Case c :newCaseMap.values()){
            if( c.Transporter_Account__c != null && transporterMap.get(c.Transporter_Account__c) != null && c.Transporter_Account__c != oldCaseMap.get(c.id).Transporter_Account__c){
                c.Transporter_Email__c = transporterMap.get(c.Transporter_Account__c).Email__c;
                c.Transporter_Name__c = transporterMap.get(c.Transporter_Account__c).Name;
                c.Transporter_Phone__c = transporterMap.get(c.Transporter_Account__c).Phone;
            }
        }
    }
    
    public static void stampAddressInfoOnCase(List<Case> incomingList){
        Set<Id> dealershipIdList = new Set<Id>();
        Set<Id> parentCaseIdList = new Set<Id>();
        Set<Id> transportAddresses = new Set<Id>();

        //Populate Sets and Lists
        for( case c : incomingList ){
            if ( c.AccountId != null && c.Seller_Dealership__c != null ) {
                // Add pickup address if it is populated 
                if ( c.Pickup_Address_Lookup__c != null ) {
                    transportAddresses.add(c.Pickup_Address_Lookup__c);
                } else {
                    dealershipIdList.add( c.Seller_Dealership__c ); 
                }
                
                // Add deliver address if it is populated
                if ( c.Delivery_Address_Lookup__c != null ) {
                    transportAddresses.add(c.Delivery_Address_Lookup__c);
                } else {
                    dealershipIdList.add( c.AccountId );
                }
            }

            if ( c.ParentId != null ) {
                parentCaseIdList.add(c.ParentId);
            }  
        }

        if ( dealershipIdList.size()>0 || transportAddresses.size()>0 ) {
            Map<Id,Account> dealerMap = new Map<Id, Account>( [SELECT Id, Name, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone 
                                                               FROM Account 
                                                               WHERE id IN :dealershipIdList] );
            Map<Id,Transportation_Address__c> transportAddressMap = new Map<Id,Transportation_Address__c>( [SELECT Id, id__c, Name, City__c, State__c, Country__c, Street__c, Postal_Code__c, Notes__c 
                                                                                                                  FROM Transportation_Address__c 
                                                                                                                  WHERE Id IN :transportAddresses] );
            Map<Id,Case> parentCaseMap = new Map<Id,Case>( [SELECT Id, Vehicle_Location__c 
                                                            FROM Case 
                                                            WHERE id IN :parentCaseIdList]);

            for ( case tCase : incomingList ){
                // Use Delivery Address lookup if it is populated
                if ( tCase.Delivery_Address_Lookup__c != null && transportAddressMap.get(tCase.Delivery_Address_Lookup__c) != null ) {
                    if ( tCase.Delivery_Address_Name__c == null ) {
                        tCase.Delivery_Address_Name__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).Name;
                    }
                    if ( tCase.Default_Delivery_Address__c == null ) {
                        tCase.Default_Delivery_Address__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).Street__c;
                    }
                    if ( tCase.Default_Delivery_City__c == null ) {
                        tCase.Default_Delivery_City__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).City__c;
                    }
                    if ( tCase.Default_Delivery_Country__c == null ) {
                        tCase.Default_Delivery_Country__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).Country__c;
                    }
                    if ( tCase.Default_Delivery_Postal_Code__c == null ) {
                        tCase.Default_Delivery_Postal_Code__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).Postal_Code__c;
                    }
                    if ( tCase.Default_Delivery_State__c == null ) {
                        tCase.Default_Delivery_State__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).State__c;
                    }
                    if ( tCase.Buyer_Pickup_Notes__c == null ) {
                        tCase.Buyer_Pickup_Notes__c = transportAddressMap.get(tCase.Delivery_Address_Lookup__c).Notes__c;
                    }
                } else if ( tCase.AccountId != null && dealerMap.get(tCase.AccountId) != null ) {
                    if ( tCase.Delivery_Address_Name__c == null ) {
                        tCase.Delivery_Address_Name__c = dealerMap.get(tCase.AccountId).Name;
                    }
                    if ( tCase.Default_Delivery_Address__c == null ) {
                        tCase.Default_Delivery_Address__c = dealerMap.get(tCase.AccountId).BillingStreet;
                    }
                    if ( tCase.Default_Delivery_City__c == null ) {
                        tCase.Default_Delivery_City__c = dealerMap.get(tCase.AccountId).BillingCity;
                    }
                    if ( tCase.Default_Delivery_Country__c == null ) {
                        tCase.Default_Delivery_Country__c = dealerMap.get(tCase.AccountId).BillingCountry;
                    }
                    if ( tCase.Default_Delivery_Postal_Code__c == null ) {
                        tCase.Default_Delivery_Postal_Code__c = dealerMap.get(tCase.AccountId).BillingPostalCode;
                    }
                    if ( tCase.Default_Delivery_State__c == null ) {
                        tCase.Default_Delivery_State__c = dealerMap.get(tCase.AccountId).BillingState;
                    }
                }

                if ( tCase.Pickup_Address_Lookup__c != null && transportAddressMap.get(tCase.Pickup_Address_Lookup__c) != null ) {
                    if ( tCase.Pickup_Address_Name__c == null ) {
                        tCase.Pickup_Address_Name__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).Name;
                    }
                    if ( tCase.Pickup_Address__c == null ) {
                        tCase.Pickup_Address__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).Street__c;
                    }
                    if ( tCase.Default_Pickup_City__c == null ) {
                        tCase.Default_Pickup_City__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).City__c;
                    }
                    if ( tCase.Default_Pickup_Country__c == null ) {
                        tCase.Default_Pickup_Country__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).Country__c;
                    }
                    if ( tCase.Default_Pickup_Postal_Code__c == null ) {
                        tCase.Default_Pickup_Postal_Code__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).Postal_Code__c;
                    }
                    if ( tCase.Default_Pickup_State__c == null ) {
                        tCase.Default_Pickup_State__c = transportAddressMap.get(tCase.Pickup_Address_Lookup__c).State__c;
                    }
                    if ( tCase.Seller_Pick_Up_Notes__c== null ) {
                        tCase.Seller_Pick_Up_Notes__c= transportAddressMap.get(tCase.Pickup_Address_Lookup__c).Notes__c;
                    }
                } else if (tCase.Seller_Dealership__c != null && dealerMap.get(tCase.Seller_Dealership__c) != null) {
                    if ( tCase.Pickup_Address_Name__c == null){
                        tCase.Pickup_Address_Name__c = dealerMap.get(tCase.Seller_Dealership__c).Name;
                    }
                    if(tCase.Pickup_Address__c == null){
                        tCase.Pickup_Address__c = dealerMap.get(tCase.Seller_Dealership__c).BillingStreet;
                    }
                    if(tCase.Default_Pickup_City__c == null){
                        tCase.Default_Pickup_City__c = dealerMap.get(tCase.Seller_Dealership__c).BillingCity;
                    }
                    if(tCase.Default_Pickup_Country__c == null){
                        tCase.Default_Pickup_Country__c = dealerMap.get(tCase.Seller_Dealership__c).BillingCountry;
                    }
                    if(tCase.Default_Pickup_Postal_Code__c == null){
                        tCase.Default_Pickup_Postal_Code__c = dealerMap.get(tCase.Seller_Dealership__c).BillingPostalCode;
                    }
                    if(tCase.Default_Pickup_State__c == null){
                        tCase.Default_Pickup_State__c = dealerMap.get(tCase.Seller_Dealership__c).BillingState;
                    }
                }
                if(parentCaseMap.get(tCase.parentId) != null){
                    if(tCase.Vehicle_Location__c == null){
                        tCase.Vehicle_Location__c = parentCaseMap.get(tCase.ParentId).Vehicle_Location__c;
                    }
                }
            }
        }
    }

    // Process: Update Unwind Transportation status - DONE
    /**
     * updateUnwindTransportStatus
     * @param  newcaseMap 
     */
    public static void updateUnwindTransportStatus (Map<Id, Case> newCaseMap){
        Set<Id> transportIDSet = new Set<Id> ();
        for(Case c : newCaseMap.values()){
            if(c.status == 'Unwind Transportation Requested'){
                transportIDSet.add(c.parentID);
            }
        }
        transportIDSet.remove(null);
         
        if (transportIDset == null){
            return;
        }
        
        Map<Id, case> parentmap = new Map<Id, Case>( [select id, Unwind_Transportation_Requested__c from case where id in : transportIDSet]);
        System.debug(parentmap);
        for(Id caseid : newCaseMap.keyset()){
            if(newCaseMap.get(caseid).parentid != null && parentmap.get(newCaseMap.get(caseid).parentid) != null ) {
                parentmap.get(newCaseMap.get(caseid).parentid).Unwind_Transportation_Requested__c = true;
            }
        }
        if(parentmap.values().size() > 0 ){
            update parentmap.values();
        }
    }
    
    /**
     * releaseAvailableStatusChange 
     *  GIVEN A Transportation Case with status 'Awaiting Release'
     *  AND the 'Release_Available__c' is True
     *  WHEN the Case is inserted or Updated
     *  THEN Change the status to 'Ready-to-Post'
     *
     * @param  incomingList - List of Cases
     */ 
    public static void releaseAvailableStatusChange(List<Case> incomingList){
        List<Case> caseList = new List<Case>();

        for(Case c : (List<Case>)incomingList){
            if(c.Status == 'Awaiting Release' && c.Release_Available__c == true){
                caseList.add(c);
            }
        }
        
        if(caseList.size() > 0){
            for(Case c : caseList){
                c.Status = 'Ready-to-Post';
            }
        }
    }

    /**
     * preventEditOnceTransportationFinal 
     *  GIVEN a Transportation Case with the Transportation Finalized checkbox is checked
     *  WHEN the Case is updated by a user who is not a System Administrator
     *  THEN prevent modifications to fields outside of Transport Bill Name or Date Transporter Paid
     *
     * @param  newCaseMap - Map of new context Cases
     * @param  oldCaseMap - Map of old context Cases
     */ 
    public static void preventEditOnceTransportationFinal( Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap ) {
        if ( !CaseTransportationProcesses.transportationFlag ) { // Bypass flag for auction related updates
            if ( UserInfo.getProfileId() != ACVUtility.profileIdMap.get( 'System Administrator' ) ) {
                final Set<String> APPROVED_FIELD_NAME_SET = new Set<String>{ 'transport_bill_name__c', 'date_transporter_paid__c',
                                                                // These fields are due to background processes that need to be allowed
                                                            'seller_payment_date__c', 'seller_payment_method__c', 
                                                            'seller_payment_tracking_number__c', 'business_hours_spent_in_queue__c',
                                                            'age_in_days__c', 'send_to_acv__c', 'open_customer_inquiry__c' };
                            // Formula Fields associated to main fields -->   'auction_number__c', 'auction_number_case__c', 'acv_condition_report__c', 'auction_lights__c' };
                final String ERROR_MSG = 'Transportation is Finalized. Please contact a System Administrator if you require changes to this case';

                Map<Id, SObject> filteredNewCaseMap = new Map<Id, SObject>();
                for ( Case caseRecord : (List<Case>) newCaseMap.values() ) {
                    // We don't want to throw an error when first changing the status
                    if ( ( caseRecord.Status == 'Finalized' && oldCaseMap.get( caseRecord.Id ).get( 'Status' ) == 'Finalized' ) || ( caseRecord.Status != 'Finalized' && oldCaseMap.get( caseRecord.Id ).get( 'Status' ) == 'Finalized' ) ) {
                        filteredNewCaseMap.put( caseRecord.Id, caseRecord );
                    }
                }
                if ( !filteredNewCaseMap.isEmpty() ) { 
                    Map<Id, Set<String>> modifiedFieldMap = ACVUtility.getChangedFields( filteredNewCaseMap, oldCaseMap, 'Case' );                
                    for ( SObject caseRecord : filteredNewCaseMap.values() ) {
                        if ( modifiedFieldMap.get( caseRecord.Id ) != null ) {
                            modifiedFieldMap.get( caseRecord.Id ).removeAll( APPROVED_FIELD_NAME_SET );
                            if ( !modifiedFieldMap.get( caseRecord.Id ).isEmpty() ) {
                                caseRecord.addError( ERROR_MSG + ': [Fields Modified:' + String.join( new List<String>( modifiedFieldMap.get( caseRecord.Id ) ), ', ' )  + ']' );
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static Map<Id,Case> filter(Map<Id,Case> newCaseMap){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Map<Id,Case> filteredMap = new Map<Id,Case>();

        for(Case c : newCaseMap.values()){
            if(c.RecordTypeId == arbRecordType){
                filteredMap.put(c.Id,c);
            }
        }

        return filteredMap;
    }

    public static List<Case> filter(List<Case> newCaseList){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Case> filteredList = new List<Case>();

        for(Case c : newCaseList){
            if(c.RecordTypeId == arbRecordType){
                filteredList.add(c);
            }
        }

        return filteredList;
    }

    public static void beforeInsertToggle(){
        beforeInsertProcessed = !beforeInsertProcessed;
    }
    public static void beforeInsertToggle(Boolean foo){
        beforeInsertProcessed = foo;
    }

    public static void afterInsertToggle(){
        afterInsertProcessed = !afterInsertProcessed;
    }
    public static void afterInsertToggle(Boolean foo){
        afterInsertProcessed = foo;
    }

    public static void beforeUpdateToggle(){
        beforeUpdateProcessed = !beforeUpdateProcessed;
    }
    public static void beforeUpdateToggle(Boolean foo){
        beforeUpdateProcessed = foo;
    }

    public static void afterUpdateToggle(){
        afterUpdateProcessed = !afterUpdateProcessed;
    }
    public static void afterUpdateToggle(Boolean foo){
        afterUpdateProcessed = foo;
    }
}