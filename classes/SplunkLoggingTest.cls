/**
 * @description It is used to add logging in splunk.
 * 
 * 
 * @author Manmeet Vaseer
 * @date 02/09/2022
 * 
 * @history 
 * 			
 * 
 */
@isTest
public class SplunkLoggingTest {

    @isTest
    static void testSplunkLogging() {
        String componentName = 'Unit_Tests';
        
        SplunkLogging sl = new SplunkLogging(componentName);
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Fatal__c) ;
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Error__c) ;
        System.assertEquals(false, sl.splunkLogging.Enable_Log_Level_Warn__c) ;
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Info__c) ;
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Debug__c) ;
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Debug_Fine__c) ;
        System.assertEquals(true, sl.splunkLogging.Enable_Log_Level_Debug_Finer__c) ;
        sl.fatal(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'fatal message', 'SplunkLoggingTest.testSplunkLogging');
        sl.error(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'error message', 'SplunkLoggingTest.testSplunkLogging');
        sl.warn(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'warn message', 'SplunkLoggingTest.testSplunkLogging');
        sl.info(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'info message', 'SplunkLoggingTest.testSplunkLogging');
        sl.debug(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'debug message', 'SplunkLoggingTest.testSplunkLogging');
        sl.debugFine(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'debug fine message', 'SplunkLoggingTest.testSplunkLogging');
        sl.debugFiner(componentName, ACVUtility.currentLineNumber(), 'User__c', UserInfo.getUserId(), SplunkHelper.CONTEXT_TYPE.APEX_CODE, 'debug finer message', 'SplunkLoggingTest.testSplunkLogging');
        
        String classMethod = 'SplunkLoggingTest.testSplunkLogging';
		sl.addDebug(ACVUtility.currentLineNumber(), classMethod, 'add debug');
		sl.addDebugFine(ACVUtility.currentLineNumber(), classMethod, 'add debug fine');
		sl.addDebugFiner(ACVUtility.currentLineNumber(), classMethod, 'add debug finer');
        sl.saveLogDebugMessages();
        
    }
    
}