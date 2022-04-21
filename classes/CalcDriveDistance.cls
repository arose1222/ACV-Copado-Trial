public class CalcDriveDistance {

    //used for before insert
    /*public static void run(List<Case> cases) {
        if(System.isFuture()) {
            System.Debug('isFutre detected exiting function.');
            return;
        }
        List<Case> validCases = new List<Case>();

        //iterate over the list of cases and add cases that have a street address and postal code
        //set to validCases list object
        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            'Transportation').getRecordTypeId();

        for(Case c : cases) {
            // Add the case if the type is Transportation, one of the delivery addresses are set,
            // the pickup address is set and the distance isn't pre-populated

            if((// If either Delivery Address or Alternate Address are populated
                (c.default_delivery_address__c != null &&
                c.default_delivery_city__c != null &&
                c.default_delivery_postal_code__c != null &&
                c.default_delivery_country__c != null)
                ||
                (c.Alternate_Delivery_Address__c != null &&
                c.Alternate_Delivery_City__C != null &&
                c.Alternate_Delivery_Postal_Code__c != null &&
                c.Alternate_Delivery_State__c != null &&
                c.Alternate_Delivery_Country__C != null))
                &&
                // If Pickup Address is populated
                (c.pickup_address__c != null &&
                c.default_pickup_city__c != null &&
                c.default_pickup_postal_code__c != null &&
                c.default_pickup_country__c != null) &&
                // If Transportation Case and Transport Distance is null
                (c.RecordTypeId == TransportationRTId) && (c.Transportation_Distance__c == null) ) {
                validCases.add(c);
            }
        }
        if(validCases.size() > 0) {
            Calculate(JSON.serialize(validCases));
        }

    }

    //used for before update
    public static void run(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(System.isFuture()) {
            System.Debug('isFutre detected exiting function.');
            return;
        }
        List<Case> validCases = new List<Case>();
        Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            'Transportation').getRecordTypeId();

        //add the Case if any of the address fields changed and the Case type is Transportation
        for (Case newCase : (List<Case>)newCaseMap.values()) {
            Case oldCase = (Case)oldCaseMap.get(newCase.Id);
            if( (oldCase.default_delivery_address__c != newCase.default_delivery_address__C ||
                 oldCase.default_delivery_city__c != newCase.default_delivery_city__C ||
                 oldCase.default_delivery_postal_code__c != newCase.default_delivery_postal_code__C ||
                 oldCase.default_delivery_country__c != newCase.default_delivery_country__C ||
                 oldCase.pickup_address__c != newCase.pickup_address__C ||
                 oldCase.default_pickup_city__c != newCase.default_pickup_city__C ||
                 oldCase.default_pickup_postal_code__c != newCase.default_pickup_postal_code__C ||
                 oldCase.default_pickup_country__c != newCase.default_pickup_country__C ||
                 oldCase.Alternate_Delivery_Address__c != newCase.Alternate_Delivery_Address__c ||
                 oldCase.Alternate_Delivery_City__C != newCase.Alternate_Delivery_City__C ||
                 oldCase.Alternate_Delivery_Postal_Code__c != newCase.Alternate_Delivery_Postal_Code__c ||
                 oldCase.Alternate_Delivery_State__c != newCase.Alternate_Delivery_State__C||
                 oldCase.Alternate_Delivery_Country__C != newCase.Alternate_Delivery_Country__C) &&
                (newCase.RecordTypeId == TransportationRTId) && (oldCase.Transportation_Distance__c == newCase.Transportation_Distance__c) ) {
                validCases.add(newCase);
            }
        }
        System.Debug('Cases that had field changed: ');
        System.Debug(validCases);

        //Create set of ID's to use with the Calculate method
        //convert the Set into JSON since @future cannot accept sobjects or lists

        if(validCases.size() > 0) {
            Calculate(JSON.serialize(validCases));
        }

    }
    @future (callout=true)
    public static void Calculate(String jsonInput){
        Boolean errorFlag = false;
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        Integration_Result__C integrationResult = new Integration_Result__C();
        List<Case> validCases = (List<Case>)System.JSON.deserializeStrict(jsonInput,
                                                                          List<Case>.Class);
        //init Geopointe API instance
        geopointe.API.DistanceService geo = new geopointe.API.DistanceService();
        Boolean send2Geopointe = false;
        for(Case c : validCases) {
            //Pass the Alternate Delivery address if the fields, other than country, are not blank or null
            //Otherwise pass the Default Delivery Address
            //Geopointe Distance Service takes the start and end locations as strings so we concatenate them
            //before passing them in.
            if(c.Alternate_Delivery_Address__c != null && c.Alternate_Delivery_City__C != null &&
               c.Alternate_Delivery_Postal_Code__c != null &&
               c.Alternate_Delivery_State__c != null &&
               c.Alternate_Delivery_Address__c != '' && c.Alternate_Delivery_City__C != '' &&
               c.Alternate_Delivery_Postal_Code__c != '' && c.Alternate_Delivery_State__c != '' ) {

                geo.add(
                    c.Alternate_Delivery_Address__c + ' ' + c.Alternate_Delivery_City__C + ' ' + c.Alternate_Delivery_State__c + ' ' + c.Alternate_Delivery_Postal_Code__c + ' ' + c.Alternate_delivery_country__c,
                    c.pickup_address__c + ' ' + c.default_pickup_city__c + ' ' + c.default_pickup_state__c + ' ' + c.default_pickup_postal_code__c + ' ' +
                    c.default_pickup_country__c);
                send2Geopointe = true;

            }else if(c.Default_Delivery_Address__c != null && c.Default_Delivery_City__C != null &&
                     c.Default_Delivery_Postal_Code__c != null &&
                     c.Default_Delivery_State__c != null &&
                     c.Default_Delivery_Address__c != '' && c.Default_Delivery_City__C != '' &&
                     c.Default_Delivery_Postal_Code__c != '' && c.Default_Delivery_State__c != '' &&
                     c.Pickup_Address__c != null && c.Default_Pickup_City__C != null &&
                     c.Default_Pickup_Postal_Code__c != null && c.Default_Pickup_State__c != null &&
                     c.Pickup_Address__c != '' && c.Default_Pickup_City__C != '' &&
                     c.Default_Pickup_Postal_Code__c != '' && c.Default_Pickup_State__c != '' ) {

                geo.add(
                    c.default_delivery_address__c + ' ' + c.default_delivery_city__c + ' ' + c.default_delivery_state__c + ' ' + c.default_delivery_postal_code__c + ' ' + c.default_delivery_country__c,
                    c.pickup_address__c + ' ' + c.default_pickup_city__c + ' ' + c.default_pickup_state__c + ' ' + c.default_pickup_postal_code__c + ' ' +
                    c.default_pickup_country__c);
                send2Geopointe = true;
            }
        }

        //create list of drivings distances returned from geopointe
        //If in an error occurs we add it to the Intergration Result Table
        List<double> driveDistances = new List<double>();
        if (validCases.size() > 0 && send2Geopointe == true) {
            try{
                driveDistances = geo.getListOfDistances();
            }
            catch(Exception e) {
                errorFlag = true;

                integrationResult.Integration_Name__C = 'Geopointe API';
                integrationResult.Request_Message__C = String.valueof(geo);
                integrationResult.Response_Message__c = String.Valueof(e);
                integrationResult.Status_Code__C = 500;
                integrationResult.Status_Message__C = 'Geopointe API Error';
                integrationResult.recordId__c = '';
                integrationResult.Integration_Type__c = 'GET';
                for (Case c : validCases) {
                    integrationResult.recordId__c = integrationResult.recordId__c + String.valueOf(
                        c.Id) +
                                                    ', ';
                }
                insert integrationResult;
            }
        }else{
            System.Debug('No address data changes detected. Exiting CalcDistance');
            return;
        }

        // Log error if the response size does not match request size
        // Does not stop update of Distances on the Cases but wrong values may be added to some 
        if ( validCases.size() != driveDistances.size() ) {
            Integration_Result__c mismatchError = new Integration_Result__c();
            Set<Id> caseIds = new Set<Id>();
            // Get all Case record Id's
            for (Case c : validCases) {
                caseIds.add(c.Id);
            }
            mismatchError.Integration_Name__c = 'Geopointe API';
            mismatchError.Request_Message__c = String.valueOf(geo);
            mismatchError.Response_Message__c = 'The response size of the Geopointe call does not match the request size. ' +
                                                'One of the Cases may have a null value for the address fields. ' +
                                                String.valueOf(caseIds);
            mismatchError.Status_Code__c = 500;
            mismatchError.Status_Message__c = 'Geopointe API';
            mismatchError.Integration_Type__c = 'GET';

            integrationList.add(mismatchError);
        }

        // Attempt update if Geopointe didn't fail
        if(errorFlag == false) {
            for(Integer i = 0; i < validCases.size(); i++) {
                if(driveDistances.size()-1 >= i) {
                    Integration_Result__c result = new Integration_Result__c();
                    validCases[i].Transportation_Distance__C = driveDistances[i];

                    result.Integration_Name__c = 'Geopointe API';
                    result.Request_Message__c = String.valueOf(geo);
                    result.Response_Message__c = String.valueOf(driveDistances[i]);
                    result.Status_Code__c = 200;
                    result.Status_Message__c = 'Geopointe API';
                    result.Integration_Type__c = 'GET';
                    result.recordId__c = validCases[i].Id;

                    integrationList.add(result);
                }
                else{
                    break;
                }
            }
            update validCases;
            insert integrationList;
        }
    }*/
}