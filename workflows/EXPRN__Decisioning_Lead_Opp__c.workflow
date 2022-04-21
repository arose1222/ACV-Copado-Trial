<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EXPRN__Update_Override_checkbox</fullName>
        <field>EXPRN__Override__c</field>
        <literalValue>1</literalValue>
        <name>Update Override checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_Override_field</fullName>
        <field>EXPRN__Override__c</field>
        <literalValue>1</literalValue>
        <name>Update Override field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_overridden_by</fullName>
        <field>EXPRN__Overridden_By__c</field>
        <formula>$User.FirstName + &quot; &quot; +$User.LastName</formula>
        <name>Update overridden by</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_prior_decision</fullName>
        <field>EXPRN__Previous_Decision__c</field>
        <formula>Text (PRIORVALUE(EXPRN__Decision_Override__c ))</formula>
        <name>Update prior decision</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_prior_decision_date</fullName>
        <field>EXPRN__Date__c</field>
        <formula>PRIORVALUE(EXPRN__Decision_Date__c)</formula>
        <name>Update prior decision date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EXPRN__Update Override</fullName>
        <actions>
            <name>EXPRN__Update_Override_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Experian Decisioning Lead &amp; Opportunity: Override to update</description>
        <formula>EXPRN__Override__c = False &amp;&amp; ISCHANGED(EXPRN__Decision_Override__c) &amp;&amp;  (  ((ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Approve&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Decline&quot;)) ||  ((ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Decline&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Approve&quot;)))  )  )  &amp;&amp; (  EXPRN__Lead__c != null || EXPRN__Opportunity__c != null  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update override details when a decision is overriden in Lead_Opp</fullName>
        <actions>
            <name>EXPRN__Update_Override_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXPRN__Update_overridden_by</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXPRN__Update_prior_decision</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>EXPRN__Update_prior_decision_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate fields Change_Decision__c, Decision_Override__c, Overwritten_By__c, Override__c, Previous_Decision__c, Date__c when user overrides decision</description>
        <formula>NOT(ISNEW()) &amp;&amp;  RecordType.DeveloperName = &apos;Recent_Decision&apos; &amp;&amp;  ISCHANGED(EXPRN__Decision_Override__c) &amp;&amp; NOT(ISPICKVAL(EXPRN__Decision_Override__c, &apos;&apos;)) &amp;&amp; ( EXPRN__Lead__c != null || EXPRN__Opportunity__c != null)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
