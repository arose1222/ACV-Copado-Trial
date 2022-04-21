/**
 * Utility class to create FSL test data for Apex Unit Tests.
 *
 * @group Utilities
 */
public class FSLTestUtility {
    // WorkType Names
    public final static String INSPECTION = 'Standard Inspection';
    public final static String ASSET = 'Asset Verification';
    public final static String TRUE_360 = 'True 360';

    /**
     * Generic Data creation method that will create all the FSL set-up data, as well as make and commit a Standard Inspection Work Order, Service Appointment, and X number of line items
     * @param acct An inserted Account that will be used to assign a work order and service appointment to
     * @param numberOfLineItems The number of auto-generatored line items you wish to make under the generated Work Order
     */
    public static void createData( Account acct, Integer numberOfLineItems ) {
        final String ZIPCODE = '14209';
        final String TERRITORY_NAME = 'Buffalo';
        createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        Map<String, WorkType> wtMap = new Map<String, WorkType>();
        for ( WorkType wtRec : [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name IN :( new Set<String>{ INSPECTION } ) ] ) {
            wtMap.put( wtRec.Name, wtRec );
        }
        generateWork( wtMap.get( INSPECTION ), wtMap.get( INSPECTION ), acct, ZIPCODE, stRec, numberOfLineItems );
    }

    /**
     * Creates the FSL set-up data, committing it all to the database, for proper
     * @param childTerritoryName Name of the Territory you wish to create
     * @param zipCodeNum Zipcode you wish to associate with the Territory (for Legacy purposes - To be deprecated)
     */
    public static void createAllStructureWithParentST( String childTerritoryName, String zipCodeNum ) {
        insert createWorkTypes();

        insert createWorkTypeGroups();
        insert createWorkTypeGroupMembers();


        List<OperatingHours> opLst = createOperatingHours( new Set<String>{ 'EDT Mon-Fri 8am-8pm, Sat 9am-5pm' } );
        insert opLst;
        insert createTimeSlots( new Set<Id>{ opLst[0].Id } );
        //List<ServiceTerritory> parentSTLst = createST( new Map<String, ServiceTerritoryStructure>{ parentTerritoryName => new ServiceTerritoryStructure( opLst[0].Id ) } );
        //insert parentSTLst;
        // Parent Territory will be added in later, there are issues from a data perspective that need to be investigated
        List<ServiceTerritory> stLst = createST( new Map<String, ServiceTerritoryStructure>{ childTerritoryName => new ServiceTerritoryStructure( opLst[0].Id/*, parentSTLst[0].Id*/ ) } );
        insert stLst;
    }

    /**
     * Generates Work Order, Work Order Line Item, and Service Appointment data based off the provided parameters
     * @param workTypeParentRec Work Type associated with the Parent Work Order
     * @param workTypeChildRec Work Type associated with the children Work Order Line Items
     * @param acctRec The Account that will parent the Work Order & Service Appointment
     * @param postalCode The zipcode to associate with the Work Order & Service Appointment Address
     * @param servTerrRec The Service Territory that the Work Order & Service Appointment records
     * @param numberOfLineItems The number of auto-generatored line items you wish to make under the generated Work Order
     * @return  Generated and committed Structure of Work Order to Work Order Line Items, based off the provided data
     */
    public static WorkStruct generateWork( WorkType workTypeParentRec, WorkType workTypeChildRec, Account acctRec, String postalCode, ServiceTerritory servTerrRec, Integer numberOfLineItems ) {
        WorkStruct returnData = new WorkStruct();
        returnData.wo = createWorkOrder( workTypeParentRec, acctRec, postalCode, servTerrRec, null );
        insert returnData.wo;

        for ( Integer index = 0; index < numberOfLineItems; index++ ) {
            returnData.woLst.add(
                createWorkOrderLineItem( returnData.wo, workTypeChildRec, index )
            );
        }

        insert returnData.woLst;
        return returnData;
    }

    /**
     * Method designed to create a Service Resource based off the standard VCI, creating a new user and committing both records to the database
     * @return A successfully committed Service Resource setup for a VCI User
     */
    public static ServiceResource makeResourceData() {
        Account testAcct;
        try { 
            testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        } catch ( exception e ) {
            // No Account Found, make one
            testAcct = TestUtility.createAccount( 'TEST Account Dealership' );
            insert testAcct;
        }
        Contact testCon = TestUtility.createContact( testAcct );
        insert testCon;

        return makeResourceData( testCon );
    }

    /**
     * Method designed to create a Service Resource based off the standard VCI, creating a new user and committing both records to the database
     * @param providedContact A Contact, ideally already in the DB, that has an email for the Resource to be created with
     * @return A successfully committed Service Resource setup for a VCI User
     */
    public static ServiceResource makeResourceData( Contact providedContact ) {
        return makeResourceData( providedContact, 'Vehicle Condition Inspector' );
    }

    /**
     * Method designed to create a Service Resource based off the standard VCI, creating a new user and committing both records to the database
     * @param providedContact A Contact, ideally already in the DB, that has an email for the Resource to be created with
     * @param profileName A specific profile for the user in the Service Resource creation process
     * @return A successfully committed Service Resource setup for a VCI User
     */
    public static ServiceResource makeResourceData( Contact providedContact, String profileName ) {
        // Make Service Resource & Preference
        // Create User:
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName ];

        User vciTestUser = TestUtility.createUser( p.Id );
        vciTestUser.Email = providedContact.Email;
        insert vciTestUser;

        providedContact.ACV_User__c = vciTestUser.Id;
        providedContact.Identity_Id__c = ACVUtility.NewGuid();
        update providedContact;

        ServiceResource vciServiceResource;

        // Make Permission Set Assignment for 'FSL Resource License' (Scheduling License)
        if ( Test.isRunningTest() ) { 
            System.runAs( vciTestUser ) { 
                insert FSLTestUtility.makePermissionSet( vciTestUser.Id );
            }

            // Create Service Resource (needed for Service Territory Member):
            vciServiceResource = new ServiceResource(
                Name = 'vciTestServiceResource',
                RelatedRecordId = vciTestUser.Id,
                ResourceType = 'T',
//                ASI_Resource_Id__c = vciTestUser.Id, 
                IsActive = true
            );
            insert vciServiceResource;
        } else { makeFuturePermissionSet( vciTestUser.Id ); DateTime start = System.Now().addSeconds(5); while(System.Now().getTime() < start.getTime()){} makeFutureServiceResource( vciTestUser.Id ); } 
        // Race condition due to system restructions

        return vciServiceResource;
    }

    @future
    private static void makeFuturePermissionSet( String userId ) {
        insert FSLTestUtility.makePermissionSet( userId );
    }

    @future
    private static void makeFutureServiceResource( String userId ) {
        insert new ServiceResource(
            Name = 'vciTestServiceResource',
            RelatedRecordId = userId,
            ResourceType = 'T',
//            ASI_Resource_Id__c = userId, 
            IsActive = true
        );
    }

    private final static Id SCHEDULING_PERMISSION_SET_ID {
        get {
            if ( SCHEDULING_PERMISSION_SET_ID == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'FSL Resource License' LIMIT 1 ];
                if ( !String.isBlank( setting.Value__c ) ) {
                    SCHEDULING_PERMISSION_SET_ID = [ SELECT Id FROM PermissionSet WHERE Name = :setting.Value__c LIMIT 1 ].Id;
                }
            }
            return SCHEDULING_PERMISSION_SET_ID;
        }
        set;
    }

    public static PermissionSetAssignment makePermissionSet( Id userId ) {
        return new PermissionSetAssignment(
            PermissionSetId = SCHEDULING_PERMISSION_SET_ID,
            AssigneeId = userId
        ); 
    }

    public static void makeAR( ServiceAppointment saRec ) {
        ServiceResource srRec = FSLTestUtility.makeResourceData();
        makeAR( saRec, srRec );
    }

    public static void makeAR( ServiceAppointment saRec, ServiceResource srRec ) {
        insert makePrimarySTM( srRec.Id, saRec.ServiceTerritoryId, saRec.ServiceTerritory.OperatingHoursId );
        
        AssignedResource testAR = new AssignedResource(
            ServiceAppointmentId = saRec.Id,
            ServiceResourceId = srRec.Id
        );
        insert testAR;
    }

    public static ServiceTerritoryMember makePrimarySTM( Id serviceResourceId, Id serviceTerritoryId, Id operatingHoursId ) {
        return makeSTM( serviceResourceId, serviceTerritoryId, operatingHoursId, 'P', DateTime.now().addDays(-1), null );
    }

    public static ServiceTerritoryMember makeSTM( Id serviceResourceId, Id serviceTerritoryId, Id operatingHoursId, String stmType, DateTime startTime, DateTime endTime ) {
        return new ServiceTerritoryMember(
            ServiceResourceId = serviceResourceId, 
            ServiceTerritoryId = serviceTerritoryId, 
            EffectiveStartDate = startTime, 
            EffectiveEndDate = endTime,
            TerritoryType = stmType,
            OperatingHoursId = operatingHoursId
        );
    }

    /**
     * Method takes an Account and creates a Service Resource, with a Resource Preference for the provided Account
     * @param record Committed Account that is used to define a Resource Preference under
     * @return A successfully committed Service Resource with a Resource Preference created for it
     */
    public static ServiceResource makePreferredResourceData( sObject record ) {
        ServiceResource vciServiceResource = makeResourceData();

        ResourcePreference acctPrefRec = new ResourcePreference(
            RelatedRecordId = record.Id,
            ServiceResourceId = vciServiceResource.Id
        );
        insert acctPrefRec;

        return vciServiceResource;
    }

    /**
     * Basic method to generate generic and minimal Work Order, regardless of Work Type, but does not commit it to the database, with the provided data
     * @param workTypeRec The Work Type associated with the generated Work Order
     * @param acctRec The Account associated with the generated Work Order
     * @param postalCode The Zipcode of the address associated with the generated Work Order
     * @param servTerrRec The Service Territory associated with the generated Work Order
     * @param optionalContactId Optional Parameter of a Contact Id, this can be set to null if not desired or needed
     * @return Generated, but not committed Work Order based off the provided data
     */
    public static WorkOrder createWorkOrder( WorkType workTypeRec, Account acctRec, String postalCode, ServiceTerritory servTerrRec, Id optionalContactId ) {
        return new WorkOrder(
            AccountId = acctRec.Id,
            Street = '101 Main Street',
            City = 'Buffalo',
            State = 'New York',
            Country = 'US',
            PostalCode = postalCode,
            WorkTypeId = workTypeRec.Id,
            ContactId = optionalContactId,
            Subject = workTypeRec.Name + ' ' + acctRec.Name,
            ServiceTerritoryId = servTerrRec.Id,
            Duration = WorkTypeRec.EstimatedDuration,
            DurationType = WorkTypeRec.DurationType,
            Origin__c = 'Apex Test Code',
            Status = 'New'
        );
    }

    /**
     * Generates a generic and minimalist Work Order Line Item, but does not commit it to the database, with the provided data
     * @param woRec An already committed Work Order to be the parent of the generated Work Order Line Items
     * @param workTypeRec The Work Type to associate with this individual Work Line Item
     * @param lineNum The number associated with this Work Order Line Item's vin
     * @return Generated, but not committed Work Order Line Item based off the provided data
     */
    public static WorkOrderLineItem createWorkOrderLineItem( WorkOrder woRec, WorkType workTypeRec, Integer lineNum ) {
        return new WorkOrderLineItem(
            WorkOrderId = woRec.Id,
            Make__c = 'Chevy',
            Model__c = 'Trax',
            Year__c = '2020',
            Color__c = 'Black',
            Stock_Number__c = 'AAR@101-Delta-Romeo-1234',
            VIN__c = '12345678901234' + lineNum,
            WorkTypeId = workTypeRec.Id,
            Street = woRec.Street,
            City = woRec.City,
            State = woRec.State,
            Country = woRec.Country,
            PostalCode = woRec.PostalCode,
            Title_With_Dealer__c = FALSE,
            Dealer_Contact__c = 'John Smith',
            Residential__c = FALSE,
            Add_To_Run_List__c = FALSE,
            Floor_Price__c = null,
            Date_Inspected__c = null,
            Duration = workTypeRec.EstimatedDuration,
            DurationType = WorkTypeRec.DurationType,
            External_Record_Guid__c = ACVUtility.NewGuid(),
            Earliest_Start_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays( 7 ),
            Status = 'New',
            Transport_Status__c = null,
            Description = 'These are inspection notes: Go meet John out back by the gate, he will have keys',
            Dealership_Name__c = 'Johnny\'s Place',
            Origin__c = 'Apex Test Code'
        );
    }


    /**
     * Generates the standard ACV Work Types for the system, but does not commit them
     * @return Generated, but not committed, standard ACV Work Types
     */
    public static List<WorkType> createWorkTypes() {
        List<WorkType> wtLst = new List<WorkType>();
        // Leave 'inspection' at the top.  Code in RevolvingGenerationMissedTest.cls expects it to be first.  This will need to be fixed.  11/20/2021 GMI
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'inspection', Name = INSPECTION, EstimatedDuration = 30, DurationType = 'Minutes', VIN_required__c = TRUE, Respects_Number_of_Vehicles__c = TRUE, Allow_for_Revolving_Appointments__c = TRUE, Work_Type_Color__c = '#FFA500'));

        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'acvhome', Name = 'ACV Anywhere', EstimatedDuration = 30, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#7B3F00'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'arbitration inspection', Name = 'Arbitration Inspection', EstimatedDuration = 5, DurationType = 'Minutes', VIN_required__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#191970'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'auction off-lease', Name = 'Auction Off-Lease', EstimatedDuration = 35, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Allow_for_Revolving_Appointments__c = TRUE, Work_Type_Color__c = '#F8C8DC '));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'auction site', Name = 'Auction Site', EstimatedDuration = 20, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FF00FF'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'buyer signup', Name = 'Buyer Signup', EstimatedDuration = 60, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#CF9FFF'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'consumer', Name = 'Consumer', EstimatedDuration = 50, DurationType = 'Minutes', VIN_required__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#7B3F00'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpobm', Name = 'CPOBM', EstimatedDuration = 210, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpofr', Name = 'CPOFR', EstimatedDuration = 155, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpolnc', Name = 'CPOLNC', EstimatedDuration = 130, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpogm', Name = 'CPOGM', EstimatedDuration = 240, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpogmcomp', Name = 'CPOGMCOMP', EstimatedDuration = 240, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn04', Name = 'CPOHN04', EstimatedDuration = 105, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn06', Name = 'CPOHN06', EstimatedDuration = 130, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn08', Name = 'CPOHN08', EstimatedDuration = 155, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn10', Name = 'CPOHN10', EstimatedDuration = 205, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn12', Name = 'CPOHN12', EstimatedDuration = 205, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn14', Name = 'CPOHN14', EstimatedDuration = 230, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn16', Name = 'CPOHN16', EstimatedDuration = 255, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn18', Name = 'CPOHN18', EstimatedDuration = 280, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohn20', Name = 'CPOHN20', EstimatedDuration = 300, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpohnice', Name = 'CPOHNICE', EstimatedDuration = 120, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'cpopo', Name = 'CPOPO', EstimatedDuration = 120, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'dealer', Name = 'Dealer', EstimatedDuration = 25, DurationType = 'Minutes', VIN_required__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FF0000'));
//        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'documentation gathering', Name = 'Documentation Gathering', EstimatedDuration = 30, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#7CFC00'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'fbi', Name = 'FBI', EstimatedDuration = 120, DurationType = 'Minutes', VIN_required__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#7B3F00'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'gmfia', Name = 'GMFIA', EstimatedDuration = 240, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FDDA0D'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'mystery test', Name = 'Mystery Test', EstimatedDuration = 150, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#00FFF6'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'other business', Name = 'Other Business', EstimatedDuration = 180, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#D3D3D3'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'promo work', Name = 'Promo Work', EstimatedDuration = 30, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#008000'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'quality audit', Name = 'Quality Audit', EstimatedDuration = 270, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#808080'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'siriusxm', Name = 'Sirius XM', EstimatedDuration = 5, DurationType = 'Minutes', VIN_required__c = false, Respects_Number_of_Vehicles__c = TRUE, Allow_for_Revolving_Appointments__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#191970'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'true360', Name = TRUE_360, EstimatedDuration = 25, DurationType = 'Minutes', VIN_required__c = TRUE, Respects_Number_of_Vehicles__c = TRUE, Allow_for_Revolving_Appointments__c = TRUE, Work_Type_Color__c = '#87CEEB'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'unwind inspection', Name = 'Unwind Inspection', EstimatedDuration = 30, DurationType = 'Minutes', VIN_required__c = TRUE, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#CF9FFF'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'vcpofr', Name = 'VCPOFR', EstimatedDuration = 75, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'vcpogm', Name = 'VCPOGM', EstimatedDuration = 210, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'vcpohn', Name = 'VCPOHN', EstimatedDuration = 120, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'vcpopo', Name = 'VCPOPO', EstimatedDuration = 120, DurationType = 'Minutes', VIN_required__c = false, ShouldAutoCreateSvcAppt = false, Work_Type_Color__c = '#FFFAA0'));
        wtLst.add( new WorkType( Work_Type_Unique_ID__c = 'verification', Name = ASSET, EstimatedDuration = 5, DurationType = 'Minutes', VIN_required__c = TRUE, Work_Type_Color__c = '#0437F2'));

        return wtLst;
    }

    /**
     * Generates the standard ACV Work Types Groups for the system, but does not commit them
     * @return Generated, but not committed, standard ACV Work Types
     */
    public static List<WorkTypeGroup> createWorkTypeGroups() {
        List<WorkTypeGroup> wtGroupLst = new List<WorkTypeGroup>();
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'allcpos', Name = 'All CPOs', isActive = true));
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'asi', Name = 'ASI', isActive = true));
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'cpoexcludingvcpo', Name = 'CPOs (excluding VCPO)', isActive = true));
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'hondacpos', Name = 'Honda CPOs', isActive = true));
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'nonasi', Name = 'Non-ASI', isActive = true));
        wtGroupLst.add( new WorkTypeGroup( Work_Type_Group_Unique_ID__c = 'vcpos', Name = 'VCPOs', isActive = true));

        return wtGroupLst;
    }

    /**
     * Generates the standard ACV Work Types Groups Memberships for the system, but does not commit them
     * @return Generated, but not committed, standard ACV Work Types
     */
    public static List<WorkTypeGroupMember> createWorkTypeGroupMembers() {

        WorkTypeGroup allcposWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='allcpos');
        WorkTypeGroup asiWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='asi');
        WorkTypeGroup cpoexcludingvcpoWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='cpoexcludingvcpo');
        WorkTypeGroup hondacposWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='hondacpos');
        WorkTypeGroup nonasiWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='nonasi');
        WorkTypeGroup vcposWTG = new WorkTypeGroup(Work_Type_Group_Unique_ID__c='vcpos');

        List<WorkTypeGroupMember> wtGroupMemberList = new List<WorkTypeGroupMember>();
        //All CPOs group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpobm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogmcomp')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn04')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn06')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn08')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn10')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn12')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn14')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn16')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn18')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn20')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohnice')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpolnc')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpopo')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpohn')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = allcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpopo')));

        // ASIs group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='acvhome')));

        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='auction off-lease')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='auction site')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='consumer')));

        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpobm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogmcomp')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn04')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn06')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn08')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn10')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn12')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn14')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn16')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn18')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn20')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohnice')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpolnc')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpopo')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='dealer')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='fbi')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='gmfia')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='mystery test')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='other business')));

        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='quality audit')));

        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpohn')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = asiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpopo')));
        
        // CPOs(excluding VCPOs) group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpobm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpogmcomp')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn04')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn06')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn08')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn10')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn12')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn14')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn16')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn18')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn20')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohnice')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpolnc')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = cpoexcludingvcpoWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpopo')));

        // Honda group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn04')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn06')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn08')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn10')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn12')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn14')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn16')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn18')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohn20')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = hondacposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='cpohnice')));

        //Non-ASI group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='arbitration inspection')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='buyer signup')));
//        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='documentation gathering')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='inspection')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='promo work')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='siriusxm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='true360')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='unwind inspection')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = nonasiWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='verification')));

        // VCPO group members
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = vcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpofr')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = vcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpogm')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = vcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpohn')));
        wtGroupMemberList.add( new WorkTypeGroupMember( WorkTypeGroup = vcposWTG, WorkType = new WorkType(Work_Type_Unique_ID__c='vcpopo')));

        return wtGroupMemberList;
    }

    /**
     * Generates basic Operating Hour structures, but does not commit them
     * @param operatingHourNameSet The Names of the Operating Hours
     * @return Generated, but not committed, Operating Hours based off the provided names
     */
    public static List<OperatingHours> createOperatingHours( Set<String> operatingHourNameSet ) {
        List<OperatingHours> operatingHourLst = new List<OperatingHours>();
        for ( String ohName : operatingHourNameSet ) {
            operatingHourLst.add( new OperatingHours(
                Name = ohName
            ) );
        }

        return operatingHourLst;
    }

    /**
     * Generates basic Time Slot structure, but does not commit them
     * @param operatingHourIdSet Set of already committed Operating Hours Ids to create Timeslots under
     * @return Generated, but not committed, Time Slots, per day of the week, per Operating Hour Id provided
     */
    public static List<TimeSlot> createTimeSlots( Set<Id> operatingHourIdSet ) {
        List<TimeSlot> timeSlotLst = new List<TimeSlot>();
        Map<String, Integer> dayOfWeekMap = HolidayUtility.createDayOfWeekMap();
        for ( Id operatingHourId : operatingHourIdSet ) {
            for ( String dayOfWeek : dayOfWeekMap.keyset() ) {
                timeSlotLst.add( new TimeSlot(
                    DayOfWeek = dayOfWeek,
                    Type = 'Normal',
                    StartTime = Time.newInstance( 11, 0, 0, 0 ), // UTC for 6 AM EST
                    EndTime = Time.newInstance( 23, 0, 0, 0 ), // UTC for 6 PM EST
                    OperatingHoursId = operatingHourId
                ) );
            }
        }

        return timeSlotLst;
    }

    /**
     * Getter Method to extract Sample KML Data from Static Resource
     */
    private final static String EXAMPLE_POLYGON_KML_DATA {
        get {
            if ( EXAMPLE_POLYGON_KML_DATA == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'FSL Example Polygon Static Resource Name' LIMIT 1 ];
                StaticResource exampleResourceData = [ SELECT Id, Body FROM StaticResource WHERE Name = :setting.Value__c LIMIT 1 ];
                EXAMPLE_POLYGON_KML_DATA = exampleResourceData.body.toString().trim();
            }
            return EXAMPLE_POLYGON_KML_DATA;
        }
        set;
    }

    /**
     * Generates generic Map (FSL) Polygon records using generic and valid KML structure, but does not commit to the database
     * @param name Name of the Polygon you wish to generate
     * @return Generated, but not committed, FSL Polygon based off the provided data
     */
    public static FSL__Polygon__c createPolygon( String name ) {
        FSL__Polygon__c newPgRec = new FSL__Polygon__c();
        newPgRec.Name = 'Test Record';
        newPgRec.FSL__KML__c = EXAMPLE_POLYGON_KML_DATA;
        return newPgRec;
    }

    /**
     * Generates a generic Service Resource record, but does not commit to the database
     * @param userId Id of a committed User
     * @param resourceName Name of the Service Resource Record, typically the User's name
     * @return Generated, but not committed, Service Resource based off the provided data
     */
    public static ServiceResource createResource( Id userId, String resourceName ) {
        return new ServiceResource(
            Name = resourceName,
            RelatedRecordId = userId,
            ResourceType = 'T',
//            ASI_Resource_Id__c = userId, 
            IsActive = true
        );
    }

    /**
     * Generates a generic, 'Required', Resource Preference record, but does not commit to the database
     * @param resourceId Id of a committed Service Resource
     * @param objectId Account or Work Order Id to associate a Service Resource with. Most be one of those two objects or an error will return
     * @return Generated, but not committed, Resource Preference based off the provided data
     */
    public static ResourcePreference createPreference( Id resourceId, Id objectId ) {
        return createPreference( 'Required', resourceId, objectId );
    }

    /**
     * Generates a generic Resource Preference record, but does not commit to the database
     * @param preferenceType The Type of Resource Preference (Options are only: Required, Preferred, Excluded)
     * @param resourceId Id of a committed Service Resource
     * @param objectId Account or Work Order Id to associate a Service Resource with. Most be one of those two objects or an error will return
     * @return Generated, but not committed, Resource Preference based off the provided data
     */
    public static ResourcePreference createPreference( String preferenceType, Id resourceId, Id objectId ) {
        return new ResourcePreference(
            PreferenceType = preferenceType,
            RelatedRecordId = objectId,
            ServiceResourceId = resourceId
        );
    }

    /**
     * Service Territroy Structure used for organization with Parent Service Territory
     */
    public class ServiceTerritoryStructure {
        public Id operatingHours;
        //public Id parentServiceTerritoryId;

        /**
         * Constructor that sets this Service Territory's Operating Hours
         * @param operatingHours Committed Id of Operating Hours
         */
        public ServiceTerritoryStructure( Id operatingHours ) {
            this.operatingHours = operatingHours;
        }

        /*public ServiceTerritoryStructure( Id operatingHours, Id parentServiceTerritoryId ) {
            this.operatingHours = operatingHours;
            this.parentServiceTerritoryId = parentServiceTerritoryId;
        }*/
    }

    /**
     * Generates, but does not commit, Service Territory data based off the provided Service Territory Structure data
     * @param territoryNameMap A Map of Territory Names to generic Territory Structure data
     * @return Generated, but not committed, Service Territory data
     */
    public static List<ServiceTerritory> createST( Map<String, ServiceTerritoryStructure> territoryNameMap ) {
        List<ServiceTerritory> serviceTerritoryLst = new List<ServiceTerritory>();
        for ( String territoryName : territoryNameMap.keySet() ) {
            serviceTerritoryLst.add( new ServiceTerritory(
                Name = territoryName, OperatingHoursId = territoryNameMap.get( territoryName ).OperatingHours,
                isActive = TRUE//, ParentTerritoryId = territoryNameMap.get( territoryName ).parentServiceTerritoryId  - Parent Territory Causes Invalid Group Id issue?
            ) );
        }

        return serviceTerritoryLst;
    }

    /**
     * Generic Structure used to return both Work Order and Work Order Line Item data for some utility methods.
     * Mimics the standard Work Order to many Work Order Line Item structure, with all records considered linked
     */
    public class WorkStruct {
        public WorkOrder wo;
        public List<WorkOrderLineItem> woLst;

        /**
         * Standard Constructor of WorkStruct to initialize the Work Order Line Item List
         */
        public WorkStruct () {
            this.woLst = new List<WorkOrderLineItem>();
        }
    }
}