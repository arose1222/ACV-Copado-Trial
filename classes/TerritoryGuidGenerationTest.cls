@isTest
public class TerritoryGuidGenerationTest {
    @testSetup
    Static void createTestData(){
        maps__ShapeLayer__c a = new maps__ShapeLayer__c(ACV_Territory_ID__c='1', Name='Test Name');
        insert a;
        maps__ShapeLayer__c a1 = new maps__ShapeLayer__c(ACV_Territory_ID__c='2', Name='Test Name 2');
        insert a1;
    }
    public static testMethod void TestTerrGuidGenerationUponInsert(){
        maps__ShapeLayer__c newTerr = new maps__ShapeLayer__c();
        newTerr = [SELECT ID, ACV_Territory_ID__c, Territory_Guid__c FROM maps__ShapeLayer__c Where ACV_Territory_ID__c = '1'];
        System.assert(newTerr.Territory_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestResolutionGuidGenerationUponUpdate(){
        maps__ShapeLayer__c newTerr = new maps__ShapeLayer__c();
        newTerr = [SELECT ID, ACV_Territory_ID__c, Territory_Guid__c FROM maps__ShapeLayer__c Where ACV_Territory_ID__c = '2'];
        newTerr.Territory_Guid__c = null;
        update newTerr;
        newTerr = [SELECT ID, ACV_Territory_ID__c, Territory_Guid__c FROM maps__ShapeLayer__c Where ACV_Territory_ID__c = '2'];
        System.assert(newTerr.Territory_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestResolutionGuidGenerationDoesNotChange(){
        maps__ShapeLayer__c newTerr = new maps__ShapeLayer__c();
        newTerr = [SELECT ID, ACV_Territory_ID__c, Territory_Guid__c FROM maps__ShapeLayer__c Where ACV_Territory_ID__c = '1'];
        update newTerr;
        maps__ShapeLayer__c newTerr1 = new maps__ShapeLayer__c();
        newTerr1 = [SELECT ID, ACV_Territory_ID__c, Territory_Guid__c FROM maps__ShapeLayer__c Where ACV_Territory_ID__c = '1'];
        System.assert(newTerr.Territory_Guid__c == newTerr1.Territory_Guid__c, 'Guid changed when it shouldnt have');      
    }
}