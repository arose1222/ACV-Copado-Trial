<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CR_Is_Under_Review</fullName>
        <description>CR Is Under Review</description>
        <protected>false</protected>
        <recipients>
            <field>Prescreen_Email_Target__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforce@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ConditionReportPrescreenEmails/Prescreen_Under_Review_Email_1650549528134</template>
    </alerts>
    <alerts>
        <fullName>CR_Review_Completed_No_Changes_Made</fullName>
        <description>CR Review Completed - No Changes Made</description>
        <protected>false</protected>
        <recipients>
            <field>Prescreen_Email_Target__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ConditionReportPrescreenEmails/Prescreen_Review_Completed_No_Changes_Made_1650549692503</template>
    </alerts>
    <alerts>
        <fullName>CR_Review_Completed_Yes_Changes_Notes</fullName>
        <description>CR Review Completed - Yes Changes/Notes</description>
        <protected>false</protected>
        <recipients>
            <field>Prescreen_Email_Target__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ConditionReportPrescreenEmails/Prescreen_Review_Completed_Changes_Notes_1650549900025</template>
    </alerts>
    <alerts>
        <fullName>CR_Sent_To_Prescreen</fullName>
        <description>CR Sent To Prescreen</description>
        <protected>false</protected>
        <recipients>
            <field>Prescreen_Email_Target__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ConditionReportPrescreenEmails/Prescreen_Created_Email_1650548825229</template>
    </alerts>
    <alerts>
        <fullName>CR_Timed_Out</fullName>
        <description>CR Timed Out</description>
        <protected>false</protected>
        <recipients>
            <field>Prescreen_Email_Target__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>system@acvauctions.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ConditionReportPrescreenEmails/Prescreen_Time_Out_1650550532483</template>
    </alerts>
    <alerts>
        <fullName>Condition_Report_Review_Completed</fullName>
        <description>Condition Report Review Completed</description>
        <protected>false</protected>
        <recipients>
            <field>VCI_Creator_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SFDX_Arbitration_Email_Templates/Condition_Report_Review_Completed</template>
    </alerts>
    <alerts>
        <fullName>Condition_Report_Review_Submitted</fullName>
        <description>Condition Report Review Submitted</description>
        <protected>false</protected>
        <recipients>
            <field>VCI_Creator_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>VCI_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SFDX_Arbitration_Email_Templates/Condition_Report_Review_Submitted</template>
    </alerts>
    <alerts>
        <fullName>Notify_VCI_of_CR_Review_Decision</fullName>
        <description>Notify VCI of CR Review Decision</description>
        <protected>false</protected>
        <recipients>
            <field>VCI__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>TM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>VCI_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SFDX_Arbitration_Email_Templates/Condition_Report_Review_CompletedVF</template>
    </alerts>
    <fieldUpdates>
        <fullName>Prescreen_Type_Update</fullName>
        <field>Prescreen_Type__c</field>
        <formula>TEXT( VCI__r.Prescreen_Type__c )</formula>
        <name>Prescreen Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CR_Review_Status_Closed</fullName>
        <description>Set&apos;s the CR Review Status = Closed</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Set CR Review Status = Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CR_Review_Timeout_TRUE</fullName>
        <description>Set&apos;s the CR Review Timeout = TRUE</description>
        <field>CR_Review_Timeout__c</field>
        <literalValue>1</literalValue>
        <name>Set CR Review Timeout = TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Prescreen_Closed_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>NOW()</formula>
        <name>Stamp Prescreen Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_TM_on_Prescreen</fullName>
        <description>Stamps the TM email address in the TM email field - For the purpose of adding them to the CRR Closed email only when a question exists</description>
        <field>TM_Email__c</field>
        <formula>Account__r.Owner.Email</formula>
        <name>Stamp TM on Prescreen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_VCI_Creator_Email</fullName>
        <description>Stamps VCI Creator Email on the Condition Report Review</description>
        <field>VCI_Creator_Email__c</field>
        <formula>Condition_Report__r.VCI_Creator__r.Email</formula>
        <name>Stamp VCI Creator Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_VCI_Submitter_Email</fullName>
        <field>VCI_Submitter_Email__c</field>
        <formula>Condition_Report__r.VCI__r.Email</formula>
        <name>Stamp VCI Submitter Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CRR-Closed</fullName>
        <actions>
            <name>Notify_VCI_of_CR_Review_Decision</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Aux_Queue__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Timed_Out__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Reason__c</field>
            <operation>notContain</operation>
            <value>Exterior Cosmetic</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Reason__c</field>
            <operation>notContain</operation>
            <value>Bumper/Lights</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Condition Report Review Email Notifications</fullName>
        <actions>
            <name>Condition_Report_Review_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Aux_Queue__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Reason__c</field>
            <operation>notContain</operation>
            <value>Bumper/Lights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Reason__c</field>
            <operation>notContain</operation>
            <value>Exterior Cosmetic</value>
        </criteriaItems>
        <description>Sends notification emails out to VCIs</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Condition_Report_Prescreen__c.CR_Review_Created_Time_Minus_30__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Condition Report Review Email Notifications - After TimeOut</fullName>
        <actions>
            <name>Condition_Report_Review_Completed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Status__c</field>
            <operation>equals</operation>
            <value>New,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.CR_Review_Timeout__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends notification emails out to VCIs</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Account</fullName>
        <active>false</active>
        <description>Populate account so we can create better reports</description>
        <formula>NOT(ISBLANK(Condition_Report__c)) &amp;&amp; ISBLANK( Account__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Prescreen Type</fullName>
        <actions>
            <name>Prescreen_Type_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updating prescreen type from Contact provided Report Prescreen isn&apos;t Closed</description>
        <formula>ISNEW() ||
AND( ISCHANGED( VCI__c ),       
NOT(ISPICKVAL(Status__c, &apos;Closed&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Closed Date</fullName>
        <actions>
            <name>Stamp_Prescreen_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamp the close date on CR Prescreen records when closed is reached</description>
        <formula>ISCHANGED(Status__c) &amp;&amp; ISPICKVAL(Status__c,&apos;Closed&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stamp TM Email</fullName>
        <actions>
            <name>Stamp_TM_on_Prescreen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Question_Count__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>This workflow will stamp the TM email on a pre-screen to allow them to be notified when there are questions on a CR.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp VCI Creator Email</fullName>
        <actions>
            <name>Stamp_VCI_Creator_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Stamp_VCI_Submitter_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Condition_Report_Prescreen__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Upon Condition Report Review Creation stamp the VCI Creator email from the CR</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
