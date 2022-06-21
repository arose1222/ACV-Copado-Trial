<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Historical_Auto_Converted_Document_Email</fullName>
        <description>Send Historical Auto-Converted Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Historical</template>
    </alerts>
    <alerts>
        <fullName>Send_Historical_Document_Email</fullName>
        <description>Send Historical Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Historical</template>
    </alerts>
    <alerts>
        <fullName>Send_Incomplete_Document_Email</fullName>
        <description>Send Incomplete Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Incomplete</template>
    </alerts>
    <alerts>
        <fullName>Send_Invalid_Document_Email</fullName>
        <description>Send Invalid Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Invalid</template>
    </alerts>
    <alerts>
        <fullName>Send_Poor_Quality_Document_Email</fullName>
        <description>Send Poor Quality Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>IST_Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Poor_Quality</template>
    </alerts>
    <alerts>
        <fullName>Send_Valid_Auto_Converted_Document_Email</fullName>
        <description>Send Valid Auto-Converted Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Valid</template>
    </alerts>
    <alerts>
        <fullName>Send_Valid_Document_Email</fullName>
        <description>Send Valid Document Email</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Business_Doc_Exception_Valid</template>
    </alerts>
    <rules>
        <fullName>Send Historical Auto-Converted Document Email</fullName>
        <actions>
            <name>Send_Historical_Auto_Converted_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Auto-Converted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Compliant__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled auto-converted and is historical.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Historical Document Email</fullName>
        <actions>
            <name>Send_Historical_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Historical Document</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled historical.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Incomplete Document Email</fullName>
        <actions>
            <name>Send_Incomplete_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Incomplete/Adjustment Needed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled incomplete/adjustment needed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Invalid Document Email</fullName>
        <actions>
            <name>Send_Invalid_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Invalid Document</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled invalid.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Poor Quality Document Email</fullName>
        <actions>
            <name>Send_Poor_Quality_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Poor Document Quality</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled poor quality.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Valid Auto-Converted Document Email</fullName>
        <actions>
            <name>Send_Valid_Auto_Converted_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Auto-Converted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Compliant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled auto-converted and is valid.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Valid Document Email</fullName>
        <actions>
            <name>Send_Valid_Document_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Exception__c.Review_Decision__c</field>
            <operation>equals</operation>
            <value>Current and Compliant Document</value>
        </criteriaItems>
        <criteriaItems>
            <field>Exception__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow is triggered when a business document has been labeled valid.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
