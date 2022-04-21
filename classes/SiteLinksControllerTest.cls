/**
 * @description It is used by SiteLinks LWC to retreive links from Site_Links__c Custom Settings.
 * 
 * @author Manmeet Vaseer
 * @date 07/02/2021
 * 
 */
@isTest
public class SiteLinksControllerTest {

    @isTest
    static void testGetSiteLinks()	{
        Test.startTest();
        List<Site_Links__c> sls = new List<Site_Links__c>();
        Site_Links__c sl = new Site_Links__c(Namespace__c='Auctions', Name='site4', Active__c=true, Site_Name__c='name4', Site_URL__c='url4', Sort_Order__c=40);
        sls.add(sl);
        sl = new Site_Links__c(Namespace__c='Titles', Name='site3', Active__c=true, Site_Name__c='name3', Site_URL__c='url3', Sort_Order__c=30);
        sls.add(sl);
        sl = new Site_Links__c(Namespace__c='Titles', Name='site2', Active__c=false, Site_Name__c='name2', Site_URL__c='url2', Sort_Order__c=20);
        sls.add(sl);
        sl = new Site_Links__c(Namespace__c='Titles', Name='site1', Active__c=true, Site_Name__c='name1', Site_URL__c='url1', Sort_Order__c=10);
        sls.add(sl);
        insert sls;
        
        List<String> siteLinks = SiteLinksController.getSiteLinks('Titles');
        System.assertEquals(2, siteLinks.size(), 'There should be 2 records in the site link list.');
        
        SiteLinksController.Payload pl = (SiteLinksController.Payload) System.JSON.deserialize(siteLinks[0], SiteLinksController.Payload.class);        
        System.assertEquals('name1', pl.siteName, 'Incorrect Site Name in Payload: ' + siteLinks[0]);
        System.assertEquals('url1', pl.siteUrl, 'Incorrect Site URL in Payload: ' + siteLinks[0]);

        pl = (SiteLinksController.Payload) System.JSON.deserialize(siteLinks[1], SiteLinksController.Payload.class);
        System.assertEquals('name3', pl.siteName, 'Incorrect Site Name in Payload: ' + siteLinks[1]);
        System.assertEquals('url3', pl.siteUrl, 'Incorrect Site URL in Payload: ' + siteLinks[1]);        
        Test.stopTest();
    }
}