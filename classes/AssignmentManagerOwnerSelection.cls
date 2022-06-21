/**
 * @author            : ACV Legacy
 * @group             : Scheduling
 * @last modified on  : 04-12-2022
 * @last modified by  : dilan.chaves@globant.com
**/
public with sharing class AssignmentManagerOwnerSelection { 
    public static Id assetVerificationOwner(){
        //grab all possible candidates for selection as av owner
        List<Asset_Verification_Owners__mdt> avoList = new List<Asset_Verification_Owners__mdt>();
        avoList = [SELECT User_Record_Id__c FROM Asset_Verification_Owners__mdt WHERE Active__c = TRUE];

        Id idToReturn;

        // if its not empty, it return the first user id
        if (avoList != null && !avoList.isEmpty()) {
            idToReturn = avoList[0].User_Record_Id__c;
        } else {
            idToReturn = null;
        }

        return idToReturn;
    }
}