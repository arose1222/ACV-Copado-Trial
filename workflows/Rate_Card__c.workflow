<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Rate_Card_Approval_Email</fullName>
        <description>Rate Card Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Rate_Card_Approval_Email</template>
    </alerts>
    <alerts>
        <fullName>Rate_Card_Rejection_Email</fullName>
        <description>Rate Card Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Rate_Card_Rejection_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_to_Draft</fullName>
        <description>Updates the Approval Status to Draft once rejected.</description>
        <field>Approval_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Approval Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_In_Review</fullName>
        <description>Updated the Approval Status to In Review once submitted.</description>
        <field>Approval_Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Approval Status to In Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Published</fullName>
        <description>Updates the Approval Status to Published once approved.</description>
        <field>Approval_Status__c</field>
        <literalValue>Published</literalValue>
        <name>Approval Status to Published</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
