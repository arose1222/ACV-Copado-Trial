@isTest
public class FslNotificationTest {

   /*@isTest(seeAllData=true)
   public static void assignmentInsert(){

       Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
       
        WorkType wt = new workType(Name = 'Standard Test Inspection', EstimatedDuration = 20 );
        insert wt;

        User u = new User(Username = 'Testy@Testington.test', LastName = 'McTesty', Email ='Testy@Testington.test', Alias = 'TESTBOY', CommunityNickname = 'tEsT', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u;

        Account acc= new Account(Name = 'E Corp');
        insert acc;
       
        ServiceResource sr = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u.Id, IsActive = true);
        insert sr;

        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        ServiceTerritoryMember stm = new ServiceTerritoryMember( ServiceResourceId = sr.Id, ServiceTerritoryId = st.Id, TerritoryType = 'P', EffectiveStartDate = Date.today().addDays(-1) );
        insert stm;

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, WorkTypeId = wt.Id );
        insert wo;

        WorkOrderLIneItem woli = new WorkOrderLineItem(VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, WorkTypeId = wt.Id );
        insert woli;

        ServiceAppointment sa = new ServiceAppointment(ParentRecordId = wo.Id, SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), Status = 'None');
        insert sa;

       test.startTest();

       AssignedResource ar = new AssignedResource(ServiceAppointmentId = sa.Id, ServiceResourceId = sr.Id);
       insert ar;



       FeedItem fi = new FeedItem();
       fi = [SELECT id, body, parentid FROM FeedItem WHERE parentid =: sa.id LIMIT 1];


       AssignedResource arResult = [SELECT id, CreatedDate FROM AssignedResource WHERE id =: ar.Id LIMIT 1];

       wo = [SELECT id, LineItemCount FROM WorkOrder WHERE id =: wo.Id LIMIT 1];

       sa = [SELECT id, duedate FROM ServiceAppointment where id = :sa.id LIMIT 1];
       
       test.stopTest();
       system.debug(fi);
       system.debug(fi.body);
       system.debug('@McTesty You are the assigned resource for a service appointment. \nAccount: E Corp\nLine Items: 1\nDue Date: ' + sa.DueDate);
       system.debug('@' + u.LastName + ' You are the assigned resource for a service appointment. \nAccount: ' + acc.Name + '\nLine Items: ' + wo.LineItemCount +'\nDue Date: ' + sa.DueDate);


       system.assert(fi.Body == '@' + u.LastName + ' You are the assigned resource for a service appointment. \nAccount: ' + acc.Name + '\nLine Items: ' + wo.LineItemCount +'\nDue Date: ' + sa.DueDate);
 
   }

    @isTest(seeAllData=true)
    public static void assignmentUpdate(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];

        WorkType wt = new workType(Name = 'Standard Test Inspection', EstimatedDuration = 20 );
        insert wt;
       
        User u = new User(Username = 'Testy@Testington.test', LastName = 'McTesty', Email ='Testy@Testington.test', Alias = 'TESTBOY', CommunityNickname = 'tEsT', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u;

        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'TestyMcGee', Email ='Testy2@Testington.test', Alias = 'yobtset', CommunityNickname = 'TEEEEESSSSTTTT', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u2;

        Account acc= new Account(Name = 'E Corp');
        insert acc;
       
        ServiceResource sr = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u.Id, IsActive = true);
        insert sr;

        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true);
        insert sr2;

        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        ServiceTerritoryMember stm = new ServiceTerritoryMember( ServiceResourceId = sr.Id, ServiceTerritoryId = st.Id, TerritoryType = 'P', EffectiveStartDate = Date.today().addDays(-1) );
        insert stm;

        ServiceTerritoryMember stm2 = new ServiceTerritoryMember( ServiceResourceId = sr2.Id, ServiceTerritoryId = st.Id, TerritoryType = 'P', EffectiveStartDate = Date.today().addDays(-1) );
        insert stm2;

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, WorkTypeId = wt.Id );
        insert wo;

        WorkOrderLIneItem woli = new WorkOrderLineItem(VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, WorkTypeId = wt.Id  );
        insert woli;

        ServiceAppointment sa = new ServiceAppointment(ParentRecordId = wo.Id, SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), Status = 'None');
        insert sa;

        AssignedResource ar = new AssignedResource(ServiceAppointmentId = sa.Id, ServiceResourceId = sr.Id);
        insert ar;


        test.startTest();
            ar.ServiceResourceId = sr2.Id;
            update ar;
            system.debug(ar);
            system.debug(sr2);
            system.debug(u2);

            wo = [SELECT id, LineItemCount FROM WorkOrder WHERE id =: wo.Id LIMIT 1];
            
        test.stopTest();

        sa =[SELECT id, dueDate FROM ServiceAppointment WHERE id =: sa.Id];

        List<FeedItem> fiList = new List<FeedItem>();
        fiList = [SELECT id, body, parentid FROM FeedItem WHERE parentid =: sa.id];
        for(FeedItem fi : fiList){
            system.debug(fi);
        }
        
        system.assert(fiList[0].Body == '@' + u2.LastName + ' You are the assigned resource for a service appointment. \nAccount: ' + acc.Name + '\nLine Items: ' + wo.LineItemCount +'\nDue Date: ' + sa.DueDate);
    }*/
// @isTest(seeAllData=true)
//     public static void appointmentUpdate(){
//         Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];

//         WorkType wt = new workType(Name = 'Standard Test Inspection', EstimatedDuration = 20 );
//         insert wt;
       
//         User u = new User(Username = 'Testy@Testington.test', LastName = 'McTesty', Email ='Testy@Testington.test', Alias = 'TESTBOY', CommunityNickname = 'tEsT', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
//         insert u;

//         Account acc= new Account(Name = 'E Corp');
//         insert acc;
       
//         ServiceResource sr = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u.Id, IsActive = true);
//         insert sr;

//         ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

//         ServiceTerritoryMember stm = new ServiceTerritoryMember( ServiceResourceId = sr.Id, ServiceTerritoryId = st.Id, TerritoryType = 'P', EffectiveStartDate = Date.today().addDays(-1) );
//         insert stm;

//         WorkOrder wo = new WorkOrder(AccountId = acc.Id, WorkTypeId = wt.Id );
//         insert wo;

//         WorkOrderLIneItem woli = new WorkOrderLineItem(VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, WorkTypeId = wt.Id );
//         insert woli;

//         ServiceAppointment sa = new ServiceAppointment(ParentRecordId = wo.Id, SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), Status = 'None', Completed_Canceled_Notes__c = 'SA1');
//         insert sa;

//         AssignedResource ar = new AssignedResource(ServiceAppointmentId = sa.Id, ServiceResourceId = sr.Id);
//         insert ar;

// system.debug( [ SELECT Id, ServiceResourceId, ServiceAppointmentId, LastModifiedDate FROM AssignedResource WHERE Id = :ar.Id ] );

//         system.debug('ar.serviceAppointmentId: ' + ar.serviceAppointmentId + '.  sa.id: ' + sa.Id);

// system.assertEquals( ar.serviceAppointmentId, sa.Id );

//         test.startTest();


//         woli.status = 'Canceled';
// system.debug( 'We have set Woli to Canceled' );
//         update woli;
// system.debug( 'Woli Update is done' );        

//         system.debug( [ SELECT Id, Status FROM WorkOrder WHERE ID = :wo.Id LIMIT 1 ] );

//         List<FeedItem> fiList = new List<FeedItem>();
//         fiList = [SELECT id, body, parentid FROM FeedItem WHERE parentid =: sa.id ORDER BY LastEditDate ASC];
//         system.debug(fiList);
//         for(FeedItem fi : fiList){
//             system.debug('FEEDITEM: ' + fi);
//         }

//         wo = [SELECT id, LineItemCount FROM WorkOrder WHERE id =: wo.Id LIMIT 1];
//         sa = [SELECT id, dueDate FROM ServiceAppointment WHERE id =: sa.id LIMIT 1];

//         system.assert(fiList[1].Body == '@' + u.LastName + ' You are the assigned resource for a service appointment. \nAccount: ' + acc.Name + '\nLine Items: ' + wo.LineItemCount +'\nDue Date: ' + sa.DueDate);
//         system.assert(fiList[0].body == '@' + u.LastName + ' Your service appointment has been canceled.\nAccount: ' + acc.Name + '\nLine Items: ' + wo.LineItemCount +'\nDue Date: ' + sa.DueDate);

//         test.stopTest();

//     }
}