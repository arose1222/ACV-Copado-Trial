public class STMAddressPopulation extends TriggerInterface{

    @TestVisible private static final String STM_NO_USER_ADDRESS_ERROR = 'You cannot create an STM if the associated Service Resource User does not have an address';

    public override void beforeInsert(List<SObject> newList){
        List<ServiceTerritoryMember> stmList = (List<ServiceTerritoryMember>)newList;
        updateSTMAddresses(stmList);
    }

    private void updateSTMAddresses(List<ServiceTerritoryMember> stmList){
        List<Id> userIds = new List<Id>();
        List<Id> resourceIds = new List<Id>();

        for(ServiceTerritoryMember stm : stmList){
            if(stm.TerritoryType == 'P'){
                resourceIds.add(stm?.ServiceResourceId);
            }
        }
        if(resourceIds.contains(null)){
            resourceIds.remove(null);
        }

        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>([SELECT RelatedRecordId FROM ServiceResource WHERE Id in : resourceIds]);
        for(ServiceResource sr : srMap.values()){
            userIds.add(sr?.RelatedRecordId);
        }
        If(userIds.contains(null)){
            userIds.remove(null);
        }

        Map<Id, User> userMap = new Map<Id, User>([SELECT Address, Street, City, State, Country, PostalCode FROM User WHERE Id in : userIds]);

        for(ServiceTerritoryMember stm: stmList){
            Id srId = stm?.ServiceResourceId;
            Id uId = srMap.get(srId)?.RelatedRecordId;
            if(uId != null && stm.TerritoryType == 'P' ){
                if ( !String.isBlank( userMap.get(uId)?.Street ) && !String.isBlank( userMap.get(uId)?.City ) && !String.isBlank( userMap.get(uId)?.State ) && !String.isBlank( userMap.get(uId)?.PostalCode )  && !String.isBlank( userMap.get(uId)?.Country ) ) {
                    stm.Street = userMap.get(uId)?.Street;
                    stm.City = userMap.get(uId)?.City;
                    stm.State = userMap.get(uId)?.State;
                    stm.Country = userMap.get(uId)?.Country;
                    stm.PostalCode = userMap.get(uId)?.PostalCode;
                } else {
                    stm.addError( STM_NO_USER_ADDRESS_ERROR );
                }
            } else if ( stm.TerritoryType == 'P' ) {
                stm.addError( STM_NO_USER_ADDRESS_ERROR );
            }
        }
    }
}