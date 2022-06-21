<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Integration_Error_Template</fullName>
        <ccEmails>SF-DevAlerts@acvauctions.com</ccEmails>
        <description>Integration Error Template</description>
        <protected>false</protected>
        <recipients>
            <recipient>huron@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Notifications/Integration_Result_Error</template>
    </alerts>
    <rules>
        <fullName>Integration Result-Error</fullName>
        <actions>
            <name>Integration_Error_Template</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Integration_Result__c.Status_Code__c</field>
            <operation>notEqual</operation>
            <value>200,201</value>
        </criteriaItems>
        <criteriaItems>
            <field>Integration_Result__c.Integration_Name__c</field>
            <operation>notEqual</operation>
            <value>TitlesAutomationAPI</value>
        </criteriaItems>
        <description>Rule will trigger an email notification to the SF-DevAlerts@acvauctions.com when status code != 200 or 201</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
