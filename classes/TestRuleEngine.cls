/**
		
 * @Known Issue	:	
 * 				:	1. All operators should have spaces , before and after, else it would raise an error.
 * 				:		 
 * */
@isTest
public class TestRuleEngine { 
    
    static Map<String, String> initBindings() {
        Map<String, String> bindings = new Map<String, String>();
        bindings.put('Val1'.toLowerCase(), '100');   
        bindings.put('Val2'.toLowerCase(), '200');  
        bindings.put('Val3'.toLowerCase(), '300');
        bindings.put('Val4'.toLowerCase(), 'RuleEngine');
        bindings.put('Val5'.toLowerCase(), 'false');
        bindings.put('Val6'.toLowerCase(), '10');
 		bindings.put('Val7'.toLowerCase(), '2021-05-10');
 		bindings.put('Val8'.toLowerCase(), '2021-05-05');

        return bindings;
    } 
    
     static Operations initOperations() {
		Operations opObj = Operations.getInstance(); 
        opObj.registerOperation(OperationFactory.getInstance('&&'));
        opObj.registerOperation(OperationFactory.getInstance('==')); 
        opObj.registerOperation(OperationFactory.getInstance('!=')); 
        opObj.registerOperation(OperationFactory.getInstance('||'));
        opObj.registerOperation(OperationFactory.getInstance('('));
        opObj.registerOperation(OperationFactory.getInstance(')'));
        opObj.registerOperation(OperationFactory.getInstance('<'));
        opObj.registerOperation(OperationFactory.getInstance('<='));
        opObj.registerOperation(OperationFactory.getInstance('>'));
        opObj.registerOperation(OperationFactory.getInstance('>='));
        return opObj; 
	} 
     
    public static testmethod void condition_Test_All_Operators(){  
        
        Map<String, String> bindings = initBindings();
    	Operations opObj = initOperations();
        
        //declaration
        String expr ;
        Rule r = new Rule() ;
        Boolean retVal;
        
        expr  = 'Val1 != 800' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val1 != 800 ||     ( Val2 != 200 &&       Val3 != 200 )' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ; 
        System.assertEquals(true, retVal);  
        
        expr  = 'Val1 < 110' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val1 <= 100' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val2 > 110.5' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val2 >= 110' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val3 == 300' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal); 
        
        expr  = 'Val3 == 300.0' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val4 == RuleEngine' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val4 == "ruleengine"' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val4 == ruleEngine' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val5 == false' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        //As below comparision is not valid, return false
        expr  = 'Val5 > false' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        //As below comparision is not valid, return false
        expr  = 'Val5 >= false' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        //As below comparision is not valid, return false
        expr  = 'Val5 < false' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        //As below comparision is not valid, return false
        expr  = 'Val5 <= false' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        expr  = 'Val1 == 100 || ( Val2 == 300 && Val3 == 200 && Val4 == ruleEngine )' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val1 == 300 || ( Val2 == 300 && Val3 == 200 && Val4 == ruleEngine )' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        expr  = 'Val1 == 300 || ( Val2 == 300 ) && ( Val3 == 200 ) && ( Val4 == ruleEngines )' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        expr  = 'Val1 == 300 || ( ( Val2 == 300 ) && ( Val3 == 200 ) && ( Val4 == ruleEngines && Val1 == 120 ) ) || Val1 == 100' ; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val1 == 1500 || Val1 == 1400 || Val1 == 1300 || Val1 == 1200 || Val1 == 1100 || Val1 == 1200 || Val1 == 1100 || Val1 == 1000'+
            ' || Val1 == 900 || Val1 == 800 || Val1 == 700 || Val1 == 600 || Val1 == 500 || Val1 == 400 || Val1 == 300 || Val1 == 200 || Val1 == 100'; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = 'Val1 == 1500 && Val1 == 1400 && Val1 == 1300 && Val1 == 1200 && Val1 == 1100 && Val1 == 1200 && Val1 == 1100 && Val1 == 1000'+
            ' && Val1 == 900 && Val1 == 800 && Val1 == 700 && Val1 == 600 && Val1 == 500 && Val1 == 400 && Val1 == 300 && Val1 == 200 && Val1 == 100'; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        //Test comma separated value
        expr  = 'Val1 == 1,2,3,4,5,6,7,100'; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);

        expr  = ' Val6 >= 9.00,9.99,8.20 || Val6 > 1.24,2.20 || Val6 < 10.24,12.20 || Val6 <= 10.24,12.20 || Val6 != 10.2,11.98'; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(true, retVal);
        
        expr  = ' Val7 >= Val8 '; 
        r.setExpression(expr);   
        retVal = r.eval(bindings) ;
        System.assertEquals(false, retVal);
        
        BaseType  b1=new BaseType('10',BaseType.enumType.INTEGER_TYPE); 
        BaseType  b2=new BaseType('11',BaseType.enumType.INTEGER_TYPE); 
		CparenthesisOperation cp=new CparenthesisOperation();
        Cp.resolve(b1,b2);
        
        OparenthesisOperation op=new OparenthesisOperation();
        op.resolve(b1,b2);
        
        ExpressionException e=new ExpressionException();
        
       /* BaseType  b3=new BaseType('2021-05-05',BaseType.enumType.DATE_TYPE); 
        BaseType  b4=new BaseType('2021-05-05',BaseType.enumType.DATE_TYPE); 
        GreaterEqualOperation ge=new GreaterEqualOperation();
        ge.resolve(b3,b4);*/
    }  
}