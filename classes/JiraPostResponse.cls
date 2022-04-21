public class JiraPostResponse {

	public String id;
	public String key;
	public String self;

	public static JiraPostResponse parse(String json) {
		return (JiraPostResponse) System.JSON.deserialize(json, JiraPostResponse.class);
	}
}