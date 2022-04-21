public class ServiceAppointmentNotificationRequest extends TriggerInterface{
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {

        Map<Id,ServiceAppointment> serviceApptMap = new Map<Id,ServiceAppointment>();

        List<String> statusToSendNotificationList = new List<String>{'Completed', 'Cannot Complete', 'Canceled'};

        for ( ServiceAppointment newSA : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( newSA.Id );
            if ( !statusToSendNotificationList.contains(oldSA.Status) && statusToSendNotificationList.contains(newSA.Status) ) {
                serviceApptMap.put(newSA.Id, newSA);
            }
        }

        if ( !serviceApptMap.isEmpty() ) {
            createNotificationsForSubscriptions( serviceApptMap );
        }
    }

    public static void createNotificationsForSubscriptions( Map<Id,ServiceAppointment> serviceApptMap ) {

        List<Email_Notification__c> emailNotificationsToUpsert = new List<Email_Notification__c>();


        for (Email_Notification_Subscription__c subscription : [SELECT Id, Email_on_Request_Inspection_Fulfillment__c, User__c, Account__c, Account__r.Name, Account__r.Dealership_Id__c, Service_Appointment__c FROM Email_Notification_Subscription__c WHERE Service_Appointment__c IN :serviceApptMap.keyset() AND Email_on_Request_Inspection_Fulfillment__c = true]) {
            emailNotificationsToUpsert.add(new Email_Notification__c(
                Account__c = subscription.Account__c,
                Account_Name__c = subscription.Account__r.Name,
                Dealership_Id__c = subscription.Account__r.Dealership_Id__c,
                User__c = subscription.User__c,
                Send_Request_Inspection_Fullfillment__c = subscription.Email_on_Request_Inspection_Fulfillment__c,
                Work_Order_Number__c = serviceApptMap.get(subscription.Service_Appointment__c).Work_Order__c,
                Service_Appointment__c = subscription.Service_Appointment__c,
                User_WorkOrder_Key__c = subscription.User__c + '' + serviceApptMap.get(subscription.Service_Appointment__c).Work_Order__c,
                Service_Appointment_Status__c = serviceApptMap.get(subscription.Service_Appointment__c).Status,
                Service_Appointment_Work_Type__c = serviceApptMap.get(subscription.Service_Appointment__c).Work_Type_Name__c,
                Service_Appointment_Completed_Date_Time__c = serviceApptMap.get(subscription.Service_Appointment__c).ActualEndTime
            ));
        }

        if (emailNotificationsToUpsert.size() > 0) {
            upsert emailNotificationsToUpsert User_WorkOrder_Key__c;
        }
    }
}