<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Last_Bid_Date</fullName>
        <field>Last_Bid_Date__c</field>
        <formula>Latest_Bid__c</formula>
        <name>Update Last Bid Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Account__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Bid</fullName>
        <actions>
            <name>Update_Last_Bid_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( Latest_Bid__c ), ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
