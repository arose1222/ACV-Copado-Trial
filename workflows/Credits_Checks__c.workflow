<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Credit_Check_Approval_Email</fullName>
        <description>Credit &amp; Check - Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Credit_Check_Approved_Credit_Notification</template>
    </alerts>
    <alerts>
        <fullName>Credit_Check_Done_Failed_Temp_Email</fullName>
        <description>Credit Check Done Failed Temp Emailed</description>
        <protected>false</protected>
        <recipients>
            <recipient>cwood@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dhaley@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sbostock@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Credit_Check_Done_Failed_Temp_Email</template>
    </alerts>
    <alerts>
        <fullName>Credit_Check_Rejection_Email</fullName>
        <description>Credit &amp; Check - Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Credit_Check_Rejected_Credit_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_ACV_User_Id</fullName>
        <description>Adds Approver&apos;s Id from Tools to ACV_User_Id field</description>
        <field>ACV_User_Id__c</field>
        <formula>$User.Id__c</formula>
        <name>Update ACV_User_Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_Approved</fullName>
        <description>Updates &apos;Amount_Approved__c&apos; field on Credits_Checks__c</description>
        <field>Amount_Approved__c</field>
        <formula>Amount_Requested__c</formula>
        <name>Update Amount Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Arb_Amount_Approved</fullName>
        <field>Arb_Amount_Approved__c</field>
        <formula>Total_Arb_Amount_Requested__c</formula>
        <name>Update Arb Amount Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Denial_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Denial Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Done Failed Email Alert</fullName>
        <actions>
            <name>Credit_Check_Done_Failed_Temp_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(Approval_Status__c) &amp;&amp; ISPICKVAL(Approval_Status__c,&apos;Done Failed&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
