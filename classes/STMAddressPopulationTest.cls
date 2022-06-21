@isTest
public class STMAddressPopulationTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        FSLTestUtility.makeResourceData();
    }

    @isTest
    public static void insertNewMembership(){
        Test.startTest();
            Id optHourId = [ SELECT Id FROM OperatingHours LIMIT 1 ].Id;
            ServiceResource sr = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
            Id srId = sr.Id;
            Id stId = [SELECT Id FROM ServiceTerritory LIMIT 1].Id;
            ServiceTerritoryMember stm = new ServiceTerritoryMember(
                ServiceResourceId = srId, ServiceTerritoryId = stId, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P', OperatingHoursId = optHourId
            );
            insert stm;
        Test.stopTest();

        stm = [SELECT Street, City, PostalCode, Country, State, Address FROM ServiceTerritoryMember WHERE ServiceResourceId =: srId AND ServiceTerritoryId =: stId];
        User u = [SELECT Address, Street, City, PostalCode, Country, State FROM User WHERE Id = :sr.RelatedRecordId ];
        System.assert(stm.Street == u.street && stm.city == u.city && stm.postalcode == u.postalcode && stm.country == u.country && stm.state == u.state);
    }

    @IsTest
    static void throwError(){
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            Id optHourId = [ SELECT Id FROM OperatingHours LIMIT 1 ].Id;
            ServiceResource sr = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];

            User userRec = [ SELECT Id, Street, City, PostalCode, Country, State FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1 ];
            userRec.Street = null;
            userRec.City = null;
            userRec.PostalCode = null;
            userRec.Country = null;
            userRec.State = null;
            update userRec; // Remove Address Info

            Id srId = sr.Id;
            Id stId = [SELECT Id FROM ServiceTerritory LIMIT 1].Id;
            ServiceTerritoryMember stm = new ServiceTerritoryMember(
                ServiceResourceId = srId, ServiceTerritoryId = stId, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P', OperatingHoursId = optHourId
            );
            try {
                insert stm;
            } catch ( exception e ) {
                if ( e.getMessage().contains( STMAddressPopulation.STM_NO_USER_ADDRESS_ERROR ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }

}