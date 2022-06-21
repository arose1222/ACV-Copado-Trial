<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Avoidable_Resolution_Notification</fullName>
        <ccEmails>fieldops@acvauctions.com</ccEmails>
        <description>Avoidable Resolution Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Territory_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>jguerra@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>acvarbitrations@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Avoidable_Resolution_Notification_VF</template>
    </alerts>
    <fieldUpdates>
        <fullName>Arb_Populate_TM_Email</fullName>
        <field>Territory_Manager_Email__c</field>
        <formula>Case__r.Seller_Dealership__r.Owner.Email</formula>
        <name>Arb: Populate TM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Checkbox_if_Fastlane</fullName>
        <description>The Fastlane checkbox on Arb Case will be marked as true</description>
        <field>Fastlane__c</field>
        <literalValue>1</literalValue>
        <name>Mark Checkbox if Fastlane</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Resolution_Created_Timstamp</fullName>
        <description>Stamps the date the resolution is created to claculate days, hours, min to close complaint</description>
        <field>Resolution_Created_Date__c</field>
        <formula>now()</formula>
        <name>Resolution Created Timstamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Parts_and_Labor_Cost_in_Amount</fullName>
        <field>Amount__c</field>
        <formula>Labor_Cost__c +  Parts_Cost__c</formula>
        <name>Stamp Parts and Labor Cost in Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCI_email</fullName>
        <field>VCI_Email__c</field>
        <formula>Case__r.Auction_Number__r.VCI__r.Email</formula>
        <name>VCI email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>lock_Resolution</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Locked_Resolution</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>lock Resolution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Add VCI email</fullName>
        <actions>
            <name>VCI_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Resolution__c.VCI_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Arb%3A Resolution TM Email Population</fullName>
        <actions>
            <name>Arb_Populate_TM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISBLANK(Territory_Manager_Email__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Arbitration%3A Parts and Labor with Estimate</fullName>
        <actions>
            <name>Stamp_Parts_and_Labor_Cost_in_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Resolution__c.Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>adds the parts and labor to fill in the amount of the resolution when estimate = yes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Avoidable Resolution Notification</fullName>
        <actions>
            <name>Avoidable_Resolution_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Complaint__c.avoidable__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>When the Avoidable flag is marked on a resolution we send an email to Craig Storm and Robert Reisch so that VCI&apos;s can be trained on how to avoid this in the future</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fastlane marked on Arb Case</fullName>
        <actions>
            <name>Mark_Checkbox_if_Fastlane</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Resolution__c.Fastlane__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>This workflow will check the fastlane checkbox on the Arb case if yes is selected in the Resolution.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lock Resolution</fullName>
        <actions>
            <name>lock_Resolution</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Resolution__c.Credit_Check_Created__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Lock resolution fields once credit/check created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Resolution created Date</fullName>
        <actions>
            <name>Resolution_Created_Timstamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Resolution__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
