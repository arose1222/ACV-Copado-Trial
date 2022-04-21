public class MapsCheckZipcodes {
    
    private static final Pattern ZIP_REGEX_PATTERN = Pattern.compile( '\"\\w+-\\w+\"' );

    // By calling this method, it is assumed there is a valid difference in string length for each record in the list
    // List should be 1:1, like apex triggers are
    // Should not be sent if either new or old record has a blank string
    public static void checkAndClearZipcodes( List<maps__ShapeLayerGeometry__c> oldShapeLayerLst, Map<String, maps__ShapeLayerGeometry__c> newShapeLayerMap ) {        
        Set<String> zipcodeSet = new Set<String>(); // These zips have been removed from a layer

        for ( maps__ShapeLayerGeometry__c shapeLayerGeoRec : oldShapeLayerLst ) {
            String newLayerBody;
            if ( newShapeLayerMap.get( shapeLayerGeoRec.Id ) != null ) {
               newLayerBody = newShapeLayerMap.get( shapeLayerGeoRec.Id ).maps__Geometry__c;
            } else {
                newLayerBody = '';
            }
            Matcher matchStrOldRec = ZIP_REGEX_PATTERN.matcher( shapeLayerGeoRec.maps__Geometry__c );

            // Only continue if the group count is mismatching   
            while( matchStrOldRec.find() ) {
                String currentZipStr = matchStrOldRec.group();
                List<String> splitZipLst = currentZipStr.split( '-' );
                if ( splitZipLst.size() == 2 ) { // Only Progress if zip format is as expected, where zip is 2nd variable
                    if ( ( !String.isBlank( newLayerBody ) && !newLayerBody.contains( splitZipLst[1] ) ) || String.isBlank( newLayerBody ) ) {
                        zipcodeSet.add( splitZipLst[1].replace( '\"', '' ) ); // Remove excess quotes to leave just a pure zipcode
                    }
                }
            }
        }
        clearAccounts( zipcodeSet );
    }

    public static void clearAccounts( Set<String> zipcodeSearchSet ) {
        if ( zipcodeSearchSet != null && !zipcodeSearchSet.isEmpty() ) { // Now get Accounts and Clear all fields related to Maps, for batch to fill in
            List<Account> acctsToBlankFieldLst = [ SELECT Id, Maps_TM_Assignment_Rule__c, maps__AssignmentRule__c, Maps_Title_Admin_Assignment_Rule__c, Maps_Title_Consultant_Assignment_Rule__c,
                                                        Maps_Title_Specialist_Assignment_Rule__c
                                                    FROM Account WHERE BillingPostalCode IN :zipcodeSearchSet ];
            if ( !acctsToBlankFieldLst.isEmpty() ) {
                 for ( Account acctRec : acctsToBlankFieldLst ) {
                    acctRec.Maps_TM_Assignment_Rule__c = null;
                    acctRec.maps__AssignmentRule__c = null;
                    acctRec.Maps_Title_Admin_Assignment_Rule__c = null;
                    acctRec.Maps_Title_Consultant_Assignment_Rule__c = null;
                    acctRec.Maps_Title_Specialist_Assignment_Rule__c = null;
                }

                update acctsToBlankFieldLst;
            }
        }
    }

    public static Set<String> getZipsFromAssignments( List<maps__AssignmentRule__c> assignmentRuleLst ) {
        Set<Id> shapeLayerIdSet = new Set<Id>();
        for ( maps__AssignmentRule__c assignRuleRec : assignmentRuleLst ) {
            shapeLayerIdSet.add( assignRuleRec.maps__ShapeLayer__c );
        }

        if ( !shapeLayerIdSet.isEmpty() ) {
            List<maps__ShapeLayerGeometry__c> shapeLayerGeoLst = [ SELECT Id, maps__Geometry__c FROM maps__ShapeLayerGeometry__c WHERE maps__ShapeLayer__c IN :shapeLayerIdSet ];

            if ( !shapeLayerGeoLst.isEmpty() ) {
                checkAndClearZipcodes( shapeLayerGeoLst, new Map<String, maps__ShapeLayerGeometry__c>() );
            }
        }

        return null;
    }
}