<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Assigned_Fee_Title_Late_Fee_Email</fullName>
        <description>Assigned Fee Title Late Fee Email   Sent Via Flow Title Late Fee Applied Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Assigned_Fee_Title_Late_Fee_Applied_1652107102601</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Seller</fullName>
        <description>Email to Seller</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Territory_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Titles_Notification_Emails/Send_Title_Late_Fee_Email_To_Seller</template>
    </alerts>
    <fieldUpdates>
        <fullName>Reset_Email_Checkbox</fullName>
        <field>Send_Title_Late_Fee_Email_To_Seller__c</field>
        <literalValue>0</literalValue>
        <name>Reset Email Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Title Late Fee Email To Seller</fullName>
        <actions>
            <name>Email_to_Seller</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Email_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Assigned_Fee__c.Send_Title_Late_Fee_Email_To_Seller__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email to Seller when the Title is late.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
