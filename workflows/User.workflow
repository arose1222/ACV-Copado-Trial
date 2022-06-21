<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Admin_Profile_Alert</fullName>
        <ccEmails>sf-infrastructure@acvauctions.com</ccEmails>
        <ccEmails>enterpriseapps_leads@acvauctions.com</ccEmails>
        <description>Admin Profile Alert</description>
        <protected>false</protected>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Admin_Profile_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Deactivated_Date_Field</fullName>
        <description>updates the deactivated date field on the user record</description>
        <field>Deactivated_Date__c</field>
        <formula>IF (IsActive=false, today(), null)</formula>
        <name>Update Deactivated Date Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Admin Profile Granted</fullName>
        <actions>
            <name>Admin_Profile_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule triggers whenever a user is given an admin profile</description>
        <formula>Profile.Name = &quot;System Administrator&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Deactivated Date</fullName>
        <actions>
            <name>Update_Deactivated_Date_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets date on user record when active is changed to false</description>
        <formula>ISCHANGED(IsActive)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
