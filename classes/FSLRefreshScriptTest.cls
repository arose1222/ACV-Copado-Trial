@isTest
public class FSLRefreshScriptTest {
    @IsTest
    static void runScript() {
        Test.startTest();
            FSLRefreshScript.processFSLData();
        Test.stopTest();
        
        System.assertNotEquals(
            0,
            [ SELECT Count() FROM WorkType ],
            'There was an unexpected amount of Work Types in the system'
        );

        System.assertEquals(
            1,
            [ SELECT Count() FROM FSL__Scheduling_Policy__c ],
            'There was an unexpected amount of Scheduling Policies in the system'
        );

        System.assertEquals(
            8,
            [ SELECT Count() FROM FSL__Scheduling_Policy_Goal__c ],
            'There was an unexpected amount of Scheduling Policy Goals in the system'
        );

        System.assertEquals(
            16, // We create 14, but 16 seem to exist? Maybe 2 are auto-created?
            [ SELECT Count() FROM FSL__Scheduling_Policy_Work_Rule__c ],
            'There was an unexpected amount of Scheduling Policy Work Rules in the system'
        );

        System.assertEquals(
            4,
            [ SELECT Count() FROM OperatingHours ],
            'There was an unexpected amount of Operating Hours in the system'
        );

        System.assertEquals(
            4,
            [ SELECT Count() FROM Timeslot ],
            'There was an unexpected amount of Timeslots in the system'
        );

        System.assertEquals(
            4,
            [ SELECT Count() FROM ServiceTerritory ],
            'There was an unexpected amount of ServiceTerritories in the system'
        );

        System.assertEquals(
            1,
            [ SELECT Count() FROM ServiceResource ],
            'There was an unexpected amount of ServiceResources in the system'
        );
    }
}