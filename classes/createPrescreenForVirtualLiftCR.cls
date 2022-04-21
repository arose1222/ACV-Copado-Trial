public class createPrescreenForVirtualLiftCR extends ClassInterface{
    
    public override List<SObject> handle(List<SObject> objList){
        //check the type call method based on type passed in
        return (List<SObject>)checkForVLImages((List<Condition_Report__c>)objList);
    }

    public override Map<String, PrescreenServiceHelper.InspectionWrapper> handle(Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap, CR_Review_Trigger__mdt crt){
        system.debug('VLCR handle entered');
        return checkForVLWithInspectionWrappers(wrapperMap, crt);
    }

    public List<Condition_Report__c> checkForVLImages(List<Condition_Report__c> crList){

        List<String> crIdList = new List<String>();
        Map<String, Condition_Report__c> vinToCRMap = new Map<String, Condition_Report__c>();
        for(Condition_Report__c c : crList){
            crIdList.add(c.id);
        }

        for(Condition_Report__c c :[Select id, Floor_Price__c, VCI_Creator__r.Successful_Virtual_Lift_Prescreens__c, VCI_Creator__r.Virtual_Lift_Enabled__c, VIN__c, Dealership__c, Vehicle__c from Condition_Report__c where ID in :crIdList]){
            if(c.Floor_Price__c >= 1 && c.VCI_Creator__r.Virtual_Lift_Enabled__c && ( c.VCI_Creator__r.Successful_Virtual_Lift_Prescreens__c == null || c.VCI_Creator__r.Successful_Virtual_Lift_Prescreens__c < 10)){
                vinToCRMap.put(c.VIN__c, c);
            }
        }

        if(vinToCRMap.values().size() > 0){
            checkForVLCallOut(JSON.serialize(vinToCRMap));
        }
        //yeah, this is super weird but I don't want this to return anytihng since we are waiting for a call out in a future call
        return new List<Condition_Report__c>();
    }

    @future(callout=true)
    public static void checkForVLCallOut(String input){

        Map<String, Condition_Report__c> vinToCRMap = (Map<String, Condition_Report__c>)JSON.deserialize(input,Map<String, Condition_Report__c>.class);
        list<Group> queueList = [select Id from Group where  Type = 'Queue' AND NAME = 'CR Queue'];
        List<Condition_Report_Prescreen__c> insertList = new List<Condition_Report_Prescreen__c>();
        List<Condition_Report_Prescreen__c> reasonNeededList = new List<Condition_Report_Prescreen__c>();
        List<Prescreen_Reason__c> reasonInsertList = new List<Prescreen_Reason__c>();
        Map<Id, Condition_Report__c> crWithVLMap = new Map<Id,Condition_Report__c>();
        Map<String,String> LinkToVL = new Map<String,String>();
        List<Condition_Report_Prescreen__c> updateList = new List<Condition_Report_Prescreen__c>();
        VirtualLiftAPIHelper api = new VirtualLiftAPIHelper();

        //loop through call out results to check for VINs that have VL images
        List<VLVinObject.Virtual_lift_list> vlList = api.getVLsFromListOfVins(new List<String>(vinToCRMap.keySet()));
        if(vlList!= null && vlList.size() > 0){
            for(VLVinObject.Virtual_lift_list vl :vlList){
                if(vl != null && vinToCRMap.get(vl.vin) != null){
                    crWithVLMap.put(vinToCRMap.get(vl.vin).id,vinToCRMap.get(vl.vin));
                    LinkToVL.put(vinToCRMap.get(vl.vin).id, vl.link);
                }
            }
            //Check to make sure we are not creating duplicate Prescreen records for the condition report, add to a new list that we will use to generate reason records
            for(Condition_Report_Prescreen__c crp :[Select Id, Condition_Report__c, Virtual_Lift_Image_URL__c,(Select ID from Prescreen_Reasons__r where name like '%Virtual Lift%') from Condition_Report_Prescreen__c where Condition_Report__c in :crWithVLMap.keySet()]){
                if(crp.Prescreen_Reasons__r.size() == 0){
                    reasonNeededList.add(crp);
                    crp.Virtual_Lift_Image_URL__c = LinkToVL.get(crp.Condition_Report__c);
                    updateList.add(crp);
                }
                crWithVLMap.remove(crp.Condition_Report__c);
            }
            //create the new prescreen records
            for(Condition_Report__c cr:crWithVLMap.values()){
                insertList.add(generatePrescreenRecord(cr,queueList[0].id,LinkToVL.get(cr.id)));
            }
            //insert the new prescreen records and add them to the reason list
            if(insertList.size() > 0){
                insert insertList;
                reasonNeededList.addAll(insertList);
            }
            if(updateList.size() > 0){
                update updateList;
            }
            if(reasonNeededList.size() > 0){
                insert generatePrescreenReasonList(reasonNeededList);
            }
        }
    }


    public static Map<String, PrescreenServiceHelper.InspectionWrapper> checkForVLWithInspectionWrappers(Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap, CR_Review_Trigger__mdt crt){

        //go from wrapper to wrapper not to idef
        Map<String, InspectionDefinition> vinIdefMap = new Map<String, InspectionDefinition>();
        Map<String, PrescreenServiceHelper.InspectionWrapper> vinWrapperMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        Map<String, Contact> contactVLCheckMap = new Map<String, Contact>();
        Set<String> contactIdentityIdSet = new Set<String>();
        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
            contactIdentityIdSet.add(wrapper.idef.inspectorIdentityId);
        }

        for(Contact c :[SELECT Id, Identity_Id__c, Virtual_Lift_Enabled__c, Successful_Virtual_Lift_Prescreens__c FROM Contact WHERE Identity_Id__c IN : contactIdentityIdSet]){
            contactVLCheckMap.put(c.Identity_Id__c, c);
        }

        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
            if(wrapper.idef != null && wrapper.idef.inspectedVehicle != null && wrapper.idef.inspectedVehicle.vin != null && contactVLCheckMap.get(wrapper.idef.inspectorIdentityId) != null
            && contactVLCheckMap.get(wrapper.idef.inspectorIdentityId).Virtual_Lift_Enabled__c
            && (contactVLCheckMap.get(wrapper.idef.inspectorIdentityId).Successful_Virtual_Lift_Prescreens__c == null 
            || contactVLCheckMap.get(wrapper.idef.inspectorIdentityId).Successful_Virtual_Lift_Prescreens__c < 10 )){
                vinIdefMap.put(wrapper.idef.inspectedVehicle.vin, wrapper.idef);
                vinWrapperMap.put(wrapper.idef.inspectedVehicle.vin, wrapper);
            }
        }
        
        
        
        Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperWithVLMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        //maps inspection id to link
        Map<String,String> LinkToVL = new Map<String,String>();
       
        VirtualLiftAPIHelper api = new VirtualLiftAPIHelper();

        //loop through call out results to check for VINs that have VL images
        List<VLVinObject.Virtual_lift_list> vlList = api.getVLsFromListOfVins(new List<String>(vinWrapperMap.keySet()));
        if(vlList!= null && vlList.size() > 0){
            for(VLVinObject.Virtual_lift_list vl :vlList){
                //for each that has virtual lift url add it to wrapper
                //add prescreen reason to wrapper
                if(vl != null && vinWrapperMap.get(vl.vin) != null){
                    //crWithVLMap.put(vinIdefMap.get(vl.vin).id,vinIdefMap.get(vl.vin));
                    wrapperWithVLMap.put(vinWrapperMap.get(vl.vin).idef.inspectionId, vinWrapperMap.get(vl.vin));
                    LinkToVL.put(vinWrapperMap.get(vl.vin).idef.inspectionID, vl.link);
                    wrapperMap.get(vinWrapperMap.get(vl.vin).idef.inspectionID).prescreenReasons.add(crt.Prescreen_Reason__c);
                    wrapperMap.get(vinWrapperMap.get(vl.vin).idef.inspectionID).prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper(crt.Prescreen_Reason__c, crt.Is_Aux_Reason__c));
                }
            }
        }
        return wrapperMap;
    }

    public static Condition_Report_Prescreen__c generatePrescreenRecord(Condition_Report__c c, Id queueId, String link){
        return new Condition_Report_Prescreen__c(
                    Condition_Report__c = c.id, 
                    OwnerId = queueId, 
                    VCI__c = c.VCI_Creator__c,
                    Seller_Dealership__c = c.Dealership__c,
                    Vehicle__c = c.Vehicle__c,
                    Virtual_Lift_Image_URL__c = link.length() <= 255 ? link : ''
                );
    }

    //overload generate prescreen to accept an inspection definition
    public static List<Condition_Report_Prescreen__c> generatePrescreenRecordsFromIdefs(List<InspectionDefinition> idefList, Id queueId, Map<String, String> inspectionIdToLink){

        //get accountinfo
        //get vci info

        Set<String> inspectorIdSet = new SEt<String>();
        Set<String> dealerIdSet = new Set<String>();

        for(InspectionDefinition idef: idefList){
            if(idef.inspectorIdentityId != null && idef.dealershipId != null){
                inspectorIdSet.add(idef.inspectorIdentityId);
                dealerIdSet.add(String.valueOf(idef.dealershipId));
            }
        }

        Map<String, Contact> vciMap = new Map<String,Contact>();
        Map<String, Account> dealerMap = new Map<String,Account>();

        List<Condition_Report_Prescreen__c> crpInsertList = new List<Condition_Report_Prescreen__c>();
        for(Contact c : [SELECT Id, Identity_Id__c FROM Contact WHERE Identity_Id__c in :inspectorIdSet]){
            vciMap.put(c.Identity_Id__c, c);
        }
        for(Account a :[SELECT Id, Dealership_Id__c FROM Account WHERE Dealership_Id__c in : dealerIdSet]){
            dealerMap.put(a.Dealership_Id__c, a);
        }

        List<Condition_Report_Prescreen__c> crpList = new List<Condition_Report_Prescreen__c>();

        for(InspectionDefinition idef: idefList){
            if(idef.inspectorIdentityId != null && idef.dealershipId != null && idef.inspectionID != null && inspectionIdToLink.containsKey(idef.inspectionID)){
                string link = inspectionIdToLink.get(idef.inspectionID);
                crpList.add(new Condition_Report_Prescreen__c(
                    VCI__c = vciMap.get(idef.inspectorIdentityId).Id,
                    Inspection_Id__c = idef.inspectionID,
                    Account__c = dealerMap.get(String.valueOf(idef.dealershipId)).Id,
                    Virtual_Lift_Image_URL__c = link.length() <= 255 ? link : '',
                    OwnerId = queueId
                ));
            }
        }

        return crpList;
    }

    public static List<Prescreen_Reason__c> generatePrescreenReasonList(List<Condition_Report_Prescreen__c> crp){
        List<Prescreen_Reason__c> returnList = new List<Prescreen_Reason__c>();
        for(Condition_Report_Prescreen__c cr :crp){
            returnList.add(new Prescreen_Reason__c(Name = 'Virtual Lift', Condition_Report_Prescreen__c = cr.id));
        }
        return returnList;
    }
}