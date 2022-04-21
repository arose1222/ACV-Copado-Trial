public class LegacyInspectionStruct {
    // General Notes:
    //  If no Comment specifying an event, it is never needed
    //  DateTime Format is 2021-04-19T13:00:00Z

    public String AssignmentID;
    public String AssignmentStart; // AppointmentUpdate, Committed, CompletedUpdate, Dispatched, IncompleteStatus, StatusUpdate
    public String CancellationDate;
    public String Comment; //IncompleteStatus
    public String CommitmentMade; //Committed
    public String CompletionDate; //CompletedUpdate
    public String ContactPrintedName; //IncompleteStatus
    public String DispatchInstructions;
    public String District;
    public String DrivingDirections;
    public String IncompleteDateTime; //IncompleteStatus
    public String IncompleteLatitude;
    public String IncompleteLongitude;
    public String IncompleteReason; // IncompleteStatus
    public String InspectorInstructions;
    public String InspectorName; //CompletedUpdate, IncompleteStatus,
    public String LOB;
    public String MessageType; //AppointmentUpdate, Committed, CompletedUpdate, Dispatched, IncompleteStatus, InfoUpdate, StatusUpdate,
    public String OnSiteDate;
    public String PersonID; //CompletedUpdate, Dispatched, IncompleteStatus,
    public String Region;
    public String Signature;
    public String Status; //AppointmentUpdate, CompletedUpdate, Dispatched, IncompleteStatus, StatusUpdate,
    public String TravelDate;
    public String UUID;
    public String UpdateUser; //AppointmentUpdate, Committed, CompletedUpdate, Dispatched, IncompleteStatus, InfoUpdate,StatusUpdate,
    public String WorkType; //Committed, CompletedUpdate
    
    // public LegacyInspectionStruct() {
    //     this.AssignmentID = '';
    //     this.AssignmentStart = '';
    //     this.CancellationDate = '';
    //     this.Comment = ''; 
    //     this.CommitmentMade = ''; 
    //     this.CompletionDate = '';
    //     this.ContactPrintedName = ''; 
    //     this.DispatchInstructions = '';
    //     this.District = '';
    //     this.DrivingDirections = '';
    //     this.IncompleteDateTime = ''; 
    //     this.IncompleteLatitude = '';
    //     this.IncompleteLongitude = '';
    //     this.IncompleteReason = '';
    //     this.InspectorInstructions = '';
    //     this.InspectorName = ''; 
    //     this.LOB = '';
    //     this.MessageType = ''; 
    //     this.OnSiteDate = '';
    //     this.PersonID = ''; 
    //     this.Region = '';
    //     this.Signature = '';
    //     this.Status = '';
    //     this.TravelDate = '';
    //     this.UUID = '';
    //     this.UpdateUser = '';
    //     this.WorkType = '';
    // }
}