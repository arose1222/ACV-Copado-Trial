public class CaseTitlesProcesses {
    // private static boolean beforeInsertProcessed = false;
    // private static boolean afterInsertProcessed = false;
    // private static boolean beforeUpdateProcessed = false;
    // private static boolean afterUpdateProcessed = false;

    // public final static String TITLE_CLERK = 'Title Clerk';

    // public static void beforeInsert(List<Case> newCaseList){
    //     if(beforeInsertProcessed == false){
    //         List<Case> filteredList = filter(newCaseList);

    //         if(filteredList.size() > 0){
    //             beforeInsertProcessed = true;
    //             stampAddressInfoOnCase(newCaseList);
    //             setTitleClerkEmails(filteredList, null);
    //             System.debug('Before Insert processes for Titles Cases executed');
    //         }
    //     } else{
    //         System.debug('Recursion on Before Insert on Titles Cases blocked. Use TitlesCaseProcesses.beforeInsertToggle() to step in.');
    //     }        
    // }

    // public static void afterInsert(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    //     if(afterInsertProcessed == false){
    //         Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
    //         if(filteredMap.size() > 0){
    //             FieldHistoryProcess.create( newCaseMap.values(), oldCaseMap );
    //             afterInsertProcessed = true;
    //             System.debug('After Update processes for Titles Cases executed');
    //         }

    //     } else{
    //         System.debug('Recursion on After Insert on Titles Cases blocked. Use TitlesCaseProcesses.afterInsertToggle() to step in.');
    //     }
    // }    

    // public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    //     if(beforeUpdateProcessed == false){
    //         Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
    //         if(filteredMap.size() > 0){
    //             beforeUpdateProcessed = true;
    //             stampAddressInfoOnCase(newCaseMap.values());
    //             dataUpdateAutomation(filteredMap, (Map<Id,Case>)oldCaseMap);
    //             updateStatusOnAuction(filteredMap, (Map<id,Case>)oldCaseMap);
    //             setTitleClerkEmails(filteredMap.values(), (Map<id,Case>)oldCaseMap);
    //             setTitleSender(filteredMap.values(), (Map<id,Case>)oldCaseMap);
    //             System.debug('Before Update processes for Titles Cases executed.');
    //         }
    //     } else{
    //         System.debug('Recursion on Before Update on Titles Cases blocked. Use TitlesCaseProcesses.beforeUpdateToggle() to step in.');
    //     }
    // }

    // public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    //     if(afterUpdateProcessed == false){
    //         Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
    //         if(filteredMap.size() > 0){
    //             FieldHistoryProcess.create( newCaseMap.values(), oldCaseMap );
    //             afterUpdateProcessed = true;
    //             System.debug('After Update processes for Titles Cases executed');
    //         }
    //     } else{
    //         System.debug('Recursion on Before Update on Titles Cases blocked. Use TitlesCaseProcesses.afterUpdateToggle() to step in.');
    //     }
    // }

    // public static void stampAddressInfoOnCase(List<Case> newCaseList){
    //     List<Id> dealershipIdList = new List<Id>();
    //     for(case c : newCaseList){
    //         if(c.AccountId != null){
    //             dealershipIdList.add(c.AccountId);
    //         }
    //     }

    //     Map<id,Account> dealerMap = new Map<Id, Account>([Select Id, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone from Account where id in :dealershipIdList]);

    //     for(case c :newCaseList){
    //         if(c.AccountId != null && dealerMap.get(c.AccountId) != null){
    //             if(c.Default_Delivery_Address__c == null){
    //                 c.Default_Delivery_Address__c = dealerMap.get(c.AccountId).BillingStreet;
    //             }
    //             if(c.Default_Delivery_City__c == null){
    //                 c.Default_Delivery_City__c = dealerMap.get(c.AccountId).BillingCity;
    //             }
    //             if(c.Default_Delivery_Country__c == null){
    //                 c.Default_Delivery_Country__c = dealerMap.get(c.AccountId).BillingCountry;
    //             }
    //             if(c.Default_Delivery_Postal_Code__c == null){
    //                 c.Default_Delivery_Postal_Code__c = dealerMap.get(c.AccountId).BillingPostalCode;
    //             }
    //             if(c.Default_Delivery_State__c == null){
    //                 c.Default_Delivery_State__c = dealerMap.get(c.AccountId).BillingState;
    //             }
    //         }
    //     }
    // }

    /** dataUpdateAutomation
     *   GIVEN A Titles Case with status of 'Working' 
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Owner Id to User Id
     *
     *   GIVEN A Titles Case with status of 'Received'
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Title Received Date to Today
     *
     *   GIVEN A Titles Case with status of 'Sent'
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Title Sent Date to Today
     *   
     *
     * @param   newCaseMap
     * @param   oldCaseMap  
     */
    // public static void dataUpdateAutomation(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
    //     List<Case> caseList = new List<Case>();
    //     Map<Id,Profile> userProfiles = new Map<Id,Profile>([SELECT Id, Name FROM Profile]);
    //     for(Case c : newCaseMap.values()){
    //         if((c.Status == 'Received' || c.Status == 'Working' || c.Status == 'Sent') && c.Status != oldCaseMap.get(c.Id).Status && userProfiles.get(UserInfo.getProfileId()).Name != 'System Administrator'){
    //             caseList.add(c);
    //         }
    //     }

    //     if(caseList.size() == 0){
    //         return;
    //     }

    //     for(Case c : caseList){
    //         if(c.Status == 'Working'){
    //             c.OwnerId = UserInfo.getUserId();
    //         } else if(c.Status == 'Received'){
    //             c.Title_Received_Date__c = Date.Today();
    //         } else if(c.Status == 'Sent'){
    //             c.Title_Sent_Date__c = Date.Today();
    //         }
    //     }
    // }

    /**
     * updateStatusOnAuction 
     *  GIVEN A Titles Case
     *  WHEN The Status changes
     *  THEN save the previous status to the Auction it relates to 
     *
     * @param  newMap
     * @param  oldMap
     */
    // public static void updateStatusOnAuction(Map<Id,Case> newMap, Map<Id,Case> oldMap){
    //     List<Auction__c> auctionUpdateList = new List<Auction__c>();
    //     for(Case c :newMap.values()){
    //         if(c.Auction_Number__c != null && c.status != oldMap.get(c.id).status){
    //             auctionUpdateList.add(new Auction__c(id = c.Auction_Number__c, Title_Status_1__c = oldMap.get(c.id).status));
    //         }
    //     }

    //     if(auctionUpdateList.size() > 0){
    //         update auctionUpdateList;
    //     }
    // }

    /**
     * setTitleSender 
     *  GIVEN A Titles Case
     *  WHEN the status is updated to sent and no title scanner
     *  THEN update the title scanner lookup field on Case to the current user
     *
     * @param  newLst
     * @param  oldMap
     */
    // public static void setTitleSender(List<Case> newLst, Map<Id,Case> oldMap){
    //     for ( Case caseRecord : newLst ) {
    //         if ( caseRecord.Status == 'Sent' && caseRecord.Status != oldMap.get( caseRecord.Id ).Status && caseRecord.Title_Scanner__c == null ) {
    //             caseRecord.Title_Scanner__c = UserInfo.getUserId();
    //         }
    //     }
    // }

    /**
     * setTitleClerkEmails 
     *  GIVEN A Titles Case
     *  WHEN A Seller Account is changed
     *  THEN update the Clerk email fields to reflect the new Account
     *
     * @param  newLst
     * @param  oldMap
     */
    // public static void setTitleClerkEmails(List<Case> newLst, Map<Id,Case> oldMap){
    //     Map<Id, List<Case>> acctIdToCaseMap = new Map<Id, List<Case>>();

    //     for(Case c : newLst ){
    //         // Seller Email Logic - If Seller changed, update email clerk field
    //         //if( ( oldMap != null && c.Seller_Dealership__c != oldMap.get(c.id).Seller_Dealership__c ) || ( oldMap == null && c.Seller_Dealership__c != null ) ) {
    //             if ( acctIdToCaseMap.get( c.Seller_Dealership__c ) == null ) {
    //                 acctIdToCaseMap.put( c.Seller_Dealership__c, new List<Case>() );
    //             }
    //             acctIdToCaseMap.get( c.Seller_Dealership__c ).add( c );
    //         /*} else*/ if ( oldMap != null && c.Seller_Dealership__c == null && c.Seller_Dealership__c != oldMap.get(c.id).Seller_Dealership__c ) {
    //             c.Seller_Title_Clerk_Email__c = null;
    //         }
    //     }

    //     if ( !acctIdToCaseMap.isEmpty() ) {
    //         for ( Contact conRecord : [ SELECT Id, AccountId, Email FROM Contact WHERE Title = :CaseTitlesProcesses.TITLE_CLERK AND Active__c = TRUE AND AccountId IN :acctIdToCaseMap.keySet() ORDER BY ACV_Updated__c DESC ] ) {
    //             if ( acctIdToCaseMap.get( conRecord.AccountId ) != null ) {
    //                 for ( Case caseRecord : acctIdToCaseMap.get( conRecord.AccountId ) ) {
    //                     caseRecord.Seller_Title_Clerk_Email__c = conRecord.Email;
    //                 }
    //             }
    //             // We order results by most recent first, remove the cases from the map once processed
    //             acctIdToCaseMap.remove( conRecord.AccountId );
    //         }
    //         if ( !acctIdToCaseMap.isEmpty() ) { // For anything left, set the values to null
    //             for ( Id acctId : acctIdToCaseMap.keySet() ) {
    //                 for ( Case caseRecord : acctIdToCaseMap.get( acctId ) ) {
    //                     caseRecord.Seller_Title_Clerk_Email__c = null;
    //                 }
    //             }
    //         }
    //     }
    // }

    // public static Map<Id,Case> filter(Map<Id,Case> newCaseMap){
    //     Id titleRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
    //     Map<Id,Case> filteredMap = new Map<Id,Case>();

    //     for(Case c : newCaseMap.values()){
    //         if(c.RecordTypeId == titleRecordType){
    //             filteredMap.put(c.Id,c);
    //         }
    //     }

    //     return filteredMap;
    // }

    // public static List<Case> filter(List<Case> newCaseList){
    //     Id titleRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
    //     List<Case> filteredList = new List<Case>();

    //     for(Case c : newCaseList){
    //         if(c.RecordTypeId == titleRecordType){
    //             filteredList.add(c);
    //         }
    //     }

    //     return filteredList;
    // }

    // public static void beforeInsertToggle(){
    //     beforeInsertProcessed = !beforeInsertProcessed;
    // }
    // public static void beforeInsertToggle(Boolean foo){
    //     beforeInsertProcessed = foo;
    // }

    // public static void afterInsertToggle(){
    //     afterInsertProcessed = !afterInsertProcessed;
    // }
    // public static void afterInsertToggle(Boolean foo){
    //     afterInsertProcessed = foo;
    // }

    // public static void beforeUpdateToggle(){
    //     beforeUpdateProcessed = !beforeUpdateProcessed;
    // }
    // public static void beforeUpdateToggle(Boolean foo){
    //     beforeUpdateProcessed = foo;
    // }

    // public static void afterUpdateToggle(){
    //     afterUpdateProcessed = !afterUpdateProcessed;
    // }
    // public static void afterUpdateToggle(Boolean foo){
    //     afterUpdateProcessed = foo;
    // }
}