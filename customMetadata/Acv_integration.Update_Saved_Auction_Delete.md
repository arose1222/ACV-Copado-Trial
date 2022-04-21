<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Update Saved Auction Delete</label>
    <protected>false</protected>
    <values>
        <field>Bulk__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>EndPoint_URL__c</field>
        <value xsi:type="xsd:string">https://acv-api-prod.acvauctions.com/v2/saved_auctions/restore</value>
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
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Write_Back_Field__c</field>
        <value xsi:type="xsd:string">Send_to_ACV__c</value>
    </values>
</CustomMetadata>
