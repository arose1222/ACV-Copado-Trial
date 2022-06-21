/**
 * Utility class to create test data for Apex Unit Tests.
 * When new objects are added to the Schema we should be adding methods to generate valid data in tests into this class.
 * Annotaed with @isTest to make this only valid to use in Test Classes
 * 
 * @group Utilities
 * @group Starting Out
 */
public class TestUtility {

    /**
     * Creates a standard support case with the basic fields filled out
     * @param  a Represents the buyer account you want the Support Case attached to
     * @return   Baisc Support Case
     */
    public static Case createSupportCase(Account a){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case caseObj = New Case();
        caseObj.Subject = 'Test Subject';
        caseObj.Description = 'Description Test';
        caseObj.Origin='Phone';
        caseObj.RecordTypeId = caseRecordTypeId;
        caseObj.AccountId = a.Id;
        return caseObj;
    }
    
    /**
     * This will link a bunch of Biz Op cases to a single Support case
     * @param  opsCaseList  a List of Biz Op cases you want added to the Support case
     * @param  standardCase The Support Case
     * @return              A list of Customer_Inquiry__c objects connecting Biz Ops cases and the Support Case
     */
    public static List<Customer_Inquiry__c> createRelatedCasesCaseContext(List<Case> opsCaseList, Case standardCase){
        List<Customer_Inquiry__c> rcList = new List<Customer_Inquiry__c>();
        for(Case c :opsCaseList){
            rcList.add(new Customer_Inquiry__c(Ops_Case__c = c.id, Support_Case__c = standardCase.id));
        }
        return rcList;
    }


    /**
     * Creates the basic Condition Report Prescreen assigned to the CR Queue
     * @param  cr A Condition_Report__c object with an Id and Vehicle__c populated
     * @param  a  Account that represents the Seller
     * @param  c  Contact that represents the VCI who preformed the inspection
     * @return    A Valid Condition_Report_Prescreen__c object that is waiting in the CR Queue to be processed
     */
    public static Condition_Report_Prescreen__c createPrescreen(Condition_Report__c cr, Account a, Contact c){
        list<Group> queueList = [select Id from Group where  Type = 'Queue' AND NAME = 'CR Queue'];
        Condition_Report_Prescreen__c crp = new Condition_Report_Prescreen__c();
        crp.Condition_Report__c = cr.id;
        crp.OwnerId = queueList[0].id;
        crp.VCI__c = c.id;
        crp.Seller_Dealership__c = a.id;
        crp.Vehicle__c = cr.Vehicle__c;
        return crp;
    }

    /**
     * Creates an Condition_Report__c with the floor price of $420
     * @param  v Basic vehicle where we only care about the Id field being populated
     * @return   Returns a valid CR with a random Saved Auction ID
     */
    public static Condition_Report__c createCr(Vehicle__c v){
        Condition_Report__c cr = new Condition_Report__c();
        cr.Name='TestCR';
        cr.ACV_Saved_Auction_Id__c=String.valueOf(Integer.valueOf(Math.rint(Math.Random()*100)));
        cr.vehicle__c = v.id;
        cr.Floor_Price__c = 420.00;
        return cr;
    }
    
    /**
     * Creates a simple Vehicle__c record
     * @return   Hard coded values for a Rav4 and MSRP of 26640.0
     */
    public static Vehicle__c createVehicle(){
        Vehicle__c vehicleObj = New Vehicle__c();
        vehicleObj.basic_color__c='4';
        vehicleObj.class_name__c='Small Crossover/SUV';
        vehicleObj.drivetrain__c='AWD';
        vehicleObj.fuel_type__c='Gas';
        vehicleObj.model__c='Rav4';
        vehicleObj.msrp__c = 26640.0;
        vehicleObj.Name ='TestVehicle';
        return vehicleObj;
    }
    
    /**
     * Creates an Auction__c record with prepopulated values
     * @param  actObj     Represents an Account that is used as both the seller and the buyer
     * @param  conObj     Represents the Buyer Contact
     * @param  vehicleobj The Vehicle__c that the auction is for
     * @return            Returns back an Auction__c record with an id__c of 123456 and buyer and seller information populated
     */
    public static Auction__c createAuction(Account actObj, Contact conObj, Vehicle__c vehicleobj){
        Auction__c auctionObj = New Auction__c(
            id__c = '123456',
            floor_price__c=6000.0,
            Name='TestAuction',
            notes__c='Car was sold as it is',
            vehicle_id__c=vehicleobj.Id,
            buyer_dealership__c = actObj.Id,
            seller_dealership__c = actObj.Id,
            buyer_contact__c = conObj.Id
        );
        return auctionObj;
    }

    /**
     * Creates an Auction__c record with prepopulated values
     * @param  actObj     Represents an Account that is used as both the seller and the buyer
     * @param  conObj     Represents the Buyer Contact
     * @param  vehicleobj The Vehicle__c that the auction is for
     * @return            Returns back an Auction__c record with a random Id, and buyer and seller information populated
     */
    public static Auction__c createAuctionWithUniqueId(Account actObj, Contact conObj, Vehicle__c vehicleobj){
        List<String> strList = ACVUtility.NewGuid().split('-');
        Auction__c auctionObj = New Auction__c(
            id__c = strList[0],
            floor_price__c=6000.0,
            Name='TestAuction',
            notes__c='Car was sold as it is',
            vehicle_id__c=vehicleobj.Id,
            buyer_dealership__c = actObj.Id,
            seller_dealership__c = actObj.Id,
            buyer_contact__c = conObj.Id
        );
        return auctionObj;
    }

    /**
     * Creates an Auction__c with a populated Vehicle__c record
     * @param  vehicleobj The Vehicle__c that the auction is for
     * @return            Returns back an Auction__c record with an id__c of 123456 
     */
    public static Auction__c createAuction(Vehicle__c vehicleobj){
        Auction__c auctionObj = New Auction__c(
            id__c='123456',
            floor_price__c=6000.0,
            Name='TestAuction',
            notes__c='Car was sold as it is',
            vehicle_id__c=vehicleobj.Id
        );
        return auctionObj;
    }
    
    /**
     * Creates an Bundle_Offer__c with a populated Dealer__c Id
     * @param  accountId The dealer id
     * @return           Returns back a Bundle_Offer__c record with a random name and bundle_Id__c
     */
    public static Bundled_Offer__c createBundleOffer(Id accountId){
        Bundled_Offer__c bundleOffer = new Bundled_Offer__c(
            name='Test bundle Offer',
            Dealer__c=accountId,
            Bundle_Id__c=123
        );
        return bundleOffer;
    }
    
    /**
     * Creates an Arbitration case with related details
     * @param  auctionObj The Auction__c the arbitration case is about
     * @param  vehicleObj The Vehicle__c the arbitration and auction are related to
     * @param  actObj     The Buyer Account who initiated the Arbitration
     * @param  conObj     The Contact we are working with on the Buyer Side
     * @return            Arbitration Claim case that is ready to start arbitrtion
     */
    public static Case createCase(Auction__c auctionObj,Vehicle__c vehicleObj,Account actObj,Contact conObj){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();
        Case caseObj = New Case();
        caseObj.Auction_Number__c=auctionObj.Id;
        caseObj.Description='Description Test';
        caseObj.Origin='Email';
        caseObj.Priority='High';
        caseObj.Status='New';
        caseObj.Subject='Testing';
        caseObj.Vehicle__c=vehicleObj.Id;
        caseObj.Type = 'Arbitration';
        caseObj.RecordTypeId = caseRecordTypeId;
        caseObj.AccountId = actObj.Id;
        caseObj.ContactId = conObj.Id;
        caseObj.Seller_Dealership__c = actObj.Id;
        caseObj.Buyer_Confusion__c = 'No';
        return caseObj;
    }

    /**
     * Creates an Account with the running users default Record Type and a custom Name
     * @param  uniqueName The Custom Name we want for the Account
     * @return            Basic Account with a custom name
     */
    public static Account createAccount(String uniqueName){
        Account actobj = New Account();
        actobj.Name = uniqueName;
        actobj.Phone = '7161234560';
        actobj.BillingStreet = '12 Test St';
        actobj.BillingCity = 'Buffalo';
        actobj.BillingState = 'NY';
        actobj.BillingPostalCode = '14228';
        actobj.BillingCountry = 'US';
        actobj.legal_Name__c= uniqueName;
        actobj.dealer_type__c='1';
        return actobj;
    }
    
    /**
     * Creates an Account with the running users default Record Type
     * @return   Basic Account
     */
    public static Account createAccount(){
        Account actobj = New Account();
        actobj.Name = 'Test Account';
        actobj.Phone = '7161234560';
        actobj.BillingStreet = '12 Test St';
        actobj.BillingCity = 'Buffalo';
        actobj.BillingState = 'NY';
        actobj.BillingPostalCode = '14228';
        actobj.BillingCountry = 'US';
        actobj.Dealership_ID__c = ACVUtility.NewGuid().substring(0, 10);
        actobj.legal_Name__c='Test Account'; 
        actobj.dealer_type__c='1';
        return actobj;
    }
    
    /**
     * Creates a ACV User cotact record that represnts the a User in the ACV App
     * This class disables a callout so you don't have to.
     * @param  actObj The Account that the User is related to
     * @return        Valid ACV User Contact
     */
    public static Contact createContact(Account actObj){
        Id acvUserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        contact conObj = New Contact();
        conObj.firstName = 'TestNameContact';
        conObj.LastName = 'TestNameLastName';
        conObj.Email = ACVUtility.NewGuid()+'@test.com';
        conObj.AccountId = actObj.Id;
        conObj.Phone = '7161234560';
        conObj.RecordTypeId = acvUserRecordTypeId;
        return conObj;
    }

    /**
     * Creates an Affiliation wich is how we link ACV Users to the Accounts they can manipulate in the ACV App
     * This will fail on insert if we do not use an ACV User contact
     * @param  actObj The Account we want the Contact to be related to
     * @param  conObj The Contact we want the ACV User to be a part of
     * @return        Affiliation__c record that has an admin role and is a Primary Contact
     */
    public static Affiliation__c createAffiliation(Account actObj, Contact conObj){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        Affiliation__c affObj = New Affiliation__c();
        affObj.Account__c = actObj.Id;
        affObj.Contact__c = conObj.Id;
        affObj.primary_contact__c=true;
        affObj.type__c='admin';
        return affObj;
    }
    
    /**
     * Creates a Complaint__c as part of the Arbitration Process
     * @param  caseObj This represents an Arbitration Case that we are attatching the complaint to
     * @return         Returns the child Complaint__c object of the Arb Case Provided
     */
    public static complaint__c createComplaint(Case caseObj){
        Id arbrecordTypeId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('Arbitration Complaint').getRecordTypeId();
        complaint__c complaintObj = New complaint__c();
        complaintObj.RecordTypeId = arbrecordTypeId;
        complaintObj.complaint_type__c='Car Not As Described (Seller)';
        complaintObj.valid__c='Yes';
        complaintObj.description__c='Test';
        complaintObj.createdbyId=UserInfo.getUserId();
        complaintObj.Claim_Parent_Type__c='Driveability';
        complaintObj.claim_type__c='Brakes Inop';
        complaintObj.arbitration_id__c=caseObj.Id;
        complaintObj.avoidable__c='Yes';
        return complaintObj;
    }

    /**
     * Creates a Resolution__c to show that a Complaint has been closed out
     * @param  caseObj      The Arbitration Case
     * @param  complaintObj The Complaint that is being closed
     * @return              Resolution__c that is set to be a Check for $600
     */
    public static Resolution__c createResolution(Case caseObj, Complaint__c complaintObj){
        Resolution__c resolutionObj = New Resolution__c();
        resolutionObj.Amount__c=600.00;
        resolutionObj.Resolution__c='ACV Issue Check';
        resolutionObj.Goodwill__c=True;
        resolutionObj.createdbyId=UserInfo.getUserId();
        resolutionObj.Case__c=caseObj.Id;
        resolutionObj.complaint_id__c=complaintObj.Id;
    return resolutionObj;
    }
    
    /**
     * This only creates a Transpotation_Address__c not to be confused with the standard SF Address Model
     * @return   Represnets the Main office location of 520 Ellicott Street
     */
    public static Transportation_Address__c createAddress(){
        Transportation_Address__c addressObj = new Transportation_Address__c(
            Name = '520 Ellicott Street'
            );
        return addressObj;

    }

    /**
     * Creates a basic Transportation Case
     * @param  addressObj The Address the Car is going to
     * @param  actObj     The Account we are transporting the car for
     * @param  conObj     Contact of the Account
     * @param  auctionObj Auction we are transporting for
     * @return            A Case with all the properties to be considered a transportation case
     */
    public static Case createTransportCase(Transportation_Address__c addressObj, Account actObj, Contact conObj, Auction__c auctionObj){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();

        Case caseObj = new Case();
        caseObj.Auction_Number__c=auctionObj.Id;
        caseObj.RecordTypeId = caseRecordTypeId;
        caseObj.Status = 'Awaiting Release';
        caseObj.Subject = 'Test Transport Case';
        caseObj.AccountId = actObj.Id;
        caseObj.ContactId = conObj.Id;
        caseObj.Delivery_Address_Lookup__c = addressObj.Id;
        caseObj.Pickup_Address_Lookup__c = addressObj.Id;
        caseObj.Buyer_Price__c = 500;
        return caseObj;

    }

    /**
     * Creates an Account with the Transporter record type
     * @return   Basic Transporter Account Named 'Test Transporter'
     */
    public static Account createTransportAcct(){
        Id caseRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transporters').getRecordTypeId();

        Account acctObj = new Account();
        acctObj.RecordTypeId = caseRecordTypeId;
        acctObj.Name = 'Test Transporter';
        acctObj.No_DOT__c = true;
        return acctObj;
    }

    /**
     * Creates a Basic Recommended Price Object
     * @param  auctionObj The Auction we are recommending a price for
     * @param  vehicleObj The Vehicle we are basing the auction off of
     * @return            Retuns back an active Recommended Price object
     */
    public static Recommended_Price__c createRecommended_Price(Auction__c auctionObj, Vehicle__c vehicleObj){
        Recommended_Price__c recPriceObj = new Recommended_Price__c(
            Auction_Where_Vehicle_Launched__c = auctionObj.Id,
            Vehicle__c = vehicleObj.Id,
            Condition_Rating__c = 4,
            Pricing_Reason__c = 'Condition',
            Pricing_Status__c = 'Active',
            Price_Floor__c = 5000,
            Validate_Price_Floor__c = 5000,
            Price_Ceiling__c = 10000,
            Validate_Price_Ceiling__c = 10000,
            Saved_Auction_Id__c = '1234',
            Send_To_ACV__c = true
        );
        return recPriceObj;
    }
    
    /**
     * Creates a Title Cas with no seller set
     * @param  auctionObj The auction that we are working a title for
     * @param  accountObj The Buyer Account
     * @param  conObj     The Buyer Contact
     * @return            Returns a Title Case in the 'Received' status
     */
    public static Case createTitleCase(Auction__c auctionObj, Account accountObj, Contact conObj){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case caseObj = new Case(
            Status = 'Received',
            Auction_Number__c = auctionObj.Id,
            AccountId = accountObj.Id,
            ContactId = conObj.Id,
            Subject = 'Title Testing',
            RecordTypeId = caseRecordTypeId,
            Easypost_Parcel_Predefined_Package__c = 'FedExEnvelope',
            Easypost_Parcel_Weight__c = 10,
            Default_Delivery_Address__c = '12 Test St',
            Default_Delivery_Address_Line2__c = 'Suite 1',
            Default_Delivery_City__c = 'Buffalo',
            Default_Delivery_State__c = 'NY',
            Default_Delivery_Postal_Code__c = '14228',
            Pickup_Address__c = '12 Test St',
            Pick_Up_Address_Line_2__c = 'Suite 1',
            Default_Pickup_City__c = 'Buffalo',
            Default_Pickup_State__c = 'NY',
            Default_Pickup_Postal_Code__c = '14228',
            ACV_Titles_External_ID__c = ACVUtility.NewGuid()
        );
        return caseObj;
    }

    /**
     * Creates a Group
     * This is for creating Groups of Accounts/Organizations
     * @param  uniqueGroupName Name that will be given to the group
     * @return                 An active group with a rank of 150
     */
    public static Group__c createGroup(String uniqueGroupName){
        return new Group__c(
            Name = uniqueGroupName,
            Active__c = true,
            Top_150_Rank__c = 150
        );
    }

    /**
     * Adds a list of Accounts to a single Group
     * @param  g        The Group we want to add Accounts to
     * @param  Accounts The Accounts
     * @return          A List of Group_Affiliation__c records for the group and accounts you passed in
     */
    public static List<Group_Affiliation__c> createGroupAffiliation(Group__c g, List<Account> Accounts){
        List<Group_Affiliation__c> returnList = new List<Group_Affiliation__c>();
        for(Account a :accounts){
            returnList.add(new Group_Affiliation__c(Group__c = g.id,Account__c = a.id));
        }
        return returnList;
    }

    /**
     * Creates a Lead with basic data
     * @return   A new Lead
     */
    public static Lead createLead() {
        return new Lead(
            Company = 'Test Corp',
            LastName = 'Johnson',
            PostalCode = '14209',
            Street = '101 Main Street',
            City = 'Buffalo',
            Country = 'US',
            State = 'New York',
            Email = 'johnson@company.com.test',
            Description = 'This is the company, you should speak with Johnson',
            DoNotCall = FALSE,
            HOT_NOTES__c = 'These are some hot notes',
            Industry = 'Transportation',
            Rating = 'Prospect',
            LeadSource = 'Email',
            Status = 'Untouched',
            Phone = '1234567890',
            Title = 'CEO'
        );
    }

    public static final id SYSTEM_ADMIN_PROFILE_ID  = [SELECT Id FROM Profile WHERE Name='System Administrator'].id;

    /**
     * Creates a user with the 'Standard User' profile
     * @return   A Standard User with the America/New_York time zone
     */
    public static User createUser() {
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        return createUser( p.Id );
    }

    /**
     * Creates a user with the provided Profile Id
     * @param  pId Profile Id you want the new user to have
     * @return     A User with the America/New_York time zone
     */
    public static User createUser( Id pId ) {
        if(pId == SYSTEM_ADMIN_PROFILE_ID){
            insertValidationBypass();
        }
        
        String uniqueUserName = 'testuser' + ACVUtility.NewGuid() + '@test.com';
        
        User newUser = new User(
            Alias = 'standt', Email=uniqueUserName, EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pId, TimeZoneSidKey='America/New_York', UserName=uniqueUserName,
            Street = '101 Main Street', City = 'Buffalo', State = 'New York', PostalCode = '14203', Country = 'US'
        );

        return newUser;
    }

    public static User createSystemAdministratorUser(){
        return createUser(SYSTEM_ADMIN_PROFILE_ID);
    }

    public static void insertValidationBypass(){
        if([Select count() FROM Validation_Bypass__c] < 1 && Test.isRunningTest()){
            Validation_Bypass__c vb = new Validation_Bypass__c(System_Admin_Assignment__c = true);
            insert vb;
        }
    }

    /**
     * Creates a Private Lane
     * @return   An open Private Lane with a Large Duration and Make Offer Duration
     */

    public static Private_Lane__c createPrivateLane(){
        Private_Lane__c pl = new Private_Lane__c();
        pl.Name = 'Test Private Lane';
        pl.Lane_Id__c = ACVUtility.NewGuid();
        pl.Status__c = 'Open';
        pl.Frequency__c = 'Perpetual';
        pl.Auction_Duration__c = 999999;
        pl.Make_Offer_Duration__c = 9999999;
        pl.Payment_Options__c = 'Default';
        pl.Custom_Start_Price_Value__c = 100;
        pl.Custom_Start_Price_Type__c = 'Percent';
        // pl.Preview_Duration__c = 60;
        // pl.Preview_Start_Price__c = true;
        // pl.Preview_Proxy_Bidding__c = true;
        return pl;
    }
    /**
     * Creates a Junktion between a Fee and Private Lane
     * @param  fee The Fee to be assigned to the Lane
     * @param  pl  The Private Lane we are assigning a fee to
     * @return     Assigned_Fee__c junction object
     */
    public static Assigned_Fee__c createAssignedFee( Fee__c fee, Private_Lane__c pl ){
        Assigned_Fee__c af = new Assigned_Fee__c();
        af.Fee__c = fee.Id;
        af.Private_Lane__c = pl.Id;
        af.Override_Amount__c = 100;
        af.RecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Standard_Fee').getRecordTypeId();
        return af;
    }

    /**
     * Creates a Buyer Fee for $100
     * @return   Fee__c object
     */
    public static Fee__c createFee(){
        Fee__c fee = new Fee__c();
        fee.Name = 'Buy Fee';
        fee.Type__c = 'Buyer Fee';
        fee.Default_Amount__c = 100;
        return fee;
    }

    /**
     * Provides Private Lane access to a Group
     * @param  pl       The Private Lane we are providing access for
     * @param  orgGroup The group who is getting access
     * @return          Private_Lane_Access__c juntion object
     */
    public static Private_Lane_Access__c createPrivateLaneAccess( Private_Lane__c pl, Group__c orgGroup ){
        Private_Lane_Access__c pla = new Private_Lane_Access__c();
        pla.Private_Lane__c = pl.Id;
        pla.Organization_Group__c = orgGroup.Id;
        pla.Buying_Power__c = false;
        pla.Selling_Power__c = false;
        return pla;
    }

    /**
     * S3 Reference Object with a random GUID
     * @return   Reference URL is 'www.testUrl.com'
     */
    public static S3_Reference__c createS3Reference(){
        S3_Reference__c ref = new S3_Reference__c();
        ref.Name = 'Test Reference';
        ref.External_Record_Guid__c = ACVUtility.newGuid();
        ref.S3_URL__c = 'www.testUrl.com';
        return ref;
    }

    /**
     * Creates an S3 Association with the provided S3 Reference
     * @param  ref S3 Reference with an S3 URL
     * @return     S3_Association__c with S3_Reference__c populated
     */
    public static S3_Association__c createS3Association( S3_Reference__c ref ){
        S3_Association__c assoc = new S3_Association__c( S3_Reference__c = ref.Id );
        return assoc;
    }
    public static List<Account> AccountWithStandardRecType() {
        
        Id iAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        List<Account> lAccount = new List<Account>();
        
        lAccount.add(new Account (Name='Test Acc1', legal_name__c='Name 1',Dealer_Type__c='1',RecordTypeId =iAccountRecordTypeId,IST_Account_Owner__c=UserInfo.getUserId()));
        lAccount.add(new Account (Name='Test Acc2', legal_name__c='Name 1',Dealer_Type__c='2',RecordTypeId =iAccountRecordTypeId,IST_Account_Owner__c=UserInfo.getUserId()));
        lAccount.add(new Account (Name='Test Acc3', legal_name__c='Name 1',Dealer_Type__c='2',RecordTypeId =iAccountRecordTypeId));    
        lAccount.add(new Account (Name='Test Acc4', legal_name__c='Name 1',Dealer_Type__c='4',RecordTypeId =iAccountRecordTypeId ));
        
        return lAccount;        
     }
    
       public static List<Account> AccountCreationWithNonStandardRecType() {
       Id iAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId(); 
        List<Account> lAccount = new List<Account>();
        
        lAccount.add(new Account (Name='Test Acc1', legal_name__c='Name 1',Dealer_Type__c='1',RecordTypeId =iAccountRecordTypeId,IST_Account_Owner__c=UserInfo.getUserId()));
        lAccount.add(new Account (Name='Test Acc2', legal_name__c='Name 1',Dealer_Type__c='2',RecordTypeId =iAccountRecordTypeId,IST_Account_Owner__c=UserInfo.getUserId()));
        
        return lAccount; 
        
    } 
    /**
     * Returns an instance of a test ContentVersion
     * @param title title of the Content Document you are creating
     * @return  `ContentVersion` to be iserted
     */
    public static ContentVersion createContentVersion( String title ){
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = 'test.csv';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        return cv;            
    }
    
    /**
     * Creates a Customer Inquiry with related details
     * @param supportCase   The related support Case 
     * @param acc           The related account
     * @return              Customer Inquiry with support case and account
     */
    public static Customer_Inquiry__c createCustomerInquiry(Case supportCase, Account acc){
        Customer_Inquiry__c ci = new Customer_Inquiry__c();
        ci.Support_Case__c = supportCase.Id;
        ci.Account__c = acc.Id;
        return ci;
    }
    
    /**
     * Creates a Dealership Contact record that is directly connected to provided account
     * This class disables a callout so you don't have to.
     * @param  actObj The Account that the contact is related to
     * @return        Valid Dealership Contact
     */
    public static Contact createDealerContact(Account actObj){
        Id dealerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();

        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        contact conObj = New Contact();
        conObj.firstName = 'TestNameContact';
        conObj.LastName = 'TestNameLastName';
        conObj.Email = ACVUtility.NewGuid()+'@test.com';
        conObj.AccountId = actObj.Id;
        conObj.Phone = '7161234560';
        conObj.RecordTypeId = dealerContactRecordTypeId;
        return conObj;
    }
    public static Vendor_Engagement__c createVendorEngagement( Id caseRecId, Id accRecId){
        Vendor_Engagement__c vendorRec = new Vendor_Engagement__c();
        vendorRec.Ops_Case__c = caseRecId;
        vendorRec.Vendor_Name__c = accRecId;
        vendorRec.Status__c = 'Submitted';
       
        return vendorRec;
    }
    public static Event createEvent(){
        Event oEvent = new Event();
        oEvent.subject ='Call';
        oEvent.ActivityDateTime = system.now().adddays(1);
        oEvent.StartDateTime = oEvent.ActivityDateTime;
        oEvent.EndDateTime = (oEvent.StartDateTime).addHours(1);
        oEvent.DurationInMinutes = 60;
        oEvent.Type = 'Call';
        
        return oEvent;
    }
    /**
     * Crates a Draft instance of a Rate Card
     * @return  `Rate_Card__c`
     */
    public static Rate_Card__c createRateCard(){
        Rate_Card__c rc = new Rate_Card__c();
        rc.Approval_Status__c = 'Draft';
        rc.Display_Name__c = 'Test Rate Card';
        rc.Fee_Type__c = 'buy_fee';
        rc.Rate_Card_State__c = 'Active';
        return rc;
    }
    /**
     * Returns a Rate Card Fee attached to the Rate Card provided
     * @param rc Rate Card to attach to
     * @param priceMin Minimum Price
     * @param feeCharged Fee charged for that price range
     * @return  `Rate_Card_Fee__c`
     */
    public static Rate_Card_Fee__c createRateCardFee( Rate_Card__c rc, Decimal priceMin, Decimal feeCharged ){
        Rate_Card_Fee__c rcf = createRateCardFee( priceMin, feeCharged );
        rcf.Rate_Card__c = rc.Id;
        return rcf;
    }
    /**
     * Returns a Rate Card Fee attached to the Rate Card provided
     * @param priceMin Minimum Price
     * @param feeCharged Fee charged for that price range
     * @return  `Rate_Card_Fee__c`
     */
    public static Rate_Card_Fee__c createRateCardFee( Decimal priceMin, Decimal feeCharged ){
        Rate_Card_Fee__c rcf = new Rate_Card_Fee__c();
        rcf.Price_Min__c = priceMin;
        rcf.Fee_Charged__c = feeCharged;
        return rcf;
    }
     //Create User
    Public static User createUser(string Email,string UserName,string LastName ){
        Profile pf= [Select Id from profile where Name='Standard User']; 
        user u = new user();
        u.Alias = 'Alias';
        u.Email = Email;
        u.country = 'United States';
        u.EmailEncodingKey='UTF-8';
        u.LastName= LastName;
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.UserName= UserName;
        u.profileId =pf.id;
        
        return u;
    }

    /**
     * Grants delete permissions to contact object for the user id
     * @param  uId Userid
    */
    public static void addContactDeletePermission(Id uId){
    PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Can_Modify_All_Contacts'];
    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = uId);
    insert psa;
    }
    /**
     * Creates a Submitted Credit of Credits_Check__c
     * @param accountId 
     * @param budgetId 
     * @return  `Credits_Checks__c`
     */
    public static Credits_Checks__c createCredit( Id accountId, Id budgetId ){
        Credits_Checks__c cc = new Credits_Checks__c();
        cc.Dealer__c = accountId;
        cc.Name = 'Arbitration';
        cc.Amount_Requested__c = 300;
        cc.Approval_Status__c = 'Submitted';
        cc.Expiration_Date__c = Date.today().addDays(60);
        cc.Explanation__c = 'test';
        cc.Payment_Type__c = 'ACV Credit Assigned';
        cc.Budget_Name__c = budgetId;
        cc.RecordTypeId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId();
        return cc;
    }
    /**
     * Creates an instance of a Limitless budget
     * @return  `Budget__c` a Limitless budget
     */
    public static Budget__c createBudget(){
        Budget__c budget = new Budget__c();
        budget.Name = 'Test Budget';
        budget.Limitless_Budget__c = true;
        budget.Current_Balance__c = 10000;
        budget.Starting_Balance__c = 10000;
        return budget;
    }
}