public without sharing class PopulateSalesContactOnProgramEnrollments extends TriggerInterface {
    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        populateProgramEligibilityCriteria(newList);
        populateProgramMonitoringCriteria(newList);
    }
    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Program__c> programListNew = (List<Program__c>)newList;
        System.debug('@@programListNew@@'+programListNew);
        List<Program__c> programListOld = (List<Program__c>)oldList;
        Map<Id, Program__c> programMapOld = new Map<Id, Program__c>(programListOld);
        Set<Id> programIdsWithSalesContactUpdated = new Set<Id>();
        for(Program__c programNew : programListNew){
            Program__c programOld = programMapOld.get(programNew.Id);
            if(programNew.Sales_Contact__c <> programOld.Sales_Contact__c){
                programIdsWithSalesContactUpdated.add(programNew.Id);
            }
        }
        Schema.SObjectType s = Schema.getGlobalDescribe().get('Program__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('Sales_Contact__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String userLookupFieldNamesOnAccount = '';
        for( Schema.PicklistEntry pickListVal : ple){
            userLookupFieldNamesOnAccount += ', Account__r.'+pickListVal.getValue();
        }
        String programEnrollmentQuery = 'SELECT Id, Program__r.Sales_Contact__c, Account__c'+userLookupFieldNamesOnAccount+' FROM Program_Enrollment__c WHERE Account__c <> NULL AND Program__c =: programIdsWithSalesContactUpdated';
        List<Program_Enrollment__c> programEnrollmentList = Database.query(programEnrollmentQuery);
        List<Program_Enrollment__c> programEnrollmentToUpdateList = new List<Program_Enrollment__c>();
        for(Program_Enrollment__c peObj : programEnrollmentList){
            Account dealerRecord = (Account)peObj.getSObject('Account__r');
            Object salesContactObj = dealerRecord.get(''+peObj.Program__r.Sales_Contact__c);
            if(salesContactObj <> NULL){
                peObj.Sales_Contact__c = String.valueOf(salesContactObj);
                programEnrollmentToUpdateList.add(peObj);
            }
        }
        if(programEnrollmentToUpdateList.size() > 0){
            update programEnrollmentToUpdateList;
        }
    } 
    
    @TestVisible private static void populateProgramEligibilityCriteria(List<SObject> newList){
        System.debug('@@newList@@'+newList);
        
        Set<Integer> OrderSet = new Set<Integer>();
        Set<Id> programId = new Set<Id>();
        
        Map<Id, Map<Decimal, String>> mapProgramRuleAssign = new Map<Id, Map<Decimal, String>>();
        Map<Decimal, String> mapRuleAssign = new Map<Decimal, String>();
        List<Program__c> programListNew = (List<Program__c>)newList;
        /* Map<Decimal, String> programStatByOrder = new Map<Decimal, String>();*/
        
        String logicField;
        
        if(programListNew!=null && !programListNew.isEmpty()) {
            for(Program__c program: programListNew) {
                programId.add(program.Id);
                logicField = (String)program.Program_Rule_Logic__c;
                System.debug('@@logicField@@'+logicField);
                
                if(String.isNotBlank(logicField)){
                    
                    integer strLength = logicField.length();
                    for(integer i =0;i<logicField.length();i++){
                        String s= logicField.mid(i,1);
                        if(s.isNumeric()){
                            integer OrderNumber =Integer.valueOf(s);
                            OrderSet.add(OrderNumber);
                        }
                    }
                }
                System.debug('Order set:'+OrderSet);
            }
        }
        /*List<Rule_Assignment__c> ruleAssignmentList =[Select Order__c, Program_Rule_Statement__c, Program__r.Id From Rule_Assignment__c 
WHERE Order__c IN:OrderSet 
AND Program__r.Id IN:programId];
System.debug('@@ruleAssignmentList@@'+ruleAssignmentList);

for(Rule_Assignment__c ruleassign: ruleAssignmentList){
programStatByOrder.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
}
System.debug('@@programStatByOrder@@'+programStatByOrder); */
        
        List<Program__c> listProgram = [Select Id, Program_Rule_Logic__c, Program_Eligibility_Criteria__c, 
                                        (Select Order__c,Program_Rule_Statement__c,Program_Rule__r.Eligibility__c From Rule_Assignment__r 
                                         WHERE Program_Rule__r.Eligibility__c=true AND Order__c IN:OrderSet  ) 
                                        from Program__c Where Id IN:programId];
        
        system.debug('ListProgram'+listProgram);
        system.debug('order set size'+OrderSet.size());
        
        for(Program__c program: listProgram){
            if(!Program.Rule_Assignment__r.isEmpty()){    
                for(Rule_Assignment__c ruleassign: program.Rule_Assignment__r){
                    mapRuleAssign.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
                    mapProgramRuleAssign.put(program.Id,mapRuleAssign);
                }            
            }
        }
        for(Program__c program: programListNew){
            String finalLogic = program.Program_Rule_Logic__c;
            System.debug('@@finalLogic@@'+finalLogic);
            if(OrderSet.size() == mapRuleAssign.Size()){
                for(Integer o : OrderSet){
                    
                    finalLogic=finalLogic.replaceAll(String.valueOf(o),('#'+String.valueOf(o))); 
                    
                }
                for(Decimal mapRuleAssignKey : mapRuleAssign.keyset()){
                    System.debug('@@mapRuleAssignKey Size@@'+mapRuleAssign.Size());
                    
                    if(program.Program_Rule_Logic__c.contains(String.valueOf(mapRuleAssignKey))){
                        System.debug('@@mapRuleAssignKey@@ inside if '+mapRuleAssignKey);
                        finalLogic = finalLogic.replaceAll('#'+String.valueOf(mapRuleAssignKey), mapRuleAssign.get(mapRuleAssignKey));
                        system.debug('FinalLogic'+finalLogic);
                        //mapRuleAssign.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
                        //mapProgramRuleAssign.put(program.Id,mapRuleAssign);
                    }
                }
            }else{
                system.debug('In else error');      
                program.Program_Rule_Logic__c.addError('Selected program rules are not available for Eligiblity');
            }
            program.Program_Eligibility_Criteria__c = finalLogic;
            system.debug('@@@@program.Program_Eligibility_Criteria__c----'+program.Program_Eligibility_Criteria__c);
        }
        System.debug('@@mapRuleAssign@@'+mapRuleAssign);
        System.debug('@@mapProgramRuleAssign@@'+mapProgramRuleAssign);
        
        
        
    }
    
    @TestVisible private static void populateProgramMonitoringCriteria(List<SObject> newList){
        System.debug('@@newList@@'+newList);
        
        Set<Integer> OrderSet = new Set<Integer>();
        Set<Id> programId = new Set<Id>();
        
        Map<Id, Map<Decimal, String>> mapProgramRuleAssign = new Map<Id, Map<Decimal, String>>();
        Map<Decimal, String> mapRuleAssign = new Map<Decimal, String>();
        List<Program__c> programListNew = (List<Program__c>)newList;
        /* Map<Decimal, String> programStatByOrder = new Map<Decimal, String>();*/
        
        String logicField;
        
        if(programListNew!=null && !programListNew.isEmpty()) {
            for(Program__c program: programListNew) {
                programId.add(program.Id);
                logicField = (String)program.Program_Rule_Logic_Monitoring__c;
                System.debug('@@logicField@@'+logicField);
                
                if(String.isNotBlank(logicField)){
                    
                    integer strLength = logicField.length();
                    for(integer i =0;i<logicField.length();i++){
                        String s= logicField.mid(i,1);
                        if(s.isNumeric()){
                            integer OrderNumber =Integer.valueOf(s);
                            OrderSet.add(OrderNumber);
                        }
                    }
                }
                System.debug('Order set:'+OrderSet);
            }
        }
        /*List<Rule_Assignment__c> ruleAssignmentList =[Select Order__c, Program_Rule_Statement__c, Program__r.Id From Rule_Assignment__c 
WHERE Order__c IN:OrderSet 
AND Program__r.Id IN:programId];
System.debug('@@ruleAssignmentList@@'+ruleAssignmentList);

for(Rule_Assignment__c ruleassign: ruleAssignmentList){
programStatByOrder.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
}
System.debug('@@programStatByOrder@@'+programStatByOrder); */
        
        
        List<Program__c> listProgram = [Select Id, Program_Rule_Logic_Monitoring__c, Program_Monitoring_Criteria__c, 
                                        (Select Order__c,Program_Rule_Statement__c,Program_Rule__r.Monitor__c From Rule_Assignment__r 
                                         WHERE Program_Rule__r.Monitor__c=true and Order__c IN:OrderSet  ) 
                                        from Program__c Where Id IN:programId];
        for(Program__c program: listProgram){
            //for(Program__c program: programListNew){    
            for(Rule_Assignment__c ruleassign: program.Rule_Assignment__r){
                mapRuleAssign.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
                mapProgramRuleAssign.put(program.Id,mapRuleAssign);
            }            
        }
        for(Program__c program: programListNew){
            String finalLogic = program.Program_Rule_Logic_Monitoring__c;
            System.debug('@@finalLogic@@'+finalLogic);
            if(OrderSet.size() == mapRuleAssign.Size()){
                for(Integer o : OrderSet){
                    
                    finalLogic=finalLogic.replaceAll(String.valueOf(o),('#'+String.valueOf(o))); 
                    
                }
                system.debug('finalLogic'+finalLogic);
                for(Decimal mapRuleAssignKey : mapRuleAssign.keyset()){
                    System.debug('@@mapRuleAssignKey@@'+mapRuleAssignKey);
                    if(program.Program_Rule_Logic_Monitoring__c.contains(String.valueOf(mapRuleAssignKey))){
                        System.debug('@@mapRuleAssignKey@@');
                        finalLogic = finalLogic.replaceAll('#'+String.valueOf(mapRuleAssignKey), mapRuleAssign.get(mapRuleAssignKey));
                        //mapRuleAssign.put(ruleassign.Order__c, ruleassign.Program_Rule_Statement__c);
                        //mapProgramRuleAssign.put(program.Id,mapRuleAssign);
                    }
                }
            }
            else{
                system.debug('In else error');      
                program.Program_Rule_Logic_Monitoring__c.addError('Selected program rules are not available for Monitoring');
            }    
            program.Program_Monitoring_Criteria__c = finalLogic;
            system.debug('@@@@program.Program_Monitoring_Criteria__c----'+program.Program_Monitoring_Criteria__c);
        }
        
        System.debug('@@mapRuleAssign@@'+mapRuleAssign);
        System.debug('@@mapProgramRuleAssign@@'+mapProgramRuleAssign);
    }
}