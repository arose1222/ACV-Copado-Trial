global class FSLRefreshScript {
    
    global static void processFSLData() {
        processMainFSLData();
        makeResourceData();
    }

    // Seperated Method to be easily called from other refresh scripts if needed
    global static void processMainFSLData() {

//        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        // Make Work Types
        List<WorkType> workTypeLst = FSLTestUtility.createWorkTypes();
        insert workTypeLst;

        // Make Work Type Groups
        List<WorkTypeGroup> workTypeGroupLst = FSLTestUtility.createWorkTypeGroups();
        insert workTypeGroupLst;

        // Make Work Type Group Memebers
        List<WorkTypeGroupMember> workTypeGroupMemberLst = FSLTestUtility.createWorkTypeGroupMembers();
        insert workTypeGroupMemberLst;

        // Get Skills to assign to Work Types
        Map<String, Skill> skillMap = new Map<String, Skill>();
        for ( Skill systemSkill :  [ SELECT Id, DeveloperName FROM Skill ] ) {
            skillMap.put( systemSkill.DeveloperName, systemSkill );
        }

        // Associate Work Type to Skill by naming
        List<SkillRequirement> skillRequireLst = new List<SkillRequirement>();
        for ( WorkType wtype : workTypeLst ) {
            Skill selectedSkill = skillMap.get( wtype.Name );
            if ( selectedSkill == null ) {
                String adjustedSkillName = null;
                switch on wtype.Work_Type_Unique_ID__c {
                    when 'inspection' {
                        adjustedSkillName = 'DealershipVisitInspections';
                    }
                    when 'verification' {
                        adjustedSkillName = 'DealershipVisitAssetVerification';
                    }
                    when 'true360' {
                        adjustedSkillName = 'DealershipVisitTrue360';
                    }
                    when 'siriusxm' {
                        adjustedSkillName = 'Sirius_XM';
                    }
                    when 'buyer signup' {
                        adjustedSkillName = 'Buyer_Signup';
                    }
                    when 'auction off-lease' {
                        adjustedSkillName = 'Auction_Off_Lease';
                    }
                    when 'acvhome' {
                        adjustedSkillName = 'ACV_Home';
                    }
                    when 'auction site' {
                        adjustedSkillName = 'Auction_Site';
                    }
                    when 'consumer' {
                        adjustedSkillName = 'FBI_Consumer';
                    }
                    when 'fbi' {
                        adjustedSkillName = 'FBI_Consumer';
                    }
                }
                selectedSkill = skillMap.get( adjustedSkillName );
            }

            if ( selectedSkill != null ) {
                skillRequireLst.add( new SkillRequirement(
                    SkillId = selectedSkill.Id,
                    RelatedRecordId = wtype.Id
                ) );
            }
        }

        // insert skill requirements
        insert skillRequireLst;

        // Generate Scheduling Policy Data
        FSL__Scheduling_Policy__c schPolicy = new FSL__Scheduling_Policy__c(
            Name = 'ACV Basic Tuning (Aug 20)',
            FSL__Description__c = 'This policy balances great customer service with travel minimization. Appointments are graded first by the customer\'s selection of a preferred employee and by the ability to provide the service as soon as possible. Travel minimization is considered as a second priority.',
            FSL__Commit_Mode__c = 'AlwaysCommit',
            FSL__Fix_Overlaps__c = TRUE
        );
        insert schPolicy;

        // Make Service Goal Data
        List<FSL__Service_Goal__c> createSchGoalLst = new List<FSL__Service_Goal__c>();
        
        FSL__Service_Goal__c asapImport = new FSL__Service_Goal__c(
            Name = 'ASAP - Important (Aug 20)',
            FSL__Object_Group_Field__c = 'ao_isao_is_asap_important_asap_important__c',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( asapImport );
        FSL__Service_Goal__c asapNonImport = new FSL__Service_Goal__c(
            Name = 'ASAP - Non Important (Aug 20)',
            FSL__Object_Group_Field__c = 'ao_isao_is_asap_important_asap_important__c',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( asapNonImport );
        FSL__Service_Goal__c asapImportOpt = new FSL__Service_Goal__c(
            Name = 'ASAP Important - Optimization (Aug20)',
            Description__c = '{"@objectType": "EnhancedTimeObjective","Name": "Schedule Non-Appointments ASAP",    "ProgID": "W6Objectives.W6EnhancedTimeObjective, W6Objectives",    "MinimalGrade": 0.0,    "MaximalGrade": 100.0,    "RelevanceGroup": {      "Key": -1,      "@DisplayString": "ASAP For Important (Aug 20)"    },    "IrrelevantGetsBestGrade": false,    "PriorityWorstValue": 0,    "PriorityBestValue": 0,    "CompareType": "W6_ASSIGNMENT_START",    "CompareToType": "W6_MAX_CURRENT_TIME_AND_PROPERTY",    "EnableTimeZoneConversion": true,    "IgnoreEffectOnOtherTasks": false,    "DateProperty": {      "PropertyName": "EarlyStart",      "CollectionName": "Task"    },    "PriorityProperty": null,    "GradeFunctionPoints": [      {        "@objectType": "GradeFunctionPoint",        "ValueX": 0,        "ValueY": 100      },      {        "@objectType": "GradeFunctionPoint",        "ValueX": 604800,        "ValueY": 0      }    ]}',
            FSL__Custom_Logic_Data__c = 'eyJAb2JqZWN0VHlwZSI6ICJFbmhhbmNlZFRpbWVPYmplY3RpdmUiLA0KIk5hbWUiOiAiU2NoZWR1bGUgTm9uLUFwcG9pbnRtZW50cyBBU0FQIiwNCiJQcm9nSUQiOiAiVzZPYmplY3RpdmVzLlc2RW5oYW5jZWRUaW1lT2JqZWN0aXZlLCBXNk9iamVjdGl2ZXMiLA0KIk1pbmltYWxHcmFkZSI6IDAuMCwNCiJNYXhpbWFsR3JhZGUiOiAxMDAuMCwNCiJSZWxldmFuY2VHcm91cCI6IHsNCiJLZXkiOiAtMSwNCiJARGlzcGxheVN0cmluZyI6ICJBU0FQIEZvciBJbXBvcnRhbnQgKEF1ZyAyMCkiDQp9LA0KIklycmVsZXZhbnRHZXRzQmVzdEdyYWRlIjogZmFsc2UsDQoiUHJpb3JpdHlXb3JzdFZhbHVlIjogMCwNCiJQcmlvcml0eUJlc3RWYWx1ZSI6IDAsDQoiQ29tcGFyZVR5cGUiOiAiVzZfQVNTSUdOTUVOVF9TVEFSVCIsDQoiQ29tcGFyZVRvVHlwZSI6ICJXNl9NQVhfQ1VSUkVOVF9USU1FX0FORF9QUk9QRVJUWSIsDQoiRW5hYmxlVGltZVpvbmVDb252ZXJzaW9uIjogdHJ1ZSwNCiJJZ25vcmVFZmZlY3RPbk90aGVyVGFza3MiOiBmYWxzZSwNCiJEYXRlUHJvcGVydHkiOiB7DQoiUHJvcGVydHlOYW1lIjogIkVhcmx5U3RhcnQiLA0KIkNvbGxlY3Rpb25OYW1lIjogIlRhc2siDQp9LA0KIlByaW9yaXR5UHJvcGVydHkiOiBudWxsLA0KIkdyYWRlRnVuY3Rpb25Qb2ludHMiOiBbDQp7DQoiQG9iamVjdFR5cGUiOiAiR3JhZGVGdW5jdGlvblBvaW50IiwNCiJWYWx1ZVgiOiAwLA0KIlZhbHVlWSI6IDEwMA0KfSwNCnsNCiJAb2JqZWN0VHlwZSI6ICJHcmFkZUZ1bmN0aW9uUG9pbnQiLA0KIlZhbHVlWCI6IDYwNDgwMCwNCiJWYWx1ZVkiOiAwDQp9DQpdfQ==',
            FSL__Custom_Type__c = 'Objective_Asap',
            FSL__Object_Group_Field__c = 'ao_isao_is_asap_important_asap_important__c',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( asapImportOpt );
        FSL__Service_Goal__c dynamicPriority = new FSL__Service_Goal__c(
            Name = 'Dynamic Priority - Optimization (Aug 20)',
            Description__c = '{"@objectType": "TaskPriorityObjective","Name": "Dynamic Priority (Aug 20)", "ProgID": "W6Objectives.W6PropBasedRevenueObj, W6Objectives", "MinimalGrade": 0.0, "MaximalGrade": 100.0, "RelevanceGroup": { "Key": -1 }, "IrrelevantGetsBestGrade": false, "TaskProperty": { "PropertyName": "Double1", "CollectionName": "Task" }, "ValueXML": "<PropertyBasedRevenues><Number><ID>88</ID><RefreshData>0</RefreshData><Revenue><SpecificRevenue><Value>1</Value><Revenue>1</Revenue></SpecificRevenue><SpecificRevenue><Value>100</Value><Revenue>100</Revenue></SpecificRevenue></Revenue></Number></PropertyBasedRevenues>", "DictionaryProperty": null}',
            FSL__Custom_Logic_Data__c = 'eyJAb2JqZWN0VHlwZSI6ICJUYXNrUHJpb3JpdHlPYmplY3RpdmUiLA0KIk5hbWUiOiAiRHluYW1pYyBQcmlvcml0eSAoQXVnIDIwKSIsDQoiUHJvZ0lEIjogIlc2T2JqZWN0aXZlcy5XNlByb3BCYXNlZFJldmVudWVPYmosIFc2T2JqZWN0aXZlcyIsDQoiTWluaW1hbEdyYWRlIjogMC4wLA0KIk1heGltYWxHcmFkZSI6IDEwMC4wLA0KIlJlbGV2YW5jZUdyb3VwIjogew0KIktleSI6IC0xDQp9LA0KIklycmVsZXZhbnRHZXRzQmVzdEdyYWRlIjogZmFsc2UsDQoiVGFza1Byb3BlcnR5Ijogew0KIlByb3BlcnR5TmFtZSI6ICJEb3VibGUxIiwNCiJDb2xsZWN0aW9uTmFtZSI6ICJUYXNrIg0KfSwNCiJWYWx1ZVhNTCI6ICI8UHJvcGVydHlCYXNlZFJldmVudWVzPjxOdW1iZXI+PElEPjg4PC9JRD48UmVmcmVzaERhdGE+MDwvUmVmcmVzaERhdGE+PFJldmVudWU+PFNwZWNpZmljUmV2ZW51ZT48VmFsdWU+MTwvVmFsdWU+PFJldmVudWU+MTwvUmV2ZW51ZT48L1NwZWNpZmljUmV2ZW51ZT48U3BlY2lmaWNSZXZlbnVlPjxWYWx1ZT4xMDA8L1ZhbHVlPjxSZXZlbnVlPjEwMDwvUmV2ZW51ZT48L1NwZWNpZmljUmV2ZW51ZT48L1JldmVudWU+PC9OdW1iZXI+PC9Qcm9wZXJ0eUJhc2VkUmV2ZW51ZXM+IiwNCiJEaWN0aW9uYXJ5UHJvcGVydHkiOiBudWxsfQ==',
            FSL__Custom_Type__c = 'Objective_Task_Priority',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( dynamicPriority );
        FSL__Service_Goal__c minTravel = new FSL__Service_Goal__c(
            Name = 'Minimize Travel',
            FSL__Prioritize_Resource__c = 'Least Qualified'
        );
        createSchGoalLst.add( minTravel );
        FSL__Service_Goal__c prefResource = new FSL__Service_Goal__c(
            Name = 'Preferred Resource (Aug 20)',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( prefResource );
        FSL__Service_Goal__c sameSiteOpt = new FSL__Service_Goal__c(
            Name = 'Same Sites - Optimization (Aug 20)',
            Description__c = '{"@objectType": "TravelBetweenConsecutiveAssignmentObjective","Name": "Same Sites (Aug 2020)","ProgID": "W6Objectives.W6ConsecutiveAssignmentsObjective, W6Objectives","MinimalGrade": 1.609,"MaximalGrade": 0.0,"RelevanceGroup": {"Key": -1},"IrrelevantGetsBestGrade": true,"PeriodicResolution": "W6_PERIODIC_DAY","PeriodicWeekDay": "W6_MONDAY","PeriodicMonthDay": 1,"PeriodicStartTime": 0,"CheckTravelFromHomeBase": true,"CheckTravelToHomeBase": true,"ByDistance": true,"UseAerialDistance_SO": true}',
            FSL__Custom_Logic_Data__c = 'eyJAb2JqZWN0VHlwZSI6ICJUcmF2ZWxCZXR3ZWVuQ29uc2VjdXRpdmVBc3NpZ25tZW50T2JqZWN0aXZlIiwNCiJOYW1lIjogIlNhbWUgU2l0ZXMgKEF1ZyAyMDIwKSIsDQoiUHJvZ0lEIjogIlc2T2JqZWN0aXZlcy5XNkNvbnNlY3V0aXZlQXNzaWdubWVudHNPYmplY3RpdmUsIFc2T2JqZWN0aXZlcyIsDQoiTWluaW1hbEdyYWRlIjogMS42MDksDQoiTWF4aW1hbEdyYWRlIjogMC4wLA0KIlJlbGV2YW5jZUdyb3VwIjogew0KIktleSI6IC0xDQp9LA0KIklycmVsZXZhbnRHZXRzQmVzdEdyYWRlIjogdHJ1ZSwNCiJQZXJpb2RpY1Jlc29sdXRpb24iOiAiVzZfUEVSSU9ESUNfREFZIiwNCiJQZXJpb2RpY1dlZWtEYXkiOiAiVzZfTU9OREFZIiwNCiJQZXJpb2RpY01vbnRoRGF5IjogMSwNCiJQZXJpb2RpY1N0YXJ0VGltZSI6IDAsDQoiQ2hlY2tUcmF2ZWxGcm9tSG9tZUJhc2UiOiB0cnVlLA0KIkNoZWNrVHJhdmVsVG9Ib21lQmFzZSI6IHRydWUsDQoiQnlEaXN0YW5jZSI6IHRydWUsDQoiVXNlQWVyaWFsRGlzdGFuY2VfU08iOiB0cnVlfQ==',
            FSL__Custom_Type__c = 'Objective_Minimize_Travel',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( sameSiteOpt );
        FSL__Service_Goal__c sameSite5MinOpt = new FSL__Service_Goal__c(
            Name = 'Same Sites 5 Minutes Travel - Optimization (Aug 20)',
            Description__c = '{"@objectType": "TravelBetweenConsecutiveAssignmentObjective","Name": "Same Sites 5 Minutes (Aug 2020)","ProgID": "W6Objectives.W6ConsecutiveAssignmentsObjective, W6Objectives","MinimalGrade": 360.0,"MaximalGrade": 300.0,"RelevanceGroup": {"Key": -1},"IrrelevantGetsBestGrade": true,"PeriodicResolution": "W6_PERIODIC_DAY","PeriodicWeekDay": "W6_MONDAY","PeriodicMonthDay": 1,"PeriodicStartTime": 0,"CheckTravelFromHomeBase": true,"CheckTravelToHomeBase": true,"ByDistance": false,"UseAerialDistance_SO": false}',
            FSL__Custom_Logic_Data__c = 'eyJAb2JqZWN0VHlwZSI6ICJUcmF2ZWxCZXR3ZWVuQ29uc2VjdXRpdmVBc3NpZ25tZW50T2JqZWN0aXZlIiwNCiJOYW1lIjogIlNhbWUgU2l0ZXMgNSBNaW51dGVzIChBdWcgMjAyMCkiLA0KIlByb2dJRCI6ICJXNk9iamVjdGl2ZXMuVzZDb25zZWN1dGl2ZUFzc2lnbm1lbnRzT2JqZWN0aXZlLCBXNk9iamVjdGl2ZXMiLA0KIk1pbmltYWxHcmFkZSI6IDM2MC4wLA0KIk1heGltYWxHcmFkZSI6IDMwMC4wLA0KIlJlbGV2YW5jZUdyb3VwIjogew0KIktleSI6IC0xDQp9LA0KIklycmVsZXZhbnRHZXRzQmVzdEdyYWRlIjogdHJ1ZSwNCiJQZXJpb2RpY1Jlc29sdXRpb24iOiAiVzZfUEVSSU9ESUNfREFZIiwNCiJQZXJpb2RpY1dlZWtEYXkiOiAiVzZfTU9OREFZIiwNCiJQZXJpb2RpY01vbnRoRGF5IjogMSwNCiJQZXJpb2RpY1N0YXJ0VGltZSI6IDAsDQoiQ2hlY2tUcmF2ZWxGcm9tSG9tZUJhc2UiOiB0cnVlLA0KIkNoZWNrVHJhdmVsVG9Ib21lQmFzZSI6IHRydWUsDQoiQnlEaXN0YW5jZSI6IGZhbHNlLA0KIlVzZUFlcmlhbERpc3RhbmNlX1NPIjogZmFsc2V9',
            FSL__Custom_Type__c = 'Objective_Minimize_Travel',
            FSL__Prioritize_Resource__c = 'Least Qualified',
            FSL__Resource_Priority_Field__c = 'fsl__priority__c'
        );
        createSchGoalLst.add( sameSite5MinOpt );

        insert createSchGoalLst;

        // Create Junction & Add Weights
        List<FSL__Scheduling_Policy_Goal__c> junctionPolicyGoalLst = new List<FSL__Scheduling_Policy_Goal__c>();
        FSL__Scheduling_Policy_Goal__c asapImportJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 3,
            FSL__Service_Goal__c = asapImport.Id
        );
        junctionPolicyGoalLst.add( asapImportJunction );
        FSL__Scheduling_Policy_Goal__c asapNonImportJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 1,
            FSL__Service_Goal__c = asapNonImport.Id
        );
        junctionPolicyGoalLst.add( asapNonImportJunction );
        FSL__Scheduling_Policy_Goal__c asapImportOptJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 40,
            FSL__Service_Goal__c = asapImportOpt.Id
        );
        junctionPolicyGoalLst.add( asapImportOptJunction );
        FSL__Scheduling_Policy_Goal__c dynamicPriorityJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 600,
            FSL__Service_Goal__c = dynamicPriority.Id
        );
        junctionPolicyGoalLst.add( dynamicPriorityJunction );
        FSL__Scheduling_Policy_Goal__c minTravelJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 30,
            FSL__Service_Goal__c = minTravel.Id
        );
        junctionPolicyGoalLst.add( minTravelJunction );
        FSL__Scheduling_Policy_Goal__c prefResourceJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 200,
            FSL__Service_Goal__c = prefResource.Id
        );
        junctionPolicyGoalLst.add( prefResourceJunction );
        FSL__Scheduling_Policy_Goal__c sameSiteOptJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 10,
            FSL__Service_Goal__c = sameSiteOpt.Id
        );
        junctionPolicyGoalLst.add( sameSiteOptJunction );
        FSL__Scheduling_Policy_Goal__c sameSite5MinOptJunction = new FSL__Scheduling_Policy_Goal__c(
            FSL__Scheduling_Policy__c = schPolicy.Id,
            FSL__Weight__c = 5,
            FSL__Service_Goal__c = sameSite5MinOpt.Id
        );
        junctionPolicyGoalLst.add( sameSite5MinOptJunction );

        insert junctionPolicyGoalLst;

        // Make Work Rules
        List<FSL__Work_Rule__c> workRuleLst = new List<FSL__Work_Rule__c>();
        final Id MATCH_BOOLEAN_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Match_Boolean_Service').getRecordTypeId();
        final Id TIME_RULE_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Time_Rule_Service').getRecordTypeId();
        final Id EXCLUDED_RESOURCES_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Excluded_Resources_Service').getRecordTypeId();
        final Id TIMESLOT_DESIGNATED_WORK_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('TimeSlot_Designated_Work').getRecordTypeId();
        final Id MATCH_CREW_SIZE_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Match_Crew_Size_Service').getRecordTypeId();
        final Id MATCH_SKILLS_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Match_Skills_Service').getRecordTypeId();
        final Id REQUIRED_RESOURCES_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Required_Resources_Service').getRecordTypeId();
        final Id GAP_RULE_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Gap_Rule_Service').getRecordTypeId();
        final Id SERVICE_VISITING_HOURS_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Service_Visiting_Hours').getRecordTypeId();
        final Id FIELD_TERRITORY_LOCATIONS_RT_ID = Schema.SObjectType.FSL__Work_Rule__c.getRecordTypeInfosByDeveloperName().get('Field_Working_Locations').getRecordTypeId();

        FSL__Work_Rule__c activeResources = new FSL__Work_Rule__c(
            Name = 'Active Resources',
            FSL__Active__c = TRUE,
            RecordTypeId = MATCH_BOOLEAN_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Resource_Property__c = 'IsActive',
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( activeResources );
        FSL__Work_Rule__c dueDate = new FSL__Work_Rule__c(
            Name = 'Due Date',
            FSL__Active__c = TRUE,
            RecordTypeId = TIME_RULE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Resource_Property__c = 'IsActive',
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedEndTime',
            FSL__Service_Time_Operator__c = 'Before or Equal to',
            FSL__Service_Time_Property__c = 'DueDate',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( dueDate );
        FSL__Work_Rule__c earliestStartPermitted = new FSL__Work_Rule__c(
            Name = 'Earliest Start Permitted',
            FSL__Active__c = TRUE,
            RecordTypeId = TIME_RULE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Later than or Equal to',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( earliestStartPermitted );
        FSL__Work_Rule__c excludeResources = new FSL__Work_Rule__c(
            Name = 'Excluded Resources',
            FSL__Active__c = TRUE,
            RecordTypeId = EXCLUDED_RESOURCES_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Later than or Equal to',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( excludeResources );
        FSL__Work_Rule__c fieldServiceTimeDesignatedWork = new FSL__Work_Rule__c(
            Name = 'Field Service - Timeslot Designated Work',
            FSL__Active__c = TRUE,
            RecordTypeId = TIMESLOT_DESIGNATED_WORK_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__CountObject__c = 'ServiceAppointment',
            FSL__CountTimeResolution__c = 'Daily',
            FSL__CountType__c = 'Assignments',
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( fieldServiceTimeDesignatedWork );
        FSL__Work_Rule__c includeSecondaryResources = new FSL__Work_Rule__c(
            Name = 'Include Secondary Resources',
            FSL__Active__c = TRUE,
            RecordTypeId = MATCH_CREW_SIZE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( includeSecondaryResources );
        FSL__Work_Rule__c matchSkills = new FSL__Work_Rule__c(
            Name = 'Match Skills',
            FSL__Active__c = TRUE,
            RecordTypeId = MATCH_SKILLS_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( matchSkills );
        FSL__Work_Rule__c requireResource = new FSL__Work_Rule__c(
            Name = 'Required Service Resource',
            FSL__Active__c = TRUE,
            RecordTypeId = REQUIRED_RESOURCES_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( requireResource );
        FSL__Work_Rule__c resourceAvailable = new FSL__Work_Rule__c(
            Name = 'Resource Availability (Aug20)',
            FSL__Active__c = TRUE,
            RecordTypeId = GAP_RULE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__CountObject__c = 'ServiceAppointment',
            FSL__CountTimeResolution__c = 'Daily',
            FSL__CountType__c = 'Assignments',
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Minimum_Gap__c = 0,
            FSL__Travel_From_Home__c = 30,
            FSL__Travel_To_Home__c = 30,
            FSL__Enable_Overtime__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( resourceAvailable );
        FSL__Work_Rule__c schEnd = new FSL__Work_Rule__c(
            Name = 'Scheduled End',
            FSL__Active__c = TRUE,
            RecordTypeId = TIME_RULE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before or Equal to',
            FSL__Service_Time_Property__c = 'ArrivalWindowEndTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( schEnd );
        FSL__Work_Rule__c schStart = new FSL__Work_Rule__c(
            Name = 'Scheduled Start',
            FSL__Active__c = TRUE,
            RecordTypeId = TIME_RULE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Later than or Equal to',
            FSL__Service_Time_Property__c = 'ArrivalWindowStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( schStart );
        FSL__Work_Rule__c servApptVisitingHours = new FSL__Work_Rule__c(
            Name = 'Service Appointment Visiting Hours',
            FSL__Active__c = TRUE,
            RecordTypeId = SERVICE_VISITING_HOURS_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( servApptVisitingHours );
        FSL__Work_Rule__c crewAvailability = new FSL__Work_Rule__c(
            Name = 'Service Crew Resources Availability',
            FSL__Active__c = TRUE,
            RecordTypeId = MATCH_CREW_SIZE_RT_ID,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( crewAvailability );
        FSL__Work_Rule__c workTerritories = new FSL__Work_Rule__c(
            Name = 'Working Territories',
            FSL__Active__c = TRUE,
            RecordTypeId = FIELD_TERRITORY_LOCATIONS_RT_ID,
            FSL__Working_Location_Enable_Primary__c = TRUE,
            //FSL__Evaluation_Order__c = 9, - Not Writable??
            FSL__Match_Constant_Boolean_Value__c = TRUE,
            FSL__Match_Skill_Level__c = TRUE,
            FSL__Pass_Empty_Values__c = TRUE,
            FSL__Service_Property__c = 'ServiceTerritory',
            FSL__Service_Schedule_Time_Property__c = 'SchedStartTime',
            FSL__Service_Time_Operator__c = 'Before',
            FSL__Service_Time_Property__c = 'EarliestStartTime',
            FSL__Start_of_Day__c = '00:00',
            FSL__Boolean_Operator__c = '='
        );
        workRuleLst.add( workTerritories );
        
        insert workRuleLst;

        List<FSL__Scheduling_Policy_Work_Rule__c> junctionWorkRuleLst = new List<FSL__Scheduling_Policy_Work_Rule__c>();
        for ( FSL__Work_Rule__c workRule : workRuleLst ) {
            junctionWorkRuleLst.add( new FSL__Scheduling_Policy_Work_Rule__c(
                FSL__Scheduling_Policy__c = schPolicy.Id,
                FSL__Work_Rule__c = workRule.Id
            ) );
        }
        insert junctionWorkRuleLst;

        // Make Operating Hours & Time Slots for a 9 to 5 Day
        List<OperatingHours> optHourLst = new List<OperatingHours>();
        OperatingHours eOptHours = new OperatingHours(
            Name = 'East',
            TimeZone = 'America/New_York'
        );
        optHourLst.add( eOptHours );
        OperatingHours cOptHours = new OperatingHours(
            Name = 'Central',
            TimeZone = 'America/Chicago'
        );
        optHourLst.add( cOptHours );
        OperatingHours mOptHours = new OperatingHours(
            Name = 'Mountain',
            TimeZone = 'America/Denver'
        );
        optHourLst.add( mOptHours );
        OperatingHours pOptHours = new OperatingHours(
            Name = 'Pacific',
            TimeZone = 'America/Los_Angeles'
        );
        optHourLst.add( pOptHours );
        
        insert optHourLst;

        List<Timeslot> timeSlotLst = new List<Timeslot>();
        for ( OperatingHours optHour : optHourLst ) {
            timeSlotLst.add( new TimeSlot( 
                StartTime = Time.newInstance( 9, 0, 0, 0 ),
                EndTime = Time.newInstance( 17, 0, 0, 0 ),
                OperatingHoursId = optHour.Id
            ) );
        }
        insert timeSlotLst;

        // Make Territories (Lowest Level only for now)
        List<ServiceTerritory> stLst = new List<ServiceTerritory>();

        Map<String, FSLTestUtility.ServiceTerritoryStructure> paraMap = new Map<String, FSLTestUtility.ServiceTerritoryStructure>();
        for ( OperatingHours optHour : optHourLst ) {
            FSLTestUtility.ServiceTerritoryStructure stStruct = new FSLTestUtility.ServiceTerritoryStructure( optHour.Id );
            paraMap.put( optHour.Name + ' Territory', stStruct );
        }

        stLst = FSLTestUtility.createST( paraMap );
        insert stLst;

        // Generate test Account to use
        Account acct = TestUtility.createAccount();
        insert acct;
    }

    global static void makeResourceData() {
        FSLTestUtility.makeResourceData();
    }
}