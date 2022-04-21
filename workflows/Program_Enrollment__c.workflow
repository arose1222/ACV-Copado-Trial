<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Alert</fullName>
        <description>Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Dealership_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Acceptance_Email</template>
    </alerts>
    <alerts>
        <fullName>Dealer_Eligible_Notification_to_Sales_Contact</fullName>
        <description>Dealer Eligible Notification to Sales Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Dealer_Eligible_Notification</template>
    </alerts>
    <alerts>
        <fullName>Dealership_Enrollment_Approved_Email_Alert</fullName>
        <description>Dealership Enrollment Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Primary_Dealership_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IST_Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Program_Enrollment_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Dealership_Enrolment_Invitation_Alert</fullName>
        <description>Dealership Enrolment Invitation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Dealership_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Dealership_Enrollment_Invitation</template>
    </alerts>
    <alerts>
        <fullName>Enrollment_Confirmation_Email_Alert</fullName>
        <description>Enrollment Confirmation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Dealership_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Enrollment_Application_Confirmation_Email</template>
    </alerts>
    <alerts>
        <fullName>Invitation_Link_Expired_Email</fullName>
        <description>Invitation Link Expired Email</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Invitation_Link_Expired</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Alert</fullName>
        <description>Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Dealership_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Dealership_Program_Templates/Rejection_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_Pending_TM</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending TM Approval</literalValue>
        <name>Approval Status Pending TM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_RSD_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RSD Approved</literalValue>
        <name>Approval Status RSD Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_RSD_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>RSD Rejected</literalValue>
        <name>Approval Status RSD Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_TM_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>TM Approved</literalValue>
        <name>Approval Status TM Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_TM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>TM Rejected</literalValue>
        <name>Approval Status TM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Enrollment_under_review_by_TM</fullName>
        <field>Status__c</field>
        <literalValue>Under review by TM under review by RSD approved Rejected [with reasons] (do not call removes from eligibility)</literalValue>
        <name>Enrollment under review by TM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateUniqueProgAcc</fullName>
        <field>UniqueProgAcc__c</field>
        <formula>Account__c +&apos;-&apos;+ Program__c</formula>
        <name>UpdateUniqueProgAcc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invitation_Sent_Date_To_Today</fullName>
        <field>Invitation_Sent_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Invitation Sent Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Invitation Sent Date</fullName>
        <actions>
            <name>Update_Invitation_Sent_Date_To_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Enrollment__c.Enrollment_Invitation_Status__c</field>
            <operation>equals</operation>
            <value>Eligible</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update_UniqueProgAccField</fullName>
        <actions>
            <name>UpdateUniqueProgAcc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( ISNULL(Account__c )),NOT(ISNULL(Program__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
