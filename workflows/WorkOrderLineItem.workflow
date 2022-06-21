<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Completed_Date</fullName>
        <description>update &apos;completed_date__c&apos; field on work order line item</description>
        <field>Completed_Date__c</field>
        <formula>DATEVALUE( WorkOrder.Completed_Date_Time__c )</formula>
        <name>Update Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_To_Canceled</fullName>
        <field>Status</field>
        <literalValue>Canceled</literalValue>
        <name>Update Status To Canceled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Completed Date</fullName>
        <actions>
            <name>Update_Completed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>completed_date__c refers to when the corresponding service appointment related to the work order line item is set to status &apos;completed&apos;</description>
        <formula>NOT(ISBLANK( WorkOrder.Completed_Date_Time__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
