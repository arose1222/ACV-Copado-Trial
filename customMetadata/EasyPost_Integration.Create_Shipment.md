<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Create Shipment</label>
    <protected>false</protected>
    <values>
        <field>EndPoint_URL__c</field>
        <value xsi:type="xsd:string">https://api.easypost.com/v2/shipments</value>
    </values>
    <values>
        <field>Integration_Method__c</field>
        <value xsi:type="xsd:string">POST</value>
    </values>
    <values>
        <field>URL_Parameters__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Write_Back_Field__c</field>
        <value xsi:type="xsd:string">:shipment_id=EasyPost_Shipment_Id__c,:id=EasyPost_Rate_ID__c</value>
    </values>
</CustomMetadata>
