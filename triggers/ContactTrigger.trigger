trigger ContactTrigger on Contact (after insert,after update,before insert,before update, after delete, after undelete, before delete) {
    (new TriggerFrameWork()).handle();
    //new ContactTriggerHandler().run();
  
}