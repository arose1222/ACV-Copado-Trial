<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_TM_of_New_Work_Order</fullName>
        <description>Notify TM of New Work Order</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Work_Order_Needs_Assignment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Final_Audit_Score</fullName>
        <description>The value of this field is equivalent to &apos;Scoring Logic Summary&apos; on work order object.</description>
        <field>Final_Audit_Score__c</field>
        <formula>Scoring_Logic_Summary__c</formula>
        <name>Update &apos;Final Audit Score&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Work Order Assignment Notification</fullName>
        <actions>
            <name>Notify_TM_of_New_Work_Order</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This is intended to inform the TM that there is a new Work Order they need to assign out</description>
        <formula>AND(ISNEW(),  WorkType.Name = &apos;Asset Verification&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
