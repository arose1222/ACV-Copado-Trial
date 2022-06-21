<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Duplicate_Checker</fullName>
        <field>Duplicate_Checker__c</field>
        <formula>Private_Lane__c + Organization_Group__c</formula>
        <name>Update Duplicate Checker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Duplicate Checker Field</fullName>
        <actions>
            <name>Update_Duplicate_Checker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>updates the duplicate checker field on Private Lane Access</description>
        <formula>ISBLANK(Duplicate_Checker__c) &amp;&amp; NOT(ISBLANK(Private_Lane__c)) &amp;&amp; NOT(ISBLANK(Organization_Group__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
