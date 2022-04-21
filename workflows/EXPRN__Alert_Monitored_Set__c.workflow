<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EXPRN__AMS_Account_Unique</fullName>
        <field>EXPRN__AMS_Account_Unique__c</field>
        <formula>EXPRN__Alert_Monitored_Set_Name__c + EXPRN__Account__c</formula>
        <name>AMS Account Unique</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EXPRN__Unique AMS Account</fullName>
        <actions>
            <name>EXPRN__AMS_Account_Unique</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Add unique accounts to an AMS record</description>
        <formula>ISNEW() ||  ( IsChanged( EXPRN__Alert_Monitored_Set_Name__c ) ||    IsChanged( EXPRN__Account__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
