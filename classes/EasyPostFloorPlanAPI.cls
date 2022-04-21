@RestResource(urlMapping='/EasyPostAddress/*')
global class EasyPostFloorPlanAPI {
    /*
    * generateLabel
    *   GIVEN a Case with an Account
    *   AND Account has a valid address
    *   AND Case is of the (Record)Type of Title
    *   WHEN the EasyPost Post API is called
    *   THEN A label is generated for the title case and returned as part of the API with a link
    *
    * @param auctionNumber
    */
    @HTTPPost
    global static void generateLabel( String auctionNumber, String userEmail, AddressStruct mailAddress ) {
        EasyPostAPI.acctAddress = new EasyPostComponentController.addressWrapper();
        EasyPostAPI.acctAddress.name = mailAddress.addressName;
        EasyPostAPI.acctAddress.street = mailAddress.street;
        EasyPostAPI.acctAddress.city = mailAddress.city;
        EasyPostAPI.acctAddress.state = mailAddress.state;
        EasyPostAPI.acctAddress.country = mailAddress.country;
        EasyPostAPI.acctAddress.zip = mailAddress.postalCode;

        if ( mailAddress != null && mailAddress.street != null && mailAddress.city != null && mailAddress.state != null && mailAddress.country != null && mailAddress.postalCode != null ) {
            EasyPostAPI.generateEasyPost( auctionNumber, userEmail );
        } else {
            EasyPostAPI.EasyPostResponse response = new EasyPostAPI.EasyPostResponse( auctionNumber, userEmail, 'One of the required Address parameters is missing: street, city, state, country, postalCode' );
            response.addAddress( EasyPostAPI.acctAddress );
            EasyPostAPI.processResponse( 400, response, null );
        }
    }

    global class AddressStruct {
        public String addressName;
        public String street; 
        public String city;
        public String state;
        public String country;
        public String postalCode;
    }
}