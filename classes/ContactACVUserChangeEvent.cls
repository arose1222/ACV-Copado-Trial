public class ContactACVUserChangeEvent extends TriggerInterface{
    //TODO: Make single method for Platform Event Record
    //TODO: Get rid of integration results

    @testvisible
    public static boolean CauseFailure = false;
   
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        Map<Id,Contact> newUserMap = (Map<Id,Contact>) incomingNewMap;
        Map<Id,Contact> oldUserMap = (Map<Id,Contact>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Acv_User__e> UserEvents = New List<Acv_User__e>();
        String fullName;
        Map<Id, Set<String>> ChangedFieldsMap = ACVUtility.getChangedFields(newUserMap, oldUserMap, 'Contact');
            
            for(Contact ConRec : newUserMap.values()) {
                //trigger where Contact fields have been updated    
                if(ConRec.RecordTypeId == acvuserRecordTypeId &&
                (ChangedFieldsMap.get(ConRec.Id).Contains('active__c') || ChangedFieldsMap.get(ConRec.Id).Contains('email') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('lastname') || ChangedFieldsMap.get(ConRec.Id).Contains('firstname') || ChangedFieldsMap.get(ConRec.Id).Contains('middlename') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('is_staff__c') || ChangedFieldsMap.get(ConRec.Id).Contains('is_superuser__c') || ChangedFieldsMap.get(ConRec.Id).Contains('phone') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('promotion_code__c') || ChangedFieldsMap.get(ConRec.Id).Contains('sms_opt_in__c') || ChangedFieldsMap.get(ConRec.Id).Contains('identity_id__c') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('mailingpostalcode') || ChangedFieldsMap.get(ConRec.Id).Contains('email_opt_out_categories__c') || ChangedFieldsMap.get(ConRec.Id).Contains('creation_source__c') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('mobilephone') || ChangedFieldsMap.get(ConRec.Id).Contains('programmatic_sms_opt_in__c'))){
                    //add Middle Name if its not null
                    if(ConRec.MiddleName == null && ConRec.FirstName == null){
                        fullName = ConRec.LastName;
                    }
                    else if(ConRec.MiddleName == null){
                        fullName = ConRec.FirstName + ' ' + ConRec.LastName; 
                    }
                    else{
                        fullName = ConRec.FirstName + ' ' + ConRec.MiddleName + ' ' + ConRec.LastName; 
                    }
                // Create an instance of the event and store it in the  variable 
                    UserEvents.add(new Acv_User__e(    
                    User_Id__c = ConRec.id__c,
                    User_Guid__c = ConRec.Contact_Guid__c, 
                    Identity_Id__c = ConRec.Identity_Id__c,
                    Active__c = ConRec.Active__c,
                    Email__c = ConRec.Email,
                    Full_Name__c = fullName,
                    Is_Staff__c = ConRec.Is_Staff__c,
                    Is_Superuser__c = ConRec.Is_Superuser__c,
                    Phone_Number__c = ConRec.Phone,
                    Referral_Code__c = ConRec.Promotion_Code__c,
                    Sms_Opt_In__c = ConRec.SMS_Opt_In__c,
                    Programmatic_Sms_Opt_In__c = ConRec.Programmatic_Sms_Opt_In__c,
                    Zip_Code__c = ConRec.MailingPostalCode,
                    Email_Opt_Out_Categories__c = ConRec.Email_Opt_Out_Categories__c,
                    Creation_Source__c = ConRec.Creation_Source__c,
                    Cell_Phone_Number__c = ConRec.MobilePhone,
                    Changed_By_Sf_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = UserInfo.getUserEmail(),
                    event_type__c = 'update-user'));
                    idList.add(ConRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!UserEvents.isempty()){
                userpublisher(UserEvents, idList);
            }         
    }   
    

    public override void afterInsert(Map<Id,SObject> incomingMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    
        Map<Id,Contact> newUser = (Map<Id,Contact>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Acv_User__e> UserEvents = New List<Acv_User__e>();
        String fullName;

        Map<id,Contact> ConMap = new Map<Id, Contact>([Select id, id__c, Contact_Guid__c,  Identity_Id__c, Is_Staff__c, Is_Superuser__c, Promotion_Code__c, SMS_Opt_In__c, Programmatic_Sms_Opt_In__c, MailingPostalCode,
        Active__c, Email, Phone, FirstName, MiddleName, LastName, Email_Opt_Out_Categories__c, creation_source__c, MobilePhone, LastModifiedBy.Email From Contact Where id IN: newUser.keyset()]);
            
            //trigger anytime a Contact(ACv User) is Created
            for(Contact ConRec : newUser.values()) {
                // Create an instance of the event and store it in the  variable 
                if(ConRec.RecordTypeId == acvuserRecordTypeId){
                    //add Middle Name if its not null
                    if(ConMap.get(ConRec.id).MiddleName == null && ConMap.get(ConRec.id).FirstName == null){
                        fullName = ConMap.get(ConRec.id).LastName;
                    }
                    else if(ConMap.get(ConRec.id).MiddleName == null){
                        fullName = ConMap.get(ConRec.id).FirstName + ' ' + ConMap.get(ConRec.id).LastName; 
                    }
                    else{
                        fullName = ConMap.get(ConRec.id).FirstName + ' ' + ConMap.get(ConRec.id).MiddleName + ' ' + ConMap.get(ConRec.id).LastName; 
                    }
                // Create an instance of the event and store it in the  variable 
                    UserEvents.add(new Acv_User__e(    
                    User_Id__c = ConMap.get(ConRec.id).id__c,
                    User_Guid__c = ConMap.get(ConRec.id).Contact_Guid__c, 
                    Identity_Id__c = ConMap.get(ConRec.id).Identity_Id__c,
                    Active__c = ConMap.get(ConRec.id).Active__c,
                    Email__c = ConMap.get(ConRec.id).Email,
                    Full_Name__c = fullName,
                    Is_Staff__c = ConMap.get(ConRec.id).Is_Staff__c,
                    Is_Superuser__c = ConMap.get(ConRec.id).Is_Superuser__c,
                    Phone_Number__c = ConMap.get(ConRec.id).Phone,
                    Referral_Code__c = ConMap.get(ConRec.id).Promotion_Code__c,
                    Sms_Opt_In__c = ConMap.get(ConRec.id).SMS_Opt_In__c,
                    Programmatic_Sms_Opt_In__c = ConMap.get(ConRec.id).Programmatic_Sms_Opt_In__c,
                    Zip_Code__c = ConMap.get(ConRec.id).MailingPostalCode,
                    Email_Opt_Out_Categories__c = ConRec.Email_Opt_Out_Categories__c,
                    Creation_Source__c = ConRec.Creation_Source__c,
                    Cell_Phone_Number__c = ConRec.MobilePhone,
                    Changed_By_Sf_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = newUser.get(ConRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'create-user'));
                    idList.add(ConRec.Id);
                }
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!UserEvents.isempty()){
                userpublisher(UserEvents, idList);
            }
    }
    public override void beforeDelete(Map<Id,SObject> incomingMap){ 
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    
        Map<Id,Contact> newUser = (Map<Id,Contact>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Acv_User__e> UserEvents = New List<Acv_User__e>();

        //trigger anytime a Contact(ACv User) is Created
        for(Contact ConRec : newUser.values()) {
            // Create an instance of the event and store it in the  variable 
            if(ConRec.RecordTypeId == acvuserRecordTypeId){
            // Create an instance of the event and store it in the  variable 
                UserEvents.add(new Acv_User__e(    
                User_Id__c = ConRec.id__c,
                User_Guid__c = ConRec.Contact_Guid__c, 
                Changed_By_Sf_User_Id__c = ConRec.LastModifiedById,
                Changed_By_Username__c = UserInfo.getUserEmail(),
                Event_Type__c = 'delete-user'));
                idList.add(ConRec.Id);
            }
            
        }
        //If the Event variable is NOT empty then fire the Publisher 
        if(!UserEvents.isempty()){
            userpublisher(UserEvents, idList);
        }
    }

    public override void afterUndelete(Map<Id,SObject> incomingMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    
        Map<Id,Contact> newUser = (Map<Id,Contact>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Acv_User__e> UserEvents = New List<Acv_User__e>();
        String fullName;
            
            //trigger anytime a Contact(ACv User) is Created
            for(Contact ConRec : newUser.values()) {
                // Create an instance of the event and store it in the  variable 
                if(ConRec.RecordTypeId == acvuserRecordTypeId){
                    //add Middle Name if its not null
                    if(ConRec.MiddleName == null && ConRec.FirstName == null){
                        fullName = ConRec.LastName;
                    }
                    else if(ConRec.MiddleName == null){
                        fullName = ConRec.FirstName + ' ' + ConRec.LastName; 
                    }
                    else{
                        fullName = ConRec.FirstName + ' ' + ConRec.MiddleName + ' ' + ConRec.LastName; 
                    }
                // Create an instance of the event and store it in the  variable 
                    UserEvents.add(new Acv_User__e(    
                    User_Id__c = ConRec.id__c,
                    User_Guid__c = ConRec.Contact_Guid__c, 
                    Identity_Id__c = ConRec.Identity_Id__c,
                    Active__c = ConRec.Active__c,
                    Email__c = ConRec.Email,
                    Full_Name__c = fullName,
                    Is_Staff__c = ConRec.Is_Staff__c,
                    Is_Superuser__c = ConRec.Is_Superuser__c,
                    Phone_Number__c = ConRec.Phone,
                    Referral_Code__c = ConRec.Promotion_Code__c,
                    Sms_Opt_In__c = ConRec.SMS_Opt_In__c,
                    Programmatic_Sms_Opt_In__c = ConRec.Programmatic_Sms_Opt_In__c,
                    Zip_Code__c = ConRec.MailingPostalCode,
                    Email_Opt_Out_Categories__c = ConRec.Email_Opt_Out_Categories__c,
                    Creation_Source__c = ConRec.Creation_Source__c,
                    Cell_Phone_Number__c = ConRec.MobilePhone,
                    Changed_By_Sf_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = UserInfo.getUserEmail(),
                    Event_Type__c = 'undelete-user'));
                    idList.add(ConRec.Id);
                }
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!UserEvents.isempty()){
                userpublisher(UserEvents, idList);
            }
    }

    public static void userpublisher(List<Acv_User__e> UserEvents, List<Id> idList){ 
        // Call method to publish list of Contact events       
        List<Database.SaveResult> results = EventBus.publish(UserEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Contact Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){
            Database.SaveResult Result = results[i];  
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Acv_User__e';
            integrationObj.Integration_Name__c = 'ContactACVUserChangeEvent';
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(UserEvents[i]);

            if (!result.isSuccess() || CauseFailure) {
                if(result.getErrors().size() > 0 || CauseFailure)
                        IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                        'ContactACVUserChangeEvent: ContactACVUser Event failed to publish to event bus', 
                        SplunkHelper.LOGLEVEL.ERROR, 'ContactACVUserChangeEvent', 
                        'ContactACVUser Event failed to publish to event bus', 
                        'Contact');
            }
            else{
                integrationObj.Status_Code__c = 200;
                integrationObj.Status_Message__c = String.valueof(result);          
            }
            integrationList.add(integrationObj);
        }   
        if (integrationList.size() > 0){
            insert integrationList;
        }           
    }   
}