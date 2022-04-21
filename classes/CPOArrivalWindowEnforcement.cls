/**
 * @description Ensures the Optimizer cannot schedule CPO Service Appointments to start outside of 9am to 2pm local time.
 * @author Matthew Fritschi
 * @since 4/4/2022
 * @group Inspector Dispatch
 */
public class CPOArrivalWindowEnforcement extends TriggerInterface {

    //If no timezone, assume it's the timezone of the scheduler??? Or don't check?
    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        List<Id> serviceTerritoriesToCheck = new List<Id>();
        List<ServiceAppointment> serviceApptsToCheck = new List<ServiceAppointment>();
        TimeZone currentTimeZone = UserInfo.getTimeZone();
        FSL_Work_Type_Arrival_Window__mdt arrivalWindow = [SELECT Label, Active__c, Earliest_Start_Time__c,  Latest_Start_Time__c FROM FSL_Work_Type_Arrival_Window__mdt WHERE Label = 'cpo' LIMIT 1];
        Boolean scheduler = UserInfo.getName() == 'FSL Optimization' ? true : false;

        if(scheduler && arrivalWindow != null && (arrivalWindow.Active__c || Test.isRunningTest())) {
            for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
                Boolean cpoSA = sa.Work_Type_Unique_Id__c.contains('cpo') && !sa.Work_Type_Unique_Id__c.contains('vcpo') ? true : false;
                if(cpoSA) {
                    ServiceAppointment oldSA = (ServiceAppointment) oldMap.get(sa.Id);
                    
                    if(sa.SchedStartTime != oldSA.SchedStartTime && sa.SchedStartTime != null) {
                        if(sa.ServiceTerritoryId != null) {
                            serviceTerritoriesToCheck.add(sa.ServiceTerritoryId);
                            serviceApptsToCheck.add(sa);
                            
                        }
                    }
                }
            }

            Map<Id, ServiceTerritory> serTerritoryMap = new Map<Id, ServiceTerritory>([SELECT Id, OperatingHoursId, OperatingHours.TimeZone FROM ServiceTerritory WHERE Id IN :serviceTerritoriesToCheck]);
            List<String> startTimes = arrivalWindow.Earliest_Start_Time__c.split(':');
            List<String> endTimes = arrivalWindow.Latest_Start_Time__c.split(':');
            for( ServiceAppointment sa : serviceApptsToCheck ) {
                if(serTerritoryMap.containsKey(sa.ServiceTerritoryId)) {
                    ServiceTerritory st = serTerritoryMap.get(sa.ServiceTerritoryId);
                    Time earliest = Time.newInstance(Integer.valueOf(startTimes[0]), Integer.valueOf(startTimes[1]), 0, 0);
                    Time latest = Time.newInstance(Integer.valueOf(endTimes[0]), Integer.valueOf(endTimes[1]), 0, 0);

                    Time startTime = Time.newInstance(sa.SchedStartTime.hour(), sa.SchedStartTime.minute(), sa.SchedStartTime.second(), sa.SchedStartTime.millisecond());
                    TimeZone territoryTimezone = TimeZone.getTimeZone( st.OperatingHours.TimeZone );
                    DateTime actualTime = RevolvingGenerator.calculateTimeWithOffset(territoryTimeZone, currentTimeZone, sa.SchedStartTime.date(), startTime);

                    startTime = Time.newInstance(actualTime.hour(), actualTime.minute(), actualTime.second(), actualTime.millisecond());
                    if(startTime < earliest || startTime > latest) {
                        sa.addError('CPO Service Appointments must be scheduled between 9am and 2pm.');
                    }
                }
            }
        } 
    }

}