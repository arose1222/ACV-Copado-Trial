<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Stamp_Document_On_Subject</fullName>
        <description>Stamp_Document_On_Subject for title cases</description>
        <field>Subject</field>
        <formula>TEXT(Documents_Items_Needed__c)</formula>
        <name>Stamp Document On Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Activity_Comments</fullName>
        <description>This copies the standard Comments (Description) field from Task to a custom field to be used in the chatter feed display. Note: This operation will Truncate the data to 256 characters.</description>
        <field>Activity_Comments__c</field>
        <formula>Left(Description, 255)</formula>
        <name>Update Activity Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateNoteField</fullName>
        <description>stamp comments on Notes</description>
        <field>Notes__c</field>
        <formula>IF(LEN(Description)&gt;255,LEFT(Description,252)&amp;&quot;...&quot;,Description)</formula>
        <name>updateNoteField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Stamp Comments on Notes to show on related lists</fullName>
        <actions>
            <name>updateNoteField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Description</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Documents needed to Subject</fullName>
        <actions>
            <name>Stamp_Document_On_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Stamps documents needed to the subject line</description>
        <formula>NOT(ISBLANK(TEXT(Documents_Items_Needed__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Additional Comments</fullName>
        <actions>
            <name>Update_Activity_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This copies the standard Comments (Description) field from Task to a custom field to be used in the chatter feed display. Note: This operation will Truncate the data to 256 characters.</description>
        <formula>NOT(ISBLANK(Description))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
