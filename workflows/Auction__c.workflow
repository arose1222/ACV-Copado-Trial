<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Inform_Buying_Contact_s_IST_AM_That_Multi_Store_Buyer_Needs_To_Select_Dealership</fullName>
        <description>Inform Buying Contact&apos;s IST AM That Multi-Store Buyer Needs To Select Dealership</description>
        <protected>false</protected>
        <recipients>
            <field>Buyer_IST_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Email_To_Buyer_AM_No_Dealer_Selected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auction_Lights_Concatenation_Update</fullName>
        <field>Auction_Lights_Concatenation__c</field>
        <formula>IF(
 AND(
  green_light__c = true,
  yellow_light__c = true,
  blue_light__c = true
 ), &quot;gyb&quot;,
 
IF(
 AND(
  green_light__c = true,
  yellow_light__c = true,
  blue_light__c = false
 ), &quot;gy&quot;,
 
IF(
 AND(
  green_light__c = true,
  yellow_light__c = false,
  blue_light__c = true
 ), &quot;gb&quot;,
 
IF(
 AND(
  green_light__c = false,
  yellow_light__c = true,
  blue_light__c = true
 ), &quot;yrb&quot;,
 
IF(
 AND(
  green_light__c = true,
  yellow_light__c = false,
  blue_light__c = false
 ), &quot;g&quot;,
 
IF(
 AND(
  green_light__c = false,
  yellow_light__c = true,
  blue_light__c = false
 ), &quot;yr&quot;,
 
IF(
 AND(
  green_light__c = false,
  yellow_light__c = false,
  blue_light__c = true
 ), &quot;rb&quot;,

IF(
 AND(
  green_light__c = false,
  yellow_light__c = false,
  blue_light__c = false
 ), &quot;r&quot;,
 
 null))))))))</formula>
        <name>Auction Lights Concatenation Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prior_Payment_Method_Updated</fullName>
        <description>Stamps the last value in the payment method into the field</description>
        <field>Prior_payment_Method__c</field>
        <formula>PriorValue(payment_method__c)</formula>
        <name>Prior Payment Method Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Buyer_s_IST_Email</fullName>
        <field>Buyer_IST_Email__c</field>
        <formula>Buyer_Contact__r.Account.IST_Account_Owner__r.Email</formula>
        <name>Stamp Buyer&apos;s IST Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_RP_Date</fullName>
        <field>Relevant_Recommended_Price_Date__c</field>
        <formula>vehicle_id__r.Most_Recent_Price_Recommendation_Date__c</formula>
        <name>Stamp RP Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Relevant_RP_Ceiling</fullName>
        <field>Relevant_Recommended_Ceiling_Price__c</field>
        <formula>vehicle_id__r.Recommended_Price_Ceiling__c</formula>
        <name>Stamp Relevant RP Ceiling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Relevant_RP_Floor</fullName>
        <field>Relevant_Recommended_Floor_Price__c</field>
        <formula>vehicle_id__r.Recommended_Price_Floor__c</formula>
        <name>Stamp Relevant RP Floor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Auction Is Created or Edited</fullName>
        <actions>
            <name>Auction_Lights_Concatenation_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule runs whenever an Auction is Created or Edited.</description>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Buyer IST AM on Auction</fullName>
        <actions>
            <name>Stamp_Buyer_s_IST_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Auction__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This places the buying contact&apos;s IST Account Manager on the auction record for communication about multi-store buyers who need to select a buying dealership.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email AM%2C No Buyer Selected</fullName>
        <actions>
            <name>Inform_Buying_Contact_s_IST_AM_That_Multi_Store_Buyer_Needs_To_Select_Dealership</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Auction__c.X4_Hours_No_Buyer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Auction__c.Buyer_Dealer_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow sends an email to the multi-store buyer contact&apos;s IST AM four hours after the auction has ended, if they have still not selected a buying dealership.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Payment Method Is Changed</fullName>
        <actions>
            <name>Prior_Payment_Method_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Looks to Buyer payment method to place prior value of that field on the auction  - it is then pulled to the case via a checkbox field called Buyer Payment Changed</description>
        <formula>ISCHANGED( payment_method__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Relevant RP Info</fullName>
        <actions>
            <name>Stamp_RP_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stamp_Relevant_RP_Ceiling</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stamp_Relevant_RP_Floor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Auction__c.id__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>Stamps the Auction record with the relevant RP Info (Dates &amp; Prices) that was given by the Pricing Manager.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
