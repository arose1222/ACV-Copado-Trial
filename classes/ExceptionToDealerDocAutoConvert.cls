public without sharing class ExceptionToDealerDocAutoConvert extends TriggerInterface {
    public static final Id licenseId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id certInsuranceId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Insurance').getRecordTypeId();
    public static final Id docsLicenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id docsResaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id docsCertInsuranceId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Insurance').getRecordTypeId();
    public static Set<Id> types = new Set<Id>{licenseId, resaleId, certInsuranceId};
    public static final Set<String> revDecisions = new Set<String>{'Current and Compliant Document', 'Historical Document'};

    public override void beforeInsert(List<sObject> newList) { //NEED TO MAKE SURE CODE KNOWS WHAT TO DO IF THERE IS NO PRIMARY CONTACT (OR DO A DATALOAD)
        List<Exception__c> newEList = (List<Exception__c>)newList;
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        Set<String> dealerIds = new Set<String>();
        Map<String, Account> acctMap = new Map<String, Account>();
        for (Exception__c ex : newEList) {
            if(!String.isBlank(ex.Dealer_Id__c)) dealerIds.add(ex.Dealer_Id__c);
        }

        if(dealerIds.size() > 0)	{
            for (Account a : [SELECT Id, Dealership_Id__c, Name, IST_Account_Owner__r.Email, Owner.Email, Primary_Contact__r.Email FROM Account WHERE Dealership_Id__c IN :dealerIds]) {
                acctMap.put(a.Dealership_Id__c, a);
            }
        }
        
        for (Exception__c e : newEList) {
            e.IST_Account_Manager_Email__c = acctMap.get(e.Dealer_Id__c)?.IST_Account_Owner__r?.Email;
            e.TM_Email__c = acctMap.get(e.Dealer_Id__c)?.Owner?.Email;
            e.Primary_Contact_Email__c = acctMap.get(e.Dealer_Id__c)?.Primary_Contact__r?.Email;
            e.Related_Account_Name__c = acctMap.get(e.Dealer_Id__c)?.Name;

            if ((e.Manual_Validation_Required__c == false && e.RecordTypeId == licenseId) || (e.RecordTypeId == licenseId && e.Document_State_ML__c == e.Document_State_Dealer_Entered__c && e.Expiration_Date_ML__c == e.Expiration_Date_Dealer_Entered__c && e.License_Number_ML__c == e.License_Number_Dealer_Entered__c && e.Manual_Validation_Required__c == false)) {
                e.Document_State__c = e.Document_State_ML__c;
                e.Expiration_Date__c = e.Expiration_Date_ML__c;
                e.License_Number__c = e.License_Number_ML__c;

                //mark all licenses as compliant (or expired)
                //VT and AZ licenses will not be auto-converted as those need a little more attention
                if (e.Expiration_Date__c > System.Today() && (e.Document_State_ML__c != 'AZ' && e.Document_State_ML__c != 'VT')) {
                    e.Compliant__c = true;
                    e.Review_Status__c = 'Complete';
                    e.Status__c = 'Closed';
                    e.Review_Decision__c = 'Auto-Converted';
                    Dealer_Docs__c d = newLicense(e);
                    docList.add(d);
                }
                else if (e.Expiration_Date__c <= System.Today() && (e.Document_State_ML__c != 'AZ' && e.Document_State_ML__c != 'VT')) {
                    e.Review_Status__c = null;
                    e.Compliance_Issues__c = 'Document expired';
                    e.Status__c = 'Closed';
                    e.Review_Decision__c = 'Auto-Converted';
                    Dealer_Docs__c d = newLicense(e);
                    docList.add(d);
                }
                else if ((e.Expiration_Date__c == null) || (e.Document_State__c == 'AZ' || e.Document_State__c == 'VT')) {
                    e.Review_Status__c = 'Ready for Review';
                }
            }
        }
        insert docList;
    }

    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, Exception__c> newEMap = (Map<Id, Exception__c>)newMap;
        Map<Id, Exception__c> oldEMap = (Map<Id, Exception__c>)oldMap;
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();

        for (Exception__c e : newEMap.values()) {
            if ((e.Status__c == 'Closed' && oldEMap.get(e.Id).Status__c == 'Open') && (types.contains(e.RecordTypeId)) && (revDecisions.contains(e.Review_Decision__c))) {
                if (e.RecordTypeId == licenseId) {
                    Dealer_Docs__c d = newLicense(e);
                    docList.add(d);
                }
                else if (e.RecordTypeId == resaleId) {
                    Dealer_Docs__c d = newResale(e);
                    docList.add(d);
                }
                else if (e.RecordTypeId == certInsuranceId) {
                    Dealer_Docs__c d = newCertInsurance(e);
                    docList.add(d);
                }

            }
        }
        insert docList;
    }

    public static Dealer_Docs__c newLicense(Exception__c e) {
        Id ContactName = getContactName(e.Document_Created_By_Id__c);
        
        Dealer_Docs__c d = new Dealer_Docs__c(
        RecordTypeId = docsLicenseId,
        License_Number__c = e.License_Number__c,
        Document_State__c = e.Document_State__c,
        Expiration_Date__c = e.Expiration_Date__c,
        No_Expiration__c = e.No_Expiration__c,
        Compliant__c = e.Compliant__c,
        Compliance_Issues__c = e.Compliance_Issues__c,
        Document_Notes__c = e.Document_Notes__c,
        Extension_Granted__c = e.Extension_Granted__c,
        S3_Link__c = e.Images_Location__c, //S3_Link__c
        ML_Reviewed__c = true, //anything passing through this code has been reviewed by ML
        Primary_Contact_Email__c = e.Primary_Contact_Email__c,
        Document_Created_By__c = ContactName);
		
        d = getAccount(d, e);
        d.Document_Expired__c = docExpiredCheck(e.Expiration_Date__c);
        d.Review_Status__c = reviewStatus(e.Review_Status__c);
        if (d.Review_Status__c == 'Requires BDR') {
            d.IST_Account_Manager_Email__c = e.IST_Account_Manager_Email__c;
            d.TM_Email__c = e.TM_Email__c;
        }

        return d;
    }

    public static Dealer_Docs__c newResale(Exception__c e) {
        String ContactName = getContactName(e.Document_Created_By_Id__c);

        Dealer_Docs__c d = new Dealer_Docs__c(
        RecordTypeId = docsResaleId,
        Permit_Resale_Number__c = e.Permit_Resale_Number__c,
        Document_State__c = e.Document_State__c,
        Expiration_Date__c = e.Expiration_Date__c,
        No_Expiration__c = e.No_Expiration__c,
        AL_Sales_Tax__c = e.AL_Sales_Tax__c,
        MTC__c = e.MTC__c,
        Compliant__c = e.Compliant__c,
        Compliance_Issues__c = e.Compliance_Issues__c,
        Document_Notes__c = e.Document_Notes__c,
        Extension_Granted__c = e.Extension_Granted__c,
        S3_Link__c = e.Images_Location__c, //S3_Link__c
        ML_Reviewed__c = true, //anything passing through this code has been reviewed by ML
        Primary_Contact_Email__c = e.Primary_Contact_Email__c,
        Document_Created_By__c = ContactName);

        d = getAccount(d, e);
        d.Document_Expired__c = docExpiredCheck(e.Expiration_Date__c);
        d.Review_Status__c = reviewStatus(e.Review_Status__c);
        if (d.Review_Status__c == 'Requires BDR') {
            d.IST_Account_Manager_Email__c = e.IST_Account_Manager_Email__c;
            d.TM_Email__c = e.TM_Email__c;
        }

        return d;
    }

    public static Dealer_Docs__c newCertInsurance(Exception__c e) {
        String ContactName = getContactName(e.Document_Created_By_Id__c);
        
        Dealer_Docs__c d = new Dealer_Docs__c(
        RecordTypeId = docsCertInsuranceId,
        Insurance_Company_Name__c = e.Insurance_Company_Name__c,
        Inventory_Coverage_Amount__c = e.Inventory_Coverage_Amount__c,
        Document_State__c = e.Document_State__c,
        Expiration_Date__c = e.Expiration_Date__c,
        Compliant__c = e.Compliant__c,
        Compliance_Issues__c = e.Compliance_Issues__c,
        Document_Notes__c = e.Document_Notes__c,
        Extension_Granted__c = e.Extension_Granted__c,
        S3_Link__c = e.Images_Location__c, //S3_Link__c
        ML_Reviewed__c = true, //anything passing through this code has been reviewed by ML
        Primary_Contact_Email__c = e.Primary_Contact_Email__c,
        Document_Created_By__c = ContactName);

        d = getAccount(d, e);
        d.Document_Expired__c = docExpiredCheck(e.Expiration_Date__c);
        d.Review_Status__c = reviewStatus(e.Review_Status__c);
        if (d.Review_Status__c == 'Requires BDR') {
            d.IST_Account_Manager_Email__c = e.IST_Account_Manager_Email__c;
            d.TM_Email__c = e.TM_Email__c;
        }

        return d;
    }

    public static Dealer_Docs__c getAccount(Dealer_Docs__c d, Exception__c e) {
        Account a = new Account(Dealership_ID__c = e.Dealer_ID__c);
        d.Account__r = a;
        return d;
    }

    public static Boolean docExpiredCheck(Date da) {
        if (da <= System.Today()) {
            return true;
        }
        else {
            return false;
        }
    }

    public static String reviewStatus(String s) {
        if (s == 'Requires IST') {
            String st = 'Requires BDR';
            return st;
        }
        else {
            String st = s;
            return st;
        }
    }
    
    public static Id getContactName(String s){
        Id contactName;
        List<Contact> contactList = new List<Contact>();
        contactList = [select id, name from Contact where ID__c =:s];
        if(contactList.size()>0){
            contactName = contactList[0].id;
        }else{
            contactName = null;
        }
        
        return contactName;
    }
}