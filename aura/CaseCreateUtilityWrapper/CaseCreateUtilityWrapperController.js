({
    doInit : function(component){

        var eventHandler = function(response){
            if(component.get("v.currentlyClosed") == true){
                if(component.get("v.hasBeenClosed") == false){
                    component.set("v.hasBeenClosed",true);
                }
                else {
                    component.set("v.hasBeenClosed",false);
                }
                component.set("v.currentlyClosed",false);
            }
        };
    
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function(response){
            if(typeof response !=='undefined'){
    
                utilityAPI.getEnclosingUtilityId().then(function(utilityId){
                    utilityAPI.onUtilityClick({ 
                        eventHandler: eventHandler 
                    })               
                })
                .catch(function(error){
                    console.log('do init: utilId error: ' + error);
                });
            }else{
                console.log('getAll Utility Info is undefined');
            }
        });
    },

    onRender : function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.disableUtilityPopOut({
            disabled: true,
            disabledText: "Pop-out is disabled"
        });
    },

    onRecordIdChange : function(component, event, helper) {
        if(component.get("v.recordId")){ // && component.get("v.recordId").substring(0,3) === '001'
            component.set("v.contextId",component.get("v.recordId"));
            if(component.find('caseCreateUtility')){
                //component.find('caseCreateUtility').getCaseList();
            }
        }
    },
    
    minimizeUtility : function(component, event, helper) {
        console.log('in minimize aura'); 
        component.set("v.currentlyClosed",true);
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },
    
    getValueFromLwc : function(component, event, helper) {
        console.log('in getValue aura');
		component.set("v.myBool",event.getParam('value'));
	}
 
})