/**
 * @description ${DESCRIPTION}
 * @name tracConstants
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-05
 */

public class tracConstants {
    /************ Data Schedule ************/
    public static final String DATA_FREQUENCY_DAILY   = 'Daily';
    public static final String DATA_FREQUENCY_WEEKLY  = 'Weekly';
    public static final String DATA_FREQUENCY_MONTHLY = 'Monthly';

    public static final String DATA_HORIZON_DAYS   = 'Days';
    public static final String DATA_HORIZON_WEEKS  = 'Weeks';
    public static final String DATA_HORIZON_MONTHS = 'Months';

    /************ OCCURRENCE OBJECT ************/
    public static final String FREQUENCY_DAILY   = 'Daily';
    public static final String FREQUENCY_WEEKLY  = 'Weekly';
    public static final String FREQUENCY_MONTHLY = 'Monthly';
    public static final String FREQUENCY_YEARLY  = 'Yearly';

    /************ Work Order Line Item Status ************/
    public static final String WOLI_STATUS_INTERNAL_REVIEW = 'Internal Review';

    /************ Condition Report Prescreen Status ************/
    public static final String PRESCREEN = 'Prescreen ';
    public static final String PRESCREEN_CLOSED_STATUS = 'Closed';
    public static final String PRESCREEN_SUBMITTED = PRESCREEN + 'Submitted';
    public static final String PRESCREEN_PASS = PRESCREEN + 'Pass';
    public static final String PRESCREEN_FAIL = PRESCREEN + 'Fail';
    public static final String WOLI_NUMBER = 'Line Item Number: ';

    public static final String WORKTYPE_DEALER_STANDARD_INSPECTION = 'Standard Inspection';



    /**
     * @description general use mail sender method for debugging email-to-case
     * @param toAddress the email address to receive the email
     * @param subject subject line of the email
     * @param message message body of the email
     * @param parameter object to debug in the email message body
     */
    public static void sendMail(String toAddress, String subject, String message, Object parameter) {
        sendMail(toAddress,subject,String.format(message,new List<Object>{parameter}));
    }

    /**
     * @description general use mail sender method for debugging email-to-case
     * @param toAddress the email address to receive the email
     * @param message message body of the email
     * @param parameter object to debug in the email message body
     */
    public static void sendMail(String toAddress, String message, Object parameter) {
        sendMail(toAddress,'Mail Utility',String.format(message,new List<Object>{parameter}));
    }

    /**
     * @description general use mail sender method for debugging email-to-case
     * @param toAddress the email address to receive the email
     * @param subject subject line of the email
     * @param message message body of the email
     * @param parameter list of objects to debug in the email message body
     */
    public static void sendMail(String toAddress, String subject, String message, List<Object> parameters) {
        sendMail(toAddress,subject,String.format(message,parameters));
    }

    /**
     * @description general use mail sender method for debugging email-to-case
     * @param toAddress the email address to receive the email
     * @param subject subject line of the email
     * @param message message body of the email
     */
    public static void sendMail(String toAddress, String subject, String message){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> to = new List<String>{toAddress};
        email.setToAddresses(to);
        email.setSubject(subject);
        email.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}