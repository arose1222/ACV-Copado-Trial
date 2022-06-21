<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_Status_Being_Reviewed</fullName>
        <description>Application Status - Being Reviewed</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Form/ACV_Application_Status_Being_reviewed</template>
    </alerts>
    <alerts>
        <fullName>Application_Status_Pending_more_information</fullName>
        <description>Application Status - Pending more information</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Form/ACV_Application_Status_Pending_more_information</template>
    </alerts>
    <alerts>
        <fullName>Application_Status_Reminder_Pending_more_information</fullName>
        <description>Application Status - Reminder Pending more information</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Application_Form/ACV_Application_Status_Reminder_Pending_more_information</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACV_Capital_Bank_statement</fullName>
        <field>Bank_Statement__c</field>
        <literalValue>Required</literalValue>
        <name>ACV Capital -Bank statement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Documents_required</fullName>
        <description>If Requested Credit Line &gt;$150000, then Required, else NA</description>
        <field>year_Tax_Return_for_Business__c</field>
        <literalValue>Required</literalValue>
        <name>ACV Capital -Documents required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Personal_Financial_doc</fullName>
        <field>Personal_Financial_Statement_PFS__c</field>
        <literalValue>Required</literalValue>
        <name>ACV Capital -Personal Financial doc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>acv_capital_interim</fullName>
        <field>Interim_Statement__c</field>
        <literalValue>Required</literalValue>
        <name>acv capital - interim statement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
