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
        <description>Update override checkbox</description>
        <field>EXPRN__Override__c</field>
        <literalValue>1</literalValue>
        <name>Update Override field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_change_decision</fullName>
        <description>Update changed decision</description>
        <field>EXPRN__Change_Decision__c</field>
        <literalValue>1</literalValue>
        <name>Update change decision</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_most_recent_decision_status</fullName>
        <field>EXPRN__Most_Recent_Decision_Status__c</field>
        <formula>If(NOT(ISNULL(Text(EXPRN__Decision_Override__c))) &amp;&amp; NOT(ISBLANK(Text(EXPRN__Decision_Override__c))),TEXT(EXPRN__Decision_Override__c),IF(

NOT(ISNULL(Text( EXPRN__Decision__c ))) &amp;&amp; NOT(ISBLANK(Text( EXPRN__Decision__c ))),TEXT(EXPRN__Decision__c), &quot;&quot;))</formula>
        <name>Update most recent decision status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>EXPRN__Business__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_overridden_by</fullName>
        <description>Update overridden by user name</description>
        <field>EXPRN__Overwritten_By__c</field>
        <formula>$User.FirstName + &quot; &quot; +$User.LastName</formula>
        <name>Update overridden by</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EXPRN__Update_prior_decision</fullName>
        <description>Update previous decision taken</description>
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
        <description>Update override checkbox when decision is changed from approve to decline or vice versa</description>
        <formula>EXPRN__Override__c = False &amp;&amp;  ISCHANGED(EXPRN__Decision_Override__c) &amp;&amp;  ( ((ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Approve&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Decline&quot;)) || ((ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Decline&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Approve&quot;))) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update changed decision</fullName>
        <actions>
            <name>EXPRN__Update_change_decision</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Experian Decisioning: Changed Decision update</description>
        <formula>EXPRN__Change_Decision__c = False &amp;&amp; ISCHANGED(EXPRN__Decision_Override__c) &amp;&amp;  ( (ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Approve&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Manual Decision&quot;)) ||  (ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Manual Decision&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Approve&quot;)) ||  (ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Decline&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Manual Decision&quot;)) ||  (ISPICKVAL(PRIORVALUE(EXPRN__Decision_Override__c),&quot;Manual Decision&quot;) &amp;&amp; ISPICKVAL(EXPRN__Decision_Override__c, &quot;Decline&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update most recent decision on Account</fullName>
        <actions>
            <name>EXPRN__Update_most_recent_decision_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the field
1. When a new decision flows into SF.
2. When a decision is overridden</description>
        <formula>(ISCHANGED( EXPRN__Decision_Override__c ) ||  (ISNEW() &amp;&amp;   Not(ISBLANK(TEXT(EXPRN__Decision__c))) ||  Not(ISNULL(TEXT(EXPRN__Decision__c))))) &amp;&amp; RecordType.DeveloperName=&quot;Recent_Decision&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EXPRN__Update override details when a decision is overriden</fullName>
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
        <formula>NOT(ISNEW()) &amp;&amp;  RecordType.DeveloperName = &apos;Recent_Decision&apos; &amp;&amp;   ISCHANGED(EXPRN__Decision_Override__c) &amp;&amp; NOT(ISPICKVAL(EXPRN__Decision_Override__c, &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
