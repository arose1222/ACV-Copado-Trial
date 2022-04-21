<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Budget_25_Remaining</fullName>
        <description>Budget - 25% Remaining</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Unfiled_Non_Public_Templates/Budget_25_Remaining</template>
    </alerts>
    <rules>
        <fullName>Budget - 25%25 remaining Email</fullName>
        <actions>
            <name>Budget_25_Remaining</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an email to the Owner of a budget when its less than 25% remaining</description>
        <formula>IsChanged(Current_Balance__c) &amp;&amp; Current_Balance__c / Starting_Balance__c &lt;= 0.25 &amp;&amp; PRIORVALUE(Current_Balance__c) / Starting_Balance__c &gt; 0.25</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
