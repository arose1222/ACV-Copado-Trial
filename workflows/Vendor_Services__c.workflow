<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_VenderServices_Name</fullName>
        <field>Name</field>
        <formula>Vendor_Name__r.Name  &amp; &apos; &apos;  &amp; Text(Service__c)</formula>
        <name>Set VenderServices Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set VenderServices Name</fullName>
        <actions>
            <name>Set_VenderServices_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISNULL(Vendor_Name__r.Name))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
