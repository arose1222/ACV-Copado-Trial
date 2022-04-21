public class AdjustmentResponse {

	public class Adjustments {
		public Integer account_id;
		public Integer amount;
		public Integer id;
	}

	public class Data {
		public List<Adjustments> adjustments;
	}

	public Integer api_version;
	public Data data;

	
	public static AdjustmentResponse parse(String json) {
		return (AdjustmentResponse) System.JSON.deserialize(json, AdjustmentResponse.class);
	}
}