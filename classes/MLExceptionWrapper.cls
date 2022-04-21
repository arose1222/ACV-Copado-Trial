public class MLExceptionWrapper {
    public Clerk Clerk {get; set;}
    public Email Email {get; set;}
    public Title Title {get; set;}
    public Scanner Scanner {get; set;}
    public String Image; 

    public class Email {
        public String Subject;
        public String Body;
        public String TimeStamp;
        public String ImagesLocation;
    }

    public class Clerk {
        public String Email;
        public String FullName;
        public String LoginId;
    }

    public class Title {
        public String State;
        public String AuctionId;
        public String Vin;
        public Boolean IsConfident;
        public String batchId;
    }

    public class Scanner {
        public String ModelName;
    }

}