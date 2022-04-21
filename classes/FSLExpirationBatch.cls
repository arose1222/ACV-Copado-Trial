global class FSLExpirationBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // Query Vars
    final static String TRUEFRAME_METADATA_NAME = 'Trueframe - FSL Expiration Batch Length';
    final static String TRUEFRAME_WORKTYPE_NAME = 'True 360';
    final static Salesforce_Setting__mdt TRUEFRAME_METADATA = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = :TRUEFRAME_METADATA_NAME LIMIT 1 ];
    final public static WorkType TRUEFRAME_360_WT = [ SELECT Id FROM WorkType WHERE Name = :TRUEFRAME_WORKTYPE_NAME ];
    final static String STATUS_CHECK = 'New';

    // Execute Vars
    final static String EXPIRED_STATUS = 'Expired';

    // Stateful Var for Logging Splunk in Finish Method
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    public static DateTime timeNow {
        get {
            if ( timeNow == null ) {
                Integer dateRange = ( Integer.valueOf( TRUEFRAME_METADATA.Value__c ) ) * -1; // negate the value for query
                timeNow = System.now().addDays( dateRange );
            }
            return timeNow;
        }
        set;
    }
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String query;
        try {
            final Id TRUEFRAME_360_WTID = TRUEFRAME_360_WT.Id;
            DateTime currentTime = timeNow;

            query = 'SELECT Id';
            query += ' FROM WorkOrderLineItem';
            query += ' WHERE CreatedDate <= :currentTime AND WorkTypeId = :TRUEFRAME_360_WTID AND Status = :STATUS_CHECK';
        } catch ( exception e ) {
            // Splunk Log
            createErrorLog(e);
        }

        return Database.getQueryLocator( query );
    }

    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        Set<String> errorStrSet = new Set<String>();

        SavePoint dbSave = Database.setSavePoint();
        Set<Id> scopeIdSet = new Set<Id>();
        for ( SObject scopeRec : scope ) {
            scopeIdSet.add( scopeRec.Id );
        }

        // Get updated fields, as some records might have already been processed in previous methods
        List<WorkOrderLineItem> woliLst = [ SELECT Id, Status, WorkOrderId, WorkOrder.Status 
                                            FROM WorkOrderLineItem WHERE Id IN :scopeIdSet AND Status != :EXPIRED_STATUS 
                                            AND WorkOrder.Status != :EXPIRED_STATUS AND Status = 'New'
                                            AND WorkType.Id = :TRUEFRAME_360_WT.Id AND CreatedDate <= :timeNow ];                                  
        BatchUtilityClass.BatchReturn loggingInfo = new BatchUtilityClass.BatchReturn( FALSE );

        if ( woliLst != null && !woliLst.isEmpty() ) {
            Set<String> successfulSet = new Set<String>();

            Set<Id> woIdSet = new Set<Id>();
            Map<Id, WorkOrder> expiredWOMap = new Map<Id, WorkOrder>();
            for ( WorkOrderLineItem woli : woliLst ) {
                // Status is New, Parent has yet to be processed
                woli.Status = EXPIRED_STATUS;
                
                if ( expiredWOMap.get( woli.WorkOrderId ) == null ) {
                    expiredWOMap.put( 
                        woli.WorkOrderId,
                        new WorkOrder(
                            Id = woli.WorkOrderId,
                            Status = EXPIRED_STATUS
                        )
                    );
                }

                // Add Parent to ferry child records later
                woIdSet.add( woli.WorkOrderId );
            }
            List<Database.UpsertResult> dbResultLst = Database.upsert( woliLst, FALSE );

            Boolean rollbackCheck = FALSE; 
            Set<Id> woCheckIdSet = new Set<Id>();
            for ( Integer index = 0; index < woliLst.size(); index++ ) {
                Database.UpsertResult dbResult = dbResultLst[index];
                WorkOrderLineItem woliRec = woliLst[index];

                if ( dbResult.isSuccess() ) {
                    woCheckIdSet.add( woliRec.WorkOrderId );
                    successfulSet.add( woliRec.Id );
                } else {
                    loggingInfo.errorReturnLst.add( JSON.serialize( woliRec ) );
                    loggingInfo.errorMessageLst.add( dbResult.getErrors()[0].message );
                    rollbackCheck = TRUE;
                }
            }

            dbResultLst = Database.upsert( expiredWOMap.values(), FALSE );
       
            for ( Integer index = 0; index < expiredWOMap.size(); index++ ) {
                Database.UpsertResult dbResult = dbResultLst[index];
                WorkOrder woRec = expiredWOMap.values()[index];

                if ( dbResult.isSuccess() ) {
                    successfulSet.add( woRec.Id );
                } else {
                    loggingInfo.errorReturnLst.add( JSON.serialize( woRec.Id ) );
                    loggingInfo.errorMessageLst.add( dbResult.getErrors()[0].message );
                    rollbackCheck = TRUE;
                }
            }

            if ( rollbackCheck ) {
                Database.rollback( dbSave ); 
            }       

            if ( woCheckIdSet != null && !woCheckIdSet.isEmpty() ) {
                BatchUtilityClass.BatchReturn returnCheck = cloneLineItemsOnExpiredWOs( woCheckIdSet );

                if ( returnCheck.successfulReturnSet.isEmpty() ) {
                    returnCheck.successfulReturnSet = successfulSet;
                }
                loggingInfo.combine( returnCheck );       

                if ( loggingInfo.hasErrors || returnInfo.hasErrors ) {
                    Database.rollback( dbSave );
                }
            } else { // Add Return records from above if we're not calling the clone method
                returnInfo.successfulReturnSet = successfulSet;
            }          

            returnInfo.combine( loggingInfo );                  
        }
    }

    global void finish( Database.BatchableContext BC ) {
        // Splunk Log
        BatchUtilityClass.createBatchLog( 
            returnInfo, BC.getJobId(), 'FSLExpirationBatch', ACVUtility.currentLineNumber(), 
            'FSLExpirationBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'WorkOrder', 'WorkOrderLineItem' }
        );
    }

    public override void executeScheduledLogic() {
        FSLExpirationBatch fslEBatch = new FSLExpirationBatch();
        Database.executeBatch( fslEBatch, 200 );
    }

    global static BatchUtilityClass.BatchReturn cloneLineItemsOnExpiredWOs( Set<Id> woIdSet ) {
        BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

        // These are for error returns
        List<Id> oldWOLst = new List<Id>();
        List<Id> oldWOLILst = new List<Id>();

        if ( woIdSet != null && !woIdSet.isEmpty() ) {

            List<WorkOrderLineItem> woliLst = [ SELECT Id, WorkOrderId, Stock_Number__c, Origin__c, Street, City, State, PostalCode, Country, vin__c, 
                                                year__c, make__c, model__c, color__c, Reserve_Price__c, Title_Status__c, Title_with_Dealer__c, 
                                                Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, 
                                                External_Record_guid__c, Due_Date__c, Status, Transport_Status__c, Job_Notes__c, Dealership_Name__c, Earliest_Start_Date__c, External_Invoice_Id__c
                                                FROM WorkOrderLineItem WHERE WorkOrderId IN :woIdSet AND Status = :STATUS_CHECK ];
            // Organize Results
            Map<Id, List<WorkOrderLineItem>> woToLineItemMap = new Map<Id, List<WorkOrderLineItem>>();
            for ( WorkOrderLineItem woli : woliLst ) {
                if ( woToLineItemMap.get( woli.WorkOrderId ) == null ) {
                    woToLineItemMap.put( woli.WorkOrderId, new List<WorkOrderLineItem>() );
                }
                woToLineItemMap.get( woli.WorkOrderId ).add( woli );
            }       

            List<WorkOrder> woRecLst = [ SELECT Id, AccountId, ServiceTerritoryId, Priority, WorkTypeId, Origin__c, Duration, 
                                        DurationType, Street, City, PostalCode, State, Country, Subject, Description, 
                                        Launch_Term_Details__c, Vehicle_Launch_Terms__c
                                        FROM WorkOrder WHERE Id IN :woToLineItemMap.keyset() ];
            // Make new Work Order first, then make line items for each
            List<WorkOrder> clonedWOLst = new List<WorkOrder>();
            for ( WorkOrder woRec : woRecLst ) {
                WorkOrder newWORec = woRec.clone( FALSE, TRUE, TRUE, FALSE );
                oldWOLst.add( woRec.Id );
                clonedWOLst.add( newWORec );
            }

            List<Database.SaveResult> dbResultLst = Database.insert( clonedWOLst, FALSE );   
            Map<Id, Id> expiredWOIdMap = new Map<Id, Id>();
            for ( Integer index = 0; index < clonedWOLst.size(); index++ ) {
                // clonedWOLst is made one to one from woRecLst, so order is guaranteed
                Database.SaveResult dbResult = dbResultLst[index];
                WorkOrder clonedWO = clonedWOLst[index];
                WorkOrder expiredWO = woRecLst[index];

                if ( dbResult.isSuccess() ) {
                    expiredWOIdMap.put( expiredWO.Id, clonedWO.Id );
                } else { 
                    // Add for Error Logging in Splunk
                    returnInfo.hasErrors = TRUE;
                    returnInfo.errorReturnLst.add( JSON.serialize( clonedWOLst[index] ) );
                    returnInfo.errorMessageLst.add( dbResult.getErrors()[0].getMessage() );
                }
            }

            if ( expiredWOIdMap != null && !expiredWOIdMap.isEmpty() ) {
                List<WorkOrderLineItem> clonedWOLILst = new List<WorkOrderLineItem>();
                List<WorkOrderLineItem> deleteWOLILst = new List<WorkOrderLineItem>();

                for ( Id expiredWOId : woToLineItemMap.keyset() ) {
                    if ( expiredWOIdMap.get( expiredWOId ) != null ) {
                        Id newClonedWoId = expiredWOIdMap.get( expiredWOId );
                        // Clone Line Item                 
                        for ( WorkOrderLineItem woliToClone : woToLineItemMap.get( expiredWOId ) ) {
                            WorkOrderLineItem clonedWOLI = woliToClone.clone( FALSE, TRUE, TRUE, FALSE );
                            clonedWOLI.WorkOrderId = newClonedWoId;
                            clonedWOLILst.add( clonedWOLI );

                            oldWOLILst.add( woliToClone.Id );
                            
                            deleteWOLILst.add( woliToClone );
                        }
                    }
                }           

                // Get rid of dupes
                try {
                    delete deleteWOLILst;
                } catch ( exception e ) {
                    returnInfo.hasErrors = TRUE;
                    createErrorLog( e );
                }

                List<Database.SaveResult> dbResultLst2 = Database.insert( clonedWOLILst, FALSE );             

                Set<String> returnWOLIIdSet = new Set<String>();
                for ( Integer index = 0; index < clonedWOLILst.size(); index++ ) {
                    // clonedWOLst is made one to one from woRecLst, so order is guaranteed
                    Database.SaveResult dbResult = dbResultLst2[index];
                    WorkOrderLineItem clonedWOLI = clonedWOLILst[index];
    
                    if ( dbResult.isSuccess() ) {
                        returnWOLIIdSet.add( clonedWOLI.Id );
                    } else { 
                        // Add for Error Logging in Splunk
                        returnInfo.hasErrors = TRUE;
                        returnInfo.errorReturnLst.add( JSON.serialize( clonedWOLILst[index] ) );
                        returnInfo.errorMessageLst.add( dbResult.getErrors()[0].getMessage() );
                    }
                }

                returnInfo.successfulReturnSet = returnWOLIIdSet;
            }
        }

        return returnInfo;
    }

    global static void createErrorLog( Exception e ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        infoLog.location = 'FSLExpirationBatch:' + e.getLineNumber();
        infoLog.message = e.getMessage();
        infoLog.stackTrace = e.getStackTraceString();
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'FSLExpirationBatch';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES };
        
        SplunkHelper.buildandProcessLog( infoLog );
    }
}