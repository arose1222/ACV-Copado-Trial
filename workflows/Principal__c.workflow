<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_Status_Pending_Credit_Consent</fullName>
        <description>Application Status - Pending Credit Consent</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Form/ACV_Application_Status_Reminder_Pending_Credit_Consent</template>
    </alerts>
    <alerts>
        <fullName>Application_Status_Reminder_Pending_Credit_Consent</fullName>
        <description>Application Status - Reminder Pending Credit Consent</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Form/ACV_Application_Status_Reminder_Pending_Credit_Consent</template>
    </alerts>
</Workflow>
