public class BusinessSearchRequest{
	public String name;	//Experian
	public String city;	//Costa Mesa
	public String state;	//CA
	public String subcode;	//0586548
	public String street;	//475 ANTON BLVD
	public String zip;	//92626
	public String phone;	//9495673800
	public String taxId;	//176970333
	public boolean geo;
	public String comments;	//testing
	public static BusinessSearchRequest parse(String json){
		return (BusinessSearchRequest) System.JSON.deserialize(json, BusinessSearchRequest.class);
	}
}