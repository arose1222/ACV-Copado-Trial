<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>VCI_Appointment_Support_Alert</fullName>
        <description>Email alert triggered from the &apos;Begin Appointment Flow&apos;</description>
        <protected>false</protected>
        <recipients>
            <recipient>acvadmin@tractionondemand.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/VCI_Appointment_Support_Required</template>
    </alerts>
    <fieldUpdates>
        <fullName>FSL_Emergency_flag_True</fullName>
        <description>If a service appointment work type is Dealer or CPO (variety), then update the Emergency flag to True.</description>
        <field>FSL__Emergency__c</field>
        <literalValue>1</literalValue>
        <name>FSL Emergency flag True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FSL_Jeopardy_flag_True</fullName>
        <description>If a service appointment is pinned, and the work type is CPO (variety), and isn&apos;t a Scheduled status, then update the Jeopardy flag to True.</description>
        <field>FSL__InJeopardy__c</field>
        <literalValue>1</literalValue>
        <name>FSL Jeopardy flag True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Time</fullName>
        <field>SchedStartTime</field>
        <formula>EarliestStartTime</formula>
        <name>Set Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>FSL Emergency flag for Dealer or CPO work types</fullName>
        <actions>
            <name>FSL_Emergency_flag_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>ServiceAppointment.Work_Type_Name__c</field>
            <operation>equals</operation>
            <value>Dealer</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceAppointment.Work_Type_Name__c</field>
            <operation>contains</operation>
            <value>CPO</value>
        </criteriaItems>
        <description>If a service appointment work type is Dealer or CPO (variety), then update the Emergency flag to True.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FSL Jeopardy flag for CPO work types</fullName>
        <actions>
            <name>FSL_Jeopardy_flag_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>ServiceAppointment.Committed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceAppointment.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceAppointment.Work_Type_Name__c</field>
            <operation>contains</operation>
            <value>CPO</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceAppointment.Work_Type_Name__c</field>
            <operation>equals</operation>
            <value>GMFIA</value>
        </criteriaItems>
        <description>If a service appointment is pinned, and the work type is CPO (variety), and isn&apos;t a Scheduled status, then update the Jeopardy flag to True.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Scheduled Time</fullName>
        <actions>
            <name>Set_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ServiceAppointment.EarliestStartTime</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
