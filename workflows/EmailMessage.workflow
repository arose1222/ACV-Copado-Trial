<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Stamp_Date_Time_Last_Email_Sent_on_Case</fullName>
        <description>Stamp Date/Time Last Email Sent on Case</description>
        <field>Date_Time_Last_Email_Sent__c</field>
        <formula>now()</formula>
        <name>Stamp Date/Time Last Email Sent on Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Stamp Date%2FTime Last Email Sent on Case</fullName>
        <actions>
            <name>Stamp_Date_Time_Last_Email_Sent_on_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <description>Stamp Date/Time Last Email Sent on Case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
