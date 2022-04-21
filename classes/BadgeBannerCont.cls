/**
 * This class holds the logic for creating badges on record pages
 * @author James Andre LaCour
 */
public class BadgeBannerCont {
    /****************Class Variables**********************/
    @TestVisible private static List<Badge__mdt> testBadgeList = new List<Badge__mdt>();    //Must be used for Tests
    /****************Helper Methods***********************/
    /**
     * runs on intiailzation on BadgeBannerCont
     * @param recordId the recordId of the page the component is currently on
     * @return JSON.serialized string of the Return Wrapper
     */
    @AuraEnabled
    public static string getBadges( String recordId ){
        ReturnWrapper rw = new ReturnWrapper();
        if( String.isNotBlank(recordId) ){
            Id thisRecordId = Id.valueOf(recordId);
            String sObjType = String.valueOf( thisRecordId.getSobjectType() );
            Map<Id,Badge__mdt> badgesMap = new Map<Id,Badge__mdt>([ SELECT Id, DeveloperName, Label, Criteria_Logic_Equation__c, Class_Name__c, ACV_Preset_Colors__c, Background_Color__c, Text_Color__c,
                                                (SELECT Id, Field_Api_Path__c, Operator__c, Value__c FROM Criteria_Line_Items__r )
                                            FROM Badge__mdt WHERE Object__c = :sObjType AND Active__c = True ]);
            // List<String> fieldList = new List<String>();
            // List<Badge__mdt> genericCriteriaBadges = new List<Badge__mdt>();
            List<Badge__mdt> badgesToIterate = Test.isRunningTest() ? testBadgeList : badgesMap.values();   // Test classes have to set there metadata 
            for( Badge__mdt badge : badgesToIterate ){
                if( String.isNotBlank(badge.Class_Name__c) ){
                    Type badgeApexLogic = Type.forName( '', badge.Class_Name__c );
                    if ( badgeApexLogic == null ) continue;
                    if( ((BadgeBannerInterface)badgeApexLogic.newInstance()).checkLogic( badge.developerName, thisRecordId) ) rw.badgeList.add(badge);
                }else if( String.isNotBlank( badge.Criteria_Logic_Equation__c ) ){
                    // genericCriteriaBadges.add( badge );
                }
            }
            
            // if( genericCriteriaBadges.size() > 0 ){
            //     Set<String> fieldApiSet = new Set<String>();
            //     List<Badge__mdt> eligibleCriteraBadges = new List<Badge__mdt>();
            //     for( Badge__mdt badge : genericCriteriaBadges ){
            //         if( badgesMap.get(badge.Id).Criteria_Line_Items__r.size() == 0 ) continue;
            //         for( Criteria_Line_Item__mdt cli : badgesMap.get(badge.Id).Criteria_Line_Items__r ){
            //             if( !fieldApiSet.contains(cli.Field_Api_Path__c) ) fieldApiSet.add( cli.Field_Api_Path__c );
            //         }
            //         eligibleCriteraBadges.add(badge);
            //     }
            //     if( eligibleCriteraBadges.size() > 0 ){
            //         String queryString = 'SELECT ' + String.join(new List<String>(fieldApiSet), ',') + ' FROM ' + sObjType + ' WHERE Id =\'' + recordId + '\'';
            //         List<SObject> thisSObj = Database.query(queryString);
            //         for( Badge__mdt badge : eligibleCriteraBadges ){
                        
            //             for( Criteria_Line_Item__mdt cli : badgesMap.get(badge.Id).Criteria_Line_Items__r ){
                            
            //             }
            //         }
            //     }
                // Query Child Criteria_Line_Item__mdt to get field list
                // and preform logic
            // }
        }
        return JSON.serialize(rw);
    }
    // public static Boolean check( List<Criteria_Line_Item__mdt> cliList, SObject thisRecord, String logicEquation ){
    //     Boolean eligibleBadge = true;
    //     for( Criteria_line_Item__mdt cli : cliList ){
    //         switch on cli.Operator__c {
    //             when '='{
    //                 eligibleBadge = thisRecord.get(cli.Field_Api_Path__c) == cli.Value__c;
    //             }
    //             when '!='{
    //                 eligibleBadge = thisRecord.get(cli.Field_Api_Path__c) != cli.Value__c;
    //             }
                
    //         }
    //         if( !eligibleBadge ) break;
    //     }
    //     return eligibleBadge;
    // }
    /****************Inner Classes************************/
    public class ReturnWrapper{
        public List<Badge__mdt> badgeList;
        public ReturnWrapper(){
            badgeList = new List<Badge__mdt>();
        }
    }
}