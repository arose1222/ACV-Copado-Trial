global class BatchProgramReviewCreate_Monitoring implements Database.Batchable<sObject> {
 
  global string accFields='id,dealer_type__c,active__c,dealer_doc_compliance__c,name';
  global string fieldlistprog='id,program_monitoring_criteria__c,name';
  global List<Program__c> EligibleprogList= new List<Program__c>();
  global List<Program__c> progList= new List<Program__c>();
  Public List<Program_Reviews__c> progReviewList = new List<Program_Reviews__c>();
  Public List<Program_Reviews__c> updateProgReviewRuleStatusList= new List<Program_Reviews__c>();
  Public List<Program_Enrollment__c> ProgEnrolLst;
  Public Map<String,Program_Enrollment__c> ProgEnrolMap=new Map<String,Program_Enrollment__c>();
  Public Set<Id> accIdwithProgEnrolLst=new Set<Id>();
  Public Map<String,Program_Reviews__c> existingProgReviewMap = new  Map<String,Program_Reviews__c>();
  Public List<Integer> removeIndex= new List<Integer>();
  //public Id accId ='0012F00000pX3NtQAK';
  //public List<Id> accId = new List<Id>{'0012F00000pX3X9QAK','0012F00000pWzxrQAC'};

  Integer i = 0;

  global BatchProgramReviewCreate_Monitoring(){      
      EligibleprogList = new List<Program__c>();
      progList = [
          SELECT id, program_monitoring_criteria__c, Name
          FROM Program__c
          WHERE Active__c = TRUE
      ];

      for(Program__c p : progList){
      System.debug('progList '+p);
          if(p.program_monitoring_criteria__c != Null){
      List<string> fields = this.getFields(p.program_monitoring_criteria__c, 'Account');
      List<string> fieldsProg = this.getFields(p.program_monitoring_criteria__c, 'Program__c');
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

        ProgEnrolLst= new List<Program_Enrollment__c>([select id,account__c,program__c,Enrollment_Start_Date__c  from Program_Enrollment__c where account__c != null and program__c != null and Enrollment_Start_Date__c != null]);
      
        for(Program_Enrollment__c pe: ProgEnrolLst){
            accIdwithProgEnrolLst.add(pe.Account__c);
            string pekey= pe.Account__c+'-'+pe.program__c;
            ProgEnrolMap.put(pekey, pe);
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
    String query = 'select '+accFields+' from Account where Id IN : accIdwithProgEnrolLst';
    System.debug('Account List **** :'+query);
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> accList) {
  System.debug('Inside execute' + accList[0]);

  List<Program_Reviews__c> existingProgReviewList=new List<Program_Reviews__c> ( [
        SELECT id, Program_Enrollment__r.Account__c, Program_Enrollment__r.program__c,IsMonitoring__c,createdDate,UniquePE__c
        FROM Program_Reviews__c
        WHERE Program_Enrollment__r.Account__c IN :accList and IsMonitoring__c = true
      ]);
  
    for(Program_Reviews__c pe: existingProgReviewList){
      if(!existingProgReviewMap.containsKey(pe.UniquePE__c)) {
        existingProgReviewMap.put(pe.UniquePE__c, pe);
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
     System.debug('ProgEnrolMap : '+ProgEnrolMap);
     if (!accList.isEmpty() && accList != null) {
      for (Account a : accList) {
        if (!EligibleprogList.isEmpty() && EligibleprogList != null) {
          for (Program__c p : EligibleprogList) {
              if(p.program_monitoring_criteria__c != Null){
                String pkey=a.Id+'-'+p.Id;
                System.debug('execute : '+pkey);
                  if(ProgEnrolMap.get(pkey) != null){
                    this.getAccounts(
                      ProgEnrolMap.get(pkey),
                      p,
                      a                
                    );
                  }
              }
            }
          }
        }
      }
    
   
    
    System.debug('progReviewList : '+progReviewList);
   
    System.debug('removeIndex :'+removeIndex);
  
    
    Integer rI=0;
    List<Integer> insertIndex=new List<Integer>();
    List<Integer> updateRemoveIndex=new List<Integer>();
    if (!updateProgReviewRuleStatusList.isEmpty()) {
      for(Program_Reviews__c pr : updateProgReviewRuleStatusList){
              
      Date myDate = Date.valueof(string.valueOf(pr.createdDate));
      
       system.debug('pr.createdDate myDate :'+myDate);
          if( myDate.format() <= (date.today()-45).format()){
            pr.UniquePE__c=pr.UniquePE__c+'-'+date.today().format()+'_old';
            insertIndex.add(rI);
          }
          else{
            updateRemoveIndex.add(rI);
          }
        rI=rI+1;
      }
      System.debug(insertIndex+' insertIndex');
      for(Integer r = insertIndex.size() - 1; r >= 0; r--) {    
    
        System.debug('removeIndex  :'+removeIndex);
        Integer rIndex=removeIndex.indexOf(insertIndex[r]);
        removeIndex.remove(rIndex);
      }
      for(Integer r = updateRemoveIndex.size() - 1; r >= 0; r--) {    
        updateProgReviewRuleStatusList.remove(updateRemoveIndex[r]);
      }
      try{update updateProgReviewRuleStatusList;}
      catch (exception e) {
        System.debug('Failed to create multiple review record');
      }
    }

    System.debug('removeIndex Last :'+removeIndex);
    System.debug('insertIndex Last :'+insertIndex);
    for(Integer r = removeIndex.size() - 1; r >= 0; r--) {    
      progReviewList.remove(removeIndex[r]);
    }     
  
 

    if (!progReviewList.isEmpty()) {       
      try{insert progReviewList;}
      catch (exception e) {
        System.debug('Failed to insert review record progReviewList: '+progReviewList);
      }
    }

  
 

  }

  global void finish(Database.BatchableContext BC) {
    Database.executeBatch(new BatchProgramReviewCreation());
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
    Program_Enrollment__c ProgEnrolObj,
    Program__c programObj,
    Account accountObj
   ) {
      system.debug(
      'inside get Accounts - programId : ' +
      programObj.Id +
      ' criteria ' +
      programObj.program_monitoring_criteria__c +
      ' accountID ' +
      accountObj.ID+' ProgEnrolObj '+ProgEnrolObj
    );
    this.setOperators();
    String criteria = this.getCriteria(programObj.program_monitoring_criteria__c);
    Map<String, Object> bindings = new Map<String, Object>();
    List<Account> EligibleAcc = new List<Account>();
    List<string> fields = this.getFields(criteria, 'Account');
    List<string> fieldsProg = this.getFields(criteria, 'Program__c');
    Map<string,string> fieldValueMap= new  Map<string,string>();
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
          bindings.put(
            'program__c.' + r.toLowerCase(),
            bindingVal
          );
        }
        fieldValueMap.put('program__c.' + r.toLowerCase() ,string.valueof(programObj.get(r)));
      }
    }
    if (fields != null) {
        for (String r : fields) {
          if (accountObj.get(r) == null) {
            bindings.put('account.' + r.toLowerCase(), 'Null');
          } else {
            
          bindingVal=string.valueof(accountObj.get(r));
          if(bindingVal.contains(' ')){
            bindingVal=bindingVal.replaceAll('\\s','_');  
          }
            bindings.put(
              'account.' + r.toLowerCase(),
              bindingVal
            );
          }
        fieldValueMap.put('account.' + r.toLowerCase() ,string.valueof(accountObj.get(r)));
        }
        System.debug('bindings : ' + bindings);

        //Initialize Rule Engine
        Rule r = new Rule().setExpression(criteria);
        system.debug('r' + r);
        //Evaluate rule with Binding values
        Boolean retVal = r.eval(bindings);
        system.debug('retVal' + retVal);
        if (retVal) {
          EligibleAcc.add(accountObj);
        }
      
      System.debug('List of EligibleAcc : ' + EligibleAcc);
      if (EligibleAcc.size() != 0) {
        this.createProgramReviewWithAccount(
          ProgEnrolObj,
          EligibleAcc,
          programObj.Id,
          programObj.Name,
          string.valueOf(fieldValueMap)
        );
         System.debug('Inside createProgramEnrollmentWithAccount fieldValueMap : ' +string.valueOf(fieldValueMap));
      }
    }
 
  }


  public void createProgramReviewWithAccount(
    Program_Enrollment__c ProgEnrolObj,
    List<Account> accList,
    Id programId,
    String pName,
    String ruleDetails
  ) {

    System.debug('Inside createProgramEnrollmentWithAccount'+accList);
    Set<Account> setAcc = new Set<Account>();
    for (Account acc : accList) {
      setAcc.add(acc);
    }
    
      for (Account a : setAcc) {
        string reviewName =  
         'Monitor-'+     
          pName +
          '-' +
          date.today().format();
        
        Program_Reviews__c progReviewRecord = new Program_Reviews__c(          
        name=reviewName,
        Program_Enrollment__c = ProgEnrolObj.Id,
        IsMonitoring__c = true,
        Rule_Details__c = ruleDetails
        );
        progReviewList.add(progReviewRecord);
       
        String uniqueKey = (String.valueOf(a.ID)).substring(0, 15) +'-'+(String.valueOf(programId)).substring(0, 15)+'-'+(String.valueOf(ProgEnrolObj.Id)).substring(0, 15);
        System.debug('uniqueProgAcc'+uniqueKey);
        if(existingProgReviewMap.containsKey(uniqueKey)){
            removeIndex.add(i);
            system.debug(i+'value of i');
            System.debug(uniqueKey+' uniqueKey');
            Program_Reviews__c existingProgReviewRecord = existingProgReviewMap.get(uniqueKey);
            System.debug('Pre-existing reocrd with Not eligible: '+existingProgReviewRecord);
            updateProgReviewRuleStatusList.add(existingProgReviewRecord);
          }
          else{
            if(Date.valueOf(string.valueOf(ProgEnrolObj.Enrollment_Start_Date__c)).format() > (date.today()-45).format()){
              removeIndex.add(i);
            }
            else{
              existingProgReviewMap.put(uniqueKey,progReviewRecord);
            }
              
          }
          i=i+1;
          
        }
        System.debug('before progReviewList : '+progReviewList);
        System.debug(removeIndex+'removeIndex');    
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