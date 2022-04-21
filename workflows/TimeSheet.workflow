<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_that_sends_to_Inspectors_when_their_Manager_approves_their_Time_shee</fullName>
        <description>Email Alert that sends to Inspectors when their Manager approves their Time sheet</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Time_Sheet_Approval</template>
    </alerts>
    <alerts>
        <fullName>Sends_an_email_alert_to_Time_Sheet_Owner_that_their_Time_Sheet_was_Approved</fullName>
        <description>Sends an email alert to Time Sheet Owner that their Time Sheet was Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Time_Sheet_Approval</template>
    </alerts>
    <alerts>
        <fullName>send_email_alerting_time_sheet_owner_of_rejection</fullName>
        <description>Sends Email Alerting Time Sheet Owner there Sheet was Rejected and Will need to be revisited</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Time_Sheet_Rejection_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Employee_Approval</fullName>
        <field>Employee_Approval_Submitted__c</field>
        <name>Clear Employee Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Employee_Approval</fullName>
        <field>Employee_Approval_Submitted__c</field>
        <formula>now()</formula>
        <name>Mark Employee Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_To_Submitted</fullName>
        <field>Status</field>
        <literalValue>Submitted</literalValue>
        <name>Update To Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
