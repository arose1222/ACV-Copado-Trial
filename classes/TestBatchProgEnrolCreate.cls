@isTest
public class TestBatchProgEnrolCreate {
  public static testMethod void TestBatchProgEnrolCreate() {

    List<Account> lstAccount= new List<Account>();
    List<String> lstCriteria=new List<String>();
    List<program__c> lstProgram=new List<Program__c>();
    List<Program_Reviews__c> lstProgramReview=new List<Program_Reviews__c>();
    List<Program_Enrollment__c> lstProgramEnrol=new List<Program_Enrollment__c>();
    lstCriteria.add('Account.Name != test_hk_acc AND Account.Dealer_Doc_Compliance__c = Compliant');
    lstCriteria.add('Account.Phone != Null OR Account.Active__c != Account.Active_Transporter__c AND Account.Purchases_All_Time__c > 500');
    lstCriteria.add('Account.Phone != Null OR Account.Active__c != Account.Active_Transporter__c AND Account.Purchases_All_Time__c > 500 AND Account.All_Time_Sales_Gross__c != Account.Purchases_All_Time__c');
    lstCriteria.add('Account.Active__c != Account.Active_Transporter__c AND Account.Purchases_All_Time__c > 500 AND Program__c.active__c = Account.Active__c');
    lstCriteria.add('Account.Phone != Null OR Account.Active__c = true AND Account.Purchases_All_Time__c < 500 AND Account.All_Time_Sales_Gross__c >= Account.Purchases_All_Time__c');


    for(Integer i=0 ;i < 100; i++){
            Account acc = new Account();
            acc.Name ='Name'+i;
            acc.Phone = '761234560';
            acc.BillingStreet = '12 Test St'+i;
            acc.BillingCity = 'Buffalo'+i;
            acc.BillingState = 'NY'+i;
            acc.BillingPostalCode = '14228';
            acc.Dealership_ID__c = String.valueOf(Math.rint(Math.Random() * 100))+i;
            acc.legal_Name__c = 'Name'+i;
            acc.dealer_type__c = '2';
            acc.Active__c = Math.mod(i,2) == 0 ? true : false;
            acc.Date_of_First_Buy__c= Date.today()-20;
            acc.Date_of_Last_Purchase__c=Date.today()-10;
            acc.Active_Transporter__c=false;
            acc.All_Time_Sales_Gross__c=Integer.valueOf(Math.Random()*10)+i;
            acc.Purchases_All_Time__c=Integer.valueOf(Math.Random()*5)+i;
			acc.Dealer_Type__c='2';
            acc.Dealer_Doc_Compliance__c='Compliant';
            lstAccount.add(acc);
        }
        
        insert lstAccount;


        for(Integer i=0 ;i <5;i++)
        {
            Program__c prog = new Program__c();
            prog.name = 'Test Program '+i;
            prog.active__c = true;
            prog.Program_Eligibility_Criteria__c=lstCriteria[i];
            prog.Program_Monitoring_Criteria__c=lstCriteria[i];
            lstProgram.add(prog);
        }
        insert lstProgram;


 	for(Integer i=0 ;i <5;i++){
        Program_Enrollment__c pe = new Program_Enrollment__c();
        pe.Account__c = lstAccount[i].id;
        pe.Program__c = lstProgram[i].id; 
                 pe.Enrollment_Start_Date__c=system.today()-45;
          lstProgramEnrol.add(pe);
      }
      
    insert lstProgramEnrol;
      
      for(Integer i=0 ;i <5;i++){
        Program_Reviews__c pe = new Program_Reviews__c();
       	pe.IsMonitoring__c=true;
        pe.Program_Enrollment__c = lstProgramEnrol[i].id;  
          
          lstProgramReview.add(pe);
      }
      
    insert lstProgramReview;

      
    Test.startTest();

    //BatchProgEnrolCreate obj = new BatchProgEnrolCreate();
    //DataBase.executeBatch(obj);
	ScheduleBatchProgEnrolCreate testsche = new ScheduleBatchProgEnrolCreate();
	String sch = '0 0 6 * * ?';
	system.schedule('Test status Check', sch, testsche );
   
    /*ScheduleBatchProgramReviewCreate_Monitor testsch = new ScheduleBatchProgramReviewCreate_Monitor();
	String sch1 = '0 0 6 * * ?';
	system.schedule('Test status Check 1', sch1, testsch );*/
   
  /*  BatchProgramReviewCreate_Monitoring obj = new BatchProgramReviewCreate_Monitoring();
    DataBase.executeBatch(obj);*/
	//ScheduleBatchProgEnrolCreate testsche = new ScheduleBatchProgEnrolCreate();
	//String sch = '0 0 6 * * ?';
	//system.schedule('Test status Check', sch, testsche );
    Test.stopTest();
  }
    
   public static testMethod void TestBatchProgramReviewUpdate() {

    Account acc = new Account();

    acc.Name = 'Test Account 1';
    acc.Phone = '7161234560';
    acc.BillingStreet = '12 Test St';
    acc.BillingCity = 'Buffalo';
    acc.BillingState = 'NY';
    acc.BillingPostalCode = '14228';
    acc.Dealership_ID__c = String.valueOf(Math.rint(Math.Random() * 100));
     acc.legal_Name__c = 'Test Account';
    acc.dealer_type__c = '2';
    acc.Active__c = true;

    insert acc;

    Program__c prog = new Program__c();
    prog.name = 'Test Program 1';
    prog.active__c = true;
    insert prog;

    Program_Enrollment__c pe = new Program_Enrollment__c();
    pe.Name='Test Enrol 1';
    pe.Account__c = acc.id;
    pe.Program__c = prog.id;
    pe.Enrollment_Start_Date__c = System.Today() - 45;
    insert pe;

    Program_Reviews__c pr= new Program_Reviews__c();
    pr.Program_Enrollment__c=pe.id;
    pr.name='Test Review 1';
    pr.CreatedDate=system.today()-45;
	pr.IsMonitoring__c=false;
    insert pr;
       
    Test.startTest();
	/*ScheduleBatchProgReviewCreation testsche = new ScheduleBatchProgReviewCreation();
	String sch = '0 0 6 * * ?';
	system.schedule('Test status Check', sch, testsche );*/
    BatchProgramReviewCreation obj = new BatchProgramReviewCreation();
    DataBase.executeBatch(obj);

    Test.stopTest();
  }
}