trigger ReleaseSurveyTrigger on Release_Survey__c (after insert) {
    (new TriggerFrameWork()).handle();
}