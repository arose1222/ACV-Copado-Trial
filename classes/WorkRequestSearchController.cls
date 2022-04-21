public class WorkRequestSearchController {

    private static final Integer LIMIT_ROWS = 50;
    
    public class DataWrapper{
        public List<WorkRequestRow> allRows;
        public DataWrapper(){
            allRows = new List<WorkRequestRow>();
        }
    }

    public class WorkRequestRow{
        // Id
        public String uuid;

        // Work Order Line Item Fields
        public String woliLink;
        public String woliName;
        public String vin;
        public String assignmentId;
        public String createdDate;

        // Service Appointment Fields
        public String serviceApptLink;
        public String serviceApptName;
        public String address;
        public String serviceApptStatus;
        public String earlyStartTime;
        public String dueDate;

        // Other Related Fields
        public String acctLink;
        public String acctName;
        public String assignedUser;

        /****************Constructors*************************/   
        public WorkRequestRow( WorkOrderLineItem providedWoli, ServiceAppointment providedSA, AssignedResource providedAR ) {
            this.uuid = providedWoli.External_Record_Guid__c;
            this.woliLink = makeLink( providedWoli.Id );
            this.woliName = 'Link to Line Item';
            this.vin = providedWoli.VIN__c;
            this.assignmentId = providedWoli.External_Assignment_Id__c;
            this.createdDate = formatDate( providedWoli.CreatedDate );

            this.serviceApptLink = makeLink( providedSA.Id );
            this.serviceApptName = providedSA.AppointmentNumber;
            this.address = makeAddress( providedSA );
            this.serviceApptStatus = providedSA.Status;
            this.earlyStartTime = providedSA.EarliestStartTime != null ? formatDate( providedSA.EarliestStartTime ) : null;
            this.dueDate = providedSA.Original_Due_Date__c != null ? formatDate( providedSA.Original_Due_Date__c ) : null;

            this.acctLink = makeLink( providedSA.AccountId );
            this.acctName = providedSA.Account.Name;
            this.assignedUser = providedAR != null ? providedAR.ServiceResource.Name : '';
        }

        private String makeLink( Id givenId ) {
            return '/' + givenId;
        }
        
        private String formatDate( DateTime givenDT ) {
            return givenDT.format( 'MM-dd-YYYY hh:mm a' );
        }

        private String makeAddress( ServiceAppointment sa ) {
            return sa.Street + ', ' + sa.City + ', ' + sa.State + ', ' + sa.PostalCode + ', ' + sa.Country;
        }
    }

    /**
     * getUpdatedData runs on Refresh of the table
     * Since it only gets records, we have made it Cacheable to help with performance
     * @param searchVar - the term searched via the Search bar for a small selection of fields
     * @return Json String of the DataWrapper
     */
    @AuraEnabled(Cacheable=true)
    public static String getData( String searchVar ) {
        DataWrapper dwReturn = new DataWrapper();

        List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
        Map<Id, ServiceAppointment> woIdToSAMap = new Map<Id, ServiceAppointment>();
        Map<Id, AssignedResource> saIdToARMap = new Map<Id, AssignedResource>();

        Set<Id> woIdSet = new Set<Id>();
        for ( WorkOrderLineItem woliRec : [ SELECT Id, External_Record_Guid__c, VIN__c, External_Assignment_Id__c, CreatedDate, WorkOrderId, WorkType.Name FROM WorkOrderLineItem WHERE VIN__c = :searchVar OR External_Assignment_Id__c = :searchVar ORDER BY CreatedDate DESC LIMIT :LIMIT_ROWS ] ) {
            woliLst.add( woliRec );
            woIdSet.add( woliRec.WorkOrderId );
        }

        Set<Id> saIdSet = new Set<Id>();
        for ( ServiceAppointment saRec : [ SELECT Id, Street, City, State, PostalCode, Country, Status, EarliestStartTime, Original_Due_Date__c, AccountId, Account.Name, ParentRecordId, AppointmentNumber 
                                            FROM ServiceAppointment WHERE ParentRecordId IN :woIdSet ] ) 
        {
            woIdToSAMap.put( saRec.ParentRecordId, saRec );
            saIdSet.add( saRec.Id );
        }

        for ( AssignedResource arRec : [ SELECT Id, ServiceAppointmentId, ServiceResource.Name 
                                            FROM AssignedResource WHERE ServiceAppointmentId IN :saIdSet ] ) 
        {
            saIdToARMap.put( arRec.ServiceAppointmentId, arRec );
        }

        for ( WorkOrderLineItem parseWOLI : woliLst ) {
            ServiceAppointment parseSA = woIdToSAMap.get( parseWOLI.WorkOrderId );
            dwReturn.allRows.add( 
                new WorkRequestRow( parseWOLI, parseSA, saIdToARMap.get( parseSA.Id ) )
            );
        }

        return JSON.serialize( dwReturn );
    }
}