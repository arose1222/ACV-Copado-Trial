({
    handleCloseTab: function(component, event, helper) {
        console.log(event);
        //var CancelClicked = event.getParam('cancel');
        var msg = event.getParam('close');
        var workspaceAPI = component.find("workspace");
        console.log(msg);
        //if(msg){
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                console.log(focusedTabId);

                //Closing old one
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        //}
    }
})