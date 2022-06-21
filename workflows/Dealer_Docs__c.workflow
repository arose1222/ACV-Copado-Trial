<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Capital_Send_Doc_Expiration_Email_to_IST_Account_Manager</fullName>
        <ccEmails>acvadvance@acvauctions.com</ccEmails>
        <description>Capital - Send Doc Expiration Email</description>
        <protected>false</protected>
        <recipients>
            <field>Capital_Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Capital_Dealer_Doc_Expiration_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Email_IST_re_Dealer_Doc_Help_Needed</fullName>
        <description>Email IST re: Dealer Doc Help Needed</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/IST_Needed_for_Dealer_Doc</template>
    </alerts>
    <alerts>
        <fullName>Expiring_Dealer_Docs_14_Day_Alert</fullName>
        <description>Expiring Dealer Docs 14 Day Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ExpiringDealerDocsLightningTemplates/Expiring_Dealer_Docs_14_Day_1633128016787</template>
    </alerts>
    <alerts>
        <fullName>Expiring_Dealer_Docs_21_Day_Alert</fullName>
        <description>Expiring Dealer Docs 21 Day Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ExpiringDealerDocsLightningTemplates/Expiring_Dealer_Docs_21_Day_1633128072614</template>
    </alerts>
    <alerts>
        <fullName>Expiring_Dealer_Docs_30_Day_Alert</fullName>
        <description>Expiring Dealer Docs 30 Day Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ExpiringDealerDocsLightningTemplates/Expiring_Dealer_Docs_30_Day_1633128112399</template>
    </alerts>
    <alerts>
        <fullName>Expiring_Dealer_Docs_7_Day_Alert</fullName>
        <description>Expiring Dealer Docs 7 Day Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ExpiringDealerDocsLightningTemplates/Expiring_Dealer_Docs_7_Day_1633127950635</template>
    </alerts>
    <alerts>
        <fullName>Send_Doc_Expiration_Email_to_IST_Account_Manager</fullName>
        <ccEmails>acvinfo@acvauctions.com</ccEmails>
        <description>Send Doc Expiration Email to IST Account Manager</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Dealer_Doc_Expiration_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Send_VT_Expiration_Email_to_IST_Account_Manager</fullName>
        <description>Send VT Expiration Email to IST Account Manager</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Dealer_Doc_VT_Expiration_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Capital_Update_Primary_Contact_Email</fullName>
        <field>Capital_Primary_Contact_Email__c</field>
        <formula>Account__r.ACV_Capital_Primary_Contact__r.Email</formula>
        <name>Capital - Update Primary Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Dealer_Doc_As_Complete_When_Complia</fullName>
        <field>Review_Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Mark Dealer Doc As Complete When Complia</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_TM_Email</fullName>
        <field>TM_Email__c</field>
        <formula>Account__r.Owner.Email</formula>
        <name>Stamp TM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Capital - Primary Contact Email</fullName>
        <actions>
            <name>Capital_Update_Primary_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Certificate of Insurance</value>
        </criteriaItems>
        <description>Add the primary contact email address (for use in email workflows)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Capital - Send 14 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Capital_Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 14 day reminder email to the IST Account Manager when 14 Day Reminder Email Sent is flipped to true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Capital - Send 30 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Capital_Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Thirty_Day_Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 30 day reminder email to the IST Account Manager when 30 Day Reminder Email Sent is flipped to true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Capital - Send 45 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Capital_Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Forty_Five_Day_Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 45 day reminder email to the IST Account Manager when 45 Day Reminder Email Sent is flipped to true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Dealer Doc Needs IST</fullName>
        <actions>
            <name>Email_IST_re_Dealer_Doc_Help_Needed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Review_Status__c</field>
            <operation>equals</operation>
            <value>Requires BDR</value>
        </criteriaItems>
        <description>This email sends to IST w/ TM copied to say there is an issue with the dealer doc and their assistance correcting is needed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Expiring Dealer Doc 14 Day Rule</fullName>
        <actions>
            <name>Expiring_Dealer_Docs_14_Day_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Rule for 14 day dealer doc expiration email to dealer.</description>
        <formula>Expiration_Date__c = TODAY() + 14</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Expiring Dealer Doc 21 Day Rule</fullName>
        <actions>
            <name>Expiring_Dealer_Docs_21_Day_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Rule for 21 day dealer doc expiration email to dealer.</description>
        <formula>Expiration_Date__c = TODAY() + 21</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Expiring Dealer Doc 30 Day Rule</fullName>
        <actions>
            <name>Expiring_Dealer_Docs_30_Day_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Rule for 30 day dealer doc expiration email to dealer.</description>
        <formula>Expiration_Date__c = TODAY() + 30</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Expiring Dealer Doc 7 Day Rule</fullName>
        <actions>
            <name>Expiring_Dealer_Docs_7_Day_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Rule for 7 day dealer doc expiration email to dealer.</description>
        <formula>Expiration_Date__c = TODAY() + 7</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Dealer Doc As Complete When Compliant</fullName>
        <actions>
            <name>Mark_Dealer_Doc_As_Complete_When_Complia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Compliant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send 14 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>License Renewal Confirmation,Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 14 day reminder email to the IST Account Manager when 14 Day Reminder Email Sent is flipped to true.  EXCEPT when License Renewal Confirmation or Certificate of Insurance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send 30 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Thirty_Day_Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>License Renewal Confirmation,Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 30 day reminder email to the IST Account Manager when 30 Day Reminder Email Sent is flipped to true. EXCEPT when License Renewal Confirmation or Certificate of Insurance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send 45 Day Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Forty_Five_Day_Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>License Renewal Confirmation,Certificate of Insurance</value>
        </criteriaItems>
        <description>Workflow to send the 45 day reminder email to the IST Account Manager when 45 Day Reminder Email Sent is flipped to true.  EXCEPT when License Renewal Confirmation or Certificate of Insurance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Doc Expiration Reminder Email</fullName>
        <actions>
            <name>Send_Doc_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow to send the reminder email to the IST Account Manager when Reminder Email Sent is flipped to true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send VT License Expiration Email</fullName>
        <actions>
            <name>Send_VT_Expiration_Email_to_IST_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.Document_State__c</field>
            <operation>equals</operation>
            <value>VT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>License Renewal Confirmation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Dealer_Docs__c.Reminder_Email_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send the VT specific expiration message when a VT License Renewal doc expires.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp TM Email</fullName>
        <actions>
            <name>Stamp_TM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Dealer_Docs__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Stamps TM (Account Owner&apos;s) email on Dealer Doc for email notifications. Use of Account Owner was not functioning.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
