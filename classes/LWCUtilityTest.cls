@isTest
public class LWCUtilityTest {
    
    @isTest
    public static void createBlankPickList(){
        LWCUtility.Picklist p = new LWCUtility.Picklist();
        system.assert(String.isBlank(p.label),'Label is not blank');
        System.assert(String.isBlank(p.value),'Value is not blank');
    }

    @isTest
    public static void createPopulatedPickList(){
        LWCUtility.Picklist p = new LWCUtility.Picklist('label','value');
        System.assert(p.value == 'value','Values does not equal what we set');
        System.assert(p.label == 'label','Label does not equal what we set');
    }
}