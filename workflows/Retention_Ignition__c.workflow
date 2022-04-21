<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Potential_Monthly_Buy_Volume_Update</fullName>
        <description>Populates the &quot;Potential Monthly Buy Volume&quot; field (on the Account) from the &quot;Forecasted Cars This Month&quot; field (from the Retention &amp; Ignitions) when created or edited.</description>
        <field>Potential_Monthly_Buy_Volume__c</field>
        <formula>Forecasted_Cars_This_Month__c</formula>
        <name>Potential Monthly Buy Volume Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>AccountName__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Potential Monthly Buy Volume Update</fullName>
        <actions>
            <name>Potential_Monthly_Buy_Volume_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Retention_Ignition__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates the &quot;Potential Monthly Buy Volume&quot; field (on the Account) from the &quot;Forecasted Cars This Month&quot; field (from the Retention &amp; Ignitions) when created or edited.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
