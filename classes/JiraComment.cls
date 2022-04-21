public class JiraComment {

	public String body;
	
	public static JiraComment parse(String json) {
		return (JiraComment) System.JSON.deserialize(json, JiraComment.class);
	}

	public static String compose(JiraComment newJiraComment) {
        return System.JSON.serialize(newJiraComment);
    }
}