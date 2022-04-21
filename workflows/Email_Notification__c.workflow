<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Request_Inspection_Fulfillment_Email</fullName>
        <description>Send Request Inspection Fulfillment Email</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Request_Inspection_Fulfillment_Email</template>
    </alerts>
    <alerts>
        <fullName>Send_Work_Order_Completed_Email</fullName>
        <description>Send Work Order Completed Email</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Work_Order_Completed_Email</template>
    </alerts>
    <rules>
        <fullName>Send Request Inspection Fulfillment Email</fullName>
        <actions>
            <name>Send_Request_Inspection_Fulfillment_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Email_Notification__c.User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Email_Notification__c.Send_Request_Inspection_Fullfillment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email based on record info when record is created or updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Work Order Completed Email</fullName>
        <actions>
            <name>Send_Work_Order_Completed_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Email_Notification__c.User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Email_Notification__c.Send_Work_Order_Completed_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email based on record info when record is created or updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
