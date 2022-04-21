/**
 * @description ${DESCRIPTION}
 * @name tracRecurringEventControllerTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-10-28
 */

@IsTest
private class tracRecurringEventControllerTest {

    @TestSetup
    static void createData() {
        Account a = TestUtility.createAccount();
        a.Name = 'Test';
        insert a;

        FSLTestUtility.createData( a, 1 );
    }

    // @IsTest static void testGetResources() {
    //     Profile profile = [SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector'];
    //     User vciUser = new User(
    //             LastName = 'vciUser2',
    //             Username = 'vciUser2@traction'+System.currentTimeMillis() + '.com',
    //             Email = 'vciUser2@traction'+System.currentTimeMillis() + '.com',
    //             TimeZoneSidKey = 'America/Los_Angeles',
    //             EmailEncodingKey = 'UTF-8',
    //             LanguageLocaleKey = 'en_US',
    //             LocaleSidKey = 'en_US',
    //             Alias = 'vciUser2',
    //             ProfileId = profile.Id);
    //     insert vciUser;
    //     ServiceResource resource = new ServiceResource(RelatedRecordId = vciUser.Id, Name = 'Johannesbourg Smithery');
    //     insert resource;

    //     List<LookupSearchResult> results =  tracRecurringEventController.getResources('Joh',new List<String>());
    //     System.debug(results);
    // }

    @IsTest static void testGetOccurrences() {
        WorkType wt2 = [ SELECT Id, EstimatedDuration FROM WorkType WHERE Name = :tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION ];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        Timeline__c tl = new Timeline__c();
        tl.Work_Type__c = wt2.id;
        tl.Average_Number_Cars__c = 1;
        tl.Account__c = acc.Id;
        insert tl;

        List<Occurrence__c> occurrences = new List<Occurrence__c>();
        occurrences.add(new Occurrence__c(Timeline__c = tl.Id,Frequency__c='Weekly', Day__c = '10'));
        occurrences.add(new Occurrence__c(Timeline__c = tl.Id,Frequency__c='Weekly',Day__c = '1'));
        insert occurrences;

        System.assert(tracRecurringEventController.getOccurrences(tl.Id).size() == 2,'The occurrence records were not properly queried');
    }

    @IsTest static void testdeleteTimeline() {
        WorkType wt2 = [ SELECT Id, EstimatedDuration FROM WorkType WHERE Name = :tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION ];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        Timeline__c tl = new Timeline__c();
        tl.Work_Type__c = wt2.Id;
        tl.Average_Number_Cars__c = 1;
        tl.Account__c = acc.Id;
        insert tl;

        tracRecurringEventController.deleteTimeline(tl.Id);

        List<Timeline__c> timelines = [SELECT Id FROM Timeline__c WHERE Id = :tl.Id];
        System.assert(timelines.size() == 0,'The timeline record wasn\'t deleted');
    }

    @isTest
    static void testGetOperatingHours() {
        Test.startTest();
            OperatingHours optHrs = [ SELECT Id FROM OperatingHours LIMIT 1 ];
            Account acct = [ SELECT Id FROM Account LIMIT 1 ];
            acct.OperatingHoursId = optHrs.Id;
            acct.BillingLongitude = 1;
            acct.BillingLatitude = 1;
            update acct;
    
            ServiceResource sr1 = FSLTestUtility.makeResourceData();
    
            ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ]; // only 1 exists
            ServiceTerritoryMember stm = new ServiceTerritoryMember(
                ServiceResourceId = sr1.Id,
                ServiceTerritoryId = st.Id,
                EffectiveStartDate = Date.today().addDays(-1),
                TerritoryType = 'P',
                OperatingHoursId = optHrs.Id
            );
            insert stm;

        
            String returnVal = tracRecurringEventController.getOperatingHours( acct.Id );
            tracRecurringEventController.OperatingHoursRange newRange = (tracRecurringEventController.OperatingHoursRange) JSON.deserialize( returnVal, tracRecurringEventController.OperatingHoursRange.class );
            returnVal = tracRecurringEventController.getUpdatedOperatingHours( JSON.serialize( newRange ), sr1.Id, acct.Id );
        Test.stopTest();

        system.Assert( newRange.startingHour != null );
        system.Assert( newRange.closingHour != null );
    }

    @isTest
    static void testGetAccountAddress() {
        Test.startTest();
            Account acct = [ SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account LIMIT 1 ];
            acct.BillingStreet = '123 fake st';
            acct.BillingCity = 'testCity';
            acct.BillingState = 'testState';
            acct.BillingPostalCode = '12345';
            acct.BillingCountry = 'US';
            update acct;

            acct = tracRecurringEventController.getAccountAddress(acct.Id);
        Test.stopTest();

        system.assertEquals('123 fake st', acct.BillingStreet);
        system.assertEquals('testCity', acct.BillingCity);
        system.assertEquals('testState', acct.BillingState);
        system.assertEquals('12345', acct.BillingPostalCode);
        system.assertEquals('US', acct.BillingCountry);
    }
}