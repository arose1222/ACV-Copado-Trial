global class ScheduleBatchProgEnrolCreate implements Schedulable {
  global void execute(SchedulableContext sc) {
    //Database.executeBatch(new BatchProgEnrolCreate());
      BatchProgEnrolCreate b = new BatchProgEnrolCreate(); 
        database.executebatch(b);
  }
}