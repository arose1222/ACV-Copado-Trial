public with sharing class TDRTriggerHandler extends TriggerInterface {


    // protected override void beforeInsert(){
    //     TransportationDispatchRequestHandler.run(false, Trigger.new);
    // }

    // public override void afterInsert(){
    //     //TransportationDispatchRequestHandler.run(false, Trigger.new);
    // }

    // protected override void beforeUpdate(){
    //     TransportationDispatchRequestHandler.run(false, Trigger.new);
    // }

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        TransportationDispatchRequestHandler.run(newMap);
    }

    // protected override void beforeDelete(){
    //     TransportationDispatchRequestHandler.run(false, Trigger.new);
    // }

    // protected override void afterDelete(){
    //     TransportationDispatchRequestHandler.run(false, Trigger.new);
    // }


}