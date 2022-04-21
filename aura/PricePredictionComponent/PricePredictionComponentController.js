({    
    "fetchPricePrediction" : function(cmp, event, helper) {
        const action = cmp.get("c.getPredictedCeilingAndFloorPrice");
        const auctionId = cmp.get("v.auctionId")
        action.setParams({ auctionId : auctionId });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const floor_ceiling_price = JSON.parse(response.getReturnValue())
                cmp.set('v.floorPrice', helper.getFloorPrice(floor_ceiling_price))
                cmp.set('v.ceilingPrice', helper.getCeilingPrice(floor_ceiling_price))
            }
            else if (state === "INCOMPLETE") {
                cmp.set('v.floorPrice', 'Unavailable')
                cmp.set('v.ceilingPrice', 'Unavailable')
            }
            else if (state === "ERROR") {
                cmp.set('v.floorPrice', 'Unavailable')
                cmp.set('v.ceilingPrice', 'Unavailable')
                helper.logErrors(response.getError())
            }
        });
        $A.enqueueAction(action);
    }
})