public with sharing class RevolvingBatchManual {

    public static void runGenerationBatch(Integer generationSize) {
        RevolvingGenerationBatch generationBatch = new RevolvingGenerationBatch(new List<String> {}, true, Date.today());
        Database.executeBatch(generationBatch, generationSize);
    }

    public static void runGenerationBatch(Integer generationSize, List<String> debugs) {
        RevolvingGenerationBatch generationBatch = new RevolvingGenerationBatch(debugs, true, Date.today());
        Database.executeBatch(generationBatch, generationSize);
    }

    public static void runCleanUpBatch(Integer cleanUpSize){
        RevolvingCleanUpBatch cleanUpBatch = new RevolvingCleanUpBatch(false, 0, true);
        Database.executeBatch(cleanUpBatch, cleanUpSize);
    }


    public static void runCleanUpBatch(Integer cleanUpSize, Integer generationSize, Boolean runGeneration){
        RevolvingCleanUpBatch cleanUpBatch = new RevolvingCleanUpBatch(runGeneration, generationSize, true);
        Database.executeBatch(cleanUpBatch, cleanUpSize);
    }
}