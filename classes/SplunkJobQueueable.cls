public class SplunkJobQueueable implements Queueable, Database.AllowsCallouts {

    private boolean defaultLog = false;
    private boolean withBulkRecords = false;
    private boolean bulkLog = false;
    private boolean integrationLog = false;
    private string jsonPayload;
    private string jsonFailedRecords;
    private string jsonSavedRecords;

    private void setBooleansFalse(){
        this.withBulkRecords = false;
        this.bulkLog = false;
        this.integrationLog = false;
    }

    public SplunkJobQueueable(){

    }
    public void setLog(string jsonPayload){
        setBooleansFalse();
        this.jsonPayload = jsonPayload;
        this.defaultLog = true;
    }
    public void setLogWithBulkRecords(string jsonPayload, string failedRecordsPayload, string savedRecordsPayload){
        setBooleansFalse();
        this.jsonPayload = jsonPayload;
        this.jsonFailedRecords = failedRecordsPayload;
        this.jsonSavedRecords = savedRecordsPayload;
        this.withBulkRecords = true;
    }
    public void setBulkLog(string jsonPayload){
        setBooleansFalse();
        this.jsonPayload = jsonPayload;
        this.bulkLog = true;
    }
    public void setIntegrationLog(string jsonPayload){
        setBooleansFalse();
        this.jsonPayload = jsonPayload;
        this.integrationLog = true;
    }

    public void execute(QueueableContext context) {
        if(withBulkRecords){
            SplunkEngine.processLogWithBulkRecords(this.jsonPayload, this.jsonFailedRecords, this.jsonSavedRecords);
        }
        else if(bulkLog){
            SplunkEngine.processBulkLog(this.jsonPayload);
        }
        else if(integrationLog){
            SplunkEngine.processIntegrationLog(this.jsonPayload);
        }
        else if(defaultLog){
            SplunkEngine.processLog(this.jsonPayload);
        }
    }


}