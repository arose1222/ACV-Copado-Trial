public class RecordCaseFieldHistory extends TriggerInterface {
    private static Map<Id, String> triggeredCases = new Map<Id, String>();
    
    private static List<Case> getUnTriggeredCases(List<Case> checkCasesIfTriggered)	{
        List<Case> unTriggeredCases = new List<Case>();
        for(Case c : checkCasesIfTriggered)	{
            String tc = triggeredCases.get(c.Id);
            if(tc == null)	{
                /* Map is used for constant lookup time. 
                 * A single letter ('y' in this case) is used as a value to keep the memory footprint small.
                 * There is no other significance of the letter 'y' here.
                 */
                triggeredCases.put(c.Id, 'y');
                unTriggeredCases.add(c);
            }
        }
        
        return unTriggeredCases;
    }
    
    /*
     * @description This recussive trigger is reset after every trancsaction (like insert/update/etc operations).
     * Sometimes, we want to reset the recussive trigger within a transaction (e.g. a Unit Test where each test method is run within a single transaction).
     */
    public static void reset()	{
        triggeredCases = new Map<Id, String>();
    }
    
    
    public override void afterInsert( List<SObject> newList ) {
        List<Case> newCasesNotTriggeredYet = getUnTriggeredCases(newList);
        if(newCasesNotTriggeredYet.size() > 0)	{
        	FieldHistoryProcess.create(newCasesNotTriggeredYet, null );
        }
    }
    
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        List<Case> newCasesNotTriggeredYet = getUnTriggeredCases((List<Case>)newMap.values());
        if(newCasesNotTriggeredYet.size() > 0)	{        
        	FieldHistoryProcess.create( newCasesNotTriggeredYet, oldMap );
        }
    }
}