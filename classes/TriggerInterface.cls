public virtual class TriggerInterface {

    public virtual void beforeUpdate(List<SObject> oldList, List<SObject> newList){}

    public virtual void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){}

    public virtual void afterUpdate(List<SObject> oldList, List<SObject> newList){}

    public virtual void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){}

    public virtual void beforeInsert(List<SObject> newList){}

    public virtual void afterInsert(List<SObject> newList){}

    public virtual void afterInsert(Map<Id, SObject> newMap){}

    public virtual void beforeDelete(List<SObject> oldList){}

    public virtual void beforeDelete(Map<Id, SObject> oldMap){}

    public virtual void afterDelete(List<SObject> oldList){}

    public virtual void afterDelete(Map<Id, SObject> oldMap){}

    public virtual void afterUndelete(List<SObject> newList){}

    public virtual void afterUndelete(Map<Id, SObject> newMap){}

    public virtual void beforeUndelete(List<SObject> newList){}

    public virtual void beforeUndelete(Map<Id, SObject> newMap){}
}