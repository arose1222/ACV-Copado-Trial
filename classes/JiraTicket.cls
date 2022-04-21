public class JiraTicket {

	public class Project {
		public String key;
	}

	public class Fields {
		public Project project;
		public String summary;
		public String description;
		public Issuetype issuetype;
	}

	public Fields fields;

	public class Issuetype {
		public String name;
	}
    
    public static JiraTicket parse(String json) {
        return (JiraTicket) System.JSON.deserialize(json, JiraTicket.class);
    } 
    public static String compose(JiraTicket newJiraTicket) {
        return System.JSON.serialize(newJiraTicket);
    }
}