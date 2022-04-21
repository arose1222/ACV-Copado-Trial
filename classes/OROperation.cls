public class OROperation extends Operation
{    
    public OROperation(String symbol)
    {
        super(symbol);
    } 
    
    public override Boolean resolve(BaseType a,BaseType b){ 
        return a.getBooleanValue() || b.getBooleanValue();  
    } 
      
}