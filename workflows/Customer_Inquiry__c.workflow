<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_CI_Owner_on_Status_Change</fullName>
        <description>Sends an email to the owner if a Customer Inquiry when that record is in the AM Follow Up status.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Notify_Owner_of_CI</template>
    </alerts>
    <alerts>
        <fullName>Notify_of_missing_consultant</fullName>
        <ccEmails>customersuccess@acvauctions.com</ccEmails>
        <description>Notify of missing consultant</description>
        <protected>false</protected>
        <recipients>
            <recipient>arichbart@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Notify_of_Needed_Consultant</template>
    </alerts>
    <alerts>
        <fullName>Notify_of_missing_specialist</fullName>
        <ccEmails>titles@acvauctions.com</ccEmails>
        <description>Notify of missing specialist</description>
        <protected>false</protected>
        <recipients>
            <recipient>arichbart@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Notify_of_Needed_Specialist</template>
    </alerts>
    <rules>
        <fullName>Need To Assign To Consultant</fullName>
        <actions>
            <name>Notify_of_missing_consultant</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Inquiry__c.Should_Assign_To__c</field>
            <operation>equals</operation>
            <value>Consultant</value>
        </criteriaItems>
        <description>Sends an email alerting users that this Customer Inquiry was created without being assigned.  It should have been assigned to the title consultant</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Need To Assign To Specialist</fullName>
        <actions>
            <name>Notify_of_missing_specialist</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Inquiry__c.Should_Assign_To__c</field>
            <operation>equals</operation>
            <value>Specialist</value>
        </criteriaItems>
        <description>Sends an email alerting users that this Customer Inquiry was created without being assigned.  It should have been assigned to the title specialist</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Inquiry Owner of Inquiry Resolved</fullName>
        <actions>
            <name>Email_CI_Owner_on_Status_Change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Inquiry__c.Status__c</field>
            <operation>equals</operation>
            <value>AM Follow Up</value>
        </criteriaItems>
        <description>Workflow to alert the Inquiry Owner that one of their CI&apos;s has been moved to the AM Follow Up status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
