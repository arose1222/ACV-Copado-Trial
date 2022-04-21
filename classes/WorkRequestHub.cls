public class WorkRequestHub {
    public static boolean firedDispatchEvent = FALSE;
    public static boolean firedUnassignEvent = FALSE;

    public static Set<Id> dispatchedSFRecSet = new Set<Id>();
    public static Set<Id> unassignedSFRecSet = new Set<Id>();
}