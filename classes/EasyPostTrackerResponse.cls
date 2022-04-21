public class EasyPostTrackerResponse {

	public class Tracking_details_Z {

		public Tracking_details_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Tracking_details_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Fees {
		public String object_Z {get;set;} // in json: object
		public String type_Z {get;set;} // in json: type
		public String amount {get;set;} 
		public Boolean charged {get;set;} 
		public Boolean refunded {get;set;} 

		public Fees(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'amount') {
							amount = parser.getText();
						} else if (text == 'charged') {
							charged = parser.getBooleanValue();
						} else if (text == 'refunded') {
							refunded = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Fees consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Trackers> trackers {get;set;} 
	public Boolean has_more {get;set;} 

	public EasyPostTrackerResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'trackers') {
						trackers = arrayOfTrackers(parser);
					} else if (text == 'has_more') {
						has_more = parser.getBooleanValue();
					} else {
						System.debug(LoggingLevel.WARN, 'EasyPostTrackerResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Tracking_location {
		public String object_Z {get;set;} // in json: object
		public String city {get;set;} 
		public String state {get;set;} 
		public String country {get;set;} 
		public String zip {get;set;} 

		public Tracking_location(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'zip') {
							zip = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Tracking_location consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Tracking_details {
		public String object_Z {get;set;} // in json: object
		public String message {get;set;} 
		public String status {get;set;} 
		public String messagedatetime {get;set;} 
		public String source {get;set;} 
		public Tracking_location tracking_location {get;set;} 

		public Tracking_details(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'message') {
							message = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'datetime') {
							messagedatetime = parser.getText();
						} else if (text == 'source') {
							source = parser.getText();
						} else if (text == 'tracking_location') {
							tracking_location = new Tracking_location(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Tracking_details consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Trackers {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String mode {get;set;} 
		public String tracking_code {get;set;} 
		public String status {get;set;} 
		public String created_at {get;set;} 
		public String updated_at {get;set;} 
		public String signed_by {get;set;} 
		public String weight {get;set;} 
		public String est_delivery_date {get;set;} 
		public String shipment_id {get;set;} 
		public String carrier {get;set;} 
		public String public_url {get;set;} 
		public List<Tracking_details> tracking_details {get;set;} 
		public String carrier_detail {get;set;} 
		public List<Fees> fees {get;set;} 

		public Trackers(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'mode') {
							mode = parser.getText();
						} else if (text == 'tracking_code') {
							tracking_code = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else if (text == 'updated_at') {
							updated_at = parser.getText();
						} else if (text == 'signed_by') {
							signed_by = parser.getText();
						} else if (text == 'weight') {
							weight = parser.getText();
						} else if (text == 'est_delivery_date') {
							est_delivery_date = parser.getText();
						} else if (text == 'shipment_id') {
							shipment_id = parser.getText();
						} else if (text == 'carrier') {
							carrier = parser.getText();
						} else if (text == 'public_url') {
							public_url = parser.getText();
						} else if (text == 'tracking_details') {
							tracking_details = arrayOfTracking_details(parser);
						} else if (text == 'carrier_detail') {
							carrier_detail = parser.getText();
						} else if (text == 'fees') {
							fees = arrayOfFees(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Trackers consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static EasyPostTrackerResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new EasyPostTrackerResponse(parser);
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
	


    private static List<Fees> arrayOfFees(System.JSONParser p) {
        List<Fees> res = new List<Fees>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Fees(p));
        }
        return res;
    }




    private static List<Trackers> arrayOfTrackers(System.JSONParser p) {
        List<Trackers> res = new List<Trackers>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Trackers(p));
        }
        return res;
    }




    private static List<Tracking_details> arrayOfTracking_details(System.JSONParser p) {
        List<Tracking_details> res = new List<Tracking_details>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Tracking_details(p));
        }
        return res;
    }




    private static List<Tracking_details_Z> arrayOfTracking_details_Z(System.JSONParser p) {
        List<Tracking_details_Z> res = new List<Tracking_details_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Tracking_details_Z(p));
        }
        return res;
    }




}