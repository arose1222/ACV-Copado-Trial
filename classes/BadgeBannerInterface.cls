/**
 * Interface for BadgeBanner class that relates to the LWC
 * @author James Andre LaCour
 * @since Aug 10th, 2021
 */
public virtual class BadgeBannerInterface {
    /**
     * Runs the logic check to see if the badge passed in is eligible for the recordId
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */
    public virtual Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        return false;
    }
}