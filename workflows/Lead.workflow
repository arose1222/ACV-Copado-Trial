<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Demo_Request_Leads_Unassigned_After_24_Hours</fullName>
        <description>Demo Request Leads Unassigned After 24 Hours</description>
        <protected>false</protected>
        <recipients>
            <recipient>dgaczewski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jroyce@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Demo_Request_24_Hour_Email</template>
    </alerts>
    <alerts>
        <fullName>Notify</fullName>
        <description>Notify VP of new lead assigned to TM</description>
        <protected>false</protected>
        <recipients>
            <recipient>mwaterman@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/VP_Email_when_Lead_is_assigned</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Duplicate_Checker_Record_Type_Fie</fullName>
        <field>Duplicate_Checker_Record_Type__c</field>
        <formula>RecordType.DeveloperName</formula>
        <name>Update Duplicate Checker Record Type Fie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Demo Request Reminder Email Handler</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>equals</operation>
            <value>Demo Request Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales</value>
        </criteriaItems>
        <description>workflow that evaluates Reminder_Email_Timer__c and sends an email when that time is reached as long as demo request is still in the queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Demo_Request_Leads_Unassigned_After_24_Hours</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lead.Reminder_Email_Timer__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Duplicate Checker Record Type Field</fullName>
        <actions>
            <name>Update_Duplicate_Checker_Record_Type_Fie</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Duplicate Checker Record Type field with the Record Types Developer Name</description>
        <formula>IsChanged(RecordTypeId) || ISBLANK(Duplicate_Checker_Record_Type__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
