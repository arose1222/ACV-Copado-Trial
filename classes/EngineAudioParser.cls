public class EngineAudioParser {

	public Integer api_version {get;set;} 
	public Data data {get;set;} 

	public EngineAudioParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'api_version') {
						api_version = parser.getIntegerValue();
					} else if (text == 'data') {
						data = new Data(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'EngineAudioParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Audio_files {
		public Integer guid {get;set;} 
		public String vin {get;set;} 
		public String link {get;set;} 
		public List<Tags> tags {get;set;} 
		public Integer owner_remote_uid {get;set;} 
		public String owner_remote_uid_source {get;set;} 
		public String created {get;set;} 

		public Audio_files(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'guid') {
							guid = parser.getIntegerValue();
						} else if (text == 'vin') {
							vin = parser.getText();
						} else if (text == 'link') {
							link = parser.getText();
						} else if (text == 'tags') {
							tags = arrayOfTags(parser);
						} else if (text == 'owner_remote_uid') {
							owner_remote_uid = parser.getIntegerValue();
						} else if (text == 'owner_remote_uid_source') {
							owner_remote_uid_source = parser.getText();
						} else if (text == 'created') {
							created = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Audio_files consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String vin {get;set;} 
		public String code {get;set;} 
		public List<Audio_files> audio_files {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'vin') {
							vin = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'audio_files') {
							audio_files = arrayOfAudio_files(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Tags {
		public String key {get;set;} 
		public String value {get;set;} 
		public String label_text {get;set;} 
		public String type_Z {get;set;} // in json: type
		public String category {get;set;} 

		public Tags(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'key') {
							key = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else if (text == 'label_text') {
							label_text = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'category') {
							category = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Tags consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static EngineAudioParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new EngineAudioParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	



    private static List<Audio_files> arrayOfAudio_files(System.JSONParser p) {
        List<Audio_files> res = new List<Audio_files>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Audio_files(p));
        }
        return res;
    }





    private static List<Tags> arrayOfTags(System.JSONParser p) {
        List<Tags> res = new List<Tags>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Tags(p));
        }
        return res;
    }


}