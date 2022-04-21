@isTest
public class RevAppActiveFieldTest {
    @TestSetup
    public static void createTerritory() {
        Account a = new Account(
            Name = 'ACV Dealership', Dealership_Id__c = '1', BillingPostalCode = '14209', legal_Name__c='ACV Dealership', dealer_type__c='1'
        );
        insert a;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        Id workTypeId = [SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1].Id;
        Timeline__c tl = new Timeline__c(
            Account__c = a.id,
            Is_Active__c = true,
            Average_Number_Cars__c = 1,
            Work_Type__c = workTypeId
        );
        insert tl;

        Occurrence__c occ1 = new Occurrence__c(
            timeline__c = tl.id,
            is_Active__c = true
        );
        insert occ1;

        Occurrence__c occ2 = new Occurrence__c(
            timeline__c = tl.id,
            Is_Active__c = true
        );
        insert occ2;

        Occurrence__c occ3 = new Occurrence__c(
            timeline__c = tl.id,
            Is_Active__c = true
        );
        insert occ3;
    }
    @isTest
    public static void deactivateRevolvingAppointment(){
        Timeline__c tl = [SELECT id, Is_Active__c FROM Timeline__c LIMIT 1];
        tl.Is_Active__c = false;
        update tl;


        List<Occurrence__c> occList = new List<Occurrence__c>([SELECT id, Is_Active__c FROM Occurrence__c WHERE Timeline__c = :tl.id]);
        for(Occurrence__c occ : occList){
            system.assert(occ.Is_Active__c == false);
        }
    }

}