public class CreditResponse {

	public class Errors {
		public Attempted_create attempted_create;
		public Error error;
	}

	public class Attempted_create {
		public Integer account_id;
		public Integer amount;
		public Integer authorizer;
		public String credit_cause_type;
		public Integer expires_after;
		public String salesforce_id;
	}

	public class Successes {
		public Integer id;
		public String timestamp;
		public Integer amount;
		public Integer remaining_amount;
		public String expiration;
		public Boolean expired;
		public Object cause_auction;
		public Integer cause_type;
		public String cause_notes;
		public Integer authorized_by;
		public String applicable_to;
		public String salesforce_id;
	}

	public class Error {
		public String name;
		public String message;
	}

	public Integer api_version;
	public Data data;

	public class Data {
		public List<Successes> successes;
		public List<Errors> errors;
	}

	
	public static CreditResponse parse(String json) {
		return (CreditResponse) System.JSON.deserialize(json, CreditResponse.class);
	}
}