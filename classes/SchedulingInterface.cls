public virtual class SchedulingInterface {
    
    /**
     * For Non-Batches, 
     * it is highly recommended that the logic is launched via a Queuable/Future method from this method.
     * This will avoid any concerns about limits and possible concerns about strain on the main Framework
     * 
     * The important thing is all instances of logic from the framework launch into a new context
     */
    public virtual void executeScheduledLogic() {

    }
}