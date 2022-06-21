<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>update_zips</fullName>
        <description>Updates zips from JSON to clean format</description>
        <field>Zips__c</field>
        <formula>SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(maps__Geometry__c,
&quot;USA-&quot;, &quot;&quot;),
&quot;USA-2-&quot;, &quot;&quot;),
&quot;USA-3-&quot;, &quot;&quot;),
&quot;USA-4-&quot;, &quot;&quot;),
&apos;{&quot;1&quot;:&apos;,&quot;&quot; ),
&apos;{&quot;2&quot;:&apos;,&quot;&quot; ),
&apos;{&quot;3&quot;:&apos;,&quot;&quot; ),
&apos;{&quot;4&quot;:&apos;,&quot;&quot; ),
&apos;&quot;2&quot;:&apos;,&quot;&quot;),
&apos;-&apos;,&quot;&quot; ),
&apos;&quot;&apos;,&quot;&quot; ),
&apos;[&apos;,&quot;&quot; ),
&apos;]&apos;,&quot;&quot; ),
&apos;}&apos;,&quot;&quot; )</formula>
        <name>update zips</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Reformat Zips</fullName>
        <actions>
            <name>update_zips</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>maps__ShapeLayerGeometry__c.maps__Geometry__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Used to clean up zips from JSON string format</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
