<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>QC Title</label>
    <protected>false</protected>
    <values>
        <field>Action_Type__c</field>
        <value xsi:type="xsd:string">SOQL</value>
    </values>
    <values>
        <field>Action__c</field>
        <value xsi:type="xsd:string">SELECT Case__r.Odometer_Reading__c, Case__r.Payment_Status__c, Case__r.Payment_Method__c, Case__r.Auction_End__c, Case__r.ACV_Condition_Report__c, Case__r.Seller_State__c, Case__r.Title_Address__c,  Case__r.Account.BillingStreet, Case__r.Account.BillingCity, Case__r.Account.BillingState, Case__r.Account.BillingPostalCode, Case__r.Seller_Title_Clerk_Email__c, Case__r.Seller_Dealership__r.BillingStreet, Case__r.Seller_Dealership__r.BillingCity, Case__r.Seller_Dealership__r.BillingState, Case__r.Seller_Dealership__r.BillingPostalCode, Case__r.Seller_Contact__r.Name, Case__r.Seller_Contact_Email__c, Case__r.Seller_Contact_Phone__c, Case__r.Contact.Name, Case__r.ContactEmail, Case__r.ContactPhone FROM Quality_Control__c  WHERE Id = &apos;:id:&apos;</value>
    </values>
    <values>
        <field>Fields_Display_Order__c</field>
        <value xsi:type="xsd:string">Odometer=Case__r.Odometer_Reading__c, Payment Status=Case__r.Payment_Status__c, Payment Method=Case__r.Payment_Method__c, Auction End Date=Case__r.Auction_End__c, ACV Condition Report=Case__r.ACV_Condition_Report__c, Seller State=Case__r.Seller_State__c, Title Address=Case__r.Title_Address__c,  Buyer Billing Street=Case__r.Account.BillingStreet, Buyer Billing City=Case__r.Account.BillingCity, Buyer Billing State=Case__r.Account.BillingState, Buyer Billing Zipcode=Case__r.Account.BillingPostalCode, Seller Billing Street=Case__r.Seller_Dealership__r.BillingStreet, Seller Billing City=Case__r.Seller_Dealership__r.BillingCity, Seller Billing State=Case__r.Seller_Dealership__r.BillingState, Seller Billing Zipcode=Case__r.Seller_Dealership__r.BillingPostalCode, Seller Title Clerk Email=Case__r.Seller_Title_Clerk_Email__c, Seller Contact Name=Case__r.Seller_Contact__r.Name, Seller Contact Email=Case__r.Seller_Contact_Email__c, Seller Contact Phone=Case__r.Seller_Contact_Phone__c, Buyer Contact Name=Case__r.Contact.Name, Buyer Contact Email=Case__r.ContactEmail, Buyer Contact Phone=Case__r.ContactPhone</value>
    </values>
</CustomMetadata>
