public class EasyPostShipmentRequest {

	public class From_address {
		public String name;
		public String company;
		public String street1;
		public String street2;
		public String city;
		public String state;
		public String zip;
		public String country;
		public String phone;
		public String email;
	}

	public class Parcel {
		public String predefined_package;
		public Integer weight;
	}

	public class Shipment {
		public Parcel parcel;
		public To_address to_address;
		public From_address from_address;
		public options options;
	}

	public Shipment shipment;

	public class To_address {
		public String name;
		public String company;
		public String street1;
		public String street2;
		public String city;
		public String state;
		public String zip;
		public String country;
		public String phone;
		public String email;
	}

	public class options {
		public String label_format;
		public Integer date_advance;
	}

	public static EasyPostShipmentRequest parse(String json) {
		return (EasyPostShipmentRequest) System.JSON.deserialize(json, EasyPostShipmentRequest.class);
	}
}