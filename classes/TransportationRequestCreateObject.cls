public class TransportationRequestCreateObject {
  //REQ "OUT_OF_APP"
  public String requestType;
  //REQ
  public Integer acvLegacyTransportId;
  public String acvAuctionId;
  public String notes;
  //REQ
  public Decimal priceCustomerPrePromotion;
  public Decimal priceCustomerCharged;
  //REQ
  public vehicle vehicle;
  //REQ
  public pickupLocation pickupLocation;
  //REQ
  public deliveryLocation deliveryLocation;
  public String releaseSecretPhrase;
  public class vehicle {
    //REQ
    public string vin;
    public Integer year;
    public String make;
    public String model;
    public String trim;
    public String className;
    public Boolean isOversize;
    public Boolean isInoperable;
    public String driveTrain;
  }

  public class pickupLocation {
    public Integer dealershipId;
    //REQ
    public String addressName;
    //REQ
    public String addressLineOne;
    public String addressLineTwo;
    public String addressLineThree;
    public String addressLineFour;
    //REQ
    public String addressCity;
    //REQ
    public String addressRegion;
    //REQ
    public String addressPostalCode;
    //REQ
    public String addressCountry;
    public String contactName;
    public String contactPhone;
    public String contactEmail;
    public String inventoryId;
    public String notes;
  }

  public class deliveryLocation {
    //REQ
    public Integer dealershipId;
    //REQ
    public String addressName;
    //REQ
    public String addressLineOne;
    public String addressLineTwo;
    public String addressLineThree;
    public String addressLineFour;
    //REQ
    public String addressCity;
    //REQ
    public String addressRegion;
    //REQ
    public String addressPostalCode;
    //REQ
    public String addressCountry;
    public String contactName;
    public String contactPhone;
    public String contactEmail;
    public String inventoryId;
    //notes from somewhere or manual?
    public String notes;
  }
}