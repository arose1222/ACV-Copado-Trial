public class BoardInfo {

	// public class Project {
	// 	public String id {get;set;} 

	// 	public Project(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'id') {
	// 						id = parser.getText();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Project consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	// public class Scope {
	// 	public String type_Z {get;set;} // in json: type
	// 	public Project project {get;set;} 

	// 	public Scope(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'type') {
	// 						type_Z = parser.getText();
	// 					} else if (text == 'project') {
	// 						project = new Project(parser);
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Scope consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class Issuetypes {
		// public String self {get;set;} 
		// public String id {get;set;} 
		// public String description {get;set;} 
		// public String iconUrl {get;set;} 
		public String name {get;set;} 
		// public Boolean subtask {get;set;} 
		// public Scope scope {get;set;} 

		// public Issuetypes(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'self') {
		// 					self = parser.getText();
		// 				} else if (text == 'id') {
		// 					id = parser.getText();
		// 				} else if (text == 'description') {
		// 					description = parser.getText();
		// 				} else if (text == 'iconUrl') {
		// 					iconUrl = parser.getText();
		// 				} else if (text == 'name') {
		// 					name = parser.getText();
		// 				} else if (text == 'subtask') {
		// 					subtask = parser.getBooleanValue();
		// 				} else if (text == 'scope') {
		// 					scope = new Scope(parser);
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'Issuetypes consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
	
//	public String expand {get;set;} 
	public List<Projects> projects {get;set;} 

	// public BoardInfo(JSONParser parser) {
	// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 			String text = parser.getText();
	// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 				if (text == 'expand') {
	// 					expand = parser.getText();
	// 				} else if (text == 'projects') {
	// 					projects = arrayOfProjects(parser);
	// 				} else {
	// 					System.debug(LoggingLevel.WARN, 'BoardInfo consuming unrecognized property: '+text);
	// 					consumeObject(parser);
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	// public class AvatarUrls {
	// 	public String 48x48 {get;set;} 
	// 	public String 24x24 {get;set;} 
	// 	public String 16x16 {get;set;} 
	// 	public String 32x32 {get;set;} 

	// 	public AvatarUrls(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == '48x48') {
	// 						48x48 = parser.getText();
	// 					} else if (text == '24x24') {
	// 						24x24 = parser.getText();
	// 					} else if (text == '16x16') {
	// 						16x16 = parser.getText();
	// 					} else if (text == '32x32') {
	// 						32x32 = parser.getText();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'AvatarUrls consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class Projects {
		// public String self {get;set;} 
		// public String id {get;set;} 
		public String key {get;set;} 
		public String name {get;set;} 
		//public AvatarUrls avatarUrls {get;set;} 
		public List<Issuetypes> issuetypes {get;set;} 

		// public Projects(JSONParser parser) {
		// 	while (parser.nextToken() != System.JSONToken.END_OBJECT) {
		// 		if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
		// 			String text = parser.getText();
		// 			if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
		// 				if (text == 'self') {
		// 					self = parser.getText();
		// 				} else if (text == 'id') {
		// 					id = parser.getText();
		// 				} else if (text == 'key') {
		// 					key = parser.getText();
		// 				} else if (text == 'name') {
		// 					name = parser.getText();
		// 				// } else if (text == 'avatarUrls') {
		// 				// 	avatarUrls = new AvatarUrls(parser);
		// 				} else if (text == 'issuetypes') {
		// 					issuetypes = arrayOfIssuetypes(parser);
		// 				} else {
		// 					System.debug(LoggingLevel.WARN, 'Projects consuming unrecognized property: '+text);
		// 					consumeObject(parser);
		// 				}
		// 			}
		// 		}
		// 	}
		// }
	}
	
	// public class Issuetypes_Z {
	// 	public String self {get;set;} 
	// 	public String id {get;set;} 
	// 	public String description {get;set;} 
	// 	public String iconUrl {get;set;} 
	// 	public String name {get;set;} 
	// 	public Boolean subtask {get;set;} 

	// 	public Issuetypes_Z(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'self') {
	// 						self = parser.getText();
	// 					} else if (text == 'id') {
	// 						id = parser.getText();
	// 					} else if (text == 'description') {
	// 						description = parser.getText();
	// 					} else if (text == 'iconUrl') {
	// 						iconUrl = parser.getText();
	// 					} else if (text == 'name') {
	// 						name = parser.getText();
	// 					} else if (text == 'subtask') {
	// 						subtask = parser.getBooleanValue();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Issuetypes_Z consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	
	// public static BoardInfo parse(String json) {
	// 	System.JSONParser parser = System.JSON.createParser(json);
	// 	return new BoardInfo(parser);
	// }
	
	// public static void consumeObject(System.JSONParser parser) {
	// 	Integer depth = 0;
	// 	do {
	// 		System.JSONToken curr = parser.getCurrentToken();
	// 		if (curr == System.JSONToken.START_OBJECT || 
	// 			curr == System.JSONToken.START_ARRAY) {
	// 			depth++;
	// 		} else if (curr == System.JSONToken.END_OBJECT ||
	// 			curr == System.JSONToken.END_ARRAY) {
	// 			depth--;
	// 		}
	// 	} while (depth > 0 && parser.nextToken() != null);
	// }
	
    // private static List<Projects> arrayOfProjects(System.JSONParser p) {
    //     List<Projects> res = new List<Projects>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new Projects(p));
    //     }
    //     return res;
    // }






    // private static List<Issuetypes> arrayOfIssuetypes(System.JSONParser p) {
    //     List<Issuetypes> res = new List<Issuetypes>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new Issuetypes(p));
    //     }
    //     return res;
    // }


    // private static List<Issuetypes_Z> arrayOfIssuetypes_Z(System.JSONParser p) {
    //     List<Issuetypes_Z> res = new List<Issuetypes_Z>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new Issuetypes_Z(p));
    //     }
    //     return res;
    // }








}