/**
 * @description It is used to add logging in splunk. You can turn on/off splunk logging using Splunk_Logging__mdt custom metadata settings.
 * 
 * 
 * @author Manmeet Vaseer
 * @date 02/09/2022
 * 
 * @history 
 * 			
 * 
 */
public class SplunkLogging {
    // Size is in Number of Characters (not Lines). 9000 chars are around 60 lines, where each line is 80 chars long.
    public Integer AUTO_SAVE_MSGS = 9000; // automatcially save to the splunk when the logDebugMessages size (num of characters) reaches the specified limit.
    public Splunk_Logging__mdt splunkLogging = null;
    
    private String componentName;
    private String logDebugMessages = '';
        
    public SplunkLogging(String splunkLoggingName)	{
        componentName = splunkLoggingName;
        splunkLogging = [SELECT Enable_Log_Level_Fatal__c, Enable_Log_Level_Error__c, Enable_Log_Level_Warn__c, Enable_Log_Level_Info__c, 
                         Enable_Log_Level_Debug__c, Enable_Log_Level_Debug_Fine__c, Enable_Log_Level_Debug_Finer__c, 
                         Enable_System_Debug__c, Enable_System_Debug_Fine__c, Enable_System_Debug_Finer__c
                         FROM Splunk_Logging__mdt WHERE DeveloperName = :splunkLoggingName LIMIT 1];
        
        if(splunkLogging == null)	{
            SplunkHelper.Log logger = new SplunkHelper.Log();
            logger.componentName = 'SplunkLogging';
            logger.location = String.valueOf(ACVUtility.currentLineNumber());
            logger.logLevel = SplunkHelper.LOGLEVEL.FATAL;
            logger.message = 'Unable to fetch records from Splunk_Logging__mdt for the Name: ' + splunkLoggingName;
            logger.sfObject = 'Splunk_Logging__mdt';
            logger.sfRecordId = UserInfo.getUserId();
            logger.stackTrace = 'SplunkLogging(String splunkLoggingGroupName)';
            logger.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
            if(!Test.isRunningTest()){
                SplunkHelper.processLog(logger);
            }            
        }
    }
        
    public void addDebug(Integer location,  String classMethod, String message)	{
        if(splunkLogging.Enable_System_Debug__c) System.debug(location + '. ' + classMethod + ':: ' + message);
        
        if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug__c)	{
            String msg = location + '. ' + classMethod + ':: ' + message + '\n';
            logDebugMessages = logDebugMessages + msg;
        
            if(logDebugMessages.length() >= AUTO_SAVE_MSGS)	{
                saveLogDebugMessages();
            }
        }
    }

    public void addDebugFine(Integer location,  String classMethod, String message)	{
        if(splunkLogging.Enable_System_Debug_Fine__c) System.debug(location + '. ' + classMethod + ':: ' + message);
        
        if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug_Fine__c)	{
            String msg = location + '. ' + classMethod + ':: ' + message + '\n';
            logDebugMessages = logDebugMessages + msg;
        
            if(logDebugMessages.length() >= AUTO_SAVE_MSGS)	{
                saveLogDebugMessages();
            }
        }
    }

    public void addDebugFiner(Integer location,  String classMethod, String message)	{
        if(splunkLogging.Enable_System_Debug_Finer__c) System.debug(location + '. ' + classMethod + ':: ' + message);
        
        if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug_Finer__c)	{
            String msg = location + '. ' + classMethod + ':: ' + message + '\n';
            logDebugMessages = logDebugMessages + msg;
        
            if(logDebugMessages.length() >= AUTO_SAVE_MSGS)	{
                saveLogDebugMessages();
            }
        }
    }
    
    public void saveLogDebugMessages()	{
        if(logDebugMessages.length() > 0)	{
            SplunkHelper.Log logger = createLogger(componentName, ACVUtility.currentLineNumber(), '', '', SplunkHelper.CONTEXT_TYPE.APEX_CODE, logDebugMessages, '');
            if(logger != null)	{
                logger.logLevel = SplunkHelper.LOGLEVEL.DEBUG; 
                if(splunkLogging != null && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
            }
            
            logDebugMessages = '';
        }
    }
    
    public SplunkHelper.Log createLogger(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
        SplunkHelper.Log logger = new SplunkHelper.Log();
        logger.componentName = componentName;
        logger.location = String.valueOf(location);
        logger.sfObject = obj;
        logger.sfRecordId = recordId;
        logger.setContext(context);
        logger.message = message;
        logger.stackTrace = stackTrace;
        logger.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS};
            
        return logger;
    }
        
    public void debug(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        debug(logger);
    }

    public void debugFine(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        debugFine(logger);
    }
    
    public void debugFiner(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        debugFiner(logger);
    }

    public void info(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        info(logger);
    }
    
    public void warn(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        warn(logger);
    }

    public void error(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        error(logger);
    }

    public void fatal(String componentName, Integer location, String obj, String recordId, SplunkHelper.CONTEXT_TYPE context, String message, String stackTrace)	{
		SplunkHelper.Log logger = createLogger(componentName, location, obj, recordId, context, message, stackTrace);
        fatal(logger);
    }
    
    public void debug(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.DEBUG; 
            if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }

    public void debugFine(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.DEBUG; 
            if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug_Fine__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }

    public void debugFiner(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.DEBUG; 
            if(splunkLogging != null && splunkLogging.Enable_Log_Level_Debug_Finer__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }
    
    public void info(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.INFO;
        	if(splunkLogging != null && splunkLogging.Enable_Log_Level_Info__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }

    public void warn(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.WARN;
        	if(splunkLogging != null && splunkLogging.Enable_Log_Level_Warn__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }
    
    public void error(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        	if(splunkLogging != null && splunkLogging.Enable_Log_Level_Error__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }
    
    public void fatal(SplunkHelper.Log logger)	{
        if(logger != null)	{
            logger.logLevel = SplunkHelper.LOGLEVEL.FATAL;
        	if(splunkLogging != null && splunkLogging.Enable_Log_Level_Fatal__c && !Test.isRunningTest()) SplunkHelper.buildAndProcessLog(logger);
        }
    }
}