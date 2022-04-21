public class AndOperation extends Operation
{    
    public AndOperation(String symbol)
    {
        super(symbol);
    } 

    public override Boolean resolve(BaseType a,BaseType b){ 
        return a.getBooleanValue() && b.getBooleanValue(); 
    } 
}