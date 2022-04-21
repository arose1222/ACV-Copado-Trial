<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Create Complaint</label>
    <protected>false</protected>
    <values>
        <field>Bulk__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>EndPoint_URL__c</field>
        <value xsi:type="xsd:string">https://acv-api-prod.acvauctions.com/v2/arbitration/auction/:auction_id/complaint</value>
    </values>
    <values>
        <field>Integration_Method__c</field>
        <value xsi:type="xsd:string">POST</value>
    </values>
    <values>
        <field>OAuth__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>URL_Parameters__c</field>
        <value xsi:type="xsd:string">:auction_id=Auction_Number_Complaint__c</value>
    </values>
    <values>
        <field>Write_Back_Field__c</field>
        <value xsi:type="xsd:string">id.id__c</value>
    </values>
</CustomMetadata>
