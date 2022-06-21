<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FLODocs__Error_Log_Alert_Email</fullName>
        <description>Error Log Alert Email</description>
        <protected>false</protected>
        <recipients>
            <field>FLODocs__Email_To__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__FLO_Email_Templates/FLODocs__Error_Log_Email</template>
    </alerts>
    <rules>
        <fullName>FLODocs__Error Log Rule</fullName>
        <actions>
            <name>FLODocs__Error_Log_Alert_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FLODocs__Error_Log__c.FLODocs__Org_ID__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
