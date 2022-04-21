public class CaseUtility {
    // Should be deleted when all Case Triggers are converted
    private Static boolean alreadyProcessed = false;
    public static void toggleAlreadyProcessed(){
        alreadyProcessed = !alreadyProcessed;
    }

    public final static String TITLES_RECORDTYPE_DEV_NAME = 'Title_Information';

    // Utiltized in multiple triggers
    public final static String TITLE_CLERK = 'Title Clerk';
}