/**
 * @description It is used by SiteLinks LWC to retreive links from Site_Links__c Custom Settings.
 * 
 * @author Manmeet Vaseer
 * @date 07/02/2021
 * 
 */
public class SiteLinksController {
    /*
     * @description Return active links from Site_Links__c Custom Settings.
     * 
     */
    @AuraEnabled(cacheable=true)    
    public static List<String> getSiteLinks(String namespace) {
        List<Site_Links__c> slList = [SELECT Id, Site_Name__c, Site_URL__c FROM Site_Links__c WHERE Active__c = true AND Namespace__c = :namespace ORDER BY Sort_Order__c];

        List<String> payloads = new List<String>();        
        for (Site_Links__c sl : slList) {
            Payload pl = new Payload();
            pl.id = sl.Id;
            pl.siteName = sl.Site_Name__c;
            pl.siteURL = sl.Site_URL__c;
            
            payloads.add(JSON.serialize(pl));
        }
        
        return payloads;
    }
    
    public class Payload {
        public String id;
        public String siteName;
        public String siteURL;
    }
}