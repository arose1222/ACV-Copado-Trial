public with sharing class AssignmentManagerOwnerSelection { 
    public static Id assetVerificationOwner(){
        //grab all possible candidates for selection as av owner
        List<Asset_Verification_Owners__mdt> avoList = new List<Asset_Verification_Owners__mdt>();
        avoList = [SELECT User_Record_Id__c FROM Asset_Verification_Owners__mdt];

        //using this list include some selection process

        Integer randomInt;
        Double randomDouble;
        randomDouble = Math.random() * avoList.size();
        randomInt = randomDouble.intValue();

        //return the selected av owner

        return avoList[randomInt].User_Record_Id__c;
    }
}