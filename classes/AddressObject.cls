public class AddressObject {
    public String street;
    public String city;
    public String state;
    public String postalCode;
    public String country;
    public String location;
    
    public override String toString() {
        return this.street + ', ' + this.city + ', ' + this.state + ', ' + this.postalCode;
    }
}