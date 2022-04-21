<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Complaint_Timestamp</fullName>
        <description>Stamps created date in Complaint date field</description>
        <field>Complaint_Created__c</field>
        <formula>now()</formula>
        <name>Complaint Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Description_Field</fullName>
        <description>New value fore removal until classes cleaned up</description>
        <field>description__c</field>
        <formula>&quot;This is a null value for removing field&quot;</formula>
        <name>Description Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason</fullName>
        <description>Update reason Field for removal of field before removing from apex classes</description>
        <field>complaint_type__c</field>
        <literalValue>Null Value</literalValue>
        <name>Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reason</fullName>
        <field>complaint_type__c</field>
        <literalValue>Title Discrepancy</literalValue>
        <name>Update Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Auto Fill Description and Reason</fullName>
        <actions>
            <name>Description_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Complaint__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>until the classes for these fields can be removed we will be auto populating</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Complate Created Timestamp</fullName>
        <actions>
            <name>Complaint_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Stamps the date on complaint when created and then used to measure days hours and minutes until resolution is entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
