/**
 * @description ${DESCRIPTION}
 * @name tracRecurringEventWrapperController.js
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-23
 */
({
    closeModal : function (component,event) {
        console.log(event);
        $A.get("e.force:closeQuickAction").fire();
    }
})