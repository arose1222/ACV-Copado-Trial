<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Awaiting_Floor_Price</fullName>
        <field>Awaiting_Floor_Price__c</field>
        <literalValue>1</literalValue>
        <name>Update Awaiting Floor Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CR_Created</fullName>
        <description>Updated CR Created checkbox</description>
        <field>CR_Created__c</field>
        <literalValue>1</literalValue>
        <name>Update CR Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CR_in_Review</fullName>
        <description>Updated CR in Review checkbox</description>
        <field>CR_in_review__c</field>
        <literalValue>1</literalValue>
        <name>Update CR in Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CR Created</fullName>
        <actions>
            <name>Update_CR_Created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When VCI scans the VIN, update CR created checkbox</description>
        <formula>NOT(ISBLANK(Vehicle__r.vin__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CR awaiting Floor price</fullName>
        <actions>
            <name>Update_Awaiting_Floor_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updated awaiting Floor price checkbox once CR review is compelete</description>
        <formula>AND(  CR_Created__c=True,  CR_Doc_Complete__c=True,  OR(Floor_Price__c&lt;20, Floor_Price__c&gt;=999999))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CR in Review update</fullName>
        <actions>
            <name>Update_CR_in_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When CR_doc_complete (launchable) and floor price is null</description>
        <formula>AND( CR_Created__c=True, CR_Doc_Complete__c=True, Floor_Price__c=Null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
