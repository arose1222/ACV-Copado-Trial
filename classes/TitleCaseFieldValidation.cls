public without sharing class TitleCaseFieldValidation extends TriggerInterface {
    public override void beforeInsert(List<sObject> objectList) {
        TitleCaseFieldValidation.processError(objectList);
    }

    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        TitleCaseFieldValidation.processError(newList);
    }

    public static void processError( List<sObject> caseNewLst ) {
        List<Case> caseList = (List<Case>) caseNewLst;

        List<Integration_User_Name__mdt> lACVIntegrationObj = [select MasterLabel from Integration_User_Name__mdt];
        List<String> userNames = new List<String>();
        for(Integration_User_Name__mdt obj :lACVIntegrationObj ){
            userNames.add(obj.MasterLabel);
        
    }

        Date enforceRuleDate = Date.newInstance( 2019, 10, 15 );

        if(!userNames.contains(UserInfo.getUserName())){
            for (Case cc: caseList) {    
                if ( cc.CreatedDate >= enforceRuleDate ) {
                    if (cc.Title_Problem_Subset__c != null && cc.Status =='Problem' ) {
                        if ((cc.Title_Problem_Subset__c.contains('O') || cc.Title_Problem_Subset__c.contains('R')) && cc.Incorrect_Vehicle_Information_on_Title__c == false) {
                            cc.addError('Your Title Problem Subset values require Incorrect Vehicle Information on Title to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('B') || cc.Title_Problem_Subset__c.contains('P') ||cc.Title_Problem_Subset__c.contains('N')) && cc.Odometer_Discrepancy__c == false) {
                            cc.addError('Your Title Problem Subset values require Odometer Discrepancy to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('K') || cc.Title_Problem_Subset__c.contains('M'))&& cc.Missing_Signature__c == false){
                            cc.addError('Your Title Problem Subset values require Missing Signature to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('Q') || cc.Title_Problem_Subset__c.contains('J') ||cc.Title_Problem_Subset__c.contains('E')||cc.Title_Problem_Subset__c.contains('C')||cc.Title_Problem_Subset__c.contains('R')|| cc.Title_Problem_Subset__c.contains('F')) && cc.Reassignment_Error__c == false) {
                            cc.addError('Your Title Problem Subset values require Reassignment Errors to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('I') || cc.Title_Problem_Subset__c.contains('A')|| cc.Title_Problem_Subset__c.contains('D')|| cc.Title_Problem_Subset__c.contains('H'))&& cc.Write_Overs__c == false) {
                            cc.addError('Your Title Problem Subset values require Write-Overs to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('L') || cc.Title_Problem_Subset__c.contains('G'))&& cc.Reassigned_To_Wrong_Purchaser__c == false) {
                            cc.addError('Your Title Problem Subset values require Reassigned to Wrong Purchaser to be selected.'); 
                        }
                        if((cc.Title_Problem_Subset__c.contains('T'))&& cc.Missing_Notary__c == false){
                            cc.addError('Your Title Problem Subset values require Missing Notary to be selected.');
                        }
                        if ((cc.Title_Problem_Subset__c.contains('U')) && cc.Missing_Lien_Release__c == false){
                             cc.addError('Your Title Problem Subset values require Missing Lien release to be selected.');
                         }
                         if ((cc.Title_Problem_Subset__c.contains('V')) && cc.Damaged_Title__c == false){
                             cc.addError('Your Title Problem Subset values require Damaged Title to be selected.');
                            }
                         if((cc.Title_Problem_Subset__c.contains('W'))&& cc.Listing_Error__c == false){
                             cc.addError('Your Title Problem Subset Values require Listing Error to be selected.');
                         }
                    }   else if ((cc.Reassigned_To_Wrong_Purchaser__c || cc.Write_Overs__c || cc.Reassignment_Error__c || cc.Incorrect_Vehicle_Information_on_Title__c || cc.Odometer_Discrepancy__c || cc.Missing_Signature__c || cc.Missing_Notary__c || cc.Missing_Lien_Release__c || cc.Damaged_Title__c || cc.Listing_Error__c) && cc.Title_Problem_Subset__c == null){
                        cc.addError('Please fill out the Title Problem Subset values related to your Primary Problem checkboxes');
                     
                        }
                
                }
            }
        }
    }
}