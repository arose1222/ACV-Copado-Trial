public class AcvIntegrationWriteBackData {

	public static void dataWriteBackToSobject(String writeBackName, List < sobject > recordList, map < string, Object > responceMap) {
		If(recordList.size() > 0) {
			list < String > writeBackNameList = writeBackName.split('\\.');
			list < sobject > sobjectListToBeUpdated = New list < sobject > ();
			for (sobject sobj: recordList) {
				Sobject newsobj = sobj.clone(true, false, false, false);
				newsobj.put(writeBackNameList.get(1), (String.valueOf(responceMap.get(writeBackNameList.get(0)))));
				sobjectListToBeUpdated.add(newsobj);
			}
            if (sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}

	public static void dataWriteBackToSobjectARB(String writeBackName, List < sobject > recordList) {
		If(recordList.size() > 0) {
			list < sobject > sobjectListToBeUpdated = New list < sobject > ();
			for (sobject sobj: recordList) {
				Sobject newsobj = sobj.clone(true, false, false, false);
				newsobj.put(writeBackName, (String)sobj.get('Auction_Number_Case__c'));
				sobjectListToBeUpdated.add(newsobj);
			}
            if (sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}

	public static void dataWriteBackToSobjectRP(String writeBackName, List < sobject > recordList, map < string, Object > responceMap) {
		If(recordList.size() > 0) {
			list < sobject > sobjectListToBeUpdated = New list < sobject > ();
			for (sobject sobj: recordList) {
				System.debug('RP sobj Id:'+sobj.get('id'));
				String sobjId = String.valueOf(sobj.get('id'));
				if(responceMap.containsKey(sobjId) && responceMap.get(sobjId) != null){
					String extId = String.valueOf(responceMap.get(sobjId));
					System.debug('RP extId:'+extId);
					Sobject newsobj = sobj.clone(true, false, false, false);
					newsobj.put(writeBackName, extId);
					newsobj.put('Send_To_ACV__c',false);
					sobjectListToBeUpdated.add(newsobj);
					System.debug(newsobj);
				}
			}
            if (sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}

	public static void dataWriteBackToSobjectTitle(String writeBackName, List < sobject > recordList, map < string, Object > responceMap) {
		System.debug('WriteBack:'+System.isBatch());
		if(System.isBatch()){
			return; 
		}else{
			Set<String> sAuctionIdSuccesses = new Set<String>();
			List<Object> successesMap = (List<Object>) responceMap.get('successes');
			System.debug('Title successMap:'+successesMap);
			for(Object successObj : (List<Object>)responceMap.get('successes')){
				Map < String, Object > successObjMap = (Map < String, Object > ) successObj;
				System.debug('Title successesObjMap:'+successObjMap);
				System.debug('Title successesObjMap auction_id:'+successObjMap.get('auction_id'));
				sAuctionIdSuccesses.add(String.valueOf(successObjMap.get('auction_id')));
			}
			System.debug(sAuctionIdSuccesses);
			if(recordList.size() > 0) {
				list < sobject > sobjectListToBeUpdated = New list < sobject > ();
				for (sobject sobj: recordList) {
					System.debug('Title sobj Id:'+sobj.get('id'));
					String auctionId = String.valueOf(sobj.get('Auction_Number_Case__c'));
					System.debug('Title Case auction_id:'+auctionId);
					if(sAuctionIdSuccesses.contains(auctionId)){
						System.debug('Title auctionId Success:'+auctionId);
						//Sobject newsobj = sobj.clone(true, false, false, false);
						Case c = (Case)sobj;
						Case newsobj = new Case(Id=c.Id);
						newsobj.put(writeBackName, false);
						sobjectListToBeUpdated.add(newsobj);
						System.debug('Title Case Update:'+newsobj);
					}
				}
				if (sobjectListToBeUpdated.size() > 0) {
					update sobjectListToBeUpdated;
				}
			}
		}
	}

	public static void dataWriteBackToSobjectTrans(String writeBackName, List < sobject > recordList, map < string, Object > responceMap, String integrationAction) {
		List<String> writeBackNameList = writeBackName.split('\\.');

		Set<String> sTransIdSuccesses = new Set<String>();
		Map<String,String> mapTransAuctionIdToTransId = new Map<String,String>();
		Map<String,String> mapBuyerSellerIdToTransId = new Map<String,String>();
		//Parse through JSON response to data/successes/update
		List<Object> successesMap = (List<Object>) responceMap.get('successes');

		for(Object successObj : (List<Object>)responceMap.get('successes')){
			Map < String, Object > successObjMap = (Map < String, Object > ) successObj;
			Map < String, Object > updateObjMap = (Map < String, Object > ) successObjMap.get('update');
			//Build Map of successful Trans AuctionId to Trans Id for writeback
			if(integrationAction.contains('Create')){
				String transId = String.valueOf(updateObjMap.get('transportation_request_id'));
				String transAuctionId = String.valueOf(updateObjMap.get('auction_id'));
				if(transAuctionId != '0'){
					mapTransAuctionIdToTransId.put(transAuctionId,transId);
				}
				else{
					//doing this so we can have transportation cases with no auctions
					String sellerbuyerKey = String.valueOf(updateObjMap.get('seller_dealership_id'))+String.valueOf(updateObjMap.get('buyer_dealership_id'));
					mapBuyerSellerIdToTransId.put(sellerbuyerkey, transId);
				}
			//Build Set of successful TransId for writeback
			}else{
				sTransIdSuccesses.add(String.valueOf(updateObjMap.get('id')));
			}
		}

		//Parse processed records and perform writeback logic
		if(recordList.size() > 0) {
			list < sobject > sobjectListToBeUpdated = New list < sobject > ();
			if(integrationAction.contains('Create')){
				for (sobject sobj: recordList) {
					String sellerBuyerKey =String.ValueOf(sobj.get('Seller_External_Id__c'))+String.ValueOf(sobj.get('Buyer_External_Id__c'));
					String auctionId = String.valueOf(sobj.get('Auction_Number_Case__c'));
					if(mapTransAuctionIdToTransId.containsKey(auctionId)){
						String newTransId = mapTransAuctionIdToTransId.get(auctionId);
						SObject newsobj = Schema.getGlobalDescribe().get('Case').newSObject();
						newsobj.put(writeBackNameList[0], false);
						newsobj.put(writeBackNameList[1], newTransId);
						newsobj.put('Id', sobj.get('Id'));
						sobjectListToBeUpdated.add(newsobj);
					}
					else if(mapBuyerSellerIdToTransId.containsKey(sellerBuyerKey)){
						String newTransId = mapBuyerSellerIdToTransId.get(sellerBuyerKey);
						SObject newsobj = Schema.getGlobalDescribe().get('Case').newSObject();
						newsobj.put(writeBackNameList[0], false);
						newsobj.put(writeBackNameList[1], newTransId);
						newsobj.put('Id', sobj.get('Id'));
						sobjectListToBeUpdated.add(newsobj);
					}
					
				}
			}else{
				for (sobject sobj: recordList) {
					String transId = String.valueOf(sobj.get('ACV_Transportation_Request_Id__c'));
					if(sTransIdSuccesses.contains(transId)){
						SObject newsobj = Schema.getGlobalDescribe().get('Case').newSObject();
						newsobj.put(writeBackName, false);
						newsobj.put('Id', sobj.get('Id'));
						sobjectListToBeUpdated.add(newsobj);
					}
				}
			}
			//If records need to be updated, update them
            if (sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}

	public static void dataWriteBackToSobjectSADelete(String writeBackName, List < sobject > recordList, map < string, Object > responceMap) {
		if(recordList.size() > 0) {
			list < sobject > sobjectListToBeUpdated = New list < sobject > ();
			for (sobject sobj: recordList) {
				System.debug('SADelete sobj Id:'+sobj.get('id'));
				String savedAuctionId = String.valueOf(sobj.get('Saved_Auction_ID__c'));
				System.debug('SADelete Case auction_id:'+savedAuctionId);
				Sobject newsobj = sobj.clone(true, false, false, false);
				newsobj.put(writeBackName, false);
				sobjectListToBeUpdated.add(newsobj);
				System.debug('SADelete Case Update:'+newsobj);
			}
            if (sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
        }
	}
}