@IsTest
public class MapsClearProcessingTest {
    @IsTest
    static void changeAccountBillingPostalCode() {
        Account acct = TestUtility.createAccount();
        acct.BillingPostalCode = '14209';
        insert acct;

        acct = [ SELECT Id, maps__AssignmentRule__c, BillingPostalCode FROM Account WHERE Id = :acct.Id LIMIT 1 ];

        System.assertEquals( '14209', acct.BillingPostalCode, 'The Billing Postal Code was not as expected' );

        Test.startTest();

        acct.BillingPostalCode = '44103';
        update acct;

        Test.stopTest();

        acct = [ SELECT Id, maps__AssignmentRule__c, BillingPostalCode FROM Account WHERE Id = :acct.Id LIMIT 1 ];

        System.assertEquals( '44103', acct.BillingPostalCode, 'The Billing Postal Code was not as expected' );
        System.assertEquals( null, acct.maps__AssignmentRule__c, 'The Maps Assignment Rule field was not blanked out' );
    }

    @IsTest
    static void changeLeadPostalCode() {
        Lead leadRec = TestUtility.createLead();
        leadRec.PostalCode = '14226';
        insert leadRec;

        leadRec = [ SELECT Id, maps__AssignmentRule__c, PostalCode FROM Lead WHERE Id = :leadRec.Id LIMIT 1 ];

        System.assertEquals( '14226', leadRec.PostalCode, 'The Postal Code was not as expected' );

        Test.startTest();

        leadRec.PostalCode = '44103';
        update leadRec;

        Test.stopTest();

        leadRec = [ SELECT Id, maps__AssignmentRule__c, PostalCode FROM Lead WHERE Id = :leadRec.Id LIMIT 1 ];

        System.assertEquals( '44103', leadRec.PostalCode, 'The Postal Code was not as expected' );
        System.assertEquals( null, leadRec.maps__AssignmentRule__c, 'The Maps Assignment Rule field was not blanked out' );
    }

    @IsTest
    static void changeShapeLayer() {
        Account acct = TestUtility.createAccount();
        acct.BillingPostalCode = '14209';
        insert acct;

        MapsTestUtility.createGeoLayer();

        maps__ShapeLayerGeometry__c shapeLayerGeoRec = [ SELECT Id, maps__Geometry__c FROM maps__ShapeLayerGeometry__c LIMIT 1 ];

        Test.startTest();
            shapeLayerGeoRec.maps__Geometry__c = shapeLayerGeoRec.maps__Geometry__c.replace( '\"USA-14010\"', '' );
            update shapeLayerGeoRec;
        Test.stopTest();

    }

    @IsTest
    static void deleteShapeLayer() {
        Account acct = TestUtility.createAccount();
        acct.BillingPostalCode = '14209';
        insert acct;

        MapsTestUtility.createGeoLayer();

        maps__ShapeLayerGeometry__c shapeLayerGeoRec = [ SELECT Id, maps__Geometry__c FROM maps__ShapeLayerGeometry__c LIMIT 1 ];

        Test.startTest();
            delete shapeLayerGeoRec;
        Test.stopTest();

        acct = [ SELECT Id, maps__AssignmentRule__c, BillingPostalCode FROM Account WHERE Id = :acct.Id LIMIT 1 ];

        System.assertEquals( null, acct.maps__AssignmentRule__c, 'The Maps Assignment Rule field was not blanked out' );

    }

    @IsTest
    static void changeAssignmentPlan() {
        Account acct = TestUtility.createAccount();
        acct.BillingPostalCode = '14209';
        insert acct;

        MapsTestUtility.makeData();
        maps__AssignmentRule__c assignRuleRec = [ SELECT Id, maps__User__c FROM maps__AssignmentRule__c LIMIT 1 ];

        User userRec = TestUtility.createUser();
        insert userRec;

        Test.startTest();

            assignRuleRec.maps__User__c = userRec.Id;
            update assignRuleRec;
            
        Test.stopTest();

        acct = [ SELECT Id, maps__AssignmentRule__c, BillingPostalCode FROM Account WHERE Id = :acct.Id LIMIT 1 ];
        
        System.assertEquals( null, acct.maps__AssignmentRule__c, 'The Maps Assignment Rule field was not blanked out' );

    }
}