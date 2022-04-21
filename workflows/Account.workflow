<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACV_Capital_Account_Blacklisted_Alert</fullName>
        <ccEmails>acvadvance@acvauctions.com</ccEmails>
        <description>ACV Capital Account Blacklisted Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>jbartz@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Account_Blacklisted_Alert</template>
    </alerts>
    <alerts>
        <fullName>ACV_Capital_Address_Change_Alert</fullName>
        <ccEmails>capitaltitlesupport@acvauctions.com</ccEmails>
        <description>ACV Capital Address Change Alert</description>
        <protected>false</protected>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Title_Address_Change</template>
    </alerts>
    <alerts>
        <fullName>ACV_Capital_Welcome_Email_Orange_Elite_2</fullName>
        <description>ACV Capital Welcome Email - Orange Elite 2</description>
        <protected>false</protected>
        <recipients>
            <field>ACV_Capital_Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ACV_Capital_Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>capitalconcierge@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACVCapital/ACV_Capital_Welcome_Orange_Elite_1635868761239</template>
    </alerts>
    <alerts>
        <fullName>Blitz_Team_Deactivate</fullName>
        <description>Blitz Team Deactivate</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Blitz_Trade_Show_Now_Inactive</template>
    </alerts>
    <alerts>
        <fullName>Documents_Received_from_IST</fullName>
        <ccEmails>agoetz@insidesalesteam.com</ccEmails>
        <description>Documents Received from IST</description>
        <protected>false</protected>
        <recipients>
            <recipient>joe@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kdamian@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kristyn@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/ContactFollowUpSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Email_IST_To_Consider_Activating_Doc_Compliant_Dealer</fullName>
        <description>Email IST To Consider Activating Doc Compliant Dealer</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Compliant_Dealer_Is_Inactive</template>
    </alerts>
    <alerts>
        <fullName>FastPass_Welcome_Email</fullName>
        <description>FastPass Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACVCapital/Fastpass_Welcome_Email_1648059673344</template>
    </alerts>
    <alerts>
        <fullName>Inform_TM_their_dealer_is_enrolled_in_Late_Fee_Program</fullName>
        <description>Inform TM their dealer is enrolled in Late Fee Program</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Late_Fee_Enrollment</template>
    </alerts>
    <alerts>
        <fullName>New_WI_Dealer_Email</fullName>
        <ccEmails>bizops@acvauctions.com</ccEmails>
        <description>New WI Dealer Email</description>
        <protected>false</protected>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/WI_Dealer_ID</template>
    </alerts>
    <alerts>
        <fullName>New_West_Dealer_Email</fullName>
        <ccEmails>bizops@acvauctions.com</ccEmails>
        <description>New West Dealer Email</description>
        <protected>false</protected>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/West_Dealer_ID</template>
    </alerts>
    <alerts>
        <fullName>Notify_AM_upon_Lead_Conversion</fullName>
        <description>Notify AM upon Lead Conversion</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_AM_upon_Lead_Conversion</template>
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
        <fullName>Project_Butter_Intro</fullName>
        <description>Project Butter Intro</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Project_Butter_Intro_Email</template>
    </alerts>
    <alerts>
        <fullName>Reactivation_Request_Approved_Alert</fullName>
        <description>Reactivation Request: Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/EmailTemplate</template>
    </alerts>
    <alerts>
        <fullName>Reactivation_Request_Rejected_Alert</fullName>
        <description>Reactivation Request: Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Reactivation_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Stephanie_email_alert</fullName>
        <description>Stephanie email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sczechowski@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/New_Opportunity_assigned_to_IST</template>
    </alerts>
    <alerts>
        <fullName>This_alert_informs_the_dealership_s_TM_that_a_first_purchase_has_been_made</fullName>
        <description>This alert informs the dealership&apos;s TM that a first purchase has been made.</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Notifications/First_Time_Buyer_Notification</template>
    </alerts>
    <alerts>
        <fullName>Title_Hold_Release_for_Dealer_Docs</fullName>
        <ccEmails>cmaue@acvauctions.com</ccEmails>
        <ccEmails>dquinlivan@acvauctions.com</ccEmails>
        <ccEmails>mhaley@acvauctions.com</ccEmails>
        <description>Title Hold Release for Dealer Docs</description>
        <protected>false</protected>
        <recipients>
            <recipient>ograves@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Relese_Title_Hold_Dealer_Docs</template>
    </alerts>
    <alerts>
        <fullName>VP_Email_Loyal_to_trying</fullName>
        <description>VP Email Loyal to trying</description>
        <protected>false</protected>
        <recipients>
            <recipient>mwaterman@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/VP_Email_Loyal_to_Trying</template>
    </alerts>
    <alerts>
        <fullName>notify_IST_that_Blits_Trade_Dealer_needs_to_be_Deactivated_due_to_dealer_Docs</fullName>
        <description>notify IST that Blits/Trade Dealer needs to be Deactivated due to dealer Docs</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Blitz_Trade_Show_Now_Inactive</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACV_Capital_Preferred_Buyer</fullName>
        <description>Marks Preferred Buyer as True when Won Oppty is greater than 0</description>
        <field>Preferred_buyer__c</field>
        <literalValue>1</literalValue>
        <name>ACV Capital - Preferred Buyer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Name_DBA_Trade_Name</fullName>
        <field>Name</field>
        <formula>dba_trade_name__c</formula>
        <name>Account Name = DBA Trade Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Do_not_Send_Titles</fullName>
        <field>Date_Do_Not_Send_Titles__c</field>
        <name>Clear Do not Send Titles</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_back_in_good_Standing</fullName>
        <description>Clear back in good standing to allow the new date stamp</description>
        <field>Date_Back_in_Good_Standing__c</field>
        <name>Clear back in good Standing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_Do_Not_Send_Titles</fullName>
        <field>Date_Do_Not_Send_Titles__c</field>
        <formula>Now()</formula>
        <name>Date Stamp Do Not Send Titles</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Dealer_Type_Commercial_Sales</fullName>
        <description>Auto populates commercial as dealer type when Major Accounts CSM creates an Account</description>
        <field>Dealer_Type__c</field>
        <literalValue>5</literalValue>
        <name>Dealer Type Commercial Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_Accepted</fullName>
        <field>Document_Status__c</field>
        <literalValue>Reviewed Accepted</literalValue>
        <name>Document Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Check_isInternational_checkbox</fullName>
        <description>Checks isInternational checkbox on Account</description>
        <field>EXPRN__isInternational__c</field>
        <literalValue>1</literalValue>
        <name>Check isInternational checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Unique_Account_ID</fullName>
        <field>EXPRN__Unique_ID__c</field>
        <formula>EXPRN__Account_Number__c</formula>
        <name>Unique Account ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Unique_Business_ID</fullName>
        <field>EXPRN__Unique_ID__c</field>
        <formula>EXPRN__BIN_formula__c</formula>
        <name>Unique Business ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Unique_Int_Business_ID</fullName>
        <field>EXPRN__Unique_ID__c</field>
        <name>Unique Int Business ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_Account_Number</fullName>
        <description>Updates the Account Number with the Account ID if the user doesn&apos;t populate the Account Number field</description>
        <field>EXPRN__Account_Number__c</field>
        <formula>UPPER(Id)</formula>
        <name>Update Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_Bin_Response_Code</fullName>
        <description>Update Bin response code</description>
        <field>EXPRN__BIN_Response_Code__c</field>
        <literalValue>1</literalValue>
        <name>Update Bin Response Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_Bin_Status_Code</fullName>
        <description>Update bin status code field</description>
        <field>EXPRN__BIN_Status_Code__c</field>
        <literalValue>C</literalValue>
        <name>Update Bin Status Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lot_Sweep_Join_Date_Stamp</fullName>
        <field>Lot_Sweep_Join_Date__c</field>
        <formula>now()</formula>
        <name>Lot Sweep Join Date Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Inactive_Reason_Blank</fullName>
        <description>make inactive reason field blank when active is true</description>
        <field>Inactive_Sub_Status__c</field>
        <name>Make Inactive Reason Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Netsuite_ID</fullName>
        <description>Add a v to the dealer ID for standard accounts and populate that value in the netsuite ID field</description>
        <field>Netsuite_ID__c</field>
        <formula>&quot;V&quot;+Dealership_ID__c</formula>
        <name>Populate Netsuite ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prior_Action_Update</fullName>
        <description>Populates the Prior Action field from the previous value of the Next Action field when updated.</description>
        <field>Prior_Action__c</field>
        <formula>Text(PriorValue(Next_Action__c))</formula>
        <name>Prior Action Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Registration_Status</fullName>
        <field>Registration_Status__c</field>
        <literalValue>Step 3 – Active: Documents Approved</literalValue>
        <name>Registration Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Timestamp_Doc_Compliance</fullName>
        <field>Date_Time_Compliant__c</field>
        <name>Remove Timestamp Doc Compliance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Standard_Record_Type</fullName>
        <description>Sets the Account record type to Standard (Sales)</description>
        <field>RecordTypeId</field>
        <lookupValue>Standard</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Standard Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Transporters_Record_Type</fullName>
        <description>Sets the Account record type to Transporters</description>
        <field>RecordTypeId</field>
        <lookupValue>Transporters</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Transporters Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Compliant_Date</fullName>
        <field>Date_Time_Compliant__c</field>
        <formula>Now()</formula>
        <name>Stamp Compliant Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Date_back_in_good_Standing</fullName>
        <field>Date_Back_in_Good_Standing__c</field>
        <formula>now()</formula>
        <name>Stamp Date back in good Standing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Lot_Sweep_End_Date</fullName>
        <field>Lot_Sweep_End_Date__c</field>
        <formula>now()</formula>
        <name>Stamp Lot Sweep End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Title_Hold_Update</fullName>
        <description>Updates title hold to back in good standing</description>
        <field>Title_Hold__c</field>
        <literalValue>Back in good standing</literalValue>
        <name>Title Hold Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Name_Legal_DBA</fullName>
        <description>Update the Account name based on Legal Name/DBA Trade Name. If DBA Trade Name is not blank Account Name = DBA Trade Name else if Legal Name is not blank Account Name = Legal Name else Name = Account Id</description>
        <field>Name</field>
        <formula>IF(NOT(ISBLANK(dba_trade_name__c)),dba_trade_name__c,
IF(NOT(ISBLANK(legal_name__c)),legal_name__c,
Id))</formula>
        <name>Update Account Name Legal/DBA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Carrier_Status</fullName>
        <description>Updates Carrier status to &quot;Inactive&quot;</description>
        <field>Carrier_Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Update Carrier Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Compliant_Resale_Certificate</fullName>
        <description>There is a field on Account, Compliant Resale Certificate. If the Billing State on the Account = NH, DE, AK, MT or OR, Compliant Resale Certificate should always = True.</description>
        <field>Compliant_Resale_Certificate__c</field>
        <literalValue>1</literalValue>
        <name>Update Compliant Resale Certificate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reviewed_By_Compliance_Flag</fullName>
        <field>Reviewed_By_Compliance__c</field>
        <literalValue>0</literalValue>
        <name>Update Reviewed By Compliance Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>loyal_checkbox</fullName>
        <description>puts a check in the checkbox for the Loyal field</description>
        <field>Loyal_Status__c</field>
        <literalValue>1</literalValue>
        <name>loyal checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>1-Deactivate for Blitz%2FTrade Acception</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Blitz_Trade_Show_Sign_Up__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealer_Doc_Compliance__c</field>
            <operation>notEqual</operation>
            <value>Compliant</value>
        </criteriaItems>
        <description>Sends the email after 48 hours notifying the IST account manager to deactivate in tools.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>notify_IST_that_Blits_Trade_Dealer_needs_to_be_Deactivated_due_to_dealer_Docs</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ACV Capital Account Blacklisted Alert</fullName>
        <actions>
            <name>ACV_Capital_Account_Blacklisted_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ACV_Capital_Customer__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Inactive_Sub_Status__c</field>
            <operation>equals</operation>
            <value>5</value>
        </criteriaItems>
        <description>Email Notification to named ACV Capital users when a Dealer is Blacklisted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Address Change Alert</fullName>
        <actions>
            <name>ACV_Capital_Address_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alerts Capital users when ACV Capital Title Email Address Changes</description>
        <formula>AND( OR( AND( ISCHANGED(BillingAddress),  Title_Mailing_Street__c =NULL), ISCHANGED(Title_Address__c)),   ACV_Capital_Customer__c  &lt;&gt;0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Relationship - Customer</fullName>
        <actions>
            <name>ACV_Capital_Preferred_Buyer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(ACV_Capital_Customer__c )&amp;&amp; ACV_Capital_Customer__c &lt;&gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Relationship - Prospect</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Open_ACV_Capital_Opptys__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ACV_Capital_Customer__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account Needs Legal Review</fullName>
        <actions>
            <name>Update_Reviewed_By_Compliance_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the account&apos;s Documentation date or check boxes are updated we need legal to review the account</description>
        <formula>IF(  Reviewed_By_Compliance__c == TRUE &amp;&amp;(ISCHANGED(Document_Resale_Cert__c) || ISCHANGED(Document_Resale_Cert_Expires__c) ||  ISCHANGED(Document_Dealer_Cert__c)  || ISCHANGED(Document_Dealer_Cert_Expires__c)) , TRUE, FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Date Fields for Title Hold when moving from back in good standing</fullName>
        <actions>
            <name>Clear_Do_not_Send_Titles</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_back_in_good_Standing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Date_Do_Not_Send_Titles__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Back_in_Good_Standing__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Title_Hold__c</field>
            <operation>equals</operation>
            <value>Do Not Send Titles</value>
        </criteriaItems>
        <description>When the Title hold is mared as back in good standing and then is marked as Do not Send Titles the date time fields are null  to be replaced with the most recent information</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Inactive Reason when Account Reactivated</fullName>
        <actions>
            <name>Make_Inactive_Reason_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Inactive_Sub_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will clear out the inactive Reason field when an inactive field is reactivated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Commercial Sales Dealer Type</fullName>
        <actions>
            <name>Dealer_Type_Commercial_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Major Accounts CSM</value>
        </criteriaItems>
        <description>This automatically populated Dealer Type as Commercial when Major Accounts CSM creates an account.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Compliant Dealer Is Inactive</fullName>
        <actions>
            <name>Email_IST_To_Consider_Activating_Doc_Compliant_Dealer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealer_Doc_Compliance__c</field>
            <operation>equals</operation>
            <value>Compliant</value>
        </criteriaItems>
        <description>This rule sends an email to IST to let them know their inactive dealer is now doc compliant. (It no longer tells them to activate the account in tools - Kendall, 7/7/2020</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compliant Resale Certificate</fullName>
        <actions>
            <name>Update_Compliant_Resale_Certificate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>NH</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>DE</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>AK</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>MT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>OR</value>
        </criteriaItems>
        <description>There is a field on Account, Compliant Resale Certificate. If the Billing State on the Account = NH, DE, AK, MT or OR, Compliant Resale Certificate should always = True.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date Stamp back in Good Standing</fullName>
        <actions>
            <name>Stamp_Date_back_in_good_Standing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Title_Hold__c</field>
            <operation>equals</operation>
            <value>Back in good standing</value>
        </criteriaItems>
        <description>Stamps the date and time when title hold is back in good standing</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Doc Compliant Timestamp</fullName>
        <actions>
            <name>Stamp_Compliant_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Dealer_Doc_Compliance__c</field>
            <operation>equals</operation>
            <value>Compliant</value>
        </criteriaItems>
        <description>Stamps the Account with a date when the Doc Compliance field moves to compliant</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Unique Account ID</fullName>
        <actions>
            <name>EXPRN__Unique_Account_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Evaluate the rule when a record is created, and every time it’s edited</description>
        <formula>NOT(ISBLANK(EXPRN__Account_Number__c) )  &amp;&amp;  (  ISCHANGED( EXPRN__Account_Number__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Unique Business ID</fullName>
        <actions>
            <name>EXPRN__Unique_Business_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Evaluate the rule when a record is created, and every time it’s edited</description>
        <formula>NOT(ISBLANK(EXPRN__BIN_formula__c) )  &amp;&amp;  (  ISCHANGED( EXPRN__BIN_formula__c)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Unique Int Business ID</fullName>
        <active>false</active>
        <description>Evaluate the rule when a record is created, and every time it’s edited</description>
        <formula>Name  &lt;&gt; Null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update Account Number on Account and Business</fullName>
        <actions>
            <name>EXPRN__Update_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the Account Number with Account ID, if the user doesn&apos;t give any Account Number</description>
        <formula>ISNULL(EXPRN__Account_Number__c ) || ISBLANK(EXPRN__Account_Number__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update Bin Status Code</fullName>
        <actions>
            <name>EXPRN__Update_Bin_Response_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXPRN__Update_Bin_Status_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Bin status code whenever an Account record is associated with business.</description>
        <formula>(ISPICKVAL( EXPRN__BIN_Status_Code__c , &apos;N&apos;) ||ISPICKVAL(EXPRN__BIN_Response_Code__c , &apos;-1&apos;)) &amp;&amp;  !(ISNULL(EXPRN__BIN_formula__c) || ISBLANK( EXPRN__BIN_formula__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update isInternational checkbox on Account</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>equals</operation>
            <value>Null</value>
        </criteriaItems>
        <description>Checks isInternational checkbox on Account if the account is an iinternational one</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Expire Transporter Accounts</fullName>
        <actions>
            <name>Update_Carrier_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Transporter Accounts will change carrier status to &quot;Inactive&quot; when their insurance expires</description>
        <formula>Insurance_Expiration_Date__c&lt;=TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inform TM of First-Time Buyer</fullName>
        <actions>
            <name>This_alert_informs_the_dealership_s_TM_that_a_first_purchase_has_been_made</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule looks to the Date of First Purchase field for notification to TM that a dealership has made their first purchase.</description>
        <formula>isChanged(Date_of_First_Buy__c) &amp;&amp; NOT(ISBLANK(Date_of_First_Buy__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Record Type Conversion-Sales</fullName>
        <actions>
            <name>Set_Standard_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_type_Conversion__c</field>
            <operation>equals</operation>
            <value>Sales</value>
        </criteriaItems>
        <description>Used for setting the correct record type id on the account upon lead conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Record Type Conversion-Transportation</fullName>
        <actions>
            <name>Set_Transporters_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_type_Conversion__c</field>
            <operation>equals</operation>
            <value>Transportation</value>
        </criteriaItems>
        <description>Used for setting the correct record type id on the account upon lead conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lot Sweep Join Date Stamp</fullName>
        <actions>
            <name>Lot_Sweep_Join_Date_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Lot_Sweep_Participant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Stamps the date that Lot Sweep Participant = True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lot Sweep Participant from True to False</fullName>
        <actions>
            <name>Stamp_Lot_Sweep_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Lot_Sweep_Join_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Lot_Sweep_Participant__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New WI dealer</fullName>
        <actions>
            <name>New_WI_Dealer_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.BillingState</field>
            <operation>equals</operation>
            <value>WI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow for when new WI dealers are created to notify biz ops</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New West Franchise Dealer</fullName>
        <actions>
            <name>New_West_Dealer_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 9 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Mountain West</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>North</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Northern California</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Northwest</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Southern California</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Texas East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Sales_Region_Formula__c</field>
            <operation>equals</operation>
            <value>Texas West</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealer_Type__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Workflow for when new franchise dealers in the West are created to notify biz ops
(Deactivated 2/8/2022 per Kyle Holmberg&apos;s comment here: https://acvauctions.lightning.force.com/lightning/r/Salesforce_Request__c/a3C5b000000InqCEAS/view)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Netsuite ID</fullName>
        <actions>
            <name>Populate_Netsuite_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Netsuite_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populate the netsuite ID on Standard accounts with the dealer ID with a V in front of the number</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prior Action Update</fullName>
        <actions>
            <name>Prior_Action_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Prior Action field with the previous value of the Action Needed field.</description>
        <formula>ISCHANGED(Next_Action__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project Butter Intro Email</fullName>
        <actions>
            <name>Project_Butter_Intro</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.IST_Account_Owner__c</field>
            <operation>equals</operation>
            <value>Nicole Klonowski,Corey Guetti,Jake Murray,Jenna Roessler,Lee Lomenzo,Krista Glownia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Time_Compliant__c</field>
            <operation>greaterThan</operation>
            <value>9/2/2020</value>
        </criteriaItems>
        <description>Used to introduce new account manager with project butter</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Relese Dealer Doc Hold</fullName>
        <actions>
            <name>Title_Hold_Release_for_Dealer_Docs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Dealer_Doc_Compliance__c</field>
            <operation>equals</operation>
            <value>Compliant</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Doc_Title_Hold__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Lets titles know that we can release titles held for dealer docs.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Account Name</fullName>
        <actions>
            <name>Update_Account_Name_Legal_DBA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the account name field based on the Legal Name and DBA Trade Name. Use DBA Trade Name unless blank, then use Legal Name.</description>
        <formula>ISCHANGED( dba_trade_name__c ) || ISCHANGED( legal_name__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Do Not Send Title Date</fullName>
        <actions>
            <name>Date_Stamp_Do_Not_Send_Titles</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Title_Hold__c</field>
            <operation>equals</operation>
            <value>Do Not Send Titles</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Title Late Fee Enrollment</fullName>
        <actions>
            <name>Inform_TM_their_dealer_is_enrolled_in_Late_Fee_Program</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Late_Title_Fee_Eligible__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used to email the TM when a dealer is now able to be charged a title late fee</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Inform_TM_their_dealer_is_enrolled_in_Late_Fee_Program</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.Late_Title_Fee_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Undo Date Time Compliant</fullName>
        <actions>
            <name>Remove_Timestamp_Doc_Compliance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Dealer_Doc_Compliance__c</field>
            <operation>equals</operation>
            <value>Out Of Compliance</value>
        </criteriaItems>
        <description>used to remove the date time compliant when Compliance is no longer true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>update Loyal checkbox</fullName>
        <actions>
            <name>loyal_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Platform_Status__c</field>
            <operation>equals</operation>
            <value>Loyal</value>
        </criteriaItems>
        <description>Updates loyal checkbox when platform status changes to Loyal</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
