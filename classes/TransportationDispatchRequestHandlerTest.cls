@isTest
public class TransportationDispatchRequestHandlerTest {
    private static Integer numCases = 1;
    @TestSetup static void makeData(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Case> cases = new List<Case>();
        List<Transportation_Dispatch_Request__C> TDRs = new List<Transportation_Dispatch_Request__c>();
        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        for(Integer i=0;i<numCases;i++){
            Case newCase = new Case(vehicle_vin__C = 'THISISWHATITWAS', RecordTypeId = TransportationRTId, Status = 'Ready-to-Post');
            cases.add(newCase);

        }
        Case newCase = new Case(Status='Awaiting Release', vehicle_vin__C = 'THISISWHATITWAS',RecordTypeId = TransportationRTId);
        insert newCase;
        insert Cases;
        System.Debug(Cases);

    }

    /* 
        Change the VIN on the Transporation_Dispatch_Request__c. 
        The VIN on the Case Object should be equal to 'THISISWHATITIS'.
    */
    @IsTest static void changeTDRfield(){
      Test.startTest();
      List<Transportation_Dispatch_Request__C> TDRs = [SELECT vehicle_vin__C, Related_Transportation_Case__c 
                          FROM Transportation_Dispatch_Request__C];
      List<String> lIds = new List<String>();

      for(Transportation_Dispatch_Request__C c : TDRs){
        c.vehicle_vin__C = 'THISISWHATITIS';
        lIds.add(String.Valueof(c.Related_Transportation_Case__c));
      }
      update TDRs;

      //Only look at the cases that have TDRs
      List<Case> theCASEs= [SELECT vehicle_vin__c
                           FROM Case WHERE Id IN :lIds];
	    System.debug(theCASEs);
      for(Case c : theCASEs){
        System.AssertEquals( 'THISISWHATITIS',c.Vehicle_VIN__C);
      }
      Test.stopTest();
      
    }


    /*
        Change the VIN field on the Case.
        The VIN on the Transportation_Dispatch_Request__c should eqal 'THISISWHATITWAS'
    */
    @isTest static void changeCASEfield(){
      Test.startTest();
      List<Case> theCASEs = [SELECT vehicle_vin__C 
                            FROM Case];
      
      for(Case c : theCASEs){
        c.vehicle_vin__C = 'THISISWHATITWAS';
      }
      Database.update(theCASEs);

      
      List<Transportation_Dispatch_Request__C> TDRs= [SELECT vehicle_vin__c
                                                      FROM Transportation_Dispatch_Request__C];
      System.debug(TDRs);
      for(Transportation_Dispatch_Request__C t : TDRs){
        System.AssertEquals( 'THISISWHATITWAS',t.vehicle_vin__C);
      }
      Test.stopTest();  
    }

    @isTest static void nonReadytoPostCase(){
      

      //Assert that a Transportation case that is not 'Ready-to-Post' does not create a TDR
      Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
      Case newCase = new Case(Status='Cancelled by ACV', RecordTypeId = TransportationRTId);
      insert newCase;
      System.assertEquals(0,[SELECT Id FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C = :newCase.Id].size());
      
      

    }

    @isTest static void readytopostCASE(){
      Test.startTest();

      //Update case to be Ready-to-Post and assert that a TDR gets created
      List<Case> firstCase = [SELECT Id FROM Case WHERE Status = 'Awaiting Release' LIMIT 1];
      firstCase[0].Status = 'Ready-to-Post';
      update firstCase;
      System.assertEquals(1, [SELECT Id FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C = :firstCase[0].Id].size());

      Test.stopTest();
  
    }
    
    @isTest static void upsertScenario(){
        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Case> lCase = new List<Case>();
        Case insertCase = new Case(Status='Ready-to-Post',vehicle_vin__C = 'THISISWHATITSCHWAS',RecordTypeId = TransportationRTId);
        Case newCase = [SELECT Id,Status FROM Case WHERE status = 'Awaiting Release' LIMIT 1] ;
        newCase.Status = 'Ready-to-Post';
        lCase.add(newCase);
        lCase.add(insertCase);
        CaseTransportationProcesses.afterUpdateToggle(false);
        System.Debug('--------Upsert---------------------------------');
        upsert lCase;

        System.Debug([SELECT vehicle_vin__C,Related_Transportation_Case__C FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C = :newCase.Id ]);
        System.Debug([SELECT vehicle_vin__c,Status FROM Case]);

        System.AssertEquals([SELECT vehicle_vin__C,Related_Transportation_Case__C FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C = :newCase.Id ].vehicle_vin__c, 'THISISWHATITWAS');
    }
    @isTest static void oneTDRperCase1(){
      Test.startTest();

      //Update case to be 'Awaiting Release' and assert that a TDR gets created
      List<Case> firstCase = [SELECT Id FROM Case LIMIT 1];
      firstCase[0].Status = 'Awaiting Release';
      update firstCase;

      Test.stopTest();
  
    }

    @isTest static void oneTDRperCase2(){
      Test.startTest();

      //Update case to be Ready-to-Post and assert that a TDR gets created
      List<Case> firstCase = [SELECT Id FROM Case LIMIT 1];
      firstCase[0].Status = 'Ready-to-Post';
      update firstCase;

      System.assertEquals(1, [SELECT Id FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C = :firstCase[0].Id].size());

      Test.stopTest();
  
    }
    
    @isTest static void insertOne(){
        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Case newCase = new Case(Status='Ready-to-Post', vehicle_vin__C = 'THISISWHATITWAS',RecordTypeId = TransportationRTId);
        insert newCase;
        
        System.assertEquals(1, [Select id from Transportation_Dispatch_Request__c WHERE Related_Transportation_Case__c = :newCase.Id].size());
        System.assertEquals('THISISWHATITWAS', [Select id, vehicle_vin__C from Transportation_Dispatch_Request__c WHERE Related_Transportation_Case__c = :newCase.Id].vehicle_vin__c);
    }
	
}