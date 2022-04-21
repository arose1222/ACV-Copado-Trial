@isTest
public class OptimizerServiceResourceTest {
 
    @TestSetup
    static void makeData(){
        Account testAcct = TestUtility.createAccount( 'TEST Account Dealership' );
        insert testAcct;
        Contact testCon = TestUtility.createContact( testAcct );
        insert testCon;
    }

    @isTest
    static void createServiceResourceToOptimize(){
        
        Contact testCon = [ SELECT Id, Email FROM Contact LIMIT 1 ];        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name IN :OptimizeServiceResource.USER_PROFILE_SET LIMIT 1 ];

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData( testCon, p.Name );

        vciServiceResource = [ SELECT Id, IsOptimizationCapable FROM ServiceResource WHERE Id = :vciServiceResource.Id ];
        System.assertEquals( TRUE, vciServiceResource.IsOptimizationCapable, 'The Service Resource was not optimized' );
    }

    @isTest
    static void updateServiceResourceToOptimize(){
        
        Contact testCon = [ SELECT Id, Email FROM Contact LIMIT 1 ];
        Profile p = [ SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData( testCon, p.Name );

        vciServiceResource = [ SELECT Id, IsOptimizationCapable FROM ServiceResource WHERE Id = :vciServiceResource.Id ];
        System.assertEquals( FALSE, vciServiceResource.IsOptimizationCapable, 'The Service Resource was optimized unexpectedly' );

        // Create New User to update Service Resource:
        String uniqueUserName = 'VCI2TestUser' + DateTime.now().getTime() + '@testorg.com';
        p = [ SELECT Id FROM Profile WHERE Name IN :OptimizeServiceResource.USER_PROFILE_SET LIMIT 1 ];
        User vciTestUser2 = new User(
            LastName = 'vciTestLastName',
            UserName = uniqueUserName,
            Email = testCon.Email,
            Alias = 'vciTUse2',
            CommunityNickname = 'vciTestUser2',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
        insert vciTestUser2;

        Test.startTest();
            System.RunAs( vciTestUser2 ) {
                insert FSLTestUtility.makePermissionSet( vciTestUser2.Id );
            }

            vciServiceResource.RelatedRecordId = vciTestUser2.Id;
            update vciServiceResource;
        Test.stopTest();

        vciServiceResource = [ SELECT Id, IsOptimizationCapable FROM ServiceResource WHERE Id = :vciServiceResource.Id ];
        System.assertEquals( TRUE, vciServiceResource.IsOptimizationCapable, 'The Service Resource was not optimized' );
    }

    @isTest
    static void createUserToOptimizeServiceResource(){
        Contact testCon = [ SELECT Id, Email FROM Contact LIMIT 1 ];    
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData( testCon, p.Name );

        vciServiceResource = [ SELECT Id, RelatedRecordId, IsOptimizationCapable FROM ServiceResource WHERE Id = :vciServiceResource.Id ];
        System.assertEquals( FALSE, vciServiceResource.IsOptimizationCapable, 'The Service Resource was optimized unexpectedly' );

        p = [SELECT Id FROM Profile WHERE Name IN :OptimizeServiceResource.USER_PROFILE_SET LIMIT 1 ];
        User vciTestUser = [ SELECT Id FROM User WHERE Id = :vciServiceResource.RelatedRecordId LIMIT 1 ];

        User runUser = [ SELECT Id FROM User WHERE Id != :vciTestUser.Id LIMIT 1 ];
        Test.startTest();
            System.RunAs(runUser) {
                vciTestUser.ProfileId = p.Id;
                update vciTestUser;
            }
        Test.stopTest();

        vciServiceResource = [ SELECT Id, IsOptimizationCapable FROM ServiceResource WHERE Id = :vciServiceResource.Id ];
        System.assertEquals( TRUE, vciServiceResource.IsOptimizationCapable, 'The Service Resource was not optimized' );
    }
}