global class DateOfFirstSaleBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    public static List<String> toSendList = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get is of transporter accounts to exclude them
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        //0120a0000000MaNAAU
        //query
        String query = 'SELECT Id, Date_of_First_Sale__c FROM Account WHERE RecordTypeId != :recordTypeId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //create map out of scope (<Id, Account>)
        Map<Id, Account> accountMap = new Map<Id, Account>(scope);
        Map<Id, DateTime> firstSaleDate = new Map<Id, DateTime>();
        //set of successful statuses
        Set<String> successfulStatuses = new Set<String>{'Ended_Accepted', 'Counter_Accepted', 'Counter_Original_Accepted'};
        //query for auctions
        List<Auction__c> auctionList = [SELECT Id, Seller_Dealership__c, End_Time__c FROM Auction__c WHERE Seller_Dealership__c IN :scope AND Status__c IN :successfulStatuses ORDER BY End_Time__c ASC];
        //loop over auction list
        if (auctionList != null && auctionList.size() > 0) { //null handler
            for (Auction__c a : auctionList) {
                //add auctions to map if the seller is not in map already (map of seller by end time of <Id, DateTime>)
                if (firstSaleDate.get(a.Seller_Dealership__c) == null) {
                    if (a.End_Time__c != null) { //null handler
                        //add seller and end time - because next time same seller comes up, ignore that auction
                        firstSaleDate.put(a.Seller_Dealership__c, a.End_Time__c);
                        //set end time equal to date of first sale in accountMap

                        Integer Day = a.End_Time__c.Day();
                        Integer Month = a.End_Time__c.Month();
                        Integer Year = a.End_Time__c.Year();
                        DateTime tempTime = DateTime.newInstance(Year, Month, Day, 6, 0, 0);
                        Date actualDate = tempTime.date();
                        accountMap.get(a.Seller_Dealership__c).Date_of_First_Sale__c = actualDate;
                    }
                    else {
                        //tell us that an end time is null because that should never happen
                        DateOfFirstSaleBatch.toSendList.add('Null End_Time__c on Auction Id ' + a.Id);
                    }

                    if (firstSaleDate.keySet() != null && accountMap.keySet() != null) { //null handler
                        if (firstSaleDate.keySet().size() == accountMap.keySet().size()) {
                            //end loop
                            break;
                        }
                    }
                }
            }
        }

        //update accounts
        Database.SaveResult[] mesgList = Database.update(accountMap.values(), false); //try to update account
        if (mesgList.size() > 0) { //null handler
            for (Database.SaveResult upRes : mesgList) {
                if (upRes.isSuccess()) {
                    //success message
                    String sucMesg = 'SUCCESS on Id: ' + upRes.getId();
                    DateOfFirstSaleBatch.toSendList.add(sucMesg);
                }
                else {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    DateOfFirstSaleBatch.toSendList.add(errMesg);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //finish
        if (DateOfFirstSaleBatch.toSendList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('DateOfFirstSaleBatch: ' + a.Status);
            String body = 'Results from DateOfFirstSaleBatch: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(DateOfFirstSaleBatch.toSendList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
    
    global void execute(SchedulableContext sc) {
        //schedule
        DateOfFirstSaleBatch dfsb = new DateOfFirstSaleBatch();
        Database.executeBatch(dfsb, 50);
    }
}