public class VLVinObject {

	public class Virtual_lift_list {
		public Integer guid;
		public String vin;
		public Boolean active;
		public Integer owner_remote_uid;
		public String link;
		public String created;
	}

	public Double api_version;
	public Data data;

	public class Data {
		public List<Virtual_lift_list> virtual_lift_list;
		public String code;
	}

	
	public static VLVinObject parse(String json) {
		return (VLVinObject) System.JSON.deserialize(json, VLVinObject.class);
	}
}