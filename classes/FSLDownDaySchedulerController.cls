public class FSLDownDaySchedulerController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getWorkTypes(String searchTerm, List<String> selectedIds){
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
        WorkType (Id, Name, EstimatedDuration, DurationType WHERE id NOT IN :selectedIds)
        LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String icon = 'custom:custom11';
        WorkType [] worktypeLst = ((List<WorkType>) searchResults[0]);
        for (WorkType wtRec : worktypeLst) {
            results.add( new LookupSearchResult(
                wtRec.Id, 'Work Type', 
                icon, wtRec.Name, 
                'WorkType • '+ wtRec.EstimatedDuration + ' ' + wtRec.DurationType 
            ));
        }

      return results;
    }

    @AuraEnabled
    public static boolean saveDownDay( String downDate, String workTypeId ) {
        if ( !String.isBlank( downDate ) && !String.isBlank( workTypeId ) ) {
            WorkType providedWT = [ SELECT Id, Name, Work_Type_Unique_ID__c FROM WorkType WHERE Id = :workTypeId LIMIT 1 ];
            List<String> dateArray = downDate.split( '-' );
            Date providedDate = Date.newInstance( Integer.valueOf( dateArray[0] ), Integer.valueOf( dateArray[1] ), Integer.valueOf( dateArray[2] ) );

            try {
                insert new Down_Day__c(
                    Work_Type__c = workTypeId,
                    Name = providedWT.Name + ' Down Day: ' + downDate,
                    Work_Type_Color__c = getColor( providedWT.Work_Type_Unique_ID__c ),
                    Start__c = DateTime.newInstance( providedDate, Time.newInstance( 4, 0, 0, 0 ) ),
                    End__c = DateTime.newInstance( providedDate, Time.newInstance( 20, 0, 0, 0 ) ),
                    Is_All_Day__c = TRUE
                );
            } catch ( exception e ) { // Send to Splunk - Future update?
                return false; 
            }
        }
        return true;
    }

    public static string getColor( String workTypeDevName ) {
        String returnColor;
        if ( workTypeDevName.contains( 'popo' ) ) { returnColor = '#7B3F00'; } //Porsche
        else if ( workTypeDevName.contains( 'gm' ) ) { returnColor = '#87CEEB'; } //GM
        else if ( workTypeDevName.contains( 'pofr' ) || workTypeDevName.contains( 'polnc' ) ) { returnColor = '#FFA500'; } //Ford
        else if ( workTypeDevName.contains( 'hn' ) ) { returnColor = '#0437F2'; } //Honda
        return returnColor;
    }
}