public class JiraUpdate {

	public class Status {
		public String self;
		public String description;
		public String iconUrl;
		public String name;
		public String id;
		public StatusCategory statusCategory;
	}

	public class Assignee {
		public String self;
		public String name;
		public String key;
		public String accountId;
		public String emailAddress;
		//public AvatarUrls avatarUrls;
		public String displayName;
		public Boolean active;
		public String timeZone;
		public String accountType;
	}

	public class Comment {
		public List<Comments> comments;
		public Integer maxResults;
		public Integer total;
		public Integer startAt;
	}

	public String expand;
	public String id;
	public String self;
	public String key;
	public Fields fields;

	public class Priority {
		public String self;
		public String iconUrl;
		public String name;
		public String id;
	}

	public class Comments {
		public String self;
		public String id;
		public Assignee author;
		public String body;
		public Assignee updateAuthor;
		public String created;
		public String updated;
		public Boolean jsdPublic;
	}

	public class Aggregateprogress {
		public Integer progress;
		public Integer total;
	}

	public class Watches {
		public String self;
		public Integer watchCount;
		public Boolean isWatching;
	}

	public class Project {
		public String self;
		public String id;
		public String key;
		public String name;
		public String projectTypeKey;
		public Boolean simplified;
		//public AvatarUrls avatarUrls;
	}

	public class StatusCategory {
		public String self;
		public Integer id;
		public String key;
		public String colorName;
		public String name;
	}

	public class Worklog {
		public Integer startAt;
		public Integer maxResults;
		public Integer total;
		public List<FixVersions> worklogs;
	}

	public class Fields {
		public String statuscategorychangedate;
		public List<FixVersions> fixVersions;
		public Object customfield_11200;
		public Object resolution;
		public Object customfield_11720;
		public Object customfield_10500;
		public Object customfield_11719;
		public Object lastViewed;
		public Priority priority;
		public List<FixVersions> labels;
		public Object customfield_11700;
		public Object customfield_11702;
		public Object customfield_11701;
		public Object timeestimate;
		public Object aggregatetimeoriginalestimate;
		// public Object customfield_11704;
		public List<FixVersions> versions;
		public Object customfield_11703;
		public Object customfield_11705;
		public List<FixVersions> issuelinks;
		public Assignee assignee;
		public Status status;
		public List<FixVersions> components;
		public Object customfield_11421;
		public Object customfield_11300;
		public Object customfield_11420;
		public Object customfield_11423;
		public Object customfield_11422;
		public Object customfield_11414;
		public Customfield_10600 customfield_10600;
		public Object customfield_11413;
		public Object customfield_11416;
		public Object customfield_11415;
		public Object customfield_11418;
		public Object aggregatetimeestimate;
		public Object customfield_11417;
		public Object customfield_11419;
		public Assignee creator;
		public List<FixVersions> subtasks;
		public Assignee reporter;
		public Aggregateprogress aggregateprogress;
		public Object customfield_11410;
		public Object customfield_11412;
		public Object customfield_11411;
		public Object customfield_11403;
		public Object customfield_11402;
		public Object customfield_11405;
		public Object customfield_11404;
		public Object customfield_11407;
		public Object customfield_11406;
		public Object customfield_11409;
		public Object customfield_11408;
		public Aggregateprogress progress;
		public Votes votes;
		public Worklog worklog;
		public Issuetype issuetype;
		//public Object timespent;
		public Project project;
		//public Object aggregatetimespent;
		//public Object customfield_11401;
		public List<FixVersions> customfield_11400;
		public String customfield_10700;
		//public Object resolutiondate;
		public Integer workratio;
		public Watches watches;
		public String created;
		public Object customfield_11753;
		public Object customfield_11502;
		public Object customfield_11501;
		public Object customfield_11504;
		public Object customfield_11746;
		public Object customfield_11745;
		public Object customfield_11503;
		public Object customfield_11748;
		public Object customfield_11747;
		public Object customfield_11505;
		public Object customfield_11749;
		public String updated;
		//public Object timeoriginalestimate;
		public String description;
		// public Object customfield_11100;
		// public Object customfield_11500;
		public String customfield_10014;
		public FixVersions timetracking;
		// public Object customfield_10005;
		// public Object security;
		// public Object customfield_10007;
		// public Object customfield_10800;
		// public Object customfield_10008;
		public List<FixVersions> attachment;
		public String summary;
		public String customfield_10000;
		// public Object customfield_10001;
		// public Object customfield_10003;
		// public Object customfield_10004;
		// public Object customfield_10400;
		// public Object customfield_11722;
		// public Object customfield_11600;
		// public Object customfield_11721;
		// public Object environment;
		// public Object customfield_11723;
		// public Object duedate;
		public Comment comment;
	}

	public class NonEditableReason {
		public String reason;
		public String message;
	}

	public class FixVersions {
	}

	public class Customfield_10600 {
		public Boolean hasEpicLinkFieldDependency;
		public Boolean showField;
		public NonEditableReason nonEditableReason;
	}

	// public class AvatarUrls {
	// 	public String 48x48;
	// 	public String 24x24;
	// 	public String 16x16;
	// 	public String 32x32;
	// }

	public class Issuetype {
		public String self;
		public String id;
		public String description;
		public String iconUrl;
		public String name;
		public Boolean subtask;
		//public Integer avatarId;
		public String entityId;
	}

	public class Votes {
		public String self;
		public Integer votes;
		public Boolean hasVoted;
	}

	
	public static JiraUpdate parse(String json) {
		return (JiraUpdate) System.JSON.deserialize(json, JiraUpdate.class);
	}
}