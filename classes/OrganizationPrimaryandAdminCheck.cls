public with sharing class OrganizationPrimaryandAdminCheck {
    Public static Boolean OrganizationPrimaryandAdminCheck(String AccountId){
        
        Boolean adminFound = false;
        Boolean primaryFound = false;
        
        For(Affiliation__c Aff : [SELECT Primary_Contact__c, Type__c FROM Affiliation__c WHERE Account__c = :AccountID AND (Primary_Contact__c = TRUE OR Type__c = 'ADMIN') AND Active__c = TRUE]){
            if(aff.Primary_Contact__c == true){
                primaryFound = true;
            }
            if(aff.Type__c == 'admin'){
                adminFound = true;
            }
            if(primaryFound && adminFound){
                return true;
            }
        }
        return false;
    }
    Public static Boolean OrganizationAffiliationPrimaryandAdminCheck(String AccountId, String AffiliationId, String fieldChanged){
        
        Boolean adminFound = false;
        Boolean primaryFound = false;
        
        if(fieldChanged == 'Primary'){
            For(Affiliation__c Aff : [SELECT Primary_Contact__c, Type__c FROM Affiliation__c WHERE Account__c = :AccountID AND ((Id=:AffiliationId AND Type__c = 'ADMIN') OR (Primary_Contact__c = TRUE OR Type__c = 'ADMIN')) AND Active__c = TRUE]){
                if(aff.Primary_Contact__c == true && aff.id != AffiliationId){
                    primaryFound = true;
                }
                if(aff.Type__c == 'admin'){
                    adminFound = true;
                }
                if(primaryFound && adminFound){
                    return true;
                }
            }
        }
        else if(fieldChanged == 'Admin'){
            For(Affiliation__c Aff : [SELECT Primary_Contact__c, Type__c FROM Affiliation__c WHERE Account__c = :AccountID AND ((Id=:AffiliationId AND Primary_Contact__c = TRUE) OR (Primary_Contact__c = TRUE OR Type__c = 'ADMIN')) AND Active__c = TRUE]){
                if(aff.Primary_Contact__c == true){
                    primaryFound = true;
                }
                if(aff.Type__c == 'admin' && aff.id != AffiliationId){
                    adminFound = true;
                }
                if(primaryFound && adminFound){
                    return true;
                }
            }
        }
        else if(fieldChanged == 'Both'){
            For(Affiliation__c Aff : [SELECT Primary_Contact__c, Type__c FROM Affiliation__c WHERE Account__c = :AccountID AND Id!=:AffiliationId AND (Primary_Contact__c = TRUE OR Type__c = 'ADMIN') AND Active__c = TRUE]){
                if(aff.Primary_Contact__c == true){
                    primaryFound = true;
                }
                if(aff.Type__c == 'admin'){
                    adminFound = true;
                }
                if(primaryFound && adminFound){
                    return true;
                }
            }
        }
        else if(String.IsBlank(fieldChanged)){
            return true;
        }
        return false;
    }
}