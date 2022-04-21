@isTest
public class VCIAssignmentUpdateTest {
    
    
    @TestSetup
    public static void makeData(){
        system.runAs(new user(id=UserInfo.getUserId())){
            List<Profile> p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1]; 
            system.debug(p);
            List<UserRole> ur = [SELECT Id from UserRole where ParentRoleId = null limit 1];
            system.debug(ur);
            // User u = new User(Alias = 'standt', Email='standarduser@acvtest.com', 
            //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            //     LocaleSidKey='en_US', ProfileId = p[0].Id, UserRoleId = ur[0].id,
            //     TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acvtest.com');
            User u =TestUtility.createUser();
            u.UserRoleId = ur[0].id;
            insert u;
        }
        
      List<Account> accountList = New List<Account>();
      accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId(), shippingStreet = '123 test St', shippingCity = 'test city', shippingState = 'test state', shippingCountry = 'test country', shippingPostalCode = '0000000'));
      accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
      insert accountList;
      List<Contact> contactList = new List<Contact>();
      contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
      contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
      insert contactList;
      vehicle__c newCar = new vehicle__c(Most_Recent_Seller__c = accountList[0].id,year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
      insert newCar;
      
    }

    @isTest
    public static void testCreatingEvent(){
        List<vehicle__c> carList = [Select id from vehicle__c];
        List<User> userList = [select id from user where Alias = 'standt'];
        system.debug(userList);
        if(carList.size() > 0){
            Event e = new Event(whatId = carList[0].id, type ='Vehicle Inspection',OwnerId = userList[0].id, subject ='test', ActivityDateTime = system.now().adddays(1),  DurationInMinutes = 90);
            insert e;
        }

        List<Event> eList=  [select id from event where subject != 'test'];
        system.debug(eList);
        system.assert(eList.size() >= 1 , 'Events were not updated properly -- good code');

    }

    @isTest
    public static void testCreatingBadEvent(){
        List<vehicle__c> carList = [Select id from vehicle__c];
        List<User> userList = [select id from user where Alias = 'standt'];
        if(carList.size() > 0){
            Event e = new Event(whatId = carList[0].id, OwnerId = userList[0].id, subject ='test', ActivityDateTime = system.now().adddays(1),DurationInMinutes = 90);
            insert e;
        }

        List<Event> eList=  [select id from event where subject != 'test'];
        system.debug(eList);
        system.assert(eList.size() == 0, 'Events were not updated properly -- bad code');

    }
}