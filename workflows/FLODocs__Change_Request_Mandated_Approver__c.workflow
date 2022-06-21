<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FLODocs__Strongpoint_MAndated_Approver_Alert_Email</fullName>
        <description>Strongpoint MAndated Approver Alert Email</description>
        <protected>false</protected>
        <recipients>
            <field>FLODocs__Mandated_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__FLO_Email_Templates/FLODocs__Strongpoint_Change_Request_Mandated_Approver_Alert</template>
    </alerts>
    <rules>
        <fullName>FLODocs__FLO Mandated Approver Alert</fullName>
        <actions>
            <name>FLODocs__Strongpoint_MAndated_Approver_Alert_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT (ISNULL(FLODocs__Change_Request__r.FLODocs__Mandated_Approvers__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
