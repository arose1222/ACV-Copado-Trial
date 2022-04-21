/**
 * Generic Engine class capable of taking a set of records, from any object, and searching the Apex Sharing Entity Custom Metadata to automatically create sharing records
 * @author Gerald McEvoy
 * @since 2/25/21
 */
public class ApexSharingEngine {
    private static String USER_ENUM_AS_STRING = 'User';
    private static String GROUP_ENUM_AS_STRING = 'Public Group';

    /**
     * Map that handles the consuming the Apex Sharing Rule data, sorting each rule into a map by SObject API Name
     */
    private static Map<String, List<Apex_Sharing_Rule__mdt>> sharingRuleMap {
        get {
            if ( sharingRuleMap == null ) {
                sharingRuleMap = new Map<String, List<Apex_Sharing_Rule__mdt>>();
                for ( Apex_Sharing_Rule__mdt apr : [ SELECT Field_Name__c, Value__c, Object_API_Name__c, Operation__c,
                                                        ( SELECT Name_of_Entity__c, Type_of_Entity__c, Access_Level__c, Sharing_Cause__c FROM Apex_Sharing_Entities__r
                                                        WHERE Active__c = TRUE ) 
                                                        FROM Apex_Sharing_Rule__mdt
                                                        WHERE Active__c = TRUE ] ) 
                {
                    if ( sharingRuleMap.get( apr.Object_API_Name__c ) == null ) {
                        sharingRuleMap.put( apr.Object_API_Name__c, new List<Apex_Sharing_Rule__mdt>() );
                    }
                    sharingRuleMap.get( apr.Object_API_Name__c).add( apr );
                }
            }
            return sharingRuleMap;
        }
        set;
    }

    /**
     * The method will take a list of objects to check for any rule custom criteria matches, then it will create the Sharing Records and return to the caller to insert
     * @param providedObjLst A list of SObjects, where each one is the most up to date record to check against custom sharing rule criteria
     * @return A list of Sharing Records, for the provided object, that are ready to be saved to the database, but not yet committed
     */
    public static List<SObject> identifyRules( List<SObject> providedObjLst ) {
        List<SObject> returnLst = new List<SObject>();
        if ( providedObjLst != null && !providedObjLst.isEmpty() ) {
            // Provided Object's Data
            SObjectType objectType = providedObjLst[0].Id.getSobjectType();
            DescribeSObjectResult objData = objectType.getDescribe();
            List<Apex_Sharing_Rule__mdt> sharingRuleLst = sharingRuleMap.get( objData.getName() );

            // Gather up Data for User/Group Ids and Organize it
            Map<String, Id> userOrGroupIdMap = new Map<String, Id>();
            Set<String> userNameSet = new Set<String>();
            Set<String> groupNameSet = new Set<String>();
            if ( sharingRuleLst != null ) {
                for ( Apex_Sharing_Rule__mdt shareRule : sharingRuleLst ) {
                    for ( Apex_Sharing_Entity__mdt entityData : shareRule.Apex_Sharing_Entities__r ) {
                        if ( entityData.Type_of_Entity__c == USER_ENUM_AS_STRING ) {
                            userNameSet.add( entityData.Name_of_Entity__c );
                        } else if ( entityData.Type_of_Entity__c == GROUP_ENUM_AS_STRING ) {
                            groupNameSet.add( entityData.Name_Of_Entity__c );
                        }
                    }
                }

                // Getting all User Data, if any
                if ( !userNameSet.isEmpty() ) {
                    for ( User u : [ SELECT Id, Name FROM User WHERE Name IN :userNameSet ] ) {
                        userOrGroupIdMap.put( u.Name, u.Id );
                    }
                }
                // Getting all Group data, if any
                if ( !groupNameSet.isEmpty() ) {
                    for ( Group g : [ SELECT Id, Name FROM Group WHERE Name IN :groupNameSet ] ) {
                        userOrGroupIdMap.put( g.Name, g.Id );
                    }
                }

                /**
                 * If Sharing Rules Exist
                 * - For each of the provided SObjects to this class
                 * -- For each Apex Sharing Rule, defined in custom metadata, for this object type
                 * --- Check what Operation we are using and use the respected function
                 * ---- See if the conditions match, ...
                 * ----- If so, put the SObject Id in a map of Id to list of SharingUtility.SharingDefintiions wrapper records
                 */
                if ( sharingRuleLst != null && !sharingRuleLst.isEmpty() ) {
                    Map<Id, List<SharingUtility.SharingDefinition>> recToSharingRecIdMap = new Map<Id, List<SharingUtility.SharingDefinition>>();
                    for ( SObject providedObj : providedObjLst ) {
                        for ( Apex_Sharing_Rule__mdt ruleRec : sharingRuleLst ) {
                            Boolean createSharingDefinitionFlag = FALSE;
                            String ruleValue = ruleRec.Value__c.replace( '%%', ' ' ); // Replace Special Character for Required String for the sake of comparing 
                            // Check Operation before making a Flag
                            if ( providedObj.get( ruleRec.Field_Name__c ) != null ) {
                                switch on ruleRec.Operation__c {
                                    when 'Equals' {
                                        if ( providedObj.get( ruleRec.Field_Name__c ) == ruleValue ) {
                                            createSharingDefinitionFlag = TRUE;
                                        }
                                    }
                                    when 'Contains' {
                                        if ( ( (String) providedObj.get( ruleRec.Field_Name__c ) ).contains( ruleValue ) ) {
                                            createSharingDefinitionFlag = TRUE;
                                        }
                                    }
                                    when 'Starts With' {
                                        if ( ( (String) providedObj.get( ruleRec.Field_Name__c ) ).startsWith( ruleValue ) ) {
                                            createSharingDefinitionFlag = TRUE;
                                        }
                                    } when else {} // Don't do anything if no condition it reached
                                }     
                            }                  

                            if ( createSharingDefinitionFlag ) {
                                if ( recToSharingRecIdMap.get( providedObj.Id ) == null ) {
                                    recToSharingRecIdMap.put( providedObj.Id, new List<SharingUtility.SharingDefinition>() );
                                }
                                for ( Apex_Sharing_Entity__mdt sharingEntity : ruleRec.Apex_Sharing_Entities__r ) {                               
                                    if ( userOrGroupIdMap.get( sharingEntity.Name_of_Entity__c ) != null ) {
                                        recToSharingRecIdMap.get( providedObj.Id ).add( new SharingUtility.SharingDefinition( 
                                            userOrGroupIdMap.get( sharingEntity.Name_of_Entity__c ),
                                            sharingEntity.Access_Level__c,
                                            sharingEntity.Sharing_Cause__c
                                        ) );
                                    }
                                }
                            }
                        }
                    }

                    // Call the SharingUtility method to create the actual Sharing Records. Will return as SObjects
                    returnLst.addAll( SharingUtility.createSharingRecords( objectType, recToSharingRecIdMap ) );
                }
            }
        }
        return returnLst;
    }
}