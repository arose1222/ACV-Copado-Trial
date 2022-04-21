public class TransportationErrorObject {

	public List<String> errors;

	
	public static TransportationErrorObject parse(String json) {
		return (TransportationErrorObject) System.JSON.deserialize(json, TransportationErrorObject.class);
	}
}