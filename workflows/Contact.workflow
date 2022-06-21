<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACV_Auctions_Policy_Information</fullName>
        <description>ACV Auctions Policy Information</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Registration20/ACV_Auctions_Policy_Information_1624483838959</template>
    </alerts>
    <alerts>
        <fullName>ACV_Auctions_Policy_Information_Email_Alert_Delay</fullName>
        <description>ACV Auctions Policy Information Email Alert Delay</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>dealeronboarding@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Registration20/ACV_Auctions_Policy_Information_Delayed_1632365171852</template>
    </alerts>
    <alerts>
        <fullName>VCI_Notification_of_VL_Graduation</fullName>
        <description>VCI Notification of VL Graduation</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>acvarbitrations@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SFDX_Arbitration_Email_Templates/VL_Graduation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Prescreen_Type_to_None</fullName>
        <field>Prescreen_Type__c</field>
        <name>Set Prescreen Type to None</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Policy_Email_Status</fullName>
        <description>Updates Policy Email Status to &quot;Policy Email Sent&quot;</description>
        <field>Policy_Email_Status__c</field>
        <literalValue>Policy Email Sent</literalValue>
        <name>Update Policy Email Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Standard_Title</fullName>
        <description>Used to update the standard tile from the title picklist</description>
        <field>Title</field>
        <formula>TEXT(Title_Picklist__c)</formula>
        <name>Update Standard Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>10 Passed VL Prescereens</fullName>
        <actions>
            <name>VCI_Notification_of_VL_Graduation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Successful_Virtual_Lift_Prescreens__c</field>
            <operation>equals</operation>
            <value>10</value>
        </criteriaItems>
        <description>Triggers email when VCI passes 10 Prescreens</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cleared CR Review</fullName>
        <actions>
            <name>Set_Prescreen_Type_to_None</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.CR_Review__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When CR Review is changed from True to False so Prescreen Type is then also cleared out</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Organization Lead Converted Email</fullName>
        <actions>
            <name>ACV_Auctions_Policy_Information</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>Lead_Convert_Status__c = &quot;Converting&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Organization Lead Converted Policy Email With Delay</fullName>
        <actions>
            <name>ACV_Auctions_Policy_Information_Email_Alert_Delay</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Policy_Email_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Policy_Email_Status__c</field>
            <operation>equals</operation>
            <value>Send Policy Email</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Standard Title From Picklist</fullName>
        <actions>
            <name>Update_Standard_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the standard contact title field from the custom title picklist field, this will help keep other logic in line, SOT Change</description>
        <formula>OR( ISCHANGED( Title_Picklist__c ), IsNew() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
