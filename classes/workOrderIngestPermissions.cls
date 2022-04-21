public with sharing class workOrderIngestPermissions {
    
    private final static Set<String> PROFILE_NAMES_TO_AVOID_REV_APPTS_SET {
        get {
            System.debug('Start PROFILE_NAMES_TO_AVOID_REV_APPTS_SET');
            if ( PROFILE_NAMES_TO_AVOID_REV_APPTS_SET == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Profile Names to not display Rev Appts' LIMIT 1 ];
                PROFILE_NAMES_TO_AVOID_REV_APPTS_SET = new Set<String>( setting.Value__c.split( ',' ) );
            }
            return PROFILE_NAMES_TO_AVOID_REV_APPTS_SET;
        }
        set;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean checkToDisplayRevolving() {        
        Profile userProfile = [ SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1 ];
        Boolean displayRevolvingAppt = true;

        for ( String checkProfileStr : PROFILE_NAMES_TO_AVOID_REV_APPTS_SET ) {
            if ( userProfile.Name.contains( checkProfileStr ) ) {
                displayRevolvingAppt = false;
                break;
            }
        }

        return displayRevolvingAppt;
    }
}