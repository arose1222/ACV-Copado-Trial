<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Price_Expired</fullName>
        <description>Mark RP record as Expired, 15 days after the created date.</description>
        <field>Pricing_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Price is Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RP_is_Active</fullName>
        <field>Recommended_Price_Active__c</field>
        <literalValue>1</literalValue>
        <name>RP is Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Send_to_ACV_True</fullName>
        <field>Send_to_ACV__c</field>
        <literalValue>1</literalValue>
        <name>Send to ACV = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Active_Checkbox_to_False</fullName>
        <field>Recommended_Price_Active__c</field>
        <literalValue>0</literalValue>
        <name>Set Active Checkbox to &apos;False&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Price Recommendation Expired</fullName>
        <active>false</active>
        <description>Marks a recommended pricing record as expired 15 days after it has been created.</description>
        <formula>AND(  ISPICKVAL( Pricing_Status__c, &quot;Active&quot;),  NOT(ISNULL(Price_Floor__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Price_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Active_Checkbox_to_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Recommended_Price__c.CreatedDate</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Price Recommendation Expired 30 Days</fullName>
        <active>false</active>
        <description>Marks a recommended pricing record as expired 30 days after it has been created.</description>
        <formula>AND(  ISPICKVAL( Pricing_Status__c, &quot;Active&quot;),  NOT(ISNULL(Price_Floor__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Price_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Active_Checkbox_to_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Recommended_Price__c.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Recommended Price Checkbox Active</fullName>
        <actions>
            <name>RP_is_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Recommended_Price__c.Pricing_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Marks the &apos;Recommended Price Active&apos; checkbox field as &apos;True&apos; when the RP status = Active.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recommended Price Created%2FModified</fullName>
        <actions>
            <name>Send_to_ACV_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will fire anytime a recommended price is touched</description>
        <formula>AND(NOT(ISBLANK(CreatedDate)),  NOT(CONTAINS($User.Username, &apos;integration@acvauctions.com&apos;)),  NOT(ISCHANGED(Send_to_ACV__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
