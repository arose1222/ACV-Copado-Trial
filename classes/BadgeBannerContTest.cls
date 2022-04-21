/**
 * Test Class for the BadgeBannerCont
 * @author James Andre LaCour
 */
@isTest
public class BadgeBannerContTest {
    /********************Test Methods****************************/
    public class BadgeBannerTrueTest extends BadgeBannerInterface{
        public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
            return true;
        }
    }
    public class BadgeBannerFalseTest extends BadgeBannerInterface{
        public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
            return false;
        }
    }
    public class BadgeBannerInterfaceTest extends BadgeBannerInterface{
    }
    /**
     * Test a Badge where a Class Name is being used
     */
    public static testMethod void getBadgeClassNameTest(){
        Badge__mdt badgeTrue = new Badge__mdt(DeveloperName = 'test', Active__c = true, ACV_Preset_Colors__c = 'testColor', Class_Name__c = 'BadgeBannerContTest.BadgeBannerTrueTest', Object__c = 'test' );
        Badge__mdt badgeFalse = new Badge__mdt(DeveloperName = 'test', Active__c = true, ACV_Preset_Colors__c = 'testColor', Class_Name__c = 'BadgeBannerContTest.BadgeBannerFalseTest', Object__c = 'test' );
        Test.startTest();
            BadgeBannerCont.testBadgeList = new List<Badge__mdt>{badgeTrue, badgeFalse};
            BadgeBannerCont.ReturnWrapper rw = (BadgeBannerCont.ReturnWrapper)JSON.deserialize( BadgeBannerCont.getBadges( UserInfo.getUserId() ), BadgeBannerCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( 1, rw.badgeList.size() );
    }
    /**
     * Tests the BadgeInterface defaulting checkLogic function
     */
    public static testMethod void badgeInterfaceTest(){
        Badge__mdt badgeDefaultFalse = new Badge__mdt(DeveloperName = 'test', Active__c = true, ACV_Preset_Colors__c = 'testColor', Class_Name__c = 'BadgeBannerContTest.BadgeBannerInterfaceTest', Object__c = 'test' );
        Test.startTest();
            BadgeBannerCont.testBadgeList = new List<Badge__mdt>{badgeDefaultFalse};
            BadgeBannerCont.ReturnWrapper rw = (BadgeBannerCont.ReturnWrapper)JSON.deserialize( BadgeBannerCont.getBadges( UserInfo.getUserId() ), BadgeBannerCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( 0, rw.badgeList.size() );
    }
}