<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_Buyer</fullName>
        <description>Email to Buyer</description>
        <protected>false</protected>
        <recipients>
            <field>Return_Postage_Label_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Titles_Notification_Emails/Shipping_Label_for_Problem_Title</template>
    </alerts>
    <fieldUpdates>
        <fullName>Reset_Email_Checkbox</fullName>
        <description>Reset the value of Send_Postage_Email_To_Buyer__c field to false so that the workflow is not trigger again.</description>
        <field>Send_Postage_Email_To_Buyer__c</field>
        <literalValue>0</literalValue>
        <name>Reset Email Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_QC_Status</fullName>
        <description>Updates the QC Status to closed when Problems Open = 0</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update QC Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>QC Status Update based on Open Problem</fullName>
        <actions>
            <name>Update_QC_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quality_Control__c.Problems_Open__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>When open Problem count = 0 mark the status as closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Shipping Label for Problem Title</fullName>
        <actions>
            <name>Email_to_Buyer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Email_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sends email notification to buyer, or floorplan that Return Postage Label to ACV is ready.</description>
        <formula>Send_Postage_Email_To_Buyer__c=true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
