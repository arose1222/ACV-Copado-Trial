/**
 * This class holds the logic to populate the 48 Hour Expiration field
 * on Case when the Status is 48 Hour Notice
 * @author James Andre LaCour
 */
public class Case48HourLogic extends TriggerInterface{
    /*If Buyer Notice Given                --> Then 48 Hour Notice Period Expires
    Monday before 5:00pm EST               --> Wednesday at 5:00pm EST
    Monday at or after 5:00pm EST          --> Thursday at 5:00pm EST
    Tuesday before 5:00pm EST              --> Thursday at 5:00pm EST
    Tuesday at or after after 5:00pm EST   --> Friday at 5:00pm EST
    Wednesday before 5:00pm EST            --> Friday at 5:00pm EST
    Wednesday at or after after 5:00pm EST --> Monday at 5:00pm EST
    Thursday before 5:00pm EST             --> Monday at 5:00pm EST
    Thursday at or after after 5:00pm EST  --> Tuesday at 5:00pm EST
    Friday before 5:00pm EST               --> Tuesday at 5:00pm EST
    Friday at or after after 5:00pm EST    --> Wednesday at 5:00pm EST
    Saturday (anytime) EST                 --> Wednesday at 5:00pm EST
    Sunday (anytime) EST                   --> Wednesday at 5:00pm EST */
    /********* Class Variables ************/
    @TestVisible private static Datetime initialDatetime = Datetime.now();
    @TestVisible private final static String CASE_STATUS_CHECK = '48 Hour Notice';
    @TestVisible private final static Time EXPIRATION_TIME = Time.newInstance(17,0,0,0);  //5 PM EST
    @TestVisible private final static Time AFTER_HOURS_TIME = Time.newInstance(23, 0, 0, 0);    //Used in the getDateAfterXBusinessDays to set after hours
    @TestVisible private final static Id titleInfoRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
    private static BusinessHours case48HourBussinessHour{
        get{
            if ( case48HourBussinessHour == null ) {
                case48HourBussinessHour = [ SELECT Id FROM BusinessHours WHERE Name = '48 Hour Expiration Date Hours' LIMIT 1 ];
            }
            return case48HourBussinessHour;
        }
        set;
    }
    /*********** Context Methods ***********/
    /**
     * logic to run in before update context
     * @param oldMap - Map of Id-->Case old values
     * @param newMap - Map of Id-->Case new values
     * @return void
     */
    public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        List<Case> casesToProcess = new List<Case>();
        Map<Id, Case> oldCaseMap = (Map<Id,Case>)oldMap;
        for( Case c : ((Map<Id,Case>)newMap).values() ){
            if( c.Status == CASE_STATUS_CHECK && c.Status != oldCaseMap.get(c.Id).Status && c.RecordTypeId == titleInfoRTId ){
                casesToProcess.add(c);
            }
        }
        if( casesToProcess.size() > 0 ) expirationDatePopulation(casesToProcess);
    }
    /************** Helper Methods ***************/
    /**
     * populates the 48 Hour Expiration field on case for the cases passed in
     * @param casesToProcess - cases that passed the conditions set in the context methods
     * @return void
     */
    public void expirationDatePopulation( List<Case> casesToProcess ){
        Datetime startDayToCount = BusinessHours.nextStartDate( case48HourBussinessHour.Id, initialDatetime );
        Datetime expirationDate = Datetime.newInstance(getDateAfterXBusinessDays(startDayToCount.date(), 2),EXPIRATION_TIME);
        for( Case c : casesToProcess ){
            c.X48_Hour_Expiration__c = expirationDate;
        }
    }
    /**
     * populates the 48 Hour Expiration field on case for the cases passed in
     * @param startDate - date to use to determine the next eligible 
     * @param dayOffset - number of days to offset
     * @return the next Business Day based on the date passed in + the offset Days
     */
    private Date getDateAfterXBusinessDays( Date startDate, Integer dayOffset ){
        Datetime newDate = Datetime.newInstance(startDate, AFTER_HOURS_TIME);
        for( Integer i=0; i<dayOffset; i++ ){
            newDate = BusinessHours.nextStartdate( case48HourBussinessHour.Id, newDate );
            newDate = Datetime.newInstance(newDate.date(), AFTER_HOURS_TIME);
        }
        return newDate.date();
    }
}