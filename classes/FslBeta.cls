public with sharing class FslBeta {

    /*public final static String[] BETA_REGIONS = new String[]{
        'Great Lakes'
        };

    public static Boolean userBetaCheck{
        get {
            if ( userBetaCheck == null ) {
                User currentUser = [ SELECT Id, FSL_Beta__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1 ];
                userBetaCheck = currentUser.FSL_Beta__c;
            }
            return userBetaCheck;
        }
        set;
    }

    //Both functions have "or" logic. If any record in the list  is contained


    public static Boolean betaCheck(List<ServiceTerritory> stList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if (!betaCodeFlag()){
            return false;
        }else{
            return isBeta(stList);
        }
    }
    public static Boolean betaCheck(List<ServiceTerritoryMember> stmList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(stmList);
        }
    }
    public static Boolean betaCheck(List<ServiceResource> srList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(srList);
        }
    }
    public static Boolean betaCheck(List<ServiceAppointment> saList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(saList);
        }
    } 
    public static Boolean betaCheck(List<AssignedResource> arList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(arList);
        }
    } 
    public static Boolean betaCheck(List<Account> accList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(accList);
        }
    }
    public static Boolean betaCheck(List<WorkOrder> woList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(woList);
        }
    }
    public static Boolean betaCheck(List<WorkOrderLineItem> woliList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(woliList);
        }
    }
    public static Boolean betaCheck(List<User> uList){
        if( FslBeta.userBetaCheck ) {
            return TRUE;
        } else if(!betaCodeFlag()){
            return false;
        }else{
            return isBeta(uList);
        }
    }


    public static Boolean betaCodeFlag(){
        return [SELECT Code_Flag__c FROM Code_Flag__mdt WHERE MasterLabel = 'Beta Check'].Code_Flag__c;
    }



    private static Boolean notContainedInRegions(List<ServiceTerritory> stList){
        Boolean notInBetaRegion = true;

        List<ServiceTerritory> topLevelList = new List<ServiceTerritory>();
        Set<Id> topIdList = new Set<Id>();
        Set<Id> noLookupList = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();


        for(ServiceTerritory st : stList){
            fieldMap = st.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('TopLevelTerritoryId')){
                topIdList.add(st.TopLevelTerritoryId);
            }else{
                noLookupList.add(st.Id);
            }
        }

system.debug( topIdList );
system.debug( noLookupList );        

        if(noLookupList.size() > 0){
            stList = [SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : noLookupList];
        }

system.debug( stList );        

        for(ServiceTerritory st : stList){
            fieldMap = st.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('TopLevelTerritoryId')){
                topIdList.add(st.TopLevelTerritoryId);
            }
            else{
                topIdList.add(st.Id);
            }
        }

        topLevelList = [SELECT Id, Name FROM ServiceTerritory WHERE Id in : topIdList];
        
system.debug( topLevelList );        

        for(ServiceTerritory st : topLevelList){
            for (String region : BETA_REGIONS){
                //find string name of region
system.debug( region );
system.debug( st.Name );                
                if (st.Name == region){
                    notInBetaRegion = false;
system.debug( 'We got a match!' );                    
                    return notInBetaRegion;
                }
            }
        }

        return notInBetaRegion;
    }

    private static Boolean ContainedInRegions(List<ServiceTerritory> stList){

        Boolean inBetaRegion = false;

        List<ServiceTerritory> topLevelList = new List<ServiceTerritory>();
        Set<Id> topIdList = new Set<Id>();
        Set<Id> noLookupList = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();


        for(ServiceTerritory st : stList){
            fieldMap = st.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('TopLevelTerritoryId')){
                topIdList.add(st.TopLevelTerritoryId);
            }else{
                noLookupList.add(st.Id);
            }
        }

        if(noLookupList.size() > 0){
            stList = [SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : noLookupList];
        }

system.debug( stList );

        for(ServiceTerritory st : stList){
            fieldMap = st.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('TopLevelTerritoryId')){
                topIdList.add(st.TopLevelTerritoryId);
            }
        }

        topLevelList = [SELECT Id, Name FROM ServiceTerritory WHERE Id in : topIdList];
        
system.debug( topLevelList );        

        for(ServiceTerritory st : topLevelList){
            for (String region : BETA_REGIONS){
                //find string name of region
system.debug( region + ' - ' + st.Name);
               
                if (st.Name == region){
                    inBetaRegion = true;
system.debug( 'We found truth!' );                    
                    return inBetaRegion;
                }
            }
        }

        return inBetaRegion;
    }


    public static Boolean isBeta(List<ServiceTerritory> stList){
system.debug( 'Is Beta - ST Enter' );
        return containedInRegions(stList);
    }

    public static Boolean isBeta(List<ServiceTerritoryMember> stmList){

     system.debug('Is Beta - stm enter');

        Set<Id>stIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(ServiceTerritoryMember stm : stmList){
            fieldMap = stm.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('ServiceTerritoryId')){
                stIdSet.add(stm.ServiceTerritoryId);
            }else{
                noLookupSet.add(stm.Id);
            }
        }

        if(noLookupSet.size() > 0){
            stmList = [SELECT id, ServiceTerritoryId FROM ServiceTerritoryMember WHERE Id in : noLookupSet];
            for(ServiceTerritoryMember stm : stmList){
                fieldMap = stm.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceTerritoryId')){
                    stIdSet.add(stm.ServiceTerritoryId);
                }
            }
        }
     system.debug('Is Beta - stm exit');
        if(stIdSet.size() > 0){
            return isBeta([SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : stIdSet]);
        }else{
            return false;
        }     
    }

    public static Boolean isBeta(List<ServiceResource> srList){
     system.debug('Is Beta - sr enter');
        Set<Id> srIdSet = new Set<Id>();
        for(ServiceResource sr : srList){
            srIdSet.add(sr.Id);
        }

        return isBeta([SELECT Id, ServiceTerritoryId FROM ServiceTerritoryMember WHERE ServiceResourceId in : srIdSet]);       
    }

    public static Boolean isBeta(List<ServiceAppointment> saList){
     system.debug('Is Beta - sa enter');
        Set<Id>stIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(ServiceAppointment sa : saList){
            fieldMap = sa.getPopulatedFieldsAsMap();         
            if(fieldMap.containsKey('ServiceTerritoryId')){
                stIdSet.add(sa.ServiceTerritoryId);
            }else{
                noLookupSet.add(sa.Id);
            }
        }        

system.debug( stIdSet );
system.debug( noLookupSet );

        if(noLookupSet.size() > 0){
            saList = [SELECT id, ServiceTerritoryId FROM ServiceAppointment WHERE Id in : noLookupSet];
            for(ServiceAppointment sa : saList){
                fieldMap = sa.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceTerritoryId')){
                        stIdSet.add(sa.ServiceTerritoryId);
                }
            }
        }

        if(stIdSet.size() > 0){
            return isBeta([SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : stIdSet]);
        }else{
            return false;
        }

    }

    public static Boolean isBeta(List<AssignedResource> arList){
     system.debug('Is Beta - ar enter');
        Set<Id> srIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

system.debug(arList);        
        for(AssignedResource ar : arList){
            fieldMap = ar.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('ServiceResourceId')){
                srIdSet.add(ar.ServiceResourceId);
            }else{
                noLookupSet.add(ar.Id);
            }
        }

system.debug( srIdSet );
system.debug( noLookupSet );        

        if(noLookupSet.size() > 0){
            arList = [SELECT id, ServiceResourceId FROM AssignedResource WHERE Id in : noLookupSet];
            for(AssignedResource ar : arList){
                fieldMap = ar.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceResourceId')){
                    srIdSet.add(ar.ServiceResourceId);
                }
            }
        }

        if(srIdSet.size() > 0){
            return isBeta([SELECT Id FROM ServiceResource WHERE Id in : srIdSet]);
        }else{
            return false;
        }
    }

    public static Boolean isBeta(List<WorkOrderLineItem> woliList){
     system.debug('Is Beta - woli enter');

        Set<Id> woIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();


        for(WorkOrderLineItem woli : woliList){
            fieldMap = woli.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('WorkOrderId')){
                woIdSet.add(woli.WorkOrderId);
            }else{
                noLookupSet.add(woli.Id);
            }
        }

        if(noLookupSet.size() > 0){
            woliList = [SELECT id, WorkOrderId FROM WorkOrderLineItem WHERE Id in : noLookupSet];
            for(WorkOrderLineItem woli : woliList){
                fieldMap = woli.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('WorkOrderId')){
                    woIdSet.add(woli.WorkOrderId);
                }
            }
        }

        if(woIdSet.size() > 0){
            return isBeta([SELECT Id, ServiceTerritoryId FROM WorkOrder WHERE Id in : woIdSet]);
        }else{
            return false;
        }
    }

    public static Boolean isBeta(List<WorkOrder> woList){
     system.debug('Is Beta - wo enter');
        Set<Id> stIdSet = new Set<Id>();
        for(WorkOrder wo : woList){
            if ( wo.ServiceTerritoryId != null ) {
                stIdSet.add( wo.ServiceTerritoryId );
            } else {
                return FALSE;
            }
        }

        return isBeta([SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : stIdSet]);
    }

    public static Boolean isBeta(List<Account> accList){
        //access owner and then go through
     system.debug('accList: ' +accList);
     system.debug('Is Beta - acc enter');

        Set<Id> uIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(Account acc : accList){
            fieldMap = acc.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('OwnerId')){
                uIdSet.add(acc.OwnerId);
            }else{
                noLookupSet.add(acc.Id);
            }
        }

        if(noLookupSet.size() > 0){
            accList = [SELECT id, OwnerId FROM Account WHERE Id in : noLookupSet];
            for(Account acc : accList){
                fieldMap = acc.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('OwnerId')){
                    uIdSet.add(acc.OwnerId);
                }
            }
        }

        system.debug(accList);
        system.debug(uIdSet);

        if(uIdSet.size() > 0){
            return isBeta([SELECT Id FROM User WHERE Id in : uIdSet]);
        }else{
            return false;
        }
     }


    public static Boolean isBeta(List<User> uList){
     system.debug('Is Beta - user enter');
        Set<Id> uIdSet = new Set<Id>();
        for(User u : uList){
            uIdSet.add(u.Id);
        }
        return isBeta([SELECT Id FROM ServiceResource WHERE RelatedRecordId in : uIdSet]);
    }

    public static Boolean isBeta(List<Condition_Report_Prescreen__c> crpList){
        Set<Id> crpIdSet = new Set<Id>();
        for(Condition_Report_Prescreen__c crp : crpList){
            crpIdSet.add(crp.Id);
        }
        crpList = [SELECT id, Condition_Report__r.Dealership__r.Id FROM Condition_Report_Prescreen__c WHERE id in : crpIdSet];
        for(Condition_Report_Prescreen__c crp : crpList){
            crpIdSet.add(crp.Condition_Report__r.Dealership__r.Id);
        }
        return isBeta([SELECT id,ownerId FROM Account WHERE id in : crpIdSet]);
    }

    public static Boolean isNotBeta(List<ServiceTerritory> stList){
        return notContainedInRegions(stList);
    }

    public static Boolean isNotBeta(List<ServiceTerritoryMember> stmList){

     system.debug('Is Beta - stm enter');

        Set<Id>stIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(ServiceTerritoryMember stm : stmList){
            fieldMap = stm.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('ServiceTerritoryId')){
                stIdSet.add(stm.ServiceTerritoryId);
            }else{
                noLookupSet.add(stm.Id);
            }
        }

        if(noLookupSet.size() > 0){
            stmList = [SELECT id, ServiceTerritoryId FROM ServiceTerritoryMember WHERE Id in : noLookupSet];
            for(ServiceTerritoryMember stm : stmList){
                fieldMap = stm.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceTerritoryId')){
                    stIdSet.add(stm.ServiceTerritoryId);
                }
            }
        }
     system.debug('Is Beta - stm exit');
        if(stIdSet.size() > 0){
            return isNotBeta([SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : stIdSet]);
        }else{
            return false;
        }     
    }

    public static Boolean isNotBeta(List<ServiceResource> srList){
     system.debug('Is Beta - sr enter');
        Set<Id> srIdSet = new Set<Id>();
        for(ServiceResource sr : srList){
            srIdSet.add(sr.Id);
        }

        return isNotBeta([SELECT Id, ServiceTerritoryId FROM ServiceTerritoryMember WHERE ServiceResourceId in : srIdSet]);       
    }

    public static Boolean isNotBeta(List<ServiceAppointment> saList){
     system.debug('Is Beta - sa enter');
        Set<Id>stIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(ServiceAppointment sa : saList){
            fieldMap = sa.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('ServiceTerritoryId')){
                stIdSet.add(sa.ServiceTerritoryId);
            }else{
                noLookupSet.add(sa.Id);
            }
        }
system.debug( stIdSet );
system.debug( noLookupSet );        

        if(noLookupSet.size() > 0){
            saList = [SELECT id, ServiceTerritoryId FROM ServiceAppointment WHERE Id in : noLookupSet];
            for(ServiceAppointment sa : saList){
                fieldMap = sa.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceTerritoryId')){
                        stIdSet.add(sa.ServiceTerritoryId);
                }
            }
        }

system.debug( stIdSet );        

        if(stIdSet.size() > 0){
            return isNotBeta([SELECT Id, Name, TopLevelTerritoryId FROM ServiceTerritory WHERE Id in : stIdSet]);
        }else{
            return false;
        }

    }

    public static Boolean isNotBeta(List<AssignedResource> arList){
     system.debug('Is Beta - ar enter');
        Set<Id> srIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();
        
        for(AssignedResource ar : arList){
            fieldMap = ar.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('ServiceResourceId')){
                srIdSet.add(ar.ServiceResourceId);
            }else{
                noLookupSet.add(ar.Id);
            }
        }

        if(noLookupSet.size() > 0){
            arList = [SELECT id, ServiceResourceId FROM AssignedResource WHERE Id in : noLookupSet];
            for(AssignedResource ar : arList){
                fieldMap = ar.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('ServiceResourceId')){
                    srIdSet.add(ar.ServiceResourceId);
                }
            }
        }

        if(srIdSet.size() > 0){
            return isNotBeta([SELECT Id FROM ServiceResource WHERE Id in : srIdSet]);
        }else{
            return false;
        }
    }

    public static Boolean isNotBeta(List<WorkOrderLineItem> woliList){
     system.debug('Is Beta - woli enter');

        Set<Id> woIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();


        for(WorkOrderLineItem woli : woliList){
            fieldMap = woli.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('WorkOrderId')){
                woIdSet.add(woli.WorkOrderId);
            }else{
                noLookupSet.add(woli.Id);
            }
        }

        if(noLookupSet.size() > 0){
            woliList = [SELECT id, WorkOrderId FROM WorkOrderLineItem WHERE Id in : noLookupSet];
            for(WorkOrderLineItem woli : woliList){
                fieldMap = woli.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('WorkOrderId')){
                    woIdSet.add(woli.WorkOrderId);
                }
            }
        }

        if(woIdSet.size() > 0){
            return isNotBeta([SELECT Id, ServiceTerritoryId FROM WorkOrder WHERE Id in : woIdSet]);
        }else{
            return false;
        }
    }

    public static Boolean isNotBeta(List<WorkOrder> woList){
     system.debug('Is Beta - wo enter');
        Set<Id> woIdSet = new Set<Id>();
        for(WorkOrder wo : woList){
            if ( wo.ServiceTerritoryId == null ) {
                return true; // If any records are not beta, aka Service Territories not being filled in, then throw true
            }
            woIdSet.add(wo.Id);
        }
system.debug( woIdSet );        

        return isNotBeta([SELECT Id, ServiceTerritoryId FROM ServiceAppointment WHERE ParentRecordId in : woIdSet]);
    }

    public static Boolean isNotBeta(List<Account> accList){
        //access owner and then go through
     system.debug('accList: ' +accList);
     system.debug('Is Beta - acc enter');

        Set<Id> uIdSet = new Set<Id>();
        Set<Id>noLookupSet = new Set<Id>();
        Map<String, Object> fieldMap = new Map<String, Object>();

        for(Account acc : accList){
            fieldMap = acc.getPopulatedFieldsAsMap();
            if(fieldMap.containsKey('OwnerId')){
                uIdSet.add(acc.OwnerId);
            }else{
                noLookupSet.add(acc.Id);
            }
        }

        if(noLookupSet.size() > 0){
            accList = [SELECT id, OwnerId FROM Account WHERE Id in : noLookupSet];
            for(Account acc : accList){
                fieldMap = acc.getPopulatedFieldsAsMap();
                if(fieldMap.containsKey('OwnerId')){
                    uIdSet.add(acc.OwnerId);
                }
            }
        }

        system.debug(accList);
        system.debug(uIdSet);

        if(uIdSet.size() > 0){
            return isNotBeta([SELECT Id FROM User WHERE Id in : uIdSet]);
        }else{
            return false;
        }
     }


    public static Boolean isNotBeta(List<User> uList){
     system.debug('Is Beta - user enter');
        Set<Id> uIdSet = new Set<Id>();
        for(User u : uList){
            uIdSet.add(u.Id);
        }
        return isNotBeta([SELECT Id FROM ServiceResource WHERE RelatedRecordId in : uIdSet]);
    }*/

    
}