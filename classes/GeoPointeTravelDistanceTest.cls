@isTest
public class GeoPointeTravelDistanceTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);

        Integer numCases = 1;
        List<Case> cases = new List<Case>();

        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        for(Integer i=0;i<numCases;i++){
            Case newCase = new Case(default_delivery_address__c = '640 Ellicott Street', default_delivery_city__c = 'Buffalo', default_delivery_state__c = 'NY', default_delivery_postal_code__c = '14203', default_delivery_country__c = 'US', 
            pickup_address__c = '194 Enchanted Forest South',default_pickup_city__c = 'Depew',default_pickup_state__c = 'NY', default_pickup_postal_code__c = '14043', default_pickup_country__c = 'US', RecordTypeId = TransportationRTId, Status = 'Ready-to-Post');
            cases.add(newCase);

        }
		
        insert Cases;
        
        
        Map<Id,SObject> caseMap = new Map<Id,SObject>();
        caseMap.put([SELECT Id FROM Case Limit 1].Id,Cases[0]);
        System.Debug(Cases); 
    }
    
    /*@isTest
    static void CaseInsertions100() {

		List<Case> checklist = [SELECT id, RecordTypeId,default_delivery_address__c,default_delivery_city__c, default_delivery_state__c,default_delivery_postal_code__c, default_delivery_country__c, 
            					pickup_address__c ,default_pickup_city__c,default_pickup_state__c, default_pickup_postal_code__c, default_pickup_country__c, Transportation_Distance__c 
                                FROM Case];
		CalcDriveDistance.run(checklist);
        for(Case c : checklist){
            //System.assertEquals('401.377082934',c.Transportation_Distance__C);
        }                        
    }*/

    @isTest
    static void UseAlternateAddressField(){
        
        Case newCase = [SELECT Id,default_delivery_address__C
                        FROM Case LIMIT 1];
    
        newCase.alternate_delivery_address__c = '4535 Broadway';
        newCase.alternate_delivery_city__C = 'Depew';
        newCase.alternate_delivery_state__C = 'NY';
        newCase.alternate_delivery_postal_code__c = '14043';
        newCase.alternate_delivery_country__C = 'US';
        newCase.default_delivery_address__c = '640 Ellicott St';
        CaseTransportationProcesses.beforeUpdateToggle(false);
        update newCase;
        //system.assertEquals('9.2', [SELECT default_delivery_address__c, transportation_distance__c FROM Case].Transportation_Distance__c);

    }

}