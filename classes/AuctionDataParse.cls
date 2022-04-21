public class AuctionDataParse {
	public class Selected_arbitration_plan {
		public String id {get;set;} 
		public String created {get;set;} 
		public String updated {get;set;} 
		public String title {get;set;} 
		public String description {get;set;} 
		public String days {get;set;} 
		public String cost {get;set;} 
		public String active {get;set;} 
		public String dealership_id {get;set;} 
		public String formatted_title {get;set;} 
		public String is_default {get;set;} 
		public String days_remaining {get;set;} 

		public Selected_arbitration_plan(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'created') {
							created = parser.getText();
						} else if (text == 'updated') {
							updated = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'days') {
							days = parser.getText();
						} else if (text == 'cost') {
							cost = parser.getText();
						} else if (text == 'active') {
							active = parser.getText();
						} else if (text == 'dealership_id') {
							dealership_id = parser.getText();
						} else if (text == 'formatted_title') {
							formatted_title = parser.getText();
						} else if (text == 'is_default') {
							is_default = parser.getText();
						} else if (text == 'days_remaining') {
							days_remaining = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Selected_arbitration_plan consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String api_version {get;set;} 
	public Data data {get;set;} 

	public AuctionDataParse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'api_version') {
						api_version = parser.getText();
					} else if (text == 'data') {
						data = new Data(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'AuctionDataParse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	// public class Answer_X {
	// 	public String type_Z {get;set;} // in json: type
	// 	public String value {get;set;} 
	// 	public String suffix {get;set;} 
	// 	public String required {get;set;} 
	// 	public String placeholder {get;set;} 
	// 	public String display_name {get;set;} 

	// 	public Answer_X(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'type') {
	// 						type_Z = parser.getText();
	// 					} else if (text == 'value') {
	// 						value = parser.getText();
	// 					} else if (text == 'suffix') {
	// 						suffix = parser.getText();
	// 					} else if (text == 'required') {
	// 						required = parser.getText();
	// 					} else if (text == 'placeholder') {
	// 						placeholder = parser.getText();
	// 					} else if (text == 'display_name') {
	// 						display_name = parser.getText();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Answer_X consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class Display_info {
		public String name {get;set;} 
		public String value {get;set;} 

		public Display_info(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Display_info consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Images {
		public String image_key {get;set;} 
		public String url {get;set;} 
		public String thumbnail {get;set;} 
		public String acv_thumbnail {get;set;} 
		public String acv_medium {get;set;} 
		public String acv_large {get;set;} 
		public String updated {get;set;} 

		public Images(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'image_key') {
							image_key = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else if (text == 'thumbnail') {
							thumbnail = parser.getText();
						} else if (text == 'acv_thumbnail') {
							acv_thumbnail = parser.getText();
						} else if (text == 'acv_medium') {
							acv_medium = parser.getText();
						} else if (text == 'acv_large') {
							acv_large = parser.getText();
						} else if (text == 'updated') {
							updated = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Images consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Subsections {
		public String id {get;set;} 
		public String sort_order {get;set;} 
		public String title {get;set;} 
		public String section_id {get;set;} 
		public String answered_affirmative {get;set;} 
		public List<Questions_Z> questions {get;set;} 	

		public Subsections(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'sort_order') {
							sort_order = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'section_id') {
							section_id = parser.getText();
						} else if (text == 'answered_affirmative') {
							answered_affirmative = parser.getText();
						} else if (text == 'questions') {
							questions = arrayOfQuestions_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Subsections consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Seller_info {
		public String user_id {get;set;} 
		public String dealer_id {get;set;} 
		public String dealership_type {get;set;} 

		public Seller_info(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'user_id') {
							user_id = parser.getText();
						} else if (text == 'dealer_id') {
							dealer_id = parser.getText();
						} else if (text == 'dealership_type') {
							dealership_type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Seller_info consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Condition_report {
		public List<Sections> sections {get;set;}

		public Condition_report(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'sections') {
							sections = arrayOfSections(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Condition_report consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Answer_Z {
		public String required {get;set;} 
		public String data_type {get;set;} 
		public String max_label {get;set;} 
		public String max_value {get;set;} 
		public String min_label {get;set;} 
		public String min_value {get;set;} 
		public String max_suffix {get;set;} 
		public String min_suffix {get;set;} 
		public String max_placeholder {get;set;} 
		public String min_placeholder {get;set;}
		public String value {get;set;} 
		public String placeholder {get;set;}
		public String suffix {get;set;}
		public String display_name {get;set;}
		public String type {get;set;} 

		public Answer_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'required') {
							required = parser.getText();
						} else if (text == 'data_type') {
							data_type = parser.getText();
						} else if (text == 'max_label') {
							max_label = parser.getText();
						} else if (text == 'max_value') {
							max_value = parser.getText();
						} else if (text == 'min_label') {
							min_label = parser.getText();
						} else if (text == 'min_value') {
							min_value = parser.getText();
						} else if (text == 'max_suffix') {
							max_suffix = parser.getText();
						} else if (text == 'min_suffix') {
							min_suffix = parser.getText();
						} else if (text == 'max_placeholder') {
							max_placeholder = parser.getText();
						} else if (text == 'min_placeholder') {
							min_placeholder = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else if (text == 'placeholder') {
							placeholder = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'display_name') {
							display_name = parser.getText();
						} else if (text == 'suffix') {
							suffix = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Answer_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Auction_condition_report {
		public List<Sections_Z> sections {get;set;}
		public String template_id {get;set;} 
		public String template_name {get;set;} 
		public String template_version {get;set;} 
		public String use_toggle_switch {get;set;} 

		public Auction_condition_report(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'sections') {
							sections = arrayOfSections_Z(parser);
						} else if (text == 'template_id') {
							template_id = parser.getText();
						} else if (text == 'template_name') {
							template_name = parser.getText();
						} else if (text == 'template_version') {
							template_version = parser.getText();
						} else if (text == 'use_toggle_switch') {
							use_toggle_switch = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Auction_condition_report consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String id {get;set;} 
		public List<Display_info> display_info {get;set;} 
		public List<Images> images {get;set;} 
		public Buyer_info buyer_info {get;set;} 
		public Seller_info seller_info {get;set;} 
		public Negotiations negotiations {get;set;} 
		public Post_auction_data post_auction_data {get;set;} 
		public Condition_report condition_report {get;set;} 
		public Auction_condition_report auction_condition_report {get;set;} 
		public String proxy_bid {get;set;} 
		public String vin {get;set;} 
		public String model {get;set;} 
		public String transmission {get;set;} 
		public String make {get;set;} 
		public String odometer {get;set;} 
		public String basic_color {get;set;} 
		public String trim {get;set;} 
		public String year {get;set;} 
		public String drivetrain {get;set;} 
		public String arbitration_id {get;set;} 
		public String sellable {get;set;} 
		public String bid_count {get;set;} 
		public String is_tmu {get;set;} 
		public String green_light {get;set;} 
		public String red_light {get;set;} 
		public String yellow_light {get;set;} 
		public String blue_light {get;set;} 
		public String proxy_amount {get;set;} 
		public String notes {get;set;} 
		public String floor_price {get;set;} 
		public String view_count {get;set;} 
		public String unique_bidders {get;set;} 
		public String source {get;set;} 
		public String start_time {get;set;} 
		public String start_time_formatted {get;set;} 
		public String end_time {get;set;} 
		public String bid_amount {get;set;} 
		public String category {get;set;} 
		public String participant {get;set;} 
		public String proxy_bid_interval {get;set;} 
		public String listed_by_vci {get;set;} 
		public String status {get;set;} 
		public String start_price {get;set;} 
		public String autosell {get;set;} 
		public String vehicle_display_name {get;set;} 
		public Images primary_image {get;set;} 
		public String saved_auction_id {get;set;} 
		public Selected_arbitration_plan selected_arbitration_plan {get;set;} 
		public List<Available_arbitration_plans> available_arbitration_plans {get;set;} 
		public String relaunchable {get;set;} 
		public List<Available_arbitration_plans> promo_messages {get;set;} 
		public String recommended_price {get;set;} 
		public String high_bidder {get;set;}


		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'display_info') {
							display_info = arrayOfDisplay_info(parser);
						} else if (text == 'images') {
							images = arrayOfImages(parser);
						} else if (text == 'buyer_info') {
							buyer_info = new Buyer_info(parser);
						} else if (text == 'seller_info') {
							seller_info = new Seller_info(parser);
						} else if (text == 'negotiations') {
							negotiations = new Negotiations(parser);
						} else if (text == 'post_auction_data') {
							post_auction_data = new Post_auction_data(parser);
						} else if (text == 'condition_report') {
							condition_report = new Condition_report(parser);
						} else if (text == 'auction_condition_report') {
							auction_condition_report = new Auction_condition_report(parser);
						} else if (text == 'proxy_bid') {
							proxy_bid = parser.getText();
						} else if (text == 'vin') {
							vin = parser.getText();
						} else if (text == 'model') {
							model = parser.getText();
						} else if (text == 'transmission') {
							transmission = parser.getText();
						} else if (text == 'make') {
							make = parser.getText();
						} else if (text == 'odometer') {
							odometer = parser.getText();
						} else if (text == 'basic_color') {
							basic_color = parser.getText();
						} else if (text == 'trim') {
							trim = parser.getText();
						} else if (text == 'year') {
							year = parser.getText();
						} else if (text == 'drivetrain') {
							drivetrain = parser.getText();
						} else if (text == 'arbitration_id') {
							arbitration_id = parser.getText();
						} else if (text == 'sellable') {
							sellable = parser.getText();
						} else if (text == 'bid_count') {
							bid_count = parser.getText();
						} else if (text == 'is_tmu') {
							is_tmu = parser.getText();
						} else if (text == 'green_light') {
							green_light = parser.getText();
						} else if (text == 'red_light') {
							red_light = parser.getText();
						} else if (text == 'yellow_light') {
							yellow_light = parser.getText();
						} else if (text == 'blue_light') {
							blue_light = parser.getText();
						} else if (text == 'proxy_amount') {
							proxy_amount = parser.getText();
						} else if (text == 'notes') {
							notes = parser.getText();
						} else if (text == 'floor_price') {
							floor_price = parser.getText();
						} else if (text == 'view_count') {
							view_count = parser.getText();
						} else if (text == 'unique_bidders') {
							unique_bidders = parser.getText();
						} else if (text == 'source') {
							source = parser.getText();
						} else if (text == 'start_time') {
							start_time = parser.getText();
						} else if (text == 'start_time_formatted') {
							start_time_formatted = parser.getText();
						} else if (text == 'end_time') {
							end_time = parser.getText();
						} else if (text == 'bid_amount') {
							bid_amount = parser.getText();
						} else if (text == 'category') {
							category = parser.getText();
						} else if (text == 'participant') {
							participant = parser.getText();
						} else if (text == 'proxy_bid_interval') {
							proxy_bid_interval = parser.getText();
						} else if (text == 'listed_by_vci') {
							listed_by_vci = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'start_price') {
							start_price = parser.getText();
						} else if (text == 'autosell') {
							autosell = parser.getText();
						} else if (text == 'vehicle_display_name') {
							vehicle_display_name = parser.getText();
						} else if (text == 'primary_image') {
							primary_image = new Images(parser);
						} else if (text == 'saved_auction_id') {
							saved_auction_id = parser.getText();
						} else if (text == 'selected_arbitration_plan') {
							selected_arbitration_plan = new Selected_arbitration_plan(parser);
						} else if (text == 'available_arbitration_plans') {
							available_arbitration_plans = arrayOfAvailable_arbitration_plans(parser);
						} else if (text == 'relaunchable') {
							relaunchable = parser.getText();
						} else if (text == 'promo_messages') {
							promo_messages = arrayOfAvailable_arbitration_plans(parser);
						} else if (text == 'recommended_price') {
							recommended_price = parser.getText();
						} else if (text == 'high_bidder') {
							high_bidder = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Questions_Z {
		public String id {get;set;} 
		public String title {get;set;} 
		public String question_text {get;set;} 
		public String example {get;set;} 
		public String yellow_light {get;set;} 
		public String sort_order {get;set;} 
		public String subsection_id {get;set;} 
		public String carfax_announcement {get;set;} 
		public String seller_disclosure {get;set;} 
		public String yes_no {get;set;} 

		public Questions_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'question_text') {
							question_text = parser.getText();
						} else if (text == 'example') {
							example = parser.getText();
						} else if (text == 'yellow_light') {
							yellow_light = parser.getText();
						} else if (text == 'sort_order') {
							sort_order = parser.getText();
						} else if (text == 'subsection_id') {
							subsection_id = parser.getText();
						} else if (text == 'carfax_announcement') {
							carfax_announcement = parser.getText();
						} else if (text == 'seller_disclosure') {
							seller_disclosure = parser.getText();
						} else if (text == 'yes_no') {
							yes_no = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Questions_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	// public class Answer_Y {
	// 	public String type_Z {get;set;} // in json: type
	// 	public String value {get;set;} 
	// 	public String suffix {get;set;} 
	// 	public String required {get;set;} 
	// 	public String placeholder {get;set;} 
	// 	public String display_name {get;set;} 

	// 	public Answer_Y(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'type') {
	// 						type_Z = parser.getText();
	// 					} else if (text == 'value') {
	// 						//value = parser.getIntegerValue();
	// 						value = parser.getText();
	// 					} else if (text == 'suffix') {
	// 						suffix = parser.getText();
	// 					} else if (text == 'required') {
	// 						required = parser.getText();
	// 					} else if (text == 'placeholder') {
	// 						placeholder = parser.getText();
	// 					} else if (text == 'display_name') {
	// 						display_name = parser.getText();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Answer_Y consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class Subsections_Z {
		public String id {get;set;} 
		public String sort_order {get;set;} 
		public String title {get;set;} 
		public String section_id {get;set;} 
		public String answered_affirmative {get;set;} 
		public List<Questions_Z> questions {get;set;} 

		public Subsections_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'sort_order') {
							sort_order = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'section_id') {
							section_id = parser.getText();
						} else if (text == 'answered_affirmative') {
							answered_affirmative = parser.getText();
						} else if (text == 'questions') {
							questions = arrayOfQuestions_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Subsections_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	// public class Answer {
	// 	public String value {get;set;} 
	// 	public String required {get;set;} 
	// 	public String placeholder {get;set;} 
		

	// 	public Answer(JSONParser parser) {
	// 		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
	// 			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
	// 				String text = parser.getText();
	// 				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
	// 					if (text == 'value') {
	// 						value = parser.getText();
	// 					} else if (text == 'required') {
	// 						required = parser.getText();
	// 					} else if (text == 'placeholder') {
	// 						placeholder = parser.getText();
	// 					} else {
	// 						System.debug(LoggingLevel.WARN, 'Answer consuming unrecognized property: '+text);
	// 						consumeObject(parser);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	
	public class Available_arbitration_plans {

		public Available_arbitration_plans(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'Available_arbitration_plans consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Buyer_info {
		public String user_id {get;set;} 
		public String dealer_id {get;set;} 
		public String dealership_type {get;set;} 

		public Buyer_info(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'user_id') {
							user_id = parser.getText();
						} else if (text == 'dealer_id') {
							dealer_id = parser.getText();
						} else if (text == 'dealership_type') {
							dealership_type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Buyer_info consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Sections {
		public String id {get;set;} 
		public String sort_order {get;set;} 
		public String title {get;set;} 
		public String answered_affirmative {get;set;} 
		public List<Subsections_Z> subsections {get;set;} 

		public Sections(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'sort_order') {
							sort_order = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'answered_affirmative') {
							answered_affirmative = parser.getText();
						} else if (text == 'subsections') {
							subsections = arrayOfSubsections_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Sections consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Post_auction_data {
		public String finalized {get;set;} 

		public Post_auction_data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'finalized') {
							finalized = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Post_auction_data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Negotiations {
		public String last_user {get;set;} 
		public String last_dealer {get;set;} 
		public String buyer_amount {get;set;} 
		public String seller_amount {get;set;} 

		public Negotiations(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'last_user') {
							last_user = parser.getText();
						} else if (text == 'last_dealer') {
							last_dealer = parser.getText();
						} else if (text == 'buyer_amount') {
							buyer_amount = parser.getText();
						} else if (text == 'seller_amount') {
							seller_amount = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Negotiations consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Questions {		
		public Answer_Z answer {get;set;} 
		public String complete {get;set;} 
		public String selected {get;set;} 
		public String answer_id {get;set;} 
		public String question_id {get;set;}
		public String question_key {get;set;} 
		public String yellow_light {get;set;} 
		public String question_type {get;set;} 
		public String question_title {get;set;} 
		public String carfax_disclosure {get;set;} 
		public String question_sub_title {get;set;} 

		public Questions(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'answer') {
							answer = new Answer_Z(parser);
						} else if (text == 'complete') {
							complete = parser.getText();
						} else if (text == 'selected') {
							selected = parser.getText();
						} else if (text == 'answer_id') {
							answer_id = parser.getText();
						} else if (text == 'question_id') {
							question_id = parser.getText();
						} else if (text == 'question_key') {
							question_key = parser.getText();
						} else if (text == 'yellow_light') {
							yellow_light = parser.getText();
						} else if (text == 'question_type') {
							question_type = parser.getText();
						} else if (text == 'question_title') {
							question_title = parser.getText();
						} else if (text == 'carfax_disclosure') {
							carfax_disclosure = parser.getText();
						} else if (text == 'question_sub_title') {
							question_sub_title = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Questions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Sections_Z {
		public List<Questions> questions {get;set;} 
		public String section_id {get;set;} 
		public String section_name {get;set;} 
		public String section_version {get;set;} 
		public String confirmed_section {get;set;} 

		public Sections_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'questions') {
							questions = arrayOfQuestions(parser);
						} else if (text == 'section_id') {
							section_id = parser.getText();
						} else if (text == 'section_name') {
							section_name = parser.getText();
						} else if (text == 'section_version') {
							section_version = parser.getText();
						} else if (text == 'confirmed_section') {
							confirmed_section = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Sections_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static AuctionDataParse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new AuctionDataParse(parser);
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

    private static List<Subsections_Z> arrayOfSubsections_Z(System.JSONParser p) {
        List<Subsections_Z> res = new List<Subsections_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Subsections_Z(p));
        }
        return res;
    }

    private static List<Questions> arrayOfQuestions(System.JSONParser p) {
        List<Questions> res = new List<Questions>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Questions(p));
        }
        return res;
    }


    private static List<Questions_Z> arrayOfQuestions_Z(System.JSONParser p) {
        List<Questions_Z> res = new List<Questions_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Questions_Z(p));
        }
        return res;
    }

    private static List<Images> arrayOfImages(System.JSONParser p) {
        List<Images> res = new List<Images>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Images(p));
        }
        return res;
    }

	// this did no exist, so added. one for answer does not exist either
	private static List<Answer_Z> arrayOfAnswer_Z(System.JSONParser p) {
        List<Answer_Z> res = new List<Answer_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Answer_Z(p));
        }
        return res;
    }

    // private static List<Answer_Y> arrayOfAnswer_Y(System.JSONParser p) {
    //     List<Answer_Y> res = new List<Answer_Y>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new Answer_Y(p));
    //     }
    //     return res;
    // }

    // private static List<Answer_X> arrayOfAnswer_X(System.JSONParser p) {
    //     List<Answer_X> res = new List<Answer_X>();
    //     if (p.getCurrentToken() == null) p.nextToken();
    //     while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //         res.add(new Answer_X(p));
    //     }
    //     return res;
    // }

    private static List<Subsections> arrayOfSubsections(System.JSONParser p) {
        List<Subsections> res = new List<Subsections>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Subsections(p));
        }
        return res;
    }

    private static List<Available_arbitration_plans> arrayOfAvailable_arbitration_plans(System.JSONParser p) {
        List<Available_arbitration_plans> res = new List<Available_arbitration_plans>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Available_arbitration_plans(p));
        }
        return res;
    }

    private static List<Display_info> arrayOfDisplay_info(System.JSONParser p) {
        List<Display_info> res = new List<Display_info>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Display_info(p));
        }
        return res;
    }

    private static List<Sections> arrayOfSections(System.JSONParser p) {
        List<Sections> res = new List<Sections>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Sections(p));
        }
        return res;
    }

    private static List<Sections_Z> arrayOfSections_Z(System.JSONParser p) {
        List<Sections_Z> res = new List<Sections_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Sections_Z(p));
        }
        return res;
    }
}