<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Onboarding_Handoff_Alert</fullName>
        <description>Onboarding Handoff Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Handoff_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/New_Account_from_onboarding</template>
    </alerts>
    <alerts>
        <fullName>Send_Auction_Email</fullName>
        <description>Send Auction Email</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>IST_Account_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Auction_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date_Completed</fullName>
        <field>Date_Completed__c</field>
        <formula>Now()</formula>
        <name>Date Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_All_time_purchases</fullName>
        <field>All_time_purchases_number__c</field>
        <formula>Account_Name__r.Purchases_All_Time__c</formula>
        <name>Update All time purchases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_All_time_sold_value</fullName>
        <field>All_time_sold_Number__c</field>
        <formula>Account_Name__r.Wholesale_Units_Sold__c</formula>
        <name>Update All time sold value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Auction_Email_sent</fullName>
        <field>Auction_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Auction Email sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BDR_owner</fullName>
        <field>BDR_owner__c</field>
        <formula>Owner:User.Full_Name__c</formula>
        <name>Update BDR owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Joined</fullName>
        <field>Date_Joined_Date__c</field>
        <formula>Account_Name__r.Date_Joined__c</formula>
        <name>Update Date Joined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Delaership_Id</fullName>
        <field>Dealership_ID_Text__c</field>
        <formula>Account_Name__r.Dealership_ID__c</formula>
        <name>Update Delaership Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fast_Pass_Opt_in_field</fullName>
        <field>Fast_Pass_Opt_in_Text__c</field>
        <formula>Text( Account_Name__r.FastPass_Opt_In__c )</formula>
        <name>Update Fast Pass Opt-in field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Territory</fullName>
        <field>Territory_Text__c</field>
        <formula>Account_Name__r.Maps_Sales_Territory_Name__c</formula>
        <name>Update Territory</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Territory_Manager</fullName>
        <field>Territory_Manager_Text__c</field>
        <formula>Account_Name__r.Territory_Manager__c</formula>
        <name>Update Territory Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notify New Account Owner</fullName>
        <actions>
            <name>Onboarding_Handoff_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the new account owner once the onboarding process has been completed</description>
        <formula>(ISBLANK(PRIORVALUE(Handoff_To__c)) == TRUE &amp;&amp; ISBLANK(Handoff_To__c) == FALSE) || (ISBLANK(Handoff_To__c) != null &amp;&amp; PRIORVALUE(Handoff_To__c)!= Handoff_To__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Auction Email</fullName>
        <actions>
            <name>Send_Auction_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Auction_Email_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT( ISBLANK(Auction_ID__c ) ), !Auction_Email_Sent__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date Onboarding Completed</fullName>
        <actions>
            <name>Date_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Onboarding__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Onboarding from Account</fullName>
        <actions>
            <name>Update_All_time_purchases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_All_time_sold_value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_BDR_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Date_Joined</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Delaership_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Fast_Pass_Opt_in_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Territory</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Territory_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Onboarding__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Update Onboarding field values from Account record.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
