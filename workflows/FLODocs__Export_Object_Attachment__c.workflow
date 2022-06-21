<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FLODocs__Export_Environment_Comparison_Attachment</fullName>
        <description>Export Environment Comparison Attachment</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__FLO_Email_Templates/FLODocs__Export_Environment_Comparison_Attachment</template>
    </alerts>
    <alerts>
        <fullName>FLODocs__Export_Object_Attachment</fullName>
        <description>Export Object Attachment</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FLODocs__FLO_Email_Templates/FLODocs__Export_Object_Attachment</template>
    </alerts>
    <rules>
        <fullName>FLODocs__Export Environment Comparison Attachment Rule</fullName>
        <actions>
            <name>FLODocs__Export_Environment_Comparison_Attachment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>FLODocs__Export_Object_Attachment__c.FLODocs__Attachment_Url__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>FLODocs__Export_Object_Attachment__c.Name</field>
            <operation>contains</operation>
            <value>Environment Comparison</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FLODocs__Export Object Attachment Rule</fullName>
        <actions>
            <name>FLODocs__Export_Object_Attachment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>FLODocs__Export_Object_Attachment__c.FLODocs__Attachment_Url__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>FLODocs__Export_Object_Attachment__c.Name</field>
            <operation>contains</operation>
            <value>Export Object Tool</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
