({
    closeModal : function (component,event) {
        console.log(event);
        $A.get("e.force:closeQuickAction").fire();
    }
})