global class BatchProgEnrolCreate implements Database.Batchable<sObject> {
 
  global string accFields='id,dealer_type__c,active__c,dealer_doc_compliance__c,name';
  global string fieldlistprog='id,program_eligibility_criteria__c,name';
  global List<Program__c> EligibleprogList= new List<Program__c>();
  global List<Program__c> progList= new List<Program__c>();
  Public List<Program_Enrollment__c> progEnrolList = new List<Program_Enrollment__c>();
  Public List<Program_Enrollment__c> updateProgEnrolStatusList= new List<Program_Enrollment__c>();
  Public Map<String,Program_Enrollment__c> existingProgEnrolMap = new  Map<String,Program_Enrollment__c>();
 // public Id accId ='0012F00000pX3NtQAK';
    //public List<Id> accId = new List<Id>{'0012F00000pX3X9QAK','0012F00000pWzxrQAC'};
  global BatchProgEnrolCreate(){      
      
      EligibleprogList = new List<Program__c>();
      progList = [
          SELECT id, Program_Eligibility_Criteria__c, Name
          FROM Program__c
          WHERE Active__c = TRUE
      ];

     
      
      for(Program__c p : progList){
      System.debug('progList '+p);
          if(p.Program_Eligibility_Criteria__c != Null){
      List<string> fields = this.getFields(p.Program_Eligibility_Criteria__c, 'Account');
      List<string> fieldsProg = this.getFields(p.Program_Eligibility_Criteria__c, 'Program__c');
          for(string s : fields){
              if(accFields != Null){
                  accFields=accFields+','+s;
              }else{
                  accFields=s;
              }
              
        }
              system.debug('After for AccFields'+accFields);
          for(string ps : fieldsProg){
              if(fieldlistprog != Null){
                  fieldlistprog=fieldlistprog+','+ps;
              }else{
                  fieldlistprog=ps;
              }
        }
       }
      }
        
      System.debug('Constructor : '+accFields);
      List<String> duplicateRemoveList = new List<String>(new Set<String>(accFields.split(',')));
  String uniquestr = String.join(duplicateRemoveList, ',');
  System.debug('uniquestr'+uniquestr);
      
      List<String> duplicateRemoveListProg = new List<String>(new Set<String>(fieldlistprog.split(',')));
  String uniquestrProg = String.join(duplicateRemoveListProg, ',');
  System.debug('uniquestrProg'+uniquestrProg);
      
      fieldlistprog=uniquestrProg;
      accFields=uniquestr;
      
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'select '+accFields+' from Account';
    System.debug(query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> accList) {
  System.debug('Inside execute' + accList[0]);

  List<Program_Enrollment__c> existingProgEnrolList=new List<Program_Enrollment__c> ( [
        SELECT id, status__c,Account__c, program__c, Program__r.name,UniqueProgAcc__c
        FROM Program_Enrollment__c
        WHERE Account__c IN :accList 
      ]);
  
    for(Program_enrollment__c pe: existingProgEnrolList){
      if(!existingProgEnrolMap.containsKey(pe.UniqueProgAcc__c)) {
        existingProgEnrolMap.put(pe.UniqueProgAcc__c, pe);
      } 
    }

  set<id> accIds=new set<id>();
  Boolean result;
  

    List<Program__c> EligibleprogList = new List<Program__c>();
    string queryProg ='Select ' +fieldlistprog +' FROM Program__c WHERE Active__c = TRUE';
      
      System.debug(
        'queryProg : ' +
        queryProg +
        ' fieldlistprog: ' +
        fieldlistprog
      );
     EligibleprogList = Database.query(queryProg);
     System.debug('EligibleprogList length: ' + EligibleprogList.size());
     System.debug('progList size: ' + progList.size());
     if (!accList.isEmpty() && accList != null) {
      for (Account a : accList) {
        if (!EligibleprogList.isEmpty() && EligibleprogList != null) {
          for (Program__c p : EligibleprogList) {
              if(p.Program_Eligibility_Criteria__c != Null){
           this.getAccounts(
              p,
              a                
            );
           // System.debug('Result : ' + result);
          }
          }
        }
      }
    }
    List<Integer> removeIndex=new List<Integer>();
      System.debug('Before removeIndex '+removeIndex);
    Integer i = 0;
    for(Program_Enrollment__c pe : progEnrolList){
      String uniqueProgAcc= (String.valueOf(pe.Account__c)).substring(0, 15) +'-'+(String.valueOf(pe.program__c)).substring(0, 15);
      System.debug('uniqueProgAcc'+uniqueProgAcc);
      if(existingProgEnrolMap.containsKey(uniqueProgAcc)){
        System.debug('Pre-existing reocrd : '+pe);
         removeIndex.add(i);
         Program_Enrollment__c existingProgEnrolRecord = existingProgEnrolMap.get(uniqueProgAcc);
        if (existingProgEnrolRecord.status__c == 'Not eligible') {
          existingProgEnrolRecord.status__c = 'Eligible';
          System.debug('Pre-existing reocrd with Not eligible: '+existingProgEnrolRecord);
          updateProgEnrolStatusList.add(existingProgEnrolRecord);
        }
       // updateProgEnrolStatusList.add(pe);
      }
      else{
        existingProgEnrolMap.put(uniqueProgAcc,pe);
      }
      i=i+1;
    }
    System.debug(removeIndex+'removeIndex');
    for(Integer r = removeIndex.size() - 1; r >= 0; r--) {    
      progEnrolList.remove(removeIndex[r]);
    }

    System.debug('updateProgEnrolStatusList'+updateProgEnrolStatusList+'progEnrolList '+progEnrolList);
    if(!progEnrolList.isEmpty())
    {
        try {
          insert progEnrolList;
          system.debug('progEnrollment created ');
         // result = true;
        } catch (exception e) {
          System.debug('Failed to create enrollment record');
            for(Program_Enrollment__c pen : progEnrolList){
                system.debug('failed records : '+pen);                    
            }
            
        }
    }
    if (!updateProgEnrolStatusList.isEmpty()) {
       
      try{update updateProgEnrolStatusList;}
      catch (exception e) {
        System.debug('Failed to Update enrollment record');
      }
    }


  }

  global void finish(Database.BatchableContext BC) {
      Database.executeBatch(new BatchProgramReviewCreate_Monitoring());
    
  }

  public String getCriteria(String criteria) {
    criteria = criteria.replaceAll('AND', '&&');
    criteria = criteria.replaceAll('OR', '||');
    criteria = criteria.replaceAll(' = ', ' == ');
    return criteria;
  }
  public List<string> getFields(string criteria, String objectAPIName) {
    List<String> reqFields = new List<String>();
    SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
    Map<String, Schema.SObjectField> mfields = objectType.getDescribe()
      .fields.getMap();
    for (string fname : mfields.keySet()) {
      if (criteria.containsIgnoreCase(fname)) {
        reqFields.add(fname.toLowerCase());
      }
    }
    System.debug(reqFields);

    return reqFields;
  }

  /* Methods used by rule class*/
  public void getAccounts(
    Program__c programObj,
    Account accountObj
   ) {
    //Boolean isCreated = false;
    system.debug(
      'inside get Accounts - programId : ' +
      programObj.Id +
      ' criteria ' +
      programObj.Program_Eligibility_Criteria__c +
      ' accountID ' +
      accountObj.ID
    );
    this.setOperators();
    String criteria = this.getCriteria(programObj.Program_Eligibility_Criteria__c);
    Map<String, Object> bindings = new Map<String, Object>();
    List<Account> EligibleAcc = new List<Account>();
    List<string> fields = this.getFields(criteria, 'Account');
    List<string> fieldsProg = this.getFields(criteria, 'Program__c');
	String bindingVal;

    if (fieldsProg != null) {
      
      for (String r : fieldsProg) {
        if (programObj.get(r) == null) {
          bindings.put('program__c.' + r.toLowerCase(), 'Null');
        } else {
            bindingVal=string.valueof(programObj.get(r));
            if(bindingVal.contains(' ')){
			      	bindingVal=bindingVal.replaceAll('\\s','_');  
            }
             System.debug('bindingVal '+bindingVal);
          bindings.put(
            'program__c.' + r.toLowerCase(),bindingVal);
        }
      }
    }
    if (fields != null) {
        //  Map<String, Object> bindings = new Map<String, Object>();
        for (String r : fields) {
          if (accountObj.get(r) == null) {
            bindings.put('account.' + r.toLowerCase(), 'Null');
          } else {
            bindingVal=string.valueof(accountObj.get(r));
           
            if(bindingVal.contains(' ')){
		      		bindingVal=bindingVal.replaceAll('\\s','_');
            }
               System.debug('bindingVal '+bindingVal);
            bindings.put(
              'account.' + r.toLowerCase(),bindingVal);
          }
        }
        System.debug('bindings : ' + bindings);

        //Initialize Rule Engine
        Rule r = new Rule().setExpression(criteria);
        system.debug('rule - ' + r);
        //Evaluate rule with Binding values
        Boolean retVal = r.eval(bindings);
        system.debug('retVal' + retVal);
        if (retVal) {
          EligibleAcc.add(accountObj);
        }
      
      System.debug('List of EligibleAcc : ' + EligibleAcc);
      if (EligibleAcc.size() != 0) {
        this.createProgramEnrollmentWithAccount(
          EligibleAcc,
          programObj.Id,
          programObj.Name
        );
        //  System.debug('Inside createProgramEnrollmentWithAccount');
      }
    }
    //System.debug('EligibleAcc : '+EligibleAcc);
    //return isCreated;
  }


  public void createProgramEnrollmentWithAccount(
    List<Account> accList,
    Id programId,
    String pName
  ) {
   // Boolean result = false;
    System.debug('Inside createProgramEnrollmentWithAccount'+accList);
    //progEnrolList = new List<Program_Enrollment__c>();
    Set<Account> setAcc = new Set<Account>();
    for (Account acc : accList) {
      setAcc.add(acc);
    }
    //   system.debug('stAccId'+stAccId);
      
    // List<Program_Enrollment__c> existingProgEnrolList = [
    //   SELECT id, status__c, program__c, Program__r.name
    //   FROM Program_Enrollment__c
    //   WHERE Account__c IN :stAccId AND Program__c = :programId
    // ];
    //updateProgEnrolStatusList = new List<Program_Enrollment__c>();
    // if (!existingProgEnrolList.isEmpty()) {
    //   for (Program_Enrollment__c pe : existingProgEnrolList) {
    //     if (pe.status__c == 'Not eligible') {
    //       pe.status__c = 'Eligible';
    //       updateProgEnrolStatusList.add(pe);
    //     }
    //   }
      
    // } else {
      for (Account a : setAcc) {
        string enrollmentName =
          a.name +
          '-' +
          pName +
          '-' +
          date.today().format();

       // String uniqueProgAcc=a.Id+''+programId;
        Program_Enrollment__c progEnrollment = new Program_Enrollment__c(
          Name = enrollmentName,
          Status__c = 'Eligible',
          Account__c = a.Id,
          Program__c = programId
        );
       
        
            progEnrolList.add(progEnrollment);
           
      }
        
   // }
   // return result;
  }  
  public void setOperators() {
    Operations opObj = Operations.getInstance();
    opObj.registerOperation(OperationFactory.getInstance('&&'));
    opObj.registerOperation(OperationFactory.getInstance('=='));
    opObj.registerOperation(OperationFactory.getInstance('!='));
    opObj.registerOperation(OperationFactory.getInstance('||'));
    opObj.registerOperation(OperationFactory.getInstance('('));
    opObj.registerOperation(OperationFactory.getInstance(')'));
    opObj.registerOperation(OperationFactory.getInstance('<'));
    opObj.registerOperation(OperationFactory.getInstance('<='));
    opObj.registerOperation(OperationFactory.getInstance('>'));
    opObj.registerOperation(OperationFactory.getInstance('>='));
  }
}