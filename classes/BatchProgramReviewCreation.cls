global class BatchProgramReviewCreation implements Database.Batchable<sObject> {
    //public Id accId='0012F00000pX3NtQAK';
        //public List<Id> accId = new List<Id>{'0012F00000pX3X9QAK','0012F00000pWzxrQAC'};

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
      String query='select id,name,Enrollment_Start_Date__c, Status__c,Account__r.Dealer_Type__c,Program__r.name from Program_Enrollment__c where Enrollment_Start_Date__c != null';
      return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Program_Enrollment__c> progEnrolList){
        // process each batch of records
        System.debug('progEnrolList : '+progEnrolList);
        Set<id> progEnrolIds= new Set<Id>();
        for (Program_Enrollment__c a : progEnrolList) {
            progEnrolIds.add(a.id);
        }
        List<Program_Reviews__c> programReviewList=[select id,name,CreatedDate,Program_Enrollment__c from Program_Reviews__c where Program_Enrollment__c in : progEnrolIds and isMonitoring__c != true];
       // System.debug('programReviewList : '+programReviewList);
        Map<Id,List<Program_Reviews__c>> mapProgEnrolProgReview=new  Map<Id,List<Program_Reviews__c>>();
        
        For(Program_Reviews__c pr : programReviewList)
        {
            if(mapProgEnrolProgReview.containsKey(pr.Program_Enrollment__c))
            {
                List<Program_Reviews__c> lstProgramReview = mapProgEnrolProgReview.get(pr.Program_Enrollment__c);
                lstProgramReview.add(pr);
            }
            else
            {
                List<Program_Reviews__c> lstProgramReview = new List<Program_Reviews__c>();
                lstProgramReview.add(pr);
                mapProgEnrolProgReview.put(pr.Program_Enrollment__c,lstProgramReview);
            }
        }
        System.debug('mapProgEnrolProgReview : '+mapProgEnrolProgReview);
        List<Program_Enrollment__c> progEnrolwithoutProgReviewList=new List<Program_Enrollment__c>();
        For(Program_Enrollment__c pe : progEnrolList)
        {
            if(!mapProgEnrolProgReview.containsKey(pe.Id)){
                progEnrolwithoutProgReviewList.add(pe);
            }

        }
        
        updateProgReviewObject(mapProgEnrolProgReview);
        createfirstProgReviewObject(progEnrolwithoutProgReviewList);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

    public static void createfirstProgReviewObject(List<Program_Enrollment__c> progEnrolwithoutProgReviewList){
        System.debug('Inside createNewProgReviewObject progEnrolwithoutProgReviewList'+progEnrolwithoutProgReviewList);
        Datetime todayDate = Datetime.now();
        if(!progEnrolwithoutProgReviewList.isEmpty()){
        for(Program_Enrollment__c pe : progEnrolwithoutProgReviewList){
            if(pe.Enrollment_Start_Date__c < (todayDate-45)){
                        System.debug('Create new review record for '+pe.id);
                        createReviewRecord(pe.id,pe.Program__r.Name);
            } 
        }
    }

    }
    public static void updateProgReviewObject(Map<Id,List<Program_Reviews__c>>  mapProgEnrolProgReview){
        System.debug('inside updateProgReviewObject');
        Datetime todayDate = Datetime.now();
        String progName='';
        Boolean CreateRecord=false;
        for (Id progId : mapProgEnrolProgReview.keySet()){
            for(Program_Reviews__c pr : mapProgEnrolProgReview.get(progId)){
                if(pr.CreatedDate > (todayDate-45) || pr.CreatedDate == null){
                    CreateRecord=false;
                    break;
                }
                else if(pr.CreatedDate < (todayDate-45)){
                    System.debug('update review record for '+pr.id);
                    progName=pr.name;
                    CreateRecord=true;
                }
            }
            if(CreateRecord){
                progName=progName.substringBefore('-');
                createReviewRecord(progId,progName);
            }
        }
    }

    public static void createReviewRecord(Id ProgEnrolId, String progName){
        List<Program_Reviews__c> prlst=new List<Program_Reviews__c>();
        Program_Reviews__c pr=new Program_Reviews__c();
       
        pr.name=progName+'-'+ date.today().format();
        pr.Program_Enrollment__c=ProgEnrolId;
        prlst.add(pr);

        insert prlst;
    }
}