<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FLODocs__Metric_Email_Alert</fullName>
        <description>Metric Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>FLODocs__Email_CC__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>FLODocs__Email_To__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__FLO_Email_Templates/FLODocs__Metric_Email</template>
    </alerts>
    <rules>
        <fullName>FLODocs__Metric Rule</fullName>
        <actions>
            <name>FLODocs__Metric_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FLODocs__Metric__c.FLODocs__Organization_Id__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
