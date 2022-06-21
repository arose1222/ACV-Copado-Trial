@isTest
public with sharing class RevolvingAppointmentTriggerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = new ServiceTerritory( Name = 'Great Lakes', OperatingHoursId = oh.Id, IsActive = TRUE );
        insert st1;

        Account a = TestUtility.createAccount();
        a.Name = 'Test';
        insert a;

        ServiceResource sr1 = FSLTestUtility.makeResourceData();
        ServiceResource sr2 = FSLTestUtility.makeResourceData();

        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P', OperatingHoursId = oh.Id );
        insert stm1;

        ServiceTerritoryMember stm2 = new ServiceTerritoryMember( ServiceResourceId = sr2.Id, ServiceTerritoryId = st1.Id, TerritoryType = 'P', EffectiveStartDate = Date.today().addDays(-1), OperatingHoursId = oh.Id );
        insert stm2;

        insert FSLTestUtility.createWorkTypes();
        
        WorkType workTypeRec = FSLWorkProcessUtility.availableWTMap.get( 'inspection' );
        //Fetching Skills as cannot be inserted
        List<Skill> maintSkill = [SELECT Id, MasterLabel FROM Skill];

        //Inserting Service Resource Skill
        ServiceResourceSkill srSkill1 = new ServiceResourceSkill(ServiceResourceId=sr1.Id,SkillId = maintSkill[0].id, EffectiveStartDate = System.Today());
        Insert srSkill1;
        //Inserting SkillReqRecord
        SkillRequirement skillReqRecord = new SkillRequirement(RelatedRecordId=workTypeRec.Id, SkillId=maintSkill[0].id);
        Insert skillReqRecord;
    }
    @isTest
    static void insertion(){

        test.startTest();
        //TO:DO:
		//Skill maintSkill = [SELECT Id, MasterLabel FROM Skill Limit 1];
		//System.debug('maintSkill'+maintSkill);
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        Timeline__c tl = new Timeline__c(Service_Resource__c = [SELECT id FROM ServiceResource LIMIT 1].id, Average_Number_Cars__c = 2, Account__c = acc.Id);
        tl.Work_Type__c = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).ID;
        system.debug('Insert new timeline');
        insert tl;

        test.stopTest();
        tl = [SELECT id, Average_Number_Cars__c, OwnerId, Service_Resource__r.RelatedRecordId FROM Timeline__c WHERE id =: tl.id];
        system.assert(tl.OwnerId == tl.Service_Resource__r.RelatedRecordId, 'The insert trigger did not update the field correctly');

    }

    @isTest
    static void updateServiceResource(){

        test.startTest();

        ServiceResource sr = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        Timeline__c tl = new Timeline__c(Service_Resource__c = sr.id, Average_Number_Cars__c = 2, Account__c = acc.Id);
		tl.Work_Type__c = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).ID;
        system.debug('Insert new timeline');
        insert tl;

        tl.Service_Resource__c = [SELECT id FROM ServiceResource WHERE Id != :sr.Id ].id;
        try{
            update tl;
        }catch(Exception ex){
            //As service resource might not be having same skills as that of work type
            System.assertEquals('System.DmlException', ex.getTypeName());
        }

        tl = [SELECT id, Average_Number_Cars__c, OwnerId, Service_Resource__r.RelatedRecordId FROM Timeline__c WHERE id =: tl.id];
        system.assert(tl.OwnerId == tl.Service_Resource__r.RelatedRecordId, 'The update trigger did not update the field correctly');



        tl.OwnerId = sr.RelatedRecordId;
        update tl;

        tl = [SELECT id, Average_Number_Cars__c, OwnerId, Service_Resource__r.RelatedRecordId FROM Timeline__c WHERE id =: tl.id];

        //pick assertion based on if trigger is active

        TriggerHandler__mdt triggerHandlerBlankUpdate = [SELECT Active__c FROM TriggerHandler__mdt WHERE MasterLabel = 'RevAppOwnerHandlerBlankUpdate'];
        system.debug('Active field: ' + triggerHandlerBlankUpdate.Active__c);
        system.debug(tl);
        String message = 'Expected OwnerId value: ';
        if(triggerHandlerBlankUpdate.Active__c == true){
            system.debug(message + tl.Service_Resource__r.RelatedRecordId);
            system.assert(tl.OwnerId == tl.Service_Resource__r.RelatedRecordId, 'The update trigger did not update the field correctly');
        }else{
            Id correctId = [SELECT id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1].id;
            system.debug(message + correctId);
            system.assert(tl.OwnerId == correctId, 'The Owner field does not have the correct value');
        }



        test.stopTest();


    }


}