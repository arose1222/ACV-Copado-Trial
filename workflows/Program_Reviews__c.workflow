<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateUniquePE</fullName>
        <field>UniquePE__c</field>
        <formula>Program_Enrollment__r.Account__c +&apos;-&apos;+ Program_Enrollment__r.Program__c +&apos;-&apos;+ Program_Enrollment__c</formula>
        <name>UpdateUniquePE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update_UniquePEfield</fullName>
        <actions>
            <name>UpdateUniquePE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( NOT( ISNULL( Program_Enrollment__r.Account__c )),NOT(ISNULL(Program_Enrollment__r.Program__c)),NOT(ISNULL( Program_Enrollment__c )), IsMonitoring__c =true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
