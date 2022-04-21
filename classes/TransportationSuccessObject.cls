public class TransportationSuccessObject {

	public class PickupLocation {
		public String id;
		public Integer version;
		public String createdDate;
		public String lastModifiedDate;
		public Integer dealershipId;
		public String addressName;
		public String addressLineOne;
		public String addressLineTwo;
		public String addressLineThree;
		public String addressLineFour;
		public String addressCity;
		public String addressRegion;
		public String addressPostalCode;
		public String addressCountry;
		public String contactName;
		public String contactPhone;
		public String contactEmail;
		public String inventoryId;
		public String notes;
	}

	public class Vehicle {
		public String id;
		public Integer version;
		public String createdDate;
		public String lastModifiedDate;
		public String vin;
		public Integer year;
		public String make;
		public String model;
		public String trim;
		public String className;
		public Boolean isOversize;
		public Boolean isInoperable;
		public String photoUrl;
	}

	public class Data {
		public String id;
		public Integer version;
		public String createdDate;
		public String lastModifiedDate;
		public PickupLocation pickupLocation;
		public PickupLocation deliveryLocation;
		public Vehicle vehicle;
		public Integer requestId;
		public String requestType;
		public String status;
		public Integer acvLegacyTransportId;
		public Integer acvAuctionId;
		public String notes;
		public Integer distance;
		public String priceCustomerPrePromotion;
		public String priceCustomerCharged;
		public String releaseSecretPhrase;
		public String releaseSlipUrl;
	}

	public Data data;

	
	public static TransportationSuccessObject parse(String json) {
		return (TransportationSuccessObject) System.JSON.deserialize(json, TransportationSuccessObject.class);
	}
}