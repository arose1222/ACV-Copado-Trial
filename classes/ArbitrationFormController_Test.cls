@IsTest
public class ArbitrationFormController_Test {
    static testMethod void Testmethod1(){
        Map<String,List<String>> arbs = ArbitrationFormController.getArbitrationrecords();        
        system.assertEquals(arbs.size() > 0, true);        
    }
}