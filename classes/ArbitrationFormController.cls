/**
* @File Name       : ArbitrationFormController.cls
* @Description     : Send email notifications to the users about their saved applications.
* @Usage           : Create LWC to dynamically render Custom Metadata as checkbox options
                     Create Customer-Facing Claim Intake Form
*                      
*                      
* @Author          : Vinod Yelala
* @Group           :
* @Modification Log:

 Jira User Stories : https://acvauctions.atlassian.net/browse/ARB-1
                     https://acvauctions.atlassian.net/browse/ARB-4
* -----------------------------------------------------------
* Version  Date        Author                   Modification
* -------  ---------   --------------------     -------------
* 1.0      03.12.2021   Vinod Yelala            Initial Version
**/
public class ArbitrationFormController {
    
    @AuraEnabled(cacheable=true)
    Public Static Map<String,List<String>> getArbitrationrecords(){
        Map<String,Decimal> sequenceNum = new Map<String,Decimal>(); 
        Map<String,List<String>> formMapping = new Map<String,List<String>>();
        
                system.debug('values in map::done by vinod::::'+formMapping);

        List<Arbitration_Claim__mdt> arbclaimmeta = [SELECT ID,MasterLabel, DeveloperName, 
                                                     Show_Hide_On_Form__c,Sequence__c,
                                                     SubSet_Form__c FROM Arbitration_Claim__mdt Where Show_Hide_On_Form__c = True];
        
        for(Arbitration_Claim__mdt arbtmdt : arbclaimmeta){
            sequenceNum.put(arbtmdt.SubSet_Form__c,arbtmdt.Sequence__c);
            if(formMapping.containsKey(arbtmdt.SubSet_Form__c))
                formMapping.get(arbtmdt.SubSet_Form__c).add(arbtmdt.MasterLabel);
            else
                formMapping.put(arbtmdt.SubSet_Form__c, new List<String>{arbtmdt.MasterLabel});
        }      
        getSequenceNumbers(sequenceNum);                                    
        system.debug('values in map::'+formMapping);
        return formMapping;
    }
    
    @AuraEnabled(cacheable=true)
    Public Static Map<String,Decimal> getSequenceNumbers(Map<String,Decimal> sequenceNum){
        return sequenceNum;
    }
}