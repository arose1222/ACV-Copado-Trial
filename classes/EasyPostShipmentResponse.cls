//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are not valid in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class EasyPostShipmentResponse {

	public class Options {
		public String currencyc {get;set;} 
		public Payment payment {get;set;} 
		public String label_date {get;set;} 
		public Integer date_advance {get;set;} 

		public Options(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currencyc = parser.getText();
						} else if (text == 'payment') {
							payment = new Payment(parser);
						} else if (text == 'label_date') {
							label_date = parser.getText();
						} else if (text == 'date_advance') {
							date_advance = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Options consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Payment {
		public String type_Z {get;set;} // in json: type

		public Payment(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Payment consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class From_address {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String created_at {get;set;} 
		public String updated_at {get;set;} 
		public String name {get;set;} 
		public String company {get;set;} 
		public String street1 {get;set;} 
		public String street2 {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zip {get;set;} 
		public String country {get;set;} 
		public String phone {get;set;} 
		public Object email {get;set;} 
		public String mode {get;set;} 
		public String carrier_facility {get;set;} 
		public Object residential {get;set;} 
		public Object federal_tax_id {get;set;} 
		public Object state_tax_id {get;set;} 
		public Messages verifications {get;set;} 

		public From_address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else if (text == 'updated_at') {
							updated_at = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'company') {
							company = parser.getText();
						} else if (text == 'street1') {
							street1 = parser.getText();
						} else if (text == 'street2') {
							street2 = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zip') {
							zip = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'email') {
							email = parser.readValueAs(Object.class);
						} else if (text == 'mode') {
							mode = parser.getText();
						} else if (text == 'carrier_facility') {
							carrier_facility = parser.getText();
						} else if (text == 'residential') {
							residential = parser.readValueAs(Object.class);
						} else if (text == 'federal_tax_id') {
							federal_tax_id = parser.readValueAs(Object.class);
						} else if (text == 'state_tax_id') {
							state_tax_id = parser.readValueAs(Object.class);
						} else if (text == 'verifications') {
							verifications = new Messages(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'From_address consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Rates {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String created_at {get;set;} 
		public String updated_at {get;set;} 
		public String mode {get;set;} 
		public String service {get;set;} 
		public String carrier {get;set;} 
		public String rate {get;set;} 
		public String currencyc {get;set;} 
		public Object retail_rate {get;set;} 
		public Object retail_currency {get;set;} 
		public String list_rate {get;set;} 
		public String list_currency {get;set;} 
		public Integer delivery_days {get;set;} 
		public String delivery_date {get;set;} 
		public Boolean delivery_date_guaranteed {get;set;} 
		public Integer est_delivery_days {get;set;} 
		public String shipment_id {get;set;} 
		public String carrier_account_id {get;set;} 

		public Rates(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else if (text == 'updated_at') {
							updated_at = parser.getText();
						} else if (text == 'mode') {
							mode = parser.getText();
						} else if (text == 'service') {
							service = parser.getText();
						} else if (text == 'carrier') {
							carrier = parser.getText();
						} else if (text == 'rate') {
							rate = parser.getText();
						} else if (text == 'currency') {
							currencyc = parser.getText();
						} else if (text == 'retail_rate') {
							retail_rate = parser.readValueAs(Object.class);
						} else if (text == 'retail_currency') {
							retail_currency = parser.readValueAs(Object.class);
						} else if (text == 'list_rate') {
							list_rate = parser.getText();
						} else if (text == 'list_currency') {
							list_currency = parser.getText();
						} else if (text == 'delivery_days') {
							delivery_days = parser.getIntegerValue();
						} else if (text == 'delivery_date') {
							delivery_date = parser.getText();
						} else if (text == 'delivery_date_guaranteed') {
							delivery_date_guaranteed = parser.getBooleanValue();
						} else if (text == 'est_delivery_days') {
							est_delivery_days = parser.getIntegerValue();
						} else if (text == 'shipment_id') {
							shipment_id = parser.getText();
						} else if (text == 'carrier_account_id') {
							carrier_account_id = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Rates consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Messages {

		public Messages(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Messages consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Parcel {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String created_at {get;set;} 
		public String updated_at {get;set;} 
		public Object length {get;set;} 
		public Object width {get;set;} 
		public Object height {get;set;} 
		public String predefined_package {get;set;} 
		public Integer weight {get;set;} 
		public String mode {get;set;} 

		public Parcel(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else if (text == 'updated_at') {
							updated_at = parser.getText();
						} else if (text == 'length') {
							length = parser.readValueAs(Object.class);
						} else if (text == 'width') {
							width = parser.readValueAs(Object.class);
						} else if (text == 'height') {
							height = parser.readValueAs(Object.class);
						} else if (text == 'predefined_package') {
							predefined_package = parser.getText();
						} else if (text == 'weight') {
							weight = parser.getIntegerValue();
						} else if (text == 'mode') {
							mode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Parcel consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class To_address {
		public String id {get;set;} 
		public String object_Z {get;set;} // in json: object
		public String created_at {get;set;} 
		public String updated_at {get;set;} 
		public String name {get;set;} 
		public String company {get;set;} 
		public String street1 {get;set;} 
		public String street2 {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zip {get;set;} 
		public String country {get;set;} 
		public String phone {get;set;} 
		public Object email {get;set;} 
		public String mode {get;set;} 
		public Object carrier_facility {get;set;} 
		public Object residential {get;set;} 
		public Object federal_tax_id {get;set;} 
		public Object state_tax_id {get;set;} 
		public Messages verifications {get;set;} 

		public To_address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'object') {
							object_Z = parser.getText();
						} else if (text == 'created_at') {
							created_at = parser.getText();
						} else if (text == 'updated_at') {
							updated_at = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'company') {
							company = parser.getText();
						} else if (text == 'street1') {
							street1 = parser.getText();
						} else if (text == 'street2') {
							street2 = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zip') {
							zip = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'email') {
							email = parser.readValueAs(Object.class);
						} else if (text == 'mode') {
							mode = parser.getText();
						} else if (text == 'carrier_facility') {
							carrier_facility = parser.readValueAs(Object.class);
						} else if (text == 'residential') {
							residential = parser.readValueAs(Object.class);
						} else if (text == 'federal_tax_id') {
							federal_tax_id = parser.readValueAs(Object.class);
						} else if (text == 'state_tax_id') {
							state_tax_id = parser.readValueAs(Object.class);
						} else if (text == 'verifications') {
							verifications = new Messages(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'To_address consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String created_at {get;set;} 
	public Boolean is_return {get;set;} 
	public List<Messages> messages {get;set;} 
	public String mode {get;set;} 
	public Options options {get;set;} 
	public Object reference {get;set;} 
	public String status {get;set;} 
	public Object tracking_code {get;set;} 
	public String updated_at {get;set;} 
	public Object batch_id {get;set;} 
	public Object batch_status {get;set;} 
	public Object batch_message {get;set;} 
	public Object customs_info {get;set;} 
	public From_address from_address {get;set;} 
	public Object insurance {get;set;} 
	public Object order_id {get;set;} 
	public Parcel parcel {get;set;} 
	public Object postage_label {get;set;} 
	public List<Rates> rates {get;set;} 
	public Object refund_status {get;set;} 
	public Object scan_form {get;set;} 
	public Object selected_rate {get;set;} 
	public Object tracker {get;set;} 
	public To_address to_address {get;set;} 
	public Integer usps_zone {get;set;} 
	public From_address return_address {get;set;} 
	public To_address buyer_address {get;set;} 
	public List<Messages> forms {get;set;} 
	public List<Messages> fees {get;set;} 
	public String id {get;set;} 
	public String object_Z {get;set;} // in json: object

	public EasyPostShipmentResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'created_at') {
						created_at = parser.getText();
					} else if (text == 'is_return') {
						is_return = parser.getBooleanValue();
					} else if (text == 'messages') {
						messages = arrayOfMessages(parser);
					} else if (text == 'mode') {
						mode = parser.getText();
					} else if (text == 'options') {
						options = new Options(parser);
					} else if (text == 'reference') {
						reference = parser.readValueAs(Object.class);
					} else if (text == 'status') {
						status = parser.getText();
					} else if (text == 'tracking_code') {
						tracking_code = parser.readValueAs(Object.class);
					} else if (text == 'updated_at') {
						updated_at = parser.getText();
					} else if (text == 'batch_id') {
						batch_id = parser.readValueAs(Object.class);
					} else if (text == 'batch_status') {
						batch_status = parser.readValueAs(Object.class);
					} else if (text == 'batch_message') {
						batch_message = parser.readValueAs(Object.class);
					} else if (text == 'customs_info') {
						customs_info = parser.readValueAs(Object.class);
					} else if (text == 'from_address') {
						from_address = new From_address(parser);
					} else if (text == 'insurance') {
						insurance = parser.readValueAs(Object.class);
					} else if (text == 'order_id') {
						order_id = parser.readValueAs(Object.class);
					} else if (text == 'parcel') {
						parcel = new Parcel(parser);
					} else if (text == 'postage_label') {
						postage_label = parser.readValueAs(Object.class);
					} else if (text == 'rates') {
						rates = arrayOfRates(parser);
					} else if (text == 'refund_status') {
						refund_status = parser.readValueAs(Object.class);
					} else if (text == 'scan_form') {
						scan_form = parser.readValueAs(Object.class);
					} else if (text == 'selected_rate') {
						selected_rate = parser.readValueAs(Object.class);
					} else if (text == 'tracker') {
						tracker = parser.readValueAs(Object.class);
					} else if (text == 'to_address') {
						to_address = new To_address(parser);
					} else if (text == 'usps_zone') {
						usps_zone = parser.getIntegerValue();
					} else if (text == 'return_address') {
						return_address = new From_address(parser);
					} else if (text == 'buyer_address') {
						buyer_address = new To_address(parser);
					} else if (text == 'forms') {
						forms = arrayOfMessages(parser);
					} else if (text == 'fees') {
						fees = arrayOfMessages(parser);
					} else if (text == 'id') {
						id = parser.getText();
					} else if (text == 'object') {
						object_Z = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'EasyPostShipmentResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static EasyPostShipmentResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new EasyPostShipmentResponse(parser);
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
	
    private static List<Rates> arrayOfRates(System.JSONParser p) {
        List<Rates> res = new List<Rates>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Rates(p));
        }
        return res;
    }

    private static List<Messages> arrayOfMessages(System.JSONParser p) {
        List<Messages> res = new List<Messages>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Messages(p));
        }
        return res;
    }
}