@isTest
public class RecommendedPriceExpirationDateBatchTest {
    @isTest
    static void batchTest() {
        //need today's date
        Date today = System.Today();
        //need tomorrow's date
        Date tomorrow = System.Today().addDays(1);
        //create a vehicle
        List<Vehicle__c> carList = new List<Vehicle__c>();
        carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030'));
        carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102031'));
        //insert vehicle
        insert carList;
        //need 2 recommended price records
        List<Recommended_Price__c> recPriceList = new List<Recommended_Price__c>();
        //one that is expiring today
        recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Active', Recommended_Price_Active__c = true, Expiration_Date__c = today, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 300, Price_Floor__c = 200, Vehicle__c = carList[0].Id));
        //one that is expiring tomorrow
        recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Active', Recommended_Price_Active__c = true, Expiration_Date__c = tomorrow, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 300, Price_Floor__c = 200, Vehicle__c = carList[1].Id));
        //insert rec prices
        insert recPriceList;
        //run batch

        Test.startTest();
            SchedulableContext sc = null;
            RecommendedPriceExpirationDateBatch batch = new RecommendedPriceExpirationDateBatch();
            Batch.execute(sc);
        Test.stopTest();
        //query
        List<Recommended_Price__c> checkRecPrices = [SELECT Id, Recommended_Price_Active__c, Pricing_Status__c FROM Recommended_Price__c ORDER BY Expiration_Date__c ASC];
        //system.asserts
        System.assertEquals(false, checkRecPrices[0].Recommended_Price_Active__c);
        System.assertEquals('Expired', checkRecPrices[0].Pricing_Status__c);
        System.assertEquals(true, checkRecPrices[1].Recommended_Price_Active__c);
        System.assertEquals('Active', checkRecPrices[1].Pricing_Status__c);
    }

    @isTest
    static void bulkTest() {
        //need date of today
        Date today = System.Today();
        //need 200 vehicles
        List<Vehicle__c> carList = new List<Vehicle__c>();
        for (Integer i = 0; i < 200; i ++) {
            carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102' + i));
        }
        //insert cars
        insert carList;
        //need 200 rec prices
        List<Recommended_Price__c> recPriceList = new List<Recommended_Price__c>();
        for (Integer i = 0; i < 200; i ++) {
            recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Active', Recommended_Price_Active__c = true, Expiration_Date__c = today, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 300, Price_Floor__c = 200, Vehicle__c = carList[i].Id));
        }
        //insert rec prices
        insert recPriceList;
        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            RecommendedPriceExpirationDateBatch batch = new RecommendedPriceExpirationDateBatch();
            Batch.execute(sc);
        Test.stopTest();
    }

    @isTest
    static void errorCheck() {
        //populate errorList
        RecommendedPriceExpirationDateBatch.errorList.add('error');
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            RecommendedPriceExpirationDateBatch batch = new RecommendedPriceExpirationDateBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
    }
}