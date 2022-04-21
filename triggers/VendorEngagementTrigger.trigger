trigger VendorEngagementTrigger on Vendor_Engagement__c (before insert, before update) {
    (new TriggerFrameWork()).handle();
}