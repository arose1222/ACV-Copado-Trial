<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Assigned_Fee_Title_Late_Fee_Email</fullName>
        <description>Assigned Fee Title Late Fee Email   Sent Via Flow Title Late Fee Applied Email</description>
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
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Assigned_Fee_Title_Late_Fee_Applied_1652107102601</template>
    </alerts>
    <alerts>
        <fullName>Title_Late_Fee_Issued</fullName>
        <description>Title Late Fee Issued</description>
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
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Inform_Seller_of_Title_Late_Fee</template>
    </alerts>
    <rules>
        <fullName>Send Title late Fee Start Email 1%2E0</fullName>
        <actions>
            <name>Assigned_Fee_Title_Late_Fee_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Assigned_Fee__c.Fee_Status__c</field>
            <operation>equals</operation>
            <value>Fee Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Fee__c.Name</field>
            <operation>equals</operation>
            <value>Title late Fee</value>
        </criteriaItems>
        <description>Sends title late fee initial email when the first fee is changed</description>
        <failedMigrationToolVersion>236.19.21</failedMigrationToolVersion>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
