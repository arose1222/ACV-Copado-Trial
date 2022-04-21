public abstract class Operation implements Expression
{ 
    
    protected String symbol;  

    public Operation(String symbol)  
    {
        this.symbol = symbol;
    } 
 	public abstract Boolean resolve(BaseType a,BaseType b);
 
    public String getSymbol()
    {
        return this.symbol;
    } 
}