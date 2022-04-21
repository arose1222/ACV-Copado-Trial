public class ConditionReportReviewEmailCont {

    public String cRRId{get;set;}

    public ConditionReportReviewEmailCont() {
    }

    public Condition_Report_Prescreen__c getcRRrecord(){
        Condition_Report_Prescreen__c tempRecord = new Condition_Report_Prescreen__c();
        for(Condition_Report_Prescreen__c crr :[Select Id, Name, Owner.Name, Owner.Email, VCI__r.FirstName, Question_Notes__c, Condition_Report__r.Vehicle_Information__c From Condition_Report_Prescreen__c where Id = :cRRId]){
            tempRecord = crr;
        }
        return tempRecord;
    }

    public List<questionGroup> getcrqList(){
        List<questionGroup> newQuestionGroup = new List<questionGroup>();
        Map<String, List<CR_Question__c>> crqMap = new Map<String,List<CR_Question__c>>();
        for(CR_Question__c crq :[Select id, Question_Type__c, Question_Sub_Type__c, Question_Notes_Photos__c From CR_Question__c where Condition_Report_Prescreen__c = :CRRId ]){
            if(crqMap.get(crq.Question_Type__c) == null){
                List<CR_Question__c> tempList = new List<CR_Question__c>();
                tempList.add(crq);
                crqMap.put(crq.Question_Type__c, tempList);
            }
            else{
                crqMap.get(crq.Question_Type__c).add(crq);
            }
        }
        for(String qType :crqMap.keySet()){
            questionGroup qg = new questionGroup();
            qg.QuestionType = qType;
            for(CR_Question__c crq :crqMap.get(qType)){
                qg.addSubType(crq);
            }
            newQuestionGroup.add(qg);
        }
        return newQuestionGroup;
    }

    public class questionGroup{
        public String QuestionType{get;set;}
        public List<questionSubType> QuestionSubTypes{get;set;}
        public questionGroup(){
            this.QuestionType = '';
            this.QuestionSubTypes = new List<questionSubType>();
        }

        public void addSubType(CR_Question__c crq){
            //this.QuestionSubTypes.add(crq.question_Sub_Type__c);
            if(crq.Question_Notes_Photos__c == null){
                this.QuestionSubTypes.add(new questionSubType(crq.question_Sub_Type__c, ''));
            }
            else{
                this.QuestionSubTypes.add(new questionSubType(crq.question_Sub_Type__c, crq.Question_Notes_Photos__c.replaceAll('<[^>]+>',' ')));
            }
        }
    }

    public class questionSubType{
        public String question{get;set;}
        public String comments{get;set;}

        public questionSubType(){
            this.question = '';
            this.comments = '';
        }

        public questionSubType(String q, String c){
            this.question = q;
            this.comments = c;
        }
    }
}