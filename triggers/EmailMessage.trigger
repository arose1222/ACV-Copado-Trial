trigger EmailMessage on EmailMessage (before insert) {
   /* for(EmailMessage em : trigger.new){
        System.debug('ParentID:'+em.ParentId);
        System.debug('FromAddress:'+em.FromAddress);
        System.debug('ToAddress:'+em.ToAddress);
        System.debug('Body:'+em.TextBody);
        System.debug('HTML Body:'+em.HtmlBody);
    }
    public class EmailCase{
        String caseId {get;set;}
        String contactEmail {get;set;}
        String auctionId {get;set;}
    }
    List<EmailCase> lEmailCases = new List<EmailCase>();
    Map<String,String> mContactEmailToId = new Map<String,String>();
    EmailToCase_Mapping__mdt acvIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Arb' LIMIT 1];
    String toAddress;
    if(acvIntegrationObj != null){
        toAddress = acvIntegrationObj.ToAddress__c;
    }
    for(EmailMessage em : trigger.new){
        System.debug('ParentID:'+em.ParentId);
        System.debug('FromAddress:'+em.FromAddress);
        System.debug('ToAddress:'+em.ToAddress);
        System.debug('ValidatedFromAddress:'+em.ValidatedFromAddress);
        if(em.ToAddress == toAddress){
            Map<String,String> mBodyFieldValues = new Map<String,String>();
            EmailCase newEmailCase = new EmailCase();
            newEmailCase.caseId = em.ParentId;
            List<String> lSplitBody = em.TextBody.split('\n\n');
            for(String str : lSplitBody){
                if(str != null && !String.isBlank(str)){
                    //List<String> splitRes = str.split(':\n');
                    List<String> splitRes = str.replaceAll('\\*','').split(':\n');
                    if(splitRes != null && splitRes.size()>1){
                        mBodyFieldValues.put(splitRes[0],splitRes[1]);
                    }
                }
            }
            System.debug(mBodyFieldValues);
            if(mBodyFieldValues.get('Report Email') != null){
                String contactEmail = mBodyFieldValues.get('Report Email').split('<')[0];
                newEmailCase.contactEmail = contactEmail;
                mContactEmailToId.put(contactEmail,null);
                //em.FromAddress = contactEmail;
            }
            if(mBodyFieldValues.get('Auction ID') != null){
                String auctionId = mBodyFieldValues.get('Auction ID');
                newEmailCase.auctionId = auctionId;
            }
            System.debug('EC:'+newEmailCase);
            lEmailCases.add(newEmailCase);
        }
    }

    for(Contact con :[SELECT Id, Email FROM Contact WHERE Email IN :mContactEmailToId.keySet()]){
        System.debug('conEmail:'+con.Email+' conId:'+con.Id);
        mContactEmailToId.put(con.Email,con.Id);
    }
    List<Case> lCasesToUpdate = new List<Case>();
    for(EmailCase ec :lEmailCases){
        Boolean bUpdateCase = false;
        Case updateCase = new Case(Id = ec.caseId);
        updateCase.SuppliedEmail = ec.contactEmail;
        if(mContactEmailToId.get(ec.contactEmail) != null){
            updateCase.ContactId = mContactEmailToId.get(ec.contactEmail);
            bUpdateCase = true;
        }
        if(ec.auctionId != null){
            Auction__c auction = new Auction__c(id__c = ec.auctionId);
            updateCase.Auction_Number__r = auction;
            bUpdateCase = true;
        }
        if(bUpdateCase){
            lCasesToUpdate.add(updateCase);
        }

    }

    if(lCasesToUpdate.size() > 0){
        System.debug('update:'+lCasesToUpdate);
        update(lCasesToUpdate);
    }*/
}