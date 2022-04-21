public class EasyPostWriteBackData {
	public static void dataWriteBackToSobject(String writeBackName, List<sobject> recordList, Map<String,Object> responseMap){
		if(recordList.size() > 0) {
			List<String> writeBackNameList = writeBackName.split(',');
			Map<String,String> writeBackMap = new Map<String,String>();
			for(String writeBackPair :writeBackNameList){
				List<String> jsonNameToSFDCAPIName = writeBackPair.split('=');
				writeBackMap.put(jsonNameToSFDCAPIName[0],jsonNameToSFDCAPIName[1]);	
			}
			System.debug('writeBackMap:'+writeBackMap);
 
			Map<String,String> writeBackValueMap = new Map<String,String>();
			if(responseMap.get('tracker') != null){
				Map<String,Object> responseTrackerList = (Map<String,Object>)responseMap.get('tracker');
				System.debug('responseTrackerList:'+responseTrackerList);
				writeBackValueMap.put('tracking_code',String.valueOf(responseTrackerList.get('tracking_code')));
				writeBackValueMap.put('public_url',String.valueOf(responseTrackerList.get('public_url')));
			}
			if(responseMap.get('postage_label') != null){
				Map<String,Object> responsePostageLabelList = (Map<String,Object>)responseMap.get('postage_label');
				System.debug('responsePostageLabelList:'+responsePostageLabelList);
				writeBackValueMap.put('label_url',String.valueOf(responsePostageLabelList.get('label_url')));
			}
			writeBackValueMap.put('id',String.valueOf(responseMap.get('id')));
			System.debug('writeBackValueMap:'+writeBackValueMap);

			List<sobject> sobjectListToBeUpdated = new List<sobject>();
			for(sobject sobj: recordList) {
				Sobject newsobj = sobj.clone(true, false, false, false);
				for(String jsonName :writeBackMap.keySet()){ 
					System.debug('jsonName:'+jsonName);
					System.debug('sfField:'+writeBackMap.get(jsonName));
					System.debug('value:'+writeBackValueMap.get(jsonName));
					newsobj.put(writeBackMap.get(jsonName), writeBackValueMap.get(jsonName));
				}
				System.debug('newsobj:'+newsobj);
				sobjectListToBeUpdated.add(newsobj);
			}
            if(sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}
}