<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Update Adjustment</label>
    <protected>false</protected>
    <values>
        <field>Bulk__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>EndPoint_URL__c</field>
        <value xsi:type="xsd:string">https://prod-api.acvauctions.com/api/v1/auctions/:auction_id/arbitration/complaints/:complaint_id/adjustments/:adjustment_id</value>
    </values>
    <values>
        <field>Integration_Method__c</field>
        <value xsi:type="xsd:string">PUT</value>
    </values>
    <values>
        <field>OAuth__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>URL_Parameters__c</field>
        <value xsi:type="xsd:string">:auction_id=Auction_Number_Resolution__c,:complaint_id=Complaint_Number__c,:adjustment_id=id__c</value>
    </values>
    <values>
        <field>Write_Back_Field__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
