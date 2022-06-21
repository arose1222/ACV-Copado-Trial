/**
 * Test class for BundleOfferController
 * @author Pankaj Kumar
 * @group Vehicle Intelligence 
 */

@isTest
public class BundleOfferControllerTest {
    
    @TestSetup
    static void makeData(){

        Account acc = TestUtility.createAccount();
        insert acc;
        
        Bundled_Offer__c bundleOffer = TestUtility.createBundleOffer(acc.Id);
        insert bundleOffer;
        
        //List<Vehicle__c> vehicles = new List<Vehicle__c>();
        Vehicle__c vehicle = TestUtility.createVehicle();
        insert vehicle;
        
        Condition_Report__c conditionReport =  TestUtility.createCr(vehicle);
        conditionReport.Dealership__c = bundleOffer.Dealer__c;
        insert conditionReport;
    }
    
    
    @IsTest
    public static void getVehiclesTest() {
        Test.startTest();
            Bundled_Offer__c bundleOffer = [SELECT Id, Dealer__c FROM Bundled_Offer__c LIMIT 1];
            
            // getting available vehicles from Dealer which are not yet added to bundleOffer
            List<Vehicle__c> vehicles = BundleOfferController.getVehicles(bundleOffer.Id);
    
            System.assertEquals(1, vehicles.size(), 'Vehicle size is not equal to 1.');
            
            //creating another vehicle to check the opposite condition
            Vehicle__c vehicle = TestUtility.createVehicle();
            insert vehicle;
            
            // this vehicle should not come from getVehicles as Inspection_Guid__c is null 
            Condition_Report__c conditionReport =  TestUtility.createCr(vehicle);
            conditionReport.Dealership__c = bundleOffer.Dealer__c;
            conditionReport.Inspection_Guid__c = null;
            conditionReport.Floor_Price__c = 0; // setting floor price 0
            insert conditionReport;
            
            vehicles = BundleOfferController.getVehicles(bundleOffer.Id);
    
            System.assertEquals(1, vehicles.size(), 'Vehicle size is not equal to 1.');
            
            // Inspection_Guid__c not null condition
            conditionReport.Inspection_Guid__c = '2312111';
            update conditionReport;
            
            vehicles = BundleOfferController.getVehicles(bundleOffer.Id);
    
            System.assertEquals(2, vehicles.size(), 'Vehicle size is not equal to 2.');
        
        Test.stopTest();
    }
    
    
    @IsTest
    public static void getRelatedVehiclesTest() {
        // adding vehicles to bundleOffer
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
		Vehicle__c vehicle = [Select Id from Vehicle__c Limit 1];	        
        BundleOfferVehicleAssociation__c bundleOfferAssociation = new BundleOfferVehicleAssociation__c(Vehicle__c = vehicle.id, Bundled_Offer__c = bundleOffer.id);
        insert bundleOfferAssociation;
        Test.startTest();
            List<BundleOfferVehicleAssociation__c> relatedVehicles = BundleOfferController.getRelatedVehicles(bundleOffer.Id);
            System.assertEquals(1, relatedVehicles.size(), 'Related vehicle size is not equal to 1.');
        Test.stopTest();
    }
    
    
    @IsTest
    public static void addVehiclesToBundleTest() {
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
        
        Vehicle__c vehicle = [Select Id from Vehicle__c Limit 1];
        List<Id> vehiclesIds = new List<Id>();
        vehiclesIds.add(vehicle.Id);
        
        Test.startTest();
            BundleOfferController.addVehiclesToBundle(bundleOffer.Id, vehiclesIds);
            List<BundleOfferVehicleAssociation__c> relatedVehicles = BundleOfferController.getRelatedVehicles(bundleOffer.Id);
            System.assertEquals(1, relatedVehicles.size(), 'Related vehicle size is not equal to 1.');
        Test.stopTest();
    }
    
    @IsTest
    public static void deleteVehiclesFromBundleTest() {
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
        
        Vehicle__c vehicle = [Select Id from Vehicle__c Limit 1];
        List<Id> vehiclesIds = new List<Id>();
        vehiclesIds.add(vehicle.Id);
        
        Test.startTest();
            BundleOfferController.addVehiclesToBundle(bundleOffer.Id, vehiclesIds);
            List<BundleOfferVehicleAssociation__c> relatedVehicles = BundleOfferController.getRelatedVehicles(bundleOffer.Id);
            System.assertEquals(1, relatedVehicles.size());
            BundleOfferVehicleAssociation__c bundleAssociation = [Select Id from BundleOfferVehicleAssociation__c Limit 1];
            List<Id> vehicleIds = new List<Id>();
            vehicleIds.add(bundleAssociation.Id);
            BundleOfferController.deleteVehiclesFromBundle(bundleOffer.Id, vehicleIds);
            List<BundleOfferVehicleAssociation__c> relatedBundleVehicles = BundleOfferController.getRelatedVehicles(bundleOffer.Id);
            System.assertEquals(0, relatedBundleVehicles.size(), 'Related vehicle size is not equal to 0.');
        Test.stopTest();
    }
    
    @IsTest
    public static void updateBundleVehicleAssociationsTest() {
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
        Vehicle__c vehicle = [Select Id from Vehicle__c Limit 1];
        List<Id> vehiclesIds = new List<Id>();
        vehiclesIds.add(vehicle.Id);
        
        Test.startTest();
            BundleOfferController.addVehiclesToBundle(bundleOffer.Id, vehiclesIds);
            List<BundleOfferVehicleAssociation__c> relatedVehicles = BundleOfferController.getRelatedVehicles(bundleOffer.Id);
            System.assertEquals(1, relatedVehicles.size(), 'Related vehicle size is not equal to 1.');
            
            String result = BundleOfferController.updateBundleVehicleAssociations(relatedVehicles);
            System.assertEquals(result, 'Success: Vehicles updated successfully', 'Vehicles did not get update.');
        Test.stopTest();
    }
    
    @IsTest
    public static void sendBundledOfferEmailTest() {
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
        bundleOffer.Seller_Email_Address__c = 'test@test.com';
        update bundleOffer;
        Boolean isError = false;
        Test.startTest();
        try {
            BundleOfferController.sendBundledOfferEmail(bundleOffer.Id);
        } catch (Exception e) {
            isError = true; 
            System.assert(isError, 'Email didn\'t fire');
        }
        
        Test.stopTest();
        
        
    }
	
    @IsTest
    public static void launchOfferActionTest() {
        Bundled_Offer__c bundleOffer = [Select Id from Bundled_Offer__c Limit 1];
        Vehicle__c vehicle = [Select Id from Vehicle__c Limit 1];
        List<Id> vehiclesIds = new List<Id>();
        vehiclesIds.add(vehicle.Id);
        
        Test.startTest();
        	try {
                BundleOfferController.addVehiclesToBundle(bundleOffer.Id, vehiclesIds);
                BundleOfferController.launchOfferAction(bundleOffer.Id);
            } catch (Exception e) {
    			System.assert(false, 'Exception ' + e);
			}
        Test.stopTest();
    }
}