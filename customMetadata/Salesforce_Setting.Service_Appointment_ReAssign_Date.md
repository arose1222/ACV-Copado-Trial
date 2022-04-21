<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Service Appointment ReAssign Date</label>
    <protected>false</protected>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">For ServiceAppointmentReAssignDateBatch:  If Service Appointment Due Date &lt; TODAY and Work Type = (Auction Site, Dealer, Auction Off-Lease) and Status = (New, Scheduled, Cannot Complete), then ADD this # days to Due Date and set FSL__InJeopardy__c to TRUE</value>
    </values>
    <values>
        <field>Filter_Grouping__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Value__c</field>
        <value xsi:type="xsd:string">10</value>
    </values>
</CustomMetadata>
