public class FieldHistoryProcess {
    
    public static Map<String, Set<Field_Tracking__mdt>> fieldTrackingMap{
        get{
            if ( fieldTrackingMap == null ) {
                fieldTrackingMap = new Map<String, Set<Field_Tracking__mdt>>();
                for ( Field_Tracking__mdt trackingRecord : [ SELECT Object_Name__c, Field_Name__c, Record_Type_Dev_Name__c, Do_Not_Set_Old_Value__c, Sort_Order__c FROM Field_Tracking__mdt ORDER BY Object_Name__c, Sort_Order__c ] ) {
                    if ( fieldTrackingMap.get( trackingRecord.Object_Name__c) == null ) {
                        fieldTrackingMap.put( trackingRecord.Object_Name__c, new Set<Field_Tracking__mdt>() );
                    }
                    fieldTrackingMap.get( trackingRecord.Object_Name__c ).add( trackingRecord );
                }
            }
            return fieldTrackingMap;
        }
        set;
    }

    public static Id overwriteUserId {
        get {
            if ( overwriteUserId == null ) {
                overwriteUserId = UserInfo.getUserId();
            }
            return overwriteUserId;
        }
        set;
    }

    public static void create( List<SObject> newLst, Map<Id, SObject> oldMap ) {
        List<Field_History__c> fieldHisLst = new List<Field_History__c>();

        if ( newLst != null && !newLst.isEmpty() ) {
            String sObjectAPI = ACVUtility.getSObjectName( newLst[0] );
            for ( SObject record : newLst ) {                
                for ( Field_Tracking__mdt ft : fieldTrackingMap.get( sObjectAPI ) ) {
                    String fieldName = ft.Field_Name__c;
                    String recordType = ft.Record_Type_Dev_Name__c;
                    Boolean setOldValue = !ft.Do_Not_Set_Old_Value__c;
                    
                    Boolean recordTypeMatched = false;
                    if ( recordType != null && ACVUtility.recordTypeCheck( recordType, sObjectAPI, (String)record.get( 'RecordTypeId' ) ))	{
                        recordTypeMatched = true;
                    }
                    
                    if ( ( oldMap != null && record.get( fieldName ) != oldMap.get( record.Id ).get( fieldName ) ) || ( oldMap == null && record.get( fieldName ) != null ) ) {
                        if(recordType == null || (recordType != null && recordTypeMatched))	{
                            Field_History__c newRecord = setIdField( record );
                            newRecord.Field__c = fieldName;
                            newRecord.New_Value__c = string.valueOf(record.get( fieldName ));
                            if ( setOldValue && oldMap != null ) {
                                newRecord.Old_Value__c = string.valueOf(oldMap.get( record.Id ).get( fieldName ));
                            }
                            newRecord.User__c = FieldHistoryProcess.overwriteUserId;
                            fieldHisLst.add( newRecord );
                        }
                    }
                }
            }

            if ( !fieldHisLst.isEmpty() ) {
                insert fieldHisLst;
                
                Set<String> idStringSet = new Set<String>();
                for ( Field_History__c fieldHisRecord : fieldHisLst ) {
                    idStringSet.add( fieldHisRecord.Id );
                }
                //REMOVED FOR COVID TITLES BATCH
                //FieldHistoryProcess.processTime( idStringSet );
            }
        }
    }

    public static Field_History__c setIdField( SObject record ) {
        Field_History__c fieldHisRecord = new Field_History__c();
        
        if ( record.Id.getSobjectType() == Schema.Case.SObjectType ) {
            fieldHisRecord.Case__c = record.Id;
        }
        else if( record.Id.getSobjectType() == Schema.Auction__c.SObjectType ) {
            fieldHisRecord.Auction__c = record.Id;
        }

        fieldHisRecord.Parent_Record__c = record.Id;
        return fieldHisRecord;
    }

    //@future
    //public static void processTime( Set<String> fieldHistoryRecordSet ) {
        //REMOVED BECAUSE COVID
        // String query = 'SELECT ';
        // query += String.join( new List<String>( ACVUtility.getFieldList( 'Field_History__c' ) ), ',' );
        // query += ' FROM Field_History__c WHERE ID IN :fieldHistoryRecordSet';

        // List<Field_History__c> fieldHisLst = (List<Field_History__c>) Database.query( query );
        
        // Set<Id> parentRecordIdSet = new Set<Id>();
        // Set<String> fieldNameSet = new Set<String>();
        // Map<String, Field_History__c> newRecordMap = new Map<String, Field_History__c>();
        // for ( Field_History__c fieldRecord : fieldHisLst ) {
        //     String key = fieldRecord.Parent_Record__c + ':' + fieldRecord.Field__c;
        //     newRecordMap.put( key, fieldRecord );
        //     parentRecordIdSet.add( fieldRecord.Parent_Record__c );
        //     fieldNameSet.add( fieldRecord.Field__c );
        // }

        // List<Field_History__c> pastFieldHistoryLst = [ SELECT Id, Parent_Record__c, Field__c, CreatedDate, Next_Change_Time__c FROM Field_History__c WHERE 
        //                     ( Parent_Record__c IN :parentRecordIdSet )
        //                     AND Field__c IN :fieldNameSet AND Next_Change_Time__c = null ];

        // Map<String, DateTime> checkTimeMap = new Map<String, DateTime>();
        // for ( Field_History__c pastFieldHistoryRec : pastFieldHistoryLst ) {
        //     String key = pastFieldHistoryRec.Parent_Record__c + ':' + pastFieldHistoryRec.Field__c;
        //     Field_History__c newRecord = newRecordMap.get( key );
        //     DateTime comparisonStamp = checkTimeMap.get( key );

        //     if ( newRecord != null ) { 
        //         if ( comparisonStamp == null || ( comparisonStamp != null && pastFieldHistoryRec.CreatedDate > comparisonStamp ) ) {
        //             pastFieldHistoryRec.Next_Change_Time__c = newRecord.CreatedDate;
        //             checkTimeMap.put( key, pastFieldHistoryRec.CreatedDate );
        //         }
        //     }
        // }

        // if ( pastFieldHistoryLst != null && !pastFieldHistoryLst.isEmpty() ) {
        //     update pastFieldHistoryLst;
        // }
    //}
}