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
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Assigned_Fee_Title_Late_Fee_Applied_1652107102601</template>
    </alerts>
</Workflow>
