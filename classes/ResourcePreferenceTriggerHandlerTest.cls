/**
 * @description ${DESCRIPTION}
 * @name ResourcePreferenceTriggerHandlerTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-10-28
 */

@IsTest
public class ResourcePreferenceTriggerHandlerTest {
    @IsTest
    static void testUpdateParentWO() {
        Account vciAccount = TestUtility.createAccount('vciTestAccount');
        insert vciAccount;
        
        FSLTestUtility.createData( vciAccount, 1 );
        
        Test.startTest();
            ServiceResource sr = FSLTestUtility.makeResourceData();
            insert FSLTestUtility.createPreference( sr.Id, [ SELECT Id FROM WorkOrder LIMIT 1 ].Id );
    
            WorkOrder updatedWorkOrder = [SELECT Has_Required_Resource__c FROM WorkOrder LIMIT 1 ];
            System.assert(updatedWorkOrder.Has_Required_Resource__c,'Has required resource field was not updated');
       Test.stopTest();
    }
}