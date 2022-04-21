global class BatchTransportationCasesforCD extends SchedulingInterface{

    global String code;
    global Boolean post;

    /*public BatchTransportationCasesforCD(String aCode, Boolean toPost){
        code = aCode;
        post = toPost;
    }*/
    
    public override void executeScheduledLogic() {
        //sendEmailToCD(code, post);
        sendEmailToCD();
    }

    public void sendEmailToCD(){//String acvCode, Boolean toPost){
        List<Transportation_Email_Address__mdt> TEA = [select MasterLabel,U_Id__c from Transportation_Email_Address__mdt where developerName = 'default'];
        List<Case> lCases = [SELECT Auction_Number_Case__c, Default_Pickup_City__c, 
                                    Default_Pickup_State__c, Default_Pickup_Postal_Code__c,Date_Last_Posted__c,
                                    Default_Delivery_City__c, Default_Delivery_State__c, Default_Delivery_Postal_Code__c,
                                    Posted_Price__c, Vehicle__r.vin__c, Vehicle__r.Name, Times_Posted_to_CD__c,Date_First_Posted__c, Previous_Last_Posted_Date__c,
                                    Vehicle__r.make__c, Vehicle__r.Year__c, Vehicle__r.model__c, inop__c
                                    FROM Case WHERE Send_to_Central_Dispatch__c = true AND Status = 'Posted'
                                    AND RecordType.DeveloperName = 'Transportation'];

        List<Case> lCasesToUpdate = new List<Case>();
        String date1 = DateTime.Now().format('YYYY-MM-dd');
        String date2 = DateTime.Now().addMonths(1).format('YYYY-MM-dd');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<String> mBodyParts = new List<String>();
        if(TEA.size() > 0){
            mBodyParts.add('UID('+TEA[0].U_Id__c+')');
        }
         
        for(Case c2Delete :lCases){
            mBodyParts.add('DELETE('+c2Delete.Auction_Number_Case__c+')');
        }

        for (Case c2Post :lCases){
            String operable ='';
            if(c2Post.inop__c){
                operable = 'inoperable';
            }
            else{
                operable = 'operable';
            }
            mBodyParts.add(c2Post.Auction_Number_Case__c+','+c2Post.Default_Pickup_City__c+','+c2Post.Default_Pickup_State__c+','+c2Post.Default_Pickup_Postal_Code__c+','+
                c2Post.Default_Delivery_City__c+','+c2Post.Default_Delivery_State__c+','+c2Post.Default_Delivery_Postal_Code__c+','+c2Post.Posted_Price__c+',0.00,check,delivery,quickpay,open,'+operable+','+date1+','+
                date2+',ACV AUCTIONS - Get Paid electronically Instantly!,'+'||||'+c2Post.Vehicle__r.vin__c);
            if(c2Post.Date_First_Posted__c==null){
                c2Post.Date_First_Posted__c=Date.Today();
            }
            c2Post.Previous_Last_Posted_Date__c=c2Post.Date_Last_Posted__c;
            c2Post.Date_Last_Posted__c=Date.Today();
            c2Post.Status = 'Posted';
            c2Post.Times_Posted_to_CD__c += 1;
            lCasesToUpdate.add(c2Post);
        }
        

        String mBody = String.join(mBodyParts, '*');
        message.plainTextBody = mBody+'*';
        message.subject = '';
        if(TEA.size() > 0){
            message.toAddresses = new String[] {TEA[0].MasterLabel};
        }
        OrgWideEmailAddress[] fromAddress = [select Id from OrgWideEmailAddress where DisplayName = 'ACV Transportation'];
        if ( fromAddress.size() > 0 ) {
            message.setOrgWideEmailAddressId(fromAddress.get(0).Id);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        if(TEA.size() <1){
            Throw new CustomException('NO DEFAULT MEATA DATA FOUND');
        }
        if(!Test.isRunningTest()){Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);}
        if(lCasesToUpdate.size()>0){
            update lCasesToUpdate;
        }  
    }
}