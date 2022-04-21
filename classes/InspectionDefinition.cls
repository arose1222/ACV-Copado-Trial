global class InspectionDefinition extends CoreObject{
    public string inspectionID;
    public string inspectorIdentityId;
    public integer dealershipId;

    public vehicle inspectedVehicle;
    public string inspectionType;
    public inspectionType type;
    public carfax carfaxAlert;
    public List<imageMap> images;
    public string region;

    public integer completedCount;

    public boolean wasManuallyCreated;


    global class imageMap extends CoreObject{
        public string imageName;
        public string imageURL;
    }

    global class vehicle extends CoreObject{
        public string vehicleId;
        public string driveTrain;
        public string make;
        public string trim;
        public string model;
        public string cylinders;
        public string engineDisplacement;
        public string fuelType;
        public string turbo;
        public string transmission;
        public string vin;
        public string year;    
        public string model_trim {get{ return this.model+' '+this.trim;} set{model_trim = this.model+' '+this.trim;}}
    }

    global class inspectionType extends CoreObject{
        public string id;
        public string description;
        public string type;
        public string name;
    }

    global class carfax extends CoreObject{
        public boolean isValid;
        public Datetime reportedDate;
        public list<string> carfaxExceptions;
        public list<string> odometerDiscrepancies;
    }
}