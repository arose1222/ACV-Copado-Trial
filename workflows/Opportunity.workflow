<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Capital_Opportunity_Approved</fullName>
        <description>Capital Opportunity Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>emilywirth@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jameswilliams@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jgrzybowski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jsaskowski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jstephenson@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/Capital_Approved</template>
    </alerts>
    <alerts>
        <fullName>FastPass_Closed_Lost_IST_Notification</fullName>
        <description>FastPass Closed Lost IST Notification</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>FastPass_Emails/FastPass_Closed_Lost</template>
    </alerts>
    <alerts>
        <fullName>FastPass_Closed_Won_Payments_Notification</fullName>
        <description>FastPass Closed Won Payments Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jdee@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kschosek@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tjastrzemski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>FastPass_Emails/FastPass_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>New_IST_Opportunity_for_ACV_CApital</fullName>
        <description>New IST Opportunity for ACV CApital</description>
        <protected>false</protected>
        <recipients>
            <recipient>anardini@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>emilywirth@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jsaskowski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ndalessio@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ptalwar@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/IST_Created_an_Opportunity_Fo_rACV_Capital</template>
    </alerts>
    <alerts>
        <fullName>New_Opportunity_Assignment_Notification</fullName>
        <description>New Opportunity Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/New_Opportunity_assigned_to_IST</template>
    </alerts>
    <alerts>
        <fullName>Notify_A_Team_member_upon_Opportunity_Assignment</fullName>
        <description>Notify A-Team member upon Opportunity Assignment</description>
        <protected>false</protected>
        <recipients>
            <field>A_Team_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_A_Team_member_upon</template>
    </alerts>
    <alerts>
        <fullName>Notify_IST_Rep_when_FastPass_is_Granted_and_Active_in_Netsuite</fullName>
        <description>Notify IST Rep when FastPass is Granted and Active in Netsuite</description>
        <protected>false</protected>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>FastPass_Emails/FastPass_Closed_Won_IST_Notify</template>
    </alerts>
    <alerts>
        <fullName>Notify_TM_on_opportunity_inactivity_for_7_days</fullName>
        <description>Notify TM on opportunity inactivity for 7 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>scott@trueframe.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_TM_on_opportunity_inactivity_for_7_days</template>
    </alerts>
    <alerts>
        <fullName>Pat_Feeley_email_alert</fullName>
        <description>Pat Feeley email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>patrick@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/New_Opportunity_assigned_to_IST</template>
    </alerts>
    <alerts>
        <fullName>Stage_Change_ACV_Capital</fullName>
        <description>Stage Change ACV Capital</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/Stage_Change_ACV_Capital</template>
    </alerts>
    <alerts>
        <fullName>Stage_Change_ACV_Capital_Awaiting_Docs</fullName>
        <description>Stage Change ACV Capital Awaiting Docs</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/Stage_Change_ACV_Capital</template>
    </alerts>
    <alerts>
        <fullName>Stage_Change_ACV_Capital_Review</fullName>
        <description>Stage Change ACV Capital Review</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/Stage_Change_ACV_Capital</template>
    </alerts>
    <alerts>
        <fullName>Stage_Change_ACV_Capital_Underwriting</fullName>
        <description>Stage Change ACV Capital Underwriting</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/Stage_Change_ACV_Capital</template>
    </alerts>
    <alerts>
        <fullName>Stephanie_Email_alert</fullName>
        <description>Stephanie Email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sczechowski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/New_Opportunity_assigned_to_IST</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_move_To_Documents</fullName>
        <field>StageName</field>
        <literalValue>Legal Documentation</literalValue>
        <name>Approved move To Documents</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Blank_out_Auction_ID</fullName>
        <description>Blank out Auction_ID</description>
        <field>Auction_ID__c</field>
        <name>Blank out Auction_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_when_Closed_Lost</fullName>
        <field>Account_Status__c</field>
        <literalValue>Prospect Lost</literalValue>
        <name>Change Status when Closed Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Opp_Name</fullName>
        <description>provides naming convention for fastpass opportunity</description>
        <field>Name</field>
        <formula>&quot;FastPass - &quot; &amp; Account.Name</formula>
        <name>FastPass Opp Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Status_Additional_Documents_T</fullName>
        <description>FastPass Opportunity - Timestamp the status of &quot;Additional Documents&quot; was selected.</description>
        <field>Status_Additional_Documents_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>FastPass Status &quot;Additional Documents&quot; T</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Status_Closed_Timestamp</fullName>
        <description>FastPass Opportunity - Timestamp the status of &quot;Closed Won or Closed Lost&quot; was selected.</description>
        <field>Status_Closed_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>FastPass Status &quot;Closed&quot; Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Status_Documents_Received_Tim</fullName>
        <description>FastPass Opportunity - Timestamp the status of &quot;Documents Received&quot; was selected.</description>
        <field>Status_Documents_Received_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>FastPass Status &quot;Documents Received&quot; Tim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Status_New_Timestamp</fullName>
        <description>FastPass Opportunity - Timestamp the status of &quot;New&quot; was selected.</description>
        <field>Status_New_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>FastPass Status &quot;New&quot; Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FastPass_Status_Processing_Timestamp</fullName>
        <description>FastPass Opportunity - Timestamp the status of &quot;Processing&quot; was selected.</description>
        <field>Status_Processing_Timestamp__c</field>
        <formula>NOW()</formula>
        <name>FastPass Status &quot;Processing&quot; Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Auction_ID</fullName>
        <description>Populate Auction_ID</description>
        <field>Auction_ID__c</field>
        <formula>Auction__r.id__c</formula>
        <name>Populate Auction_ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_IST_Account_Owner_Email</fullName>
        <description>populates IST Account Owner Email</description>
        <field>IST_Account_Manager_Email__c</field>
        <formula>Account.IST_Account_Owner__r.Email</formula>
        <name>Populate IST Account Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Closed_Lost</fullName>
        <field>Closed_Lost_Reason__c</field>
        <literalValue>Not Credit Worthy</literalValue>
        <name>Reason Closed Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Referred_Date_Now</fullName>
        <field>Referred_Date__c</field>
        <formula>Now()</formula>
        <name>Referred Date Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Closed_Lost</fullName>
        <description>if rejected, the stage will be moved to closed lost</description>
        <field>StageName</field>
        <literalValue>Closed Lost</literalValue>
        <name>Rejected Closed Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opp_Name_for_ACV_Capital_Referrals</fullName>
        <description>Replaces user set opportunity name with Standard naming convention for the ACV Capital referrals record type.</description>
        <field>Name</field>
        <formula>&quot;ACV Capital - &quot; &amp; Account.Name</formula>
        <name>Set Opp Name for ACV Capital Referrals</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_New_on_Create</fullName>
        <description>Default the stage to new on create of opportunity</description>
        <field>StageName</field>
        <literalValue>New</literalValue>
        <name>Stage New on Create</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_Field</fullName>
        <description>Updates the amount field using values from the following group of fields
Base Seller Fee
VCI Fee
Pack Fee
Go Green Fee
Anticipated Yearly Volume</description>
        <field>Amount</field>
        <formula>(Base_Seller_Fee__c +  VCI_Fee__c + Pack_Fee__c + Go_Green_Fee__c)* Anticipated_Yearly_Volume__c</formula>
        <name>Update Amount Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Owner_to_Julie</fullName>
        <description>Sets Owner to Julie Saskowski</description>
        <field>OwnerId</field>
        <lookupValue>jsaskowski@acvauctions.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Opp Owner to Julie</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_account_status_when_closed_won</fullName>
        <field>Account_Status__c</field>
        <literalValue>Customer</literalValue>
        <name>Update account status when closed/won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ACV Capital - Change Opp Owner</fullName>
        <actions>
            <name>Update_Opp_Owner_to_Julie</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Referred</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACV Capital Referral</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>ACV Capital Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notContain</operation>
            <value>Inside Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.LastName</field>
            <operation>notEqual</operation>
            <value>Teluk</value>
        </criteriaItems>
        <description>Changes the Owner of the ACV Capital Opportunities upon status = &quot;Referred&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital - Set Naming Convention</fullName>
        <actions>
            <name>Set_Opp_Name_for_ACV_Capital_Referrals</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACV Capital Referral</value>
        </criteriaItems>
        <description>Set&apos;s the Opportunity Name correctly for ACV Capital Referrals</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Stage -Awaiting docs</fullName>
        <actions>
            <name>Stage_Change_ACV_Capital_Awaiting_Docs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify opp owner on ACV Capital referrals when hitting the following stages: Under Review, Underwriting, awaiting Docs and Closed</description>
        <formula>AND(RecordType.DeveloperName = &quot;ACV_Capital_Referral&quot;,  ISPICKVAL(StageName, &quot;Awaiting Documents&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Stage -Closed</fullName>
        <actions>
            <name>Stage_Change_ACV_Capital</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify opp owner on ACV Capital referrals when hitting the following stages: Under Review, Underwriting, awaiting Docs and Closed</description>
        <formula>AND(RecordType.DeveloperName = &quot;ACV_Capital_Referral&quot;,  ISPICKVAL(StageName, &quot;Closed Won&quot;)|| ISPICKVAL(StageName, &quot;Closed Lost&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Stage -Review</fullName>
        <actions>
            <name>Stage_Change_ACV_Capital_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify opp owner on ACV Capital referrals when hitting the following stages: Under Review, Underwriting, awaiting Docs and Closed</description>
        <formula>AND(RecordType.DeveloperName = &quot;ACV_Capital_Referral&quot;,  ISPICKVAL(StageName, &quot;Under Review&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Stage -Underwriting</fullName>
        <actions>
            <name>Stage_Change_ACV_Capital_Underwriting</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify opp owner on ACV Capital referrals when hitting the following stages: Under Review, Underwriting, awaiting Docs and Closed</description>
        <formula>AND(RecordType.DeveloperName = &quot;ACV_Capital_Referral&quot;,  ISPICKVAL(StageName, &quot;Underwriting&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Fleet%2FLease Amount Field</fullName>
        <actions>
            <name>Update_Amount_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Anticipated_Yearly_Volume__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow to auto calculate the Amount field on fleet lease opportunities using the following fields.
Base Seller Fee
VCI Fee
Pack Fee
Go Green Fee
Anticipated Yearly Volume</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Status when Closed Lost</fullName>
        <actions>
            <name>Change_Status_when_Closed_Lost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>ACV Capital Referral</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Closed Lost Notify IST</fullName>
        <actions>
            <name>FastPass_Closed_Lost_IST_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <description>Sends email to let IST know the account has been denied FastPass</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Closed Won Email</fullName>
        <actions>
            <name>FastPass_Closed_Won_Payments_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Used to send an email to the payments team when a Fastpass opps are closed won, giving them instructions to update netsuite</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Closed Won Notify IST</fullName>
        <actions>
            <name>Notify_IST_Rep_when_FastPass_is_Granted_and_Active_in_Netsuite</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Granted_FastPass__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Sends email to let IST know the account has been grated the fastpass access and has already been turned on in NetSuite.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Opp Name and Stage New</fullName>
        <actions>
            <name>FastPass_Opp_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stage_New_on_Create</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto populates the FastPass Opportunity Name and makes stage new on create</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Status %22Additional Documents%22 Timestamp</fullName>
        <actions>
            <name>FastPass_Status_Additional_Documents_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Additional Documents</value>
        </criteriaItems>
        <description>FastPass Opportunity - Timestamp the status of &quot;Additional Documents&quot; was selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Status %22Closed%22 Timestamp</fullName>
        <actions>
            <name>FastPass_Status_Closed_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <description>FastPass Opportunity - Timestamp the status of &quot;Closed&quot; was selected. (Closed Won or Closed Lost)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Status %22Documents Received%22 Timestamp</fullName>
        <actions>
            <name>FastPass_Status_Documents_Received_Tim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Documents Received</value>
        </criteriaItems>
        <description>FastPass Opportunity - Timestamp the status of &quot;Documents Received&quot; was selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Status %22New%22 Timestamp</fullName>
        <actions>
            <name>FastPass_Status_New_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>FastPASS Opportunity - Timestamp the status of &quot;New&quot; was selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FastPass Status %22Processing%22 Timestamp</fullName>
        <actions>
            <name>FastPass_Status_Processing_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Processing</value>
        </criteriaItems>
        <description>FastPass Opportunity - Timestamp the status of &quot;Processing&quot; was selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify ACV Capital when IST Creates a New Opportunity</fullName>
        <actions>
            <name>New_IST_Opportunity_for_ACV_CApital</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>ACV Capital Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACV Capital Referral</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Referral_Promotion__c</field>
            <operation>notEqual</operation>
            <value>Summer Savings</value>
        </criteriaItems>
        <description>This notifies Emily and Julie when an IST opportunity is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity is Closed Blank out Auction_ID</fullName>
        <actions>
            <name>Blank_out_Auction_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Deal Maker</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity is Closed Blank out Auction_ID</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity is Updated Check Auction_ID</fullName>
        <actions>
            <name>Populate_Auction_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Opportunity is Updated Check Auction_ID</description>
        <formula>(RecordType.Name = &apos;Deal Maker&apos;) &amp;&amp; (IsClosed = FALSE) &amp;&amp; (NOT(ISBLANK (Auction__c)) &amp;&amp; ISBLANK(Auction_ID__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate IST Account Owner Email</fullName>
        <actions>
            <name>Populate_IST_Account_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>FastPass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Populates the IST Account owner Email field once the FastPass Opp is closed won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Referred Date</fullName>
        <actions>
            <name>Referred_Date_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Referred</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update account status when closed%2Fwon</fullName>
        <actions>
            <name>Update_account_status_when_closed_won</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>ACV Capital Referral</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
