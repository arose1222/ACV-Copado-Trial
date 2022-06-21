public class RevolvingGenerator {

    public static final Date TODAY = Date.today();
    public static final Datetime NOW = System.now();
    public static TimeZone currentTimeZone = UserInfo.getTimeZone();
    //change this to select based on the revolving appointment record in the future
    public static WorkType currentWorkType = [SELECT Id FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1];
    public static Decimal durationMin = [SELECT DurationInMinutes FROM WorkType WHERE Name = 'Standard Inspection'].DurationInMinutes;

    public static Time defaultStartTime = Time.newInstance(0,0,0,0);
    public static Time defaultEndTime = Time.newInstance(23,59,59,999);



    public static List<String> generate(List<Occurrence__c> occList, Date beginningDate, Date farthestDate) {
        Map<Id, Occurrence__c> occs = new Map<Id, Occurrence__c>(occList);

        List<String> returnDebug = new List<String>();

        List<WorkOrder> generatedWorkOrders = new List<WorkOrder>();
        for(Occurrence__c occ : occs.values()){
            if(occ.Farthest_Date_Generated__c == null){
                    returnDebug.add('Occurrence ' + occ.Id + ' is missing the value Farthest_Date_Generated. Creating Values from today onward.');
                    occ.Farthest_Date_Generated__c = beginningDate;
            }
                //create work orders for this occurrence
                generatedWorkOrders.addAll(createData(occ, RevolvingUtility.getDatesFromOccurence(occ, farthestDate)));
        }

        //insert wos
        List<Database.SaveResult> workOrderResults = Database.insert(generatedWorkOrders, false);
        List<String> woErrors = RevolvingUtility.processSaveResults(workOrderResults);
        returnDebug.add((generatedWorkOrders.size() - woErrors.size()) + ' of ' + generatedWorkOrders.size() + ' Work Orders successfully inserted');
        returnDebug.addAll(woErrors);

        Map<Id, Occurrence__c> occsWithFailedChildren = new Map<Id, Occurrence__c>();
        Set<Id> workOrderIds = new Set<Id>();


        for(Integer i = 0; i < workOrderResults.size(); i++){
            if(!workOrderResults[i].isSuccess()){
                if(generatedWorkOrders[i].Occurrence__c != null && occs.containsKey(generatedWorkOrders[i].Occurrence__c)){
                    Id occId = generatedWorkOrders[i].Occurrence__c;
                    returnDebug.add('Occurrence ' + occId + ' had a child that that caused an error, the record will not be updated.');
                    occsWithFailedChildren.put(occId, occs.remove(occId));
                }
            }
            else{
                workOrderIds.add(generatedWorkOrders[i].id);
            }
        }


        List<ServiceAppointment> generatedServiceAppointments = [
                SELECT  Id,
                        Work_Order__r.StartDate,
                        Work_Order__r.EndDate,
                        Work_Order__r.Occurrence__r.Start_Time__c,
                        Work_Order__r.Occurrence__r.End_Time__c,
                        Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__r.Id,
                        Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__c,
                        Work_Order__r.Occurrence__r.Timeline__r.Street__c,
                        Work_Order__r.Occurrence__r.Timeline__r.City__c,
                        Work_Order__r.Occurrence__r.Timeline__r.State__c,
                        Work_Order__r.Occurrence__r.Timeline__r.Country__c,
                        Work_Order__r.Occurrence__r.Timeline__r.Postal_Code__c,
                        Work_Order__r.Duration,
                        Account.BillingLatitude,
                        Account.BillingLongitude,
            			ServiceTerritory.OperatingHours.TimeZone
                FROM ServiceAppointment
                WHERE ParentRecordId IN :workOrderIds];

        // Get Resource Preferences that exist, verify they are required
        Map<Id, List<ResourcePreference>> generatedResourcePrefFromAcctMap = new Map<Id, List<ResourcePreference>>();
        for ( ResourcePreference rePrefRec : [ SELECT Id, PreferenceType, RelatedRecordId, ServiceResourceId FROM ResourcePreference WHERE RelatedRecordId IN :workOrderIds ] ) {
            if ( generatedResourcePrefFromAcctMap.get( rePrefRec.RelatedRecordId ) == null ) {
                generatedResourcePrefFromAcctMap.put( rePrefRec.RelatedRecordId, new List<ResourcePreference>() );
            }
            generatedResourcePrefFromAcctMap.get( rePrefRec.RelatedRecordId ).add( rePrefRec );
        }

        List<ResourcePreference> generatedResourcePreferences = new List<ResourcePreference>();
        List<ResourcePreference> updateResourcePrefLst = new List<ResourcePreference>();

        for (ServiceAppointment sa : generatedServiceAppointments){
            if(sa.Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__c != null) {
                Boolean checkGeneration = FALSE;
                if ( generatedResourcePrefFromAcctMap.get( sa.Work_Order__c ) == null ) {  // If no existing Resource Preference Exists
                    generatedResourcePreferences.add( createData( sa ) );
                } else { // A Resource Preference Exists
                    for ( ResourcePreference existingRePref : generatedResourcePrefFromAcctMap.get( sa.Work_Order__c ) ) {
                        if ( existingRePref.ServiceResourceId == sa.Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__r.Id ) {
                            existingRePref.PreferenceType = 'Required';
                            updateResourcePrefLst.add( existingRePref );
                            checkGeneration = TRUE;
                            break; // No need to continue if a resource is found
                        }
                    }

                    if ( !checkGeneration ) { // If no proper existing resource is found, we need to make one
                        generatedResourcePreferences.add( createData( sa ) );
                    }
                }
            }

            //need null-checking here
            sa.Duration = sa.Work_Order__r.Duration;

            //if start and end time are populated on the occurrence, use that, else use the default
            TimeZone territoryTimezone;
            if(sa.ServiceTerritory != null) {
                territoryTimezone = TimeZone.getTimeZone( sa.ServiceTerritory.OperatingHours.TimeZone );
            }
            else {
                territoryTimezone = currentTimeZone;
            }

            if(sa.Work_Order__r.Occurrence__r.Start_Time__c != null) {
                sa.EarliestStartTime = calculateTimeWithOffset(currentTimeZone, territoryTimezone, sa.Work_Order__r.StartDate.date(), sa.Work_Order__r.Occurrence__r.Start_Time__c);
            }
            else { 
                sa.EarliestStartTime = Datetime.newInstance(sa.Work_Order__r.StartDate.date(), defaultStartTime); 
            }

            if(sa.Work_Order__r.Occurrence__r.End_Time__c != null) {
                sa.DueDate = calculateTimeWithOffset(currentTimeZone, territoryTimezone, sa.Work_Order__r.EndDate.date(), sa.Work_Order__r.Occurrence__r.End_Time__c);
            }
            else { 
                sa.DueDate = Datetime.newInstance(sa.Work_Order__r.EndDate.date(), defaultEndTime); 
            }

            //sa.EarliestStartTime = Datetime.newInstance(sa.Work_Order__r.StartDate.date(), (sa.Work_Order__r.Occurrence__r.Start_Time__c != null ? sa.Work_Order__r.Occurrence__r.Start_Time__c : defaultStartTime));
            //sa.DueDate = Datetime.newInstance(sa.Work_Order__r.EndDate.date(), (sa.Work_Order__r.Occurrence__r.End_Time__c != null ? sa.Work_Order__r.Occurrence__r.End_Time__c : defaultEndTime));

            if((sa.Work_Order__r.Occurrence__r.Timeline__r.Street__c == null || sa.Work_Order__r.Occurrence__r.Timeline__r.City__c == null || sa.Work_Order__r.Occurrence__r.Timeline__r.Postal_Code__c == null || sa.Work_Order__r.Occurrence__r.Timeline__r.State__c == null || sa.Work_Order__r.Occurrence__r.Timeline__r.Country__c == null)
                && sa.Account.BillingLatitude != null && sa.Account.BillingLongitude != null) {
                sa.Latitude = sa.Account.BillingLatitude;
                sa.Longitude = sa.Account.BillingLongitude;
            }
        }

        List<Database.SaveResult> resourcePreferenceResults = Database.insert(generatedResourcePreferences, false);
        List<String> rpErrors = RevolvingUtility.processSaveResults(resourcePreferenceResults);
        Set<Id> rpErrorIds = RevolvingUtility.errorIdSet(resourcePreferenceResults);
        returnDebug.add((generatedResourcePreferences.size() - rpErrors.size()) + ' of ' + generatedResourcePreferences.size() +  ' Resource Preferences successfully inserted');
        returnDebug.addAll(rpErrors);

        //Update Resource Preferences
        List<Database.SaveResult> updateResourcePreferenceResults = Database.update(updateResourcePrefLst, false);
        List<String> updateRPErrors = RevolvingUtility.processSaveResults(updateResourcePreferenceResults);
        returnDebug.add((updateResourcePrefLst.size() - updateRPErrors.size()) + ' of ' + updateResourcePrefLst.size() +  ' Resource Preferences successfully updated');
        returnDebug.addAll(updateRPErrors);

        List<Database.SaveResult> serviceAppointmentResults = Database.update(generatedServiceAppointments, false);
        List<String> saErrors = RevolvingUtility.processSaveResults(serviceAppointmentResults);
        Set<Id> saErrorIds = RevolvingUtility.errorIdSet(serviceAppointmentResults);
        returnDebug.add((generatedServiceAppointments.size() - saErrors.size()) + ' of ' + generatedServiceAppointments.size() +  ' Service Appointments successfully inserted');
        returnDebug.addAll(saErrors);


        //insert rps
        //insert service appointments

        List<WorkOrder> wosWithErrors = new List<WorkOrder>();

        wosWithErrors.addAll([SELECT Id FROM WorkOrder WHERE Id in (SELECT Work_Order__c FROM ServiceAppointment WHERE Id in : saErrorIds)]);
        wosWithErrors.addAll([SELECT Id FROM WorkOrder WHERE Id in (SELECT RelatedRecordId FROM ResourcePreference WHERE Id in : rpErrorIds)]);
        occsWithFailedChildren.putAll([SELECT Id, Farthest_Date_Generated__c FROM Occurrence__c WHERE Id in (SELECT Occurrence__c FROM WorkOrder WHERE Id in : wosWithErrors)]);
        Map<Id, Occurrence__c> occsToUpdate = new Map<Id, Occurrence__c>();
        for(Occurrence__c occ : occs.values()){
            if(occsWithFailedChildren.containsKey(occ.id)){
                returnDebug.add('Occurrence ' + occ.id + ' had a child that that caused an error, the record will not be updated.');
            }
            else{
                Occurrence__c occurrenceRecord = occs.get(occ.id);
                occurrenceRecord.Farthest_Date_Generated__c = DateTime.newInstance(farthestDate.year(), farthestDate.month(), farthestDate.day(), Now.hour(), Now.minute(), NOW.second()).addHours(-5);//add four hours or however far is needed
                occurrenceRecord.Most_Recent_Batch__c = System.now().addMinutes(15);
                occsToUpdate.put(occ.id, occs.get(occ.id));
            }
        }
        //clean up the failed occurrence record in case there were a mix of successes and failures
        RevolvingCleaner.deleteChangedRecords(occsWithFailedChildren.values());


        List<Database.SaveResult> occurrenceResults = Database.update(occsToUpdate.values(), false);
        List<String> occErrors = RevolvingUtility.processSaveResults(occurrenceResults);
        Set<Id> occErrorIds = RevolvingUtility.errorIdSet(occurrenceResults);
        returnDebug.add((occs.size() - occErrors.size()) + ' of ' + occs.size() + ' Occurrences successfully inserted');
        returnDebug.addAll(occErrors);


        returnDebug.add('Number of SOQL queries executed = ' + Limits.getQueries());

        //update the occurrences with new farthest date, unless an error occurred, then exclude that record from updating
        return returnDebug;
    }

    public static Datetime calculateTimeWithOffset(TimeZone currentTimeZone, TimeZone territoryTimeZone, Date startOrEndDate, Time startOrEndTime) {
        if(territoryTimezone.toString() == currentTimeZone.toString()) {
            return Datetime.newInstance(startOrEndDate, startOrEndTime);
        }
        else {
            DateTime dtime = Datetime.newInstance(startOrEndDate, startOrEndTime);
            
            Integer territoryOffset = territoryTimeZone.getOffset(dtime);
            Integer runningOffset = currentTimeZone.getOffset(dtime);
            Integer totalOffset = runningOffset - territoryOffset;
            totalOffset = totalOffset / 1000;
            
            dtime = dtime.addSeconds(totalOffset);
            return dtime;
        }
    }

    public static List<WorkOrder> createData(Occurrence__c occ, List<Date> dates) {
        List<WorkOrder> wos = new List<WorkOrder>();

        //Make sure account has service territory
        TimeZone territoryTimezone;
        if(occ.Timeline__r.Account__r.Service_Territory__c != null) {
            territoryTimezone = TimeZone.getTimeZone( occ.Timeline__r.Account__r.Service_Territory__r.OperatingHours.TimeZone );
        }
        else {
            territoryTimezone = currentTimeZone;
        }

        for(Date d : dates) {
            
            Datetime startingDateTime = null;
            DateTime endingDateTime = null;

            if(occ.Start_Time__c != null) {
                startingDateTime = calculateTimeWithOffset(currentTimeZone, territoryTimezone, d, occ.Start_Time__c);
            }
            else { startingDateTime = Datetime.newInstance(d, defaultStartTime); }

            if(occ.End_Time__c != null) {
                endingDateTime = calculateTimeWithOffset(currentTimeZone, territoryTimezone, d, occ.End_Time__c);
            }
            else { endingDateTime = Datetime.newInstance(d, defaultEndTime); }

            WorkOrder woRec = new WorkOrder(
                StartDate = startingDateTime,
                EndDate = endingDateTime,
                //StartDate = Datetime.newInstance(d,(occ.Start_Time__c!=null?occ.Start_Time__c:defaultStartTime)),
                //EndDate = Datetime.newInstance(d,(occ.End_Time__c!=null?occ.End_Time__c:defaultEndTime)),
                AccountId = occ.Timeline__r.Account__c,
                ServiceTerritoryId = occ.Timeline__r.Account__r.Service_Territory__c,
                Priority = 'Low',
                Duration = (occ.Timeline__r.Average_Number_Cars__c != null
                            &&(occ.Timeline__r.Work_Type__r != NULL && occ.Timeline__r.Work_Type__r.DurationInMinutes != NULL))
                			? occ.Timeline__r.Average_Number_Cars__c*occ.Timeline__r.Work_Type__r.DurationInMinutes
                			:  2 ,
                DurationType = 'Minutes',
                Occurrence__c = occ.Id,
                WorkTypeId = (occ.Timeline__r.Work_Type__c == NULL) ? currentWorkType.Id : occ.Timeline__r.Work_Type__c,
                Origin__c = 'Revolving Term',
                Inspection_Number_of_Vehicles__c = occ.Timeline__r.Average_Number_Cars__c,
                Created_Without_Line_Items__c = TRUE,
                DueDate_Adjustment_Engine_Bypass__c = TRUE,
                Special_Instructions_for_VCI__c = occ.Timeline__r.Special_Instructions__c
            );

            setAddress(woRec, occ);

            wos.add(woRec);
        }
        return wos;
    }

    public static void setAddress(WorkOrder woRec, Occurrence__c occ) {
        if(occ.Timeline__r.Street__c == null || occ.Timeline__r.City__c == null || occ.Timeline__r.Postal_Code__c == null || occ.Timeline__r.State__c == null || occ.Timeline__r.Country__c == null) {
            woRec.Street = occ.Timeline__r.Account__r?.BillingStreet;
            woRec.City = occ.Timeline__r.Account__r?.BillingCity;
            woRec.PostalCode = occ.Timeline__r.Account__r?.BillingPostalCode;
            woRec.State = occ.Timeline__r.Account__r?.BillingState;
            woRec.Country = occ.Timeline__r.Account__r?.BillingCountry;
            woRec.Latitude = occ.Timeline__r.Account__r?.BillingLatitude;
            woRec.Longitude = occ.Timeline__r.Account__r?.BillingLongitude;
        }
        else {
            woRec.Street = occ.Timeline__r.Street__c;
            woRec.City = occ.Timeline__r.City__c;
            woRec.PostalCode = occ.Timeline__r.Postal_Code__c;
            woRec.State = occ.Timeline__r.State__c;
            woRec.Country = occ.Timeline__r.Country__c;
        }
    }

    public static ResourcePreference createData( ServiceAppointment sa ) {
        return new ResourcePreference(
            RelatedRecordId = sa.Work_Order__c,
            PreferenceType = 'Required',
            ServiceResourceId = sa.Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__r.Id
        );
    }
}