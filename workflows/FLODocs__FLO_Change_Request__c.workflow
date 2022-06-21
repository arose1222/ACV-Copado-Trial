<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FLODocs__Approved_Alert</fullName>
        <description>Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__Strongpoint_Emails/FLODocs__Approve_Strongpoint_Change_Request</template>
    </alerts>
    <alerts>
        <fullName>FLODocs__FLODocs_Approver_Alert_Email</fullName>
        <description>FLODocs Approver Alert Email</description>
        <protected>false</protected>
        <recipients>
            <field>FLODocs__Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__Strongpoint_Emails/FLODocs__Strongpoint_Change_Request_Alert</template>
    </alerts>
    <alerts>
        <fullName>FLODocs__Strongpoint_Approved_Alert</fullName>
        <description>Strongpoint Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__Strongpoint_Emails/FLODocs__Approve_Strongpoint_Change_Request</template>
    </alerts>
    <alerts>
        <fullName>FLODocs__Strongpoint_Approver_Alert_Email</fullName>
        <description>Strongpoint Approver Alert Email</description>
        <protected>false</protected>
        <recipients>
            <field>FLODocs__Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__Strongpoint_Emails/FLODocs__Strongpoint_Change_Request_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>FLODocs__Assign_Customizations_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>FLODocs__Customizations</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Assign Customizations Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FLODocs__Assign_Data_Records_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>FLODocs__Data_Records</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Assign Data Records Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>FLODocs__Approved%2FRejected Alert</fullName>
        <actions>
            <name>FLODocs__Strongpoint_Approved_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>FLODocs__FLO_Change_Request__c.FLODocs__Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>FLODocs__FLO_Change_Request__c.FLODocs__Approval_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>FLODocs__FLO_Change_Request__c.FLODocs__Affected_Bundle_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Approved Reject Alert when the CR is fully approved or rejected by Strongpoint Admin.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FLODocs__Assign Customizations Record Type</fullName>
        <actions>
            <name>FLODocs__Assign_Customizations_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FLODocs__FLO_Change_Request__c.FLODocs__Change_Request_Type__c</field>
            <operation>equals</operation>
            <value>Customizations</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FLODocs__Assign Data Records Record Type</fullName>
        <actions>
            <name>FLODocs__Assign_Data_Records_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FLODocs__FLO_Change_Request__c.FLODocs__Change_Request_Type__c</field>
            <operation>equals</operation>
            <value>Data Records</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FLODocs__FLO Approver Alert</fullName>
        <actions>
            <name>FLODocs__Strongpoint_Approver_Alert_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert to notify the user to approve/reject a particular CR.</description>
        <formula>AND(ISBLANK( FLODocs__Affected_Bundle_Id__c ),AND(ISCHANGED( FLODocs__Approver__c ), AND(PRIORVALUE(FLODocs__Approver__c) != FLODocs__Approver__c)), OR (NOT ( FLODocs__Approved_Is_Included_in_Mandated__c ),  AND (ISBLANK(FLODocs__Change_Policy__r.FLODocs__Max_of_Approvals_Required__c),  NOT(FLODocs__Change_Policy__r.FLODocs__No_Order_Required__c) ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
