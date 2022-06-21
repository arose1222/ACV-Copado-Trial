<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACV_Capital_Borrowed_Capital</fullName>
        <description>ACV Capital Borrowed Capital</description>
        <protected>false</protected>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
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
            <recipient>jstephenson@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Borrowed_Title</template>
    </alerts>
    <alerts>
        <fullName>ACV_Capital_Dealer_Borrowed_Title</fullName>
        <ccEmails>acvadvance@acvauctions.com</ccEmails>
        <description>ACV Capital - Dealer Borrowed Title</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>acvadvance@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Borrowed_Title_Dealer_Notification</template>
    </alerts>
    <alerts>
        <fullName>ACV_Capital_Notify_Buyer_of_Received_Title</fullName>
        <description>ACV Capital - Notify Buyer of Received Title</description>
        <protected>false</protected>
        <recipients>
            <field>ACV_Capital_Primary_Contact_Email_Text__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ACVCapital/ACV_Capital_Notify_Buyer_of_Received_Title_1648226011515</template>
    </alerts>
    <alerts>
        <fullName>ACV_Capital_Title_Received_Alert</fullName>
        <description>ACV Capital Title Received Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Title_Received</template>
    </alerts>
    <alerts>
        <fullName>ACV_Title_Borrowed_7_Days</fullName>
        <description>ACV Title Borrowed 7 Days</description>
        <protected>false</protected>
        <recipients>
            <recipient>emilywirth@acvauctions.com</recipient>
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
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ACV_Capital_Email_Templates/ACV_Capital_Borrowed_Title</template>
    </alerts>
    <alerts>
        <fullName>Arb_Case_Closed_Alert</fullName>
        <description>Arb Case Closed Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Arbitration_Claim_Templates/Outbound_Notification_Arb_Case_Closed_Text</template>
    </alerts>
    <alerts>
        <fullName>Arb_Case_Created_Non_Auto_Responder</fullName>
        <description>Arb Case Created Non-Auto-Responder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Arbitration_Claim_Templates/Outbound_Notification_Arb_Case_Created_Text</template>
    </alerts>
    <alerts>
        <fullName>Arb_Escalated_Case_Alert</fullName>
        <description>Arb Escalated Case Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Arbitration_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>System_Admin</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/SUPPORTCaseescalationnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Case_Assigned_to_User</fullName>
        <description>Case Assigned to User</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Arbitration_Claim_Templates/Outbound_Notification_Arb_Case_Assigned_to_User_Text</template>
    </alerts>
    <alerts>
        <fullName>Case_Buyer_Response_Reminder</fullName>
        <description>Case Buyer Response Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Arbitration_Claim_Templates/Outbound_Notification_Awaiting_Buyer_Response_Reminder_Text</template>
    </alerts>
    <alerts>
        <fullName>Double_Sale_Notification</fullName>
        <description>Double Sale Unwind Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Account_Management/Double_Sale_Unwind_Notification</template>
    </alerts>
    <alerts>
        <fullName>Forty_Eight_Hour_Notification_received</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>48 Hour Notice Received</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Notice_Received</template>
    </alerts>
    <alerts>
        <fullName>Informs_transport_team_that_an_auction_with_ACV_transport_has_been_unwound</fullName>
        <ccEmails>transport@acvauctions.com</ccEmails>
        <description>Informs transport team that an auction with ACV transport has been unwound</description>
        <protected>false</protected>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Unwound_ACV_Transport</template>
    </alerts>
    <alerts>
        <fullName>Informs_user_that_their_title_will_be_delayed_TA_TWD</fullName>
        <description>Informs user that their title will be delayed (TA &amp; TWD)</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/TWD_TA_Delay</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Seller_for_Digital_Title_Received_Alert</fullName>
        <description>Notification to Seller for Digital Title Received Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Notification_to_Seller_for_Digital_Title_Received</template>
    </alerts>
    <alerts>
        <fullName>Notify_Arb_Case_Owner</fullName>
        <description>Notify Arb Case Owner of Status = &quot;Reviewed&quot;</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Arbitration_Claim_Templates/Internal_Notification_Arb_Case_Reviewed</template>
    </alerts>
    <alerts>
        <fullName>Notify_of_New_Commercial_Assignment_Case</fullName>
        <description>Notify of New Commercial Assignment Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Commercial_Assignments</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/New_Commercial_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Problem_Email_Alert</fullName>
        <ccEmails>titles@acvauctions.com</ccEmails>
        <description>Problem Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Territory_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/Problem_Email</template>
    </alerts>
    <alerts>
        <fullName>Problem_Email_Alert_Other</fullName>
        <ccEmails>titles@acvauctions.com</ccEmails>
        <description>Problem Email Alert Other</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Territory_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/Problem_Email_Other</template>
    </alerts>
    <alerts>
        <fullName>Project_Butter_TWD_TA</fullName>
        <description>Project Butter - TWD/TA</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Project_Butter_TA_TWD_Delay</template>
    </alerts>
    <alerts>
        <fullName>Send_Seller_Shipping_Label</fullName>
        <description>Send Seller Shipping Label</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Seller_Title_Shipping_Label</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_notify_IST_a_Case_is_reasdy_for_follow_up</fullName>
        <description>Send email to notify IST a Case is ready for follow up</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Owner_Lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/IST_Follow_Up_Standard_Case</template>
    </alerts>
    <alerts>
        <fullName>Sends_email_2_days_before_title_late_fee_start</fullName>
        <description>Sends email 2 days before title late fee start</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Title_Late_Fee_2_days_until_Start</template>
    </alerts>
    <alerts>
        <fullName>Sends_email_about_the_start_of_a_title_late_fee</fullName>
        <description>Sends email about the start of a title late fee</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Inform_Seller_of_Title_Late_Fee</template>
    </alerts>
    <alerts>
        <fullName>TA_Delay_Follow_Up_CA_Alert</fullName>
        <description>TA Delay Follow Up - CA Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/TA_Delay_Follow_Up_CA</template>
    </alerts>
    <alerts>
        <fullName>TA_Delay_Follow_Up_Non_CA_Alert</fullName>
        <description>TA Delay Follow Up - Non-CA Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/TA_Delay_Follow_Up_Non_CA</template>
    </alerts>
    <alerts>
        <fullName>TWD_Delay_Follow_Up_Alert</fullName>
        <description>TWD Delay Follow Up Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/TWD_Delay_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Tell_Unwind_Owner_Prescreen_is_Completed</fullName>
        <description>Tell Unwind Owner Prescreen is Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Relaunch_Prescreen_Complete</template>
    </alerts>
    <alerts>
        <fullName>Title_Problem_Additional</fullName>
        <ccEmails>areilly@acvauctions.com</ccEmails>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>Title Problem Additional</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Territory_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Title_Problem_Emails_from_QC/Title_Problem_Additional</template>
    </alerts>
    <alerts>
        <fullName>Title_Problem_Original</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>Title Problem Original</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Territory_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Title_Problem_Emails_from_QC/Title_Problem_Original</template>
    </alerts>
    <alerts>
        <fullName>Unwind_Approval</fullName>
        <description>Unwind Approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Unwind_Approval</template>
    </alerts>
    <alerts>
        <fullName>Unwind_Request_was_Rejected</fullName>
        <description>Unwind Request was Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Unwind_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Unwind_Request_was_submitted</fullName>
        <description>Unwind Request was submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>mgreene@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sfadmin@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Unwind_Request</template>
    </alerts>
    <alerts>
        <fullName>Unwind_case_was_Rewound</fullName>
        <ccEmails>resolutions@acvauctions.com</ccEmails>
        <description>Unwind case was Rewound</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Rewound_Case</template>
    </alerts>
    <alerts>
        <fullName>X48_HOUR_NOTICE_START</fullName>
        <description>48 HOUR NOTICE START</description>
        <protected>false</protected>
        <recipients>
            <recipient>areilly@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Notice_Start</template>
    </alerts>
    <alerts>
        <fullName>X48_Hour_Expired_Email_Notification_to_Buyer</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>48 Hour Expired Email - Notification to Buyer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Expired_Notification_to_Buyer</template>
    </alerts>
    <alerts>
        <fullName>X48_Hour_Notice_Expired</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>48 Hour Notice Expired</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Notice_Expired</template>
    </alerts>
    <alerts>
        <fullName>X48_Hour_Start</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>48 Hour Start</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>zdamon@acvauctions.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>48hournotice@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Notice_Start</template>
    </alerts>
    <alerts>
        <fullName>X48_Hour_Unwind_to_Seller_Alert</fullName>
        <ccEmails>ops@acvauctions.com</ccEmails>
        <description>48 Hour Unwind to Seller Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Seller_Title_Clerk_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_Hour_Unwind_to_Seller</template>
    </alerts>
    <alerts>
        <fullName>X48_hour_notice_internal</fullName>
        <description>48 hour notice-internal</description>
        <protected>false</protected>
        <recipients>
            <field>Seller_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Unfiled_Non_Public_Templates/Internal_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>X48_notification_to_Buyer</fullName>
        <ccEmails>ops@acvauction.com</ccEmails>
        <description>48 notification to Buyer Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Titles_Notification_Emails/X48_notification_to_Buyer</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACV_Capital_Advantage_Email_Sent_By</fullName>
        <field>Email_Sent_By__c</field>
        <formula>$User.Full_Name__c</formula>
        <name>ACV Capital - Advantage Email Sent By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Advantage_Email_Sent_Date</fullName>
        <field>Email_Sent_Date__c</field>
        <formula>now()</formula>
        <name>ACV Capital - Advantage Email Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Payment_Execution_By</fullName>
        <field>Capital_Payment_Executed_By__c</field>
        <formula>$User.Full_Name__c</formula>
        <name>ACV Capital - Payment Execution By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Payment_Execution_Date</fullName>
        <field>Capital_Payment_Executed_Date__c</field>
        <formula>now()</formula>
        <name>ACV Capital - Payment Execution Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Status_Updated_By</fullName>
        <field>Capital_Title_Status_Last_Updated_By__c</field>
        <formula>$User.Full_Name__c</formula>
        <name>ACV Capital - Status Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACV_Capital_Title_Status_UPDATES_to_Se</fullName>
        <field>ACV_Capital_Title_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>ACV_Capital_Title_Status UPDATES to Se</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ArbReviewedBy</fullName>
        <field>Arb_Reviewed_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>ArbReviewedBy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Arb_Claim_Date</fullName>
        <field>Claim_Manually_Submitted_Date__c</field>
        <formula>IF( CreatedById == &apos;0050a00000HqbMO&apos;, DATEVALUE(CreatedDate), DATEVALUE(TEXT(Claim_Manually_Submitted_Date__c)))</formula>
        <name>Arb Claim Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Legal_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Legal_Review</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Legal Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Buyer_Dealership_Notes_to_Case</fullName>
        <field>Buyer_Notes__c</field>
        <formula>Buyer_Dealership__r.Dealership_Notes__c</formula>
        <name>Buyer Dealership  Notes to Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Buyer_Pick_Up_Notes_from_Acct</fullName>
        <description>moves the Pick Up notes from account to the Buyer pick up notes on case</description>
        <field>Buyer_Pickup_Notes__c</field>
        <formula>Account.Pickup_Notes__c</formula>
        <name>Buyer Pick Up Notes from Acct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Buyer_Pickup_Notes_Account_Pickup_Note</fullName>
        <field>Buyer_Pickup_Notes__c</field>
        <formula>Account.Pickup_Notes__c+&apos; &apos;+Account.Dealership_Notes__c</formula>
        <name>Buyer Pickup Notes = Account Pickup Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Buyer_Response_Due_Date</fullName>
        <description>Date buyer response is due</description>
        <field>Buyer_Response_Due_Date__c</field>
        <formula>CASE( 
  MOD( TODAY() - DATE( 1900, 1, 6 ), 7 ),
  0, TODAY() + 1 + 3,
  4, TODAY() + 2 + 3,
  5, TODAY() + 1 + 3,
  6, TODAY() + 2 + 3,
  TODAY() + 3
)</formula>
        <name>Buyer Response Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Capital_Title_Sent_Date</fullName>
        <field>Capital_Title_Sent_Date__c</field>
        <formula>today()</formula>
        <name>Capital Title Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Auction_ID_Searchable</fullName>
        <description>Update the text type Auction ID field whenever a case is created or edited</description>
        <field>Auction_Number_Searchable__c</field>
        <formula>Auction_Number__r.id__c</formula>
        <name>Case: Auction ID Searchable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Clear_Buyer_Response_Due</fullName>
        <field>Buyer_Response_Due_Date__c</field>
        <name>Case Clear Buyer Response Due</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Titles_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Titles_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner = Titles Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Send_To_ACV_false</fullName>
        <field>Send_to_ACV__c</field>
        <literalValue>0</literalValue>
        <name>Case: Send To ACV = false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Send_to_ACV_True</fullName>
        <description>checks Send to ACV checkbox</description>
        <field>Send_to_ACV__c</field>
        <literalValue>1</literalValue>
        <name>Case: Send to ACV = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_Ready_to_Post</fullName>
        <description>update the status to be ready-to-post</description>
        <field>Status</field>
        <literalValue>Ready-to-Post</literalValue>
        <name>Case Status = &quot;Ready-to-Post&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Send_to_ACV</fullName>
        <field>Send_to_ACV__c</field>
        <literalValue>1</literalValue>
        <name>Check Send to ACV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Send_to_ACV_Trans</fullName>
        <field>Send_to_ACV__c</field>
        <literalValue>1</literalValue>
        <name>Check Send to ACV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_Capital_Borrowed</fullName>
        <field>Capital_Title_Borrowed_Date__c</field>
        <formula>now()</formula>
        <name>Date Stamp Capital Borrowed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_Capital_Sent_to_Floor</fullName>
        <field>Capital_Title_Sent_to_Floor_Plan_Date__c</field>
        <formula>now()</formula>
        <name>Date Stamp Capital Sent to Floor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_Received_Capital</fullName>
        <field>Capital_Title_Received_Date__c</field>
        <formula>now()</formula>
        <name>Date Stamp Received Capital</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Stamp_capital_Sent</fullName>
        <field>Capital_Title_Sent_Date__c</field>
        <formula>now()</formula>
        <name>Date Stamp capital Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Assigned_to_Queue_NOW</fullName>
        <field>Date_Time_Assigned_to_Queue__c</field>
        <formula>NOW()</formula>
        <name>Date/Time Assigned to Queue = NOW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Removed_from_Queue_NOW</fullName>
        <field>Date_Time_Removed_from_Queue__c</field>
        <formula>NOW()</formula>
        <name>Date/Time Removed from Queue = NOW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_stamp_Status_change</fullName>
        <field>Status_Last_Updated__c</field>
        <formula>now()</formula>
        <name>Date stamp Status change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalation_Date_Time_NOW</fullName>
        <field>Escalation_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Escalation Date/Time = NOW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IST_Follow_DateTime_Populate</fullName>
        <field>IST_Follow_Up_DateTime__c</field>
        <formula>NOW()</formula>
        <name>IST Follow DateTime Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IsEscalated_True</fullName>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>IsEscalated True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pick_Up_notes_to_Seller_Pick_up_notes</fullName>
        <field>Seller_Pick_Up_Notes__c</field>
        <formula>Seller_Dealership__r.Pickup_Notes__c</formula>
        <name>Pick Up notes to Seller Pick up notes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Relaunch_Info_Posted</fullName>
        <field>Date_Relaunch_Sale_Posted__c</field>
        <formula>now()</formula>
        <name>Relaunch Info Posted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Buyer_Confusion_No</fullName>
        <description>Set&apos;s Buyer Confusion = &quot;No&quot;</description>
        <field>Buyer_Confusion__c</field>
        <literalValue>No</literalValue>
        <name>Set Buyer Confusion = &quot;No&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_48_Hour_Notice_Day_Time</fullName>
        <field>Date_Time_of_48_Hour_Notice__c</field>
        <formula>now()</formula>
        <name>Stamp 48 Hour Notice Day/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Buyer_s_IST_Email</fullName>
        <description>Populate buying dealership&apos;s IST account manager&apos;s email.</description>
        <field>Buyer_IST_Email__c</field>
        <formula>Account.IST_Account_Owner__r.Email</formula>
        <name>Stamp Buyer&apos;s IST Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Date_Time_Denial_Review_Completed</fullName>
        <description>Stamps the date/time the denial review is completed</description>
        <field>Date_Time_Case_Denial_Review_Completed__c</field>
        <formula>NOW()</formula>
        <name>Stamp Date/Time Denial Review Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Date_time_Working_Now</fullName>
        <field>Date_Time_Working__c</field>
        <formula>now()</formula>
        <name>Stamp Date time Working Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Seller_Contact_Email</fullName>
        <field>Seller_Contact_Email__c</field>
        <formula>Seller_Contact__r.Email</formula>
        <name>Stamp Seller Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Seller_s_TM_Email</fullName>
        <field>Seller_TM_Email__c</field>
        <formula>Seller_Dealership__r.Owner.Email</formula>
        <name>Stamp Seller&apos;s TM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Title_Working_Date</fullName>
        <field>Title_Clerked_Date__c</field>
        <formula>now()</formula>
        <name>Stamp Title Working Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Unwind_Approval_Date</fullName>
        <description>Places date/time of unwind approval, based on Status = Unwound</description>
        <field>Date_Unwind_Approved__c</field>
        <formula>now()</formula>
        <name>Stamp Unwind Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Was_Problem_Field</fullName>
        <field>Was_Problem__c</field>
        <literalValue>1</literalValue>
        <name>Stamp Was Problem Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Change_to_Closed_No_title</fullName>
        <description>Status change to Closed (No title) when Title_deleted is checked</description>
        <field>Status</field>
        <literalValue>Closed (No Title)</literalValue>
        <name>Status Change to Closed (No title)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Title_Owner_Resolutions</fullName>
        <field>OwnerId</field>
        <lookupValue>Resolutions_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Title Owner Resolutions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Transportation_Finalized</fullName>
        <description>Sets the Transportation Finalized checkbox = TRUE</description>
        <field>Transportation_Finalized__c</field>
        <literalValue>1</literalValue>
        <name>Transportation Finalized</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Transportation_Status_Closed_Dry_Run</fullName>
        <description>Sets the Transportation Case Status to &quot;Closed Dry Run&quot;</description>
        <field>Status</field>
        <literalValue>Closed Dry Run</literalValue>
        <name>Transportation Status &quot;Closed Dry Run&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unwind_Approved</fullName>
        <field>Status</field>
        <literalValue>Unwound</literalValue>
        <name>Unwind Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unwind_Case_Status</fullName>
        <description>Change unwind case status to &quot;Transportation Arranged&quot;</description>
        <field>Status</field>
        <literalValue>Transportation Arranged</literalValue>
        <name>Unwind Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unwind_Rejected</fullName>
        <field>Status</field>
        <literalValue>Closed (Not Approved)</literalValue>
        <name>Unwind Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unwind_Status</fullName>
        <field>Status</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Unwind Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus</fullName>
        <field>Status</field>
        <literalValue>Unwound</literalValue>
        <name>UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_First_Posted_Portal</fullName>
        <field>Date_First_Posted_Portal__c</field>
        <formula>NOW()</formula>
        <name>Update Date First Posted Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LastTouched</fullName>
        <field>Last_Touched__c</field>
        <formula>NOW()</formula>
        <name>Update LastTouched</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_closed_compliant</fullName>
        <field>Status</field>
        <literalValue>Closed(compliant)</literalValue>
        <name>Update to closed compliant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_closed_non_compliant</fullName>
        <field>Status</field>
        <literalValue>Closed(non-compliant)</literalValue>
        <name>Update to closed non-compliant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_status_to_compliance_review</fullName>
        <field>Status</field>
        <literalValue>Compliance Review</literalValue>
        <name>update status to compliance review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>48 Hour Expired Email Notification to Buyer</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>48 Hour Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Date_Time_of_48_Hour_Notice__c</field>
            <operation>greaterThan</operation>
            <value>2/7/2020</value>
        </criteriaItems>
        <description>automated email to the buyer on a 48 hour notice</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X48_Hour_Expired_Email_Notification_to_Buyer</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.X48_Hour_Expiration__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>48 Hour Notice Expired</fullName>
        <active>false</active>
        <description>This workflow informs the selling dealership that the 48 hour notice placed by the buyer has expired and the auction is now at risk of being unwound.</description>
        <formula>AND( ISPICKVAL(Status, &quot;48 Hour Notice&quot;),  Date_Time_of_48_Hour_Notice__c  &gt;  DATETIMEVALUE(&quot;2019-08-13 23:59:00&quot;), Account.Dealership_ID__c &lt;&gt; &quot;4308&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X48_Hour_Notice_Expired</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.X48_Hour_Expiration__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>48 Hour Notice Received</fullName>
        <actions>
            <name>Forty_Eight_Hour_Notification_received</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow sends when a title goes from 48 Hour Notice to Received prior to the 48 Hour Expiration hitting.</description>
        <formula>AND(  Buyer_Called_to_Request_48_Hour_Notice__c = true,  ISPICKVAL(Status, &quot;Received&quot;),   X48_Hour_Expiration__c  &gt; now())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>48 Hour Notice Start</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>48 Hour Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Date_Time_of_48_Hour_Notice__c</field>
            <operation>greaterThan</operation>
            <value>9/15/2021</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>4308</value>
        </criteriaItems>
        <description>This workflow fires when a title case status is changed to 48 Hour Notice, sending an informational email to stakeholders.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X48_Hour_Start</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Date_Time_of_48_Hour_Notice__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>48 Hour Unwind to Seller</fullName>
        <actions>
            <name>X48_Hour_Unwind_to_Seller_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Unwind_Reason__c</field>
            <operation>equals</operation>
            <value>48-Hour Title Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Unwind_Type__c</field>
            <operation>equals</operation>
            <value>Return_to_Seller</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Unwind</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>11/5/2019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Unwound</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>4308</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>48 notification to Buyer</fullName>
        <actions>
            <name>X48_notification_to_Buyer</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>48 Hour Notice</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>11/5/2019</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital - Advantage Email Sent</fullName>
        <actions>
            <name>ACV_Capital_Advantage_Email_Sent_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ACV_Capital_Advantage_Email_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED( Email_Sent__c ),Email_Sent__c=TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital - Payment Execution</fullName>
        <actions>
            <name>ACV_Capital_Payment_Execution_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ACV_Capital_Payment_Execution_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Updates fields when Payment Executed = True</description>
        <formula>AND(ISCHANGED(Capital_Payment_Executed__c),Capital_Payment_Executed__c=TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital - Status Updated By</fullName>
        <actions>
            <name>ACV_Capital_Status_Updated_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When Capital Title status is changed, mark who made the change</description>
        <formula>ISCHANGED( ACV_Capital_Title_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACV Capital Title Borrowed</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Borrowed</value>
        </criteriaItems>
        <description>Sends Email to Capital team when title marked as borrowed for 7 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ACV_Capital_Dealer_Borrowed_Title</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>ACV_Title_Borrowed_7_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Capital_Title_Borrowed_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ACV Capital Title Received</fullName>
        <actions>
            <name>ACV_Capital_Title_Received_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Working</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Payment_Method__c</field>
            <operation>contains</operation>
            <value>acv</value>
        </criteriaItems>
        <description>Once ACV Capital title status is changed to received an automatic email is sent to buyer letting them know that this title is in office and includes auction ID and vin.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACV_Capital_Title_Status updates to Sent</fullName>
        <actions>
            <name>ACV_Capital_Status_Updated_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ACV_Capital_Title_Status_UPDATES_to_Se</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Capital_Title_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When ‘Status&apos; ISCHANGED TO ‘Sent’ AND Buyer_Payment_Method__c contains ’acv_capital, THEN ACV_Capital_Title_Status = ‘Sent’</description>
        <formula>ISCHANGED(Status) &amp;&amp;   ISPICKVAL(Status, &quot;Sent&quot;)&amp;&amp; CONTAINS(   Payment_Method__c  , &quot;acv_capital&quot;) &amp;&amp;   RecordType.Name  = &apos;Title Information&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Arb Case%3A Clear Buyer Response Due</fullName>
        <actions>
            <name>Case_Clear_Buyer_Response_Due</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Awaiting Buyer Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Arbitration Claim</value>
        </criteriaItems>
        <description>This rule fires when an Arb Case Status is no longer &apos;Awaiting Buyer Response.&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Arb Case%3A Closed</fullName>
        <actions>
            <name>Arb_Case_Closed_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Arbitration Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule fires when an Arbitration Case is Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Arb Case%3A Escalated</fullName>
        <actions>
            <name>Arb_Escalated_Case_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Escalation_Date_Time_NOW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Arbitration Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsEscalated</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule fires when an Arbitration Case has been Escalated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Arb Case%3A Not Created via Email-to-Case</fullName>
        <actions>
            <name>Arb_Case_Created_Non_Auto_Responder</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This rule fires when an Arbitration Case is not created from an Email-to-Case message.</description>
        <formula>RecordType.DeveloperName = &quot;Arbitration_Claim&quot; &amp;&amp; IsClosedOnCreate = false &amp;&amp; ISCHANGED(SuppliedEmail) &amp;&amp; NOT(CONTAINS(SuppliedEmail, &quot;@acvauctions.com&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Arb Case%3A Status %3D Awaiting Buyer Response</fullName>
        <actions>
            <name>Buyer_Response_Due_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Buyer Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Arbitration Claim</value>
        </criteriaItems>
        <description>This rule will fire when an Arbitration Case Status is updated to &quot;Awaiting Buyer Response.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Buyer_Response_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Buyer_Response_Due_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Arb Case%3A Update Searchable Auction ID</fullName>
        <actions>
            <name>Case_Auction_ID_Searchable</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Necessary to provide an Auction ID that is searchable on the Case object (Arb)</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ArbByNameStamp</fullName>
        <actions>
            <name>ArbReviewedBy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Reviewed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Title Unwind case to Titles Queue</fullName>
        <actions>
            <name>Case_Owner_Titles_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Unwind</value>
        </criteriaItems>
        <description>Workflow used for assigning the new &quot;Title Unwind&quot; case to titles queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auction w Transport Unwound</fullName>
        <actions>
            <name>Informs_transport_team_that_an_auction_with_ACV_transport_has_been_unwound</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Unwound</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Unwind</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ACV_Transport__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule will trigger an email to the transport team to let them know that an auction with ACV transport has been unwound.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Buyer Notes to Case</fullName>
        <actions>
            <name>Buyer_Dealership_Notes_to_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Dealership_Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Buyer_Pickup_Notes__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Buyer Pick Up notes from Account</fullName>
        <actions>
            <name>Buyer_Pick_Up_Notes_from_Acct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Pickup_Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Capital Title Sent Date</fullName>
        <actions>
            <name>Capital_Title_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Account Not Blank</fullName>
        <actions>
            <name>Buyer_Pickup_Notes_Account_Pickup_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule fires when the Account field on a Case is not blank.</description>
        <formula>AccountId != null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Unwound Send to ACV</fullName>
        <actions>
            <name>Case_Send_to_ACV_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(  RecordType.DeveloperName= &quot;Unwind&quot;,ISCHANGED(Status), TEXT(Status) = &quot;Unwound&quot;, NOT(ISCHANGED(Send_to_ACV__c )),  NOT(CONTAINS($User.Username, &apos;integration@acvauctions.com&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Assigned to Queue</fullName>
        <actions>
            <name>Date_Time_Assigned_to_Queue_NOW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule fires when a Case has been assigned to a Queue.</description>
        <formula>LEFT(OwnerId,3) = &apos;00G&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A No Longer Assigned to Queue</fullName>
        <actions>
            <name>Date_Time_Removed_from_Queue_NOW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule fires when case is removed from a queue and is assigned to a user.</description>
        <formula>LEFT(PRIORVALUE(OwnerId), 3) = &apos;00G&apos; &amp;&amp; LEFT(OwnerId, 3) &lt;&gt; &apos;00G&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Create a task when Unwind is Created</fullName>
        <actions>
            <name>Contact_VCI_for_re_inspection</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Unwound</value>
        </criteriaItems>
        <description>Create a task for Resolutions team to request VCI when the unwind case status is unwound</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date stamp Status change</fullName>
        <actions>
            <name>Date_stamp_Status_change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ischanged(Status)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deleted Title Status change</fullName>
        <actions>
            <name>Status_Change_to_Closed_No_title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If the Title_Deleted box is checked, then change status to Closed (No title)</description>
        <formula>Title_Deleted__c  = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Denial Review Completed</fullName>
        <actions>
            <name>Stamp_Date_Time_Denial_Review_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Stamps the time the denial review was completed</description>
        <formula>AND( ISCHANGED(Denial_Status__c), OR( ISPICKVAL(Denial_Status__c,&quot;IST to Handle&quot;), ISPICKVAL(Denial_Status__c,&quot;ARB to Handle&quot;), ISPICKVAL(Denial_Status__c,&quot;Denial Recalled&quot;) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Double Sale Unwind Notification</fullName>
        <actions>
            <name>Double_Sale_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Unwind</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Unwind_Reason__c</field>
            <operation>equals</operation>
            <value>Double Sale</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Unwound</value>
        </criteriaItems>
        <description>When an unwind occurs due to a double sale the seller sales team needs to be notified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Arb Case Owner once %22Reviewed%22</fullName>
        <actions>
            <name>Notify_Arb_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will fire an email alert to the Arb Case Owner once the status moves from &quot;Under Review&quot; to &quot;Reviewed&quot;</description>
        <formula>AND(     ISCHANGED(Status),     ISPICKVAL(PRIORVALUE(Status),&quot;Under Review&quot;),     ISPICKVAL(Status,&quot;Reviewed&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IST Follow Up Email</fullName>
        <actions>
            <name>Send_email_to_notify_IST_a_Case_is_reasdy_for_follow_up</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>IST Follow Up</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>9/29/2020</value>
        </criteriaItems>
        <description>Send an email to the IST rep when a standard case is moved back to IST Follow up</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inform Unwind Owner of Prescreen</fullName>
        <actions>
            <name>Tell_Unwind_Owner_Prescreen_is_Completed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Manual_Relaunch_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This rule informs an unwind case owner that the CR review team has completed a prescreen for an auction relaunch.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Commercial Assignment Notification</fullName>
        <actions>
            <name>Notify_of_New_Commercial_Assignment_Case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Commercial Assignments</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Commercial Assignments</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Seller for Digital Title Received Rule</fullName>
        <actions>
            <name>Notification_to_Seller_for_Digital_Title_Received_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Digital_Title__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Working</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Title_Sent_Digitally__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Notification to Seller for Digital Title Received</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pick Up notes to Seller Pick up notes</fullName>
        <actions>
            <name>Pick_Up_notes_to_Seller_Pick_up_notes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Moves the Pick Up notes on Account to Seller Pick up notes</description>
        <formula>AND(Seller_Dealership__r.Pickup_Notes__c &lt;&gt; null, ISNULL(Seller_Pick_Up_Notes__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Arb Claim Date</fullName>
        <actions>
            <name>Arb_Claim_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Arbitration Claim</value>
        </criteriaItems>
        <description>This rule copies the Case Created Date to the Claim Manually Submitted Date field when the creating user is ACV SF Admin.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate IST Follow Up DateTime</fullName>
        <actions>
            <name>IST_Follow_DateTime_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>IST Follow Up</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Priority Title Escalate</fullName>
        <actions>
            <name>IsEscalated_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When buyer or seller has Title Priority, Escalated is checked to limit title scan process for internal priority</description>
        <formula>RecordType.DeveloperName = &quot;Title_Information&quot;  &amp;&amp; OR( Account.Titles_Priority__c = TRUE, Seller_Dealership__r.Titles_Priority__c = TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Problem Email Rule</fullName>
        <actions>
            <name>Problem_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Problem</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Other__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Problem Other Email Rule</fullName>
        <actions>
            <name>Problem_Email_Alert_Other</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Problem</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Other__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Butter - TA Delay %28CA%29</fullName>
        <actions>
            <name>Project_Butter_TWD_TA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Title_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Age_in_Days__c</field>
            <operation>greaterThan</operation>
            <value>45</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Auction_End__c</field>
            <operation>greaterThan</operation>
            <value>8/13/2019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Seller_State__c</field>
            <operation>equals</operation>
            <value>CA,California</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>7960</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IST_Account_Owner__c</field>
            <operation>equals</operation>
            <value>Nicole Klonowski,Corey Guetti,Jake Murray,Jenna Roessler,Lee Lomenzo,Krista Glownia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Time_Compliant__c</field>
            <operation>greaterOrEqual</operation>
            <value>9/1/2020</value>
        </criteriaItems>
        <description>This workflow fires an email when a &quot;title absent&quot; auction takes place but the title has not been received 46 days after auction end, and the seller is based in California. Set for only project butter IST reps.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Butter - TA Delay %28non-CA%29</fullName>
        <actions>
            <name>Project_Butter_TWD_TA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow fires an email when a &quot;title absent&quot; auction takes place but the title has not been received 31 days after auction end, and the seller is not based in California.</description>
        <formula>AND( Title_Attached__c = True,  Age_in_Days__c &gt; 30,  Auction_End__c &gt; DATETIMEVALUE(&quot;2019-8-13 23:59:00&quot;), ISPICKVAL(Status, &quot;New&quot;),   Account.Date_Time_Compliant__c &gt; DATETIMEVALUE(&quot;2020-8-31 23:59:00&quot;), RecordType.DeveloperName = &quot;Title Information&quot;,  Account.IST_Account_Owner__r.FirstName = &quot;Nicole Klonowski&quot;|| Account.IST_Account_Owner__r.FirstName = &quot;Corey Guetti&quot;|| Account.IST_Account_Owner__r.FirstName = &quot;Jake Murray&quot;|| Account.IST_Account_Owner__r.FirstName = &quot;Jenna Roessler&quot;|| Account.IST_Account_Owner__r.FirstName =&quot;Lee Lomenzo&quot;|| Account.IST_Account_Owner__r.FirstName = &quot;Krista Glownia&quot;, Seller_State__c  &lt;&gt; (&quot;CA, California&quot;), Account.Dealership_ID__c &lt;&gt; &quot;7960&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Butter - TWD Delay</fullName>
        <actions>
            <name>Project_Butter_TWD_TA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Title_Attached__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Age_in_Days__c</field>
            <operation>greaterThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Auction_End__c</field>
            <operation>greaterThan</operation>
            <value>8/13/2019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>7960</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IST_Account_Owner_Lookup__c</field>
            <operation>equals</operation>
            <value>Nicole Klonowski,Corey Guetti,Jake Murray,Jenna Roessler,Lee Lomenzo,Krista Glownia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Time_Compliant__c</field>
            <operation>greaterOrEqual</operation>
            <value>9/1/2020</value>
        </criteriaItems>
        <description>This workflow fires an email when a &quot;title with deal&quot; auction takes place but the title has not been received 8 days after auction end. This is specific to the accounts with project butter reps.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Seller Contact Email</fullName>
        <actions>
            <name>Stamp_Seller_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow places the selling dealership&apos;s main contact&apos;s email address on titles cases.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Seller TM Email</fullName>
        <actions>
            <name>Stamp_Seller_s_TM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow places the selling dealership&apos;s territory manager&apos;s email on a titles case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Shipping Label</fullName>
        <actions>
            <name>Send_Seller_Shipping_Label</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Digital_Title__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Easypost_PostageLabel_Label_URL__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Created as part of the COVID Response tp send shipping labels to Sellers</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Title Problem Additional Email</fullName>
        <actions>
            <name>Title_Problem_Additional</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sends title problem email when qc count is greater than 1 and sends full list of title problems</description>
        <formula>And( ISPICKVAL(Status, &apos;problem&apos;),   QC_Count_Seller_Needed__c &gt; 1,   ISCHANGED( QC_Count_Seller_Needed__c), RecordType.DeveloperName = &apos;Title_Information&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Title Problem Original Email</fullName>
        <actions>
            <name>Title_Problem_Original</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Problem</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <description>Sends title problem email at first qc entry where title case is changed to problem.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Buyer Confusion to %22No%22 for non-arb cases</fullName>
        <actions>
            <name>Set_Buyer_Confusion_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow sets the Buyer Confusion field to &quot;No&quot; upon case creation for non-arbitration case record types</description>
        <formula>RecordType.Name != &quot;Arbitration Claim&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Stamp 48 Hour Notice Day%2FTime</fullName>
        <actions>
            <name>Stamp_48_Hour_Notice_Day_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>48 Hour Notice</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Buyer%27s IST Email</fullName>
        <actions>
            <name>Stamp_Buyer_s_IST_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This places the buying dealership&apos;s IST account manager&apos;s user email address on the title case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date ACV Capital Title Borrowed</fullName>
        <actions>
            <name>Date_Stamp_Capital_Borrowed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Borrowed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date ACV Capital Title Received</fullName>
        <actions>
            <name>Date_Stamp_Received_Capital</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Received</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date ACV Capital Title Sent</fullName>
        <actions>
            <name>Date_Stamp_capital_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date ACV Capital Title Sent to Floor</fullName>
        <actions>
            <name>Date_Stamp_Capital_Sent_to_Floor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.ACV_Capital_Title_Status__c</field>
            <operation>equals</operation>
            <value>Sent to Floor Plan</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Date Time Working</fullName>
        <actions>
            <name>Stamp_Date_time_Working_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Working</value>
        </criteriaItems>
        <description>Stamps date time working field on standard case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Problem Status</fullName>
        <actions>
            <name>Stamp_Was_Problem_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Problem</value>
        </criteriaItems>
        <description>This rule indicates true on Was Problem field when a title case is marked as problem. Field always remains true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Title Working Date</fullName>
        <actions>
            <name>Stamp_Title_Working_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Working</value>
        </criteriaItems>
        <description>This rule places the date that a Title case had its status marked as Working.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TA Delay %28CA%29</fullName>
        <actions>
            <name>Informs_user_that_their_title_will_be_delayed_TA_TWD</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Title_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Age_in_Days__c</field>
            <operation>greaterThan</operation>
            <value>45</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Auction_End__c</field>
            <operation>greaterThan</operation>
            <value>8/13/2019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Seller_State__c</field>
            <operation>equals</operation>
            <value>CA,California</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>7960</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IST_Account_Owner__c</field>
            <operation>notEqual</operation>
            <value>Nicole Klonowski,Corey Guetti,Jake Murray,Jenna Roessler,Lee Lomenzo,Krista Glownia</value>
        </criteriaItems>
        <description>This workflow fires an email when a &quot;title absent&quot; auction takes place but the title has not been received 46 days after auction end, and the seller is based in California.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TA Delay %28non-CA%29</fullName>
        <actions>
            <name>Informs_user_that_their_title_will_be_delayed_TA_TWD</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow fires an email when a &quot;title absent&quot; auction takes place but the title has not been received 31 days after auction end, and the seller is not based in California.</description>
        <formula>AND( Title_Attached__c = True,  Age_in_Days__c &gt; 30,  Auction_End__c &gt; DATETIMEVALUE(&quot;2019-8-13 23:59:00&quot;),  ISPICKVAL(Status, &quot;New&quot;),  RecordType.DeveloperName = &quot;Title Information&quot;,  Account.IST_Account_Owner__r.FirstName &lt;&gt;&quot;Nicole Klonowski&quot;||  Account.IST_Account_Owner__r.FirstName &lt;&gt; &quot;Corey Guetti&quot;|| Account.IST_Account_Owner__r.FirstName &lt;&gt; &quot;Jake Murray&quot;|| Account.IST_Account_Owner__r.FirstName &lt;&gt; &quot;Jenna Roessler&quot;|| Account.IST_Account_Owner__r.FirstName &lt;&gt; &quot;Lee Lomenzo&quot;|| Account.IST_Account_Owner__r.FirstName &lt;&gt; &quot;Krista Glownia&quot;, Seller_State__c  &lt;&gt; (&quot;CA, California&quot;),  Account.Dealership_ID__c &lt;&gt; &quot;7960&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TA Delay Follow Up - CA</fullName>
        <actions>
            <name>TA_Delay_Follow_Up_CA_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( Title_Attached__c = true, NOT(ISBLANK(Date_Time_of_48_Hour_Notice__c)),  Seller_State__c = &quot;CA&quot;,  (DATETIMEVALUE( TODAY() ) - Auction_End__c) &gt; 45,  Auction_End__c &gt; DATETIMEVALUE(&quot;2019-11-05 10:00:00&quot;),  ISPICKVAL( Status, &apos;Received&apos;),  Account.Dealership_ID__c &lt;&gt; &quot;7960&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TA Delay Follow Up - Non-CA</fullName>
        <actions>
            <name>TA_Delay_Follow_Up_Non_CA_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( Title_Attached__c = true, NOT(ISBLANK(Date_Time_of_48_Hour_Notice__c)),  Seller_State__c  &lt;&gt; &quot;CA&quot;,  ( DATETIMEVALUE( TODAY() ) - Auction_End__c) &gt; 30,  Auction_End__c &gt; DATETIMEVALUE(&quot;2019-11-05 10:00:00&quot;),  ISPICKVAL( Status, &apos;Received&apos;),   Account.Dealership_ID__c &lt;&gt; &quot;7960&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TWD Delay</fullName>
        <actions>
            <name>Informs_user_that_their_title_will_be_delayed_TA_TWD</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Title_Attached__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Age_in_Days__c</field>
            <operation>greaterThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Auction_End__c</field>
            <operation>greaterThan</operation>
            <value>8/13/2019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title Information</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Dealership_ID__c</field>
            <operation>notEqual</operation>
            <value>7960</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IST_Account_Owner__c</field>
            <operation>notEqual</operation>
            <value>Nicole Klonowski,Corey Guetti,Jake Murray,Jenna Roessler,Lee Lomenzo,Krista Glownia</value>
        </criteriaItems>
        <description>This workflow fires an email when a &quot;title with deal&quot; auction takes place but the title has not been received 8 days after auction end.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TWD Delay Follow Up</fullName>
        <actions>
            <name>TWD_Delay_Follow_Up_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( Title_Attached__c  = false,    NOT(ISBLANK(Date_Time_of_48_Hour_Notice__c)), ( DATETIMEVALUE( TODAY() ) - Auction_End__c) &gt; 7,   Auction_End__c &gt;  DATETIMEVALUE(&quot;2019-11-05 10:00:00&quot;),   ISPICKVAL( Status, &apos;Received&apos;),  Account.Dealership_ID__c &lt;&gt; &quot;7960&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Timestamp Date of Unwind Approval</fullName>
        <actions>
            <name>Stamp_Unwind_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Unwound</value>
        </criteriaItems>
        <description>This rule populates &apos;Date Unwind Approved&apos; on Unwind cases based on the the date/time the Status = Unwound</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Timestamp Relaunch Info Posted</fullName>
        <actions>
            <name>Relaunch_Info_Posted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Unwind</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Relisted_Sale_Price__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Places date/time Relisted Sale Price field is populated in the Date Relaunch Sale Posted field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Title Late Fee  2 days until Start</fullName>
        <active>false</active>
        <description>Used to trigger email alert so that seller and seller tm can be informed that a title is 2 days out from  being charged late fees</description>
        <formula>AND ( Seller_Dealership__r.Late_Title_Fee_Eligible__c = true, Seller_Dealership__r.Late_Title_Fee_Start_Date__c &lt; CreatedDate,    ISBLANK(Title_Received_Date__c ),  NOT( OR(ISPICKVAL(Status, &quot;ACV Unwound&quot;),  ISPICKVAL(Status, &quot;Returned to Seller Unwound&quot;), ISPICKVAL(Status, &quot;Closed Unwound&quot;))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Sends_email_2_days_before_title_late_fee_start</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Title_Due_Date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Title Late Fee Start Notification</fullName>
        <active>false</active>
        <description>Used to trigger email alert so that seller and seller tm can be informed that a title is now late and being charged late fees</description>
        <formula>AND (Seller_Dealership__r.Late_Title_Fee_Eligible__c = true, Seller_Dealership__r.Late_Title_Fee_Start_Date__c &lt; CreatedDate,   ISBLANK(Title_Received_Date__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Sends_email_about_the_start_of_a_title_late_fee</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Title_Due_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Title Status Outbound Call</fullName>
        <actions>
            <name>Check_Send_to_ACV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Triggers when Title Information Case Status is changed to a certain value supported by ACV platform</description>
        <formula>AND(   RecordType.DeveloperName= &quot;Title_Information&quot;,    ISCHANGED(Status),   NOT(ISCHANGED(Send_to_ACV__c )),   NOT(CONTAINS($User.Username, &apos;integration@acvauctions.com&apos;)),   NOT(CONTAINS($User.Username, &apos;arabey@acvauctions.com&apos;)),   NOT(CONTAINS($User.Username, &apos;jbudnack@acvauctions.com&apos;)),   OR(     TEXT(Status) = &quot;New&quot;,      TEXT(Status) = &quot;Received&quot;,      TEXT(Status) = &quot;Working&quot;,     TEXT(Status) = &quot;Problem&quot;,      TEXT(Status) = &quot;48 Hour Notice&quot;,      TEXT(Status) = &quot;Return to Seller&quot;,      TEXT(Status) = &quot;Sent&quot;,      TEXT(Status) = &quot;Title At ACV Unwound&quot;,      TEXT(Status) = &quot;Closed Unwound&quot;    ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Title Status Outbound Call Uncheck</fullName>
        <actions>
            <name>Case_Send_To_ACV_false</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>inverse of the Title Status Outbound Call WFR to uncheck cases that no longer meet this criteria</description>
        <formula>AND(   RecordType.DeveloperName= &quot;Title_Information&quot;,   ISCHANGED(Status),     NOT(ISCHANGED(Send_to_ACV__c )),   NOT(TEXT(Status) = &quot;New&quot;),   NOT(TEXT(Status) = &quot;Received&quot;),   NOT(TEXT(Status) = &quot;Working&quot;),   NOT(TEXT(Status) = &quot;Problem&quot;),   NOT(TEXT(Status) = &quot;48 Hour Notice&quot;),   NOT(TEXT(Status) = &quot;Return to Seller&quot;),   NOT(TEXT(Status) = &quot;Sent&quot;),   NOT(TEXT(Status) = &quot;Title at ACV Unwound&quot;),   NOT(TEXT(Status) = &quot;Closed Unwound&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Title case to Resolutions</fullName>
        <actions>
            <name>Title_Owner_Resolutions</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed Unwound</value>
        </criteriaItems>
        <description>Workflow used to reassign the title case to resolutions team when auction is unwound</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Titles Case Owned by ACV Integration</fullName>
        <actions>
            <name>Case_Owner_Titles_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule fires when a Titles Case is created and is owned by the ACV Integration user. This is in a workflow rule, not an assignment rule, because Titles Cases get created via Bulk API Integration, and there is not setting to run assignment rule via Bulk</description>
        <formula>AND(  RecordType.DeveloperName=&quot;Title_Information&quot;,  OwnerId=&quot;0050a00000HqbIl&quot;  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Transportation Finalized</fullName>
        <actions>
            <name>Transportation_Finalized</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Finalized</value>
        </criteriaItems>
        <description>Runs when status = &quot;Finalized&quot; for Transportation cases.  Sets the Transportation Finalized checkbox = TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Transportation Outbound Call Uncheck</fullName>
        <actions>
            <name>Case_Send_To_ACV_false</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>inverse of transprotation outbound call, uncheck send to acv checkbox</description>
        <formula>AND  (  RecordType.DeveloperName= &quot;Transportation&quot;,  ISCHANGED(Status),  NOT(ISCHANGED(Send_to_ACV__c )),  NOT(CONTAINS($User.Username,&apos;integration@acvauctions.com&apos;)),  NOT(TEXT(Status) = &quot;Assigned&quot;),  NOT(TEXT(Status) = &quot;Picked-Up&quot;),  NOT(TEXT(Status) = &quot;Delivered&quot;),  NOT(TEXT(Status) = &quot;Posted&quot;),  NOT(TEXT(Status) = &quot;Cancelled by Transporter&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Transportation Stamp Date First Posted Portal</fullName>
        <actions>
            <name>Update_Date_First_Posted_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>stamping the date first posted portal on a transportation case when the status changes to posted</description>
        <formula>AND(ISCHANGED(Status),  ISPICKVAL( Status , &apos;Posted&apos;),  ISNULL( Date_First_Posted_Portal__c ),  RecordType.Name = &apos;Transportation&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Transportation Status %22Closed Dry Run%22</fullName>
        <actions>
            <name>Transportation_Status_Closed_Dry_Run</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Dry_Run_Fee__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Transportation</value>
        </criteriaItems>
        <description>Sets the Status of a Transportation Case to &quot;Closed Dry Run&quot; when the Dry Run Fee field != null</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Transportation Status Outbound Call</fullName>
        <actions>
            <name>Case_Send_to_ACV_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Check_Send_to_ACV_Trans</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Triggers when transportation case status is changed to certain value supported by ACV platform</description>
        <formula>AND(RecordType.DeveloperName=&quot;Transportation&quot;, ISCHANGED(Status), NOT(ISCHANGED(Send_to_ACV__c)), NOT(CONTAINS($User.Username, &apos;integration@acvauctions.com&apos;)), OR(TEXT(Status)=&quot;Assigned&quot;,  TEXT(Status)=&quot;Picked-Up&quot;,  TEXT(Status)=&quot;Delivered&quot;,  TEXT(Status)=&quot;Posted&quot;, TEXT(Status) = &quot;Cancelled by Transporter&quot;, TEXT(Status) = &quot;Awaiting Release&quot;,TEXT(Status) = &quot;Finalized&quot;, TEXT(Status) = &quot;Unwind Transportation Requested&quot;, TEXT(Status) = &quot;Failed Post&quot;, TEXT(Status) = &quot;Locked&quot;, TEXT(Status) = &quot;Sent to Third-Party&quot;, TEXT(Status) = &quot;Closed Dry Run&quot;, TEXT(Status) = &quot;Cancelled by ACV&quot;, TEXT(Status) = &quot;Accepted&quot;, TEXT(Status) = &quot;Hold&quot;, TEXT(Status) = &quot;Staged&quot;, TEXT(Status) = &quot;Non-Responsive-Unpaid&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unwind Transportation Status</fullName>
        <actions>
            <name>Unwind_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When unwind transportation is requested or dealer arranged unwind status (path) is changed to transportation arranged</description>
        <formula>OR(   Unwind_Transportation_Requested__c = TRUE,    Dealer_Arranged__c = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unwind case was Rewound</fullName>
        <actions>
            <name>Unwind_case_was_Rewound</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Rewound</value>
        </criteriaItems>
        <description>workflow rule sends email to resolutions team when an unwind case is rewound</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UnwindCreatedStatus</fullName>
        <actions>
            <name>UpdateStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.Can_Unwind__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Unwind</value>
        </criteriaItems>
        <description>Rule used for updating unwind case status when a user can directly unwind (doesn&apos;t go through an approval process)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Touched Date</fullName>
        <actions>
            <name>Update_LastTouched</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Used to let us know when a case was last touched, while excluding Admin updates</description>
        <formula>IF( $Profile.Name != &apos;System Administrator&apos;, TRUE, FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Transportation Case Status</fullName>
        <actions>
            <name>Case_Status_Ready_to_Post</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the Case Status if the Release_Available__c equals true and current status = &quot;Awaiting Release&quot;</description>
        <formula>AND( RecordType.Name = &apos;Transportation&apos;, ISPICKVAL(Status,&quot;Awaiting Release&quot;), Release_Available__c = True)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Contact_VCI_for_re_inspection</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Contact VCI for re-inspection</subject>
    </tasks>
    <tasks>
        <fullName>Unwind_Request_was_submitted_for_approval</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Unwind Request was submitted for approval</subject>
    </tasks>
</Workflow>
