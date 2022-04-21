<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Integration Results [UAT]</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Environment__c</field>
        <value xsi:type="xsd:string">UAT</value>
    </values>
    <values>
        <field>Operation__c</field>
        <value xsi:type="xsd:string">Delete</value>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">10.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT ID FROM Integration_Result__c WHERE Createddate != TODAY</value>
    </values>
</CustomMetadata>
