public class ACVLoginObject {
    public String api_version;
	public Data data;

	public class Data {
		public String user_id;
		public String session_token;
		public String code;
	}

	
	public static ACVLoginObject parse(String json) {
		return (ACVLoginObject) System.JSON.deserialize(json, ACVLoginObject.class);
	}
}