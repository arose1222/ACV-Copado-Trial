@isTest
public class RecPriceUpdateActiveTest {
    @isTest
    static void runTest() {
        //need three vehicles
        List<Vehicle__c> carList = new List<Vehicle__c>();
        carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102030'));
        carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102031'));
        carList.add(new Vehicle__c(Year__c = '2009', Make__c = 'test make', Model__c = 'test model', VIN__c = '1234567890102032'));
        //insert vehicles
        insert carList;
        //need three recprice records
        List<Recommended_Price__c> recPriceList = new List<Recommended_Price__c>();
        //two inserted as active
        recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Active', Recommended_Price_Active__c = true, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 303, Price_Floor__c = 200, Vehicle__c = carList[0].Id));
        recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Active', Recommended_Price_Active__c = true, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 301, Price_Floor__c = 200, Vehicle__c = carList[1].Id));
        //one inserted as expired (if it lets us)
        recPriceList.add(new Recommended_Price__c(Pricing_Status__c = 'Expired', Recommended_Price_Active__c = false, Pricing_Reason__c = 'MMR', Price_Ceiling__c = 302, Price_Floor__c = 200, Vehicle__c = carList[2].Id));
        //insert recprices
        insert recPriceList;
        //query
        List<Recommended_Price__c> updateList = [SELECT Pricing_Status__c, Price_Ceiling__c, Price_Floor__c FROM Recommended_Price__c];
        for (Recommended_Price__c r : updateList) {
            if (r.Price_Ceiling__c == 303) {
                //update one recprice to be expired
                r.Pricing_Status__c = 'Expired';
            }
            else if (r.Price_Ceiling__c == 302) {
                //update one to be active
                r.Pricing_Status__c = 'Active';
            }
            else {
                //update random field
                r.Price_Floor__c = 201;
            }
        }
        //update recprices
        update updateList;
        //query
        List<Recommended_Price__c> checkRecPriceStatus = [SELECT Id, Pricing_Status__c, Recommended_Price_Active__c FROM Recommended_Price__c ORDER BY Price_Ceiling__c DESC];
        //system.asserts
        System.assertEquals('Expired', checkRecPriceStatus[0].Pricing_Status__c);
        System.assertEquals(false, checkRecPriceStatus[0].Recommended_Price_Active__c);
        System.assertEquals('Active', checkRecPriceStatus[1].Pricing_Status__c);
        System.assertEquals(true, checkRecPriceStatus[1].Recommended_Price_Active__c);
        System.assertEquals('Active', checkRecPriceStatus[2].Pricing_Status__c);
        System.assertEquals(true, checkRecPriceStatus[2].Recommended_Price_Active__c);
    }
}