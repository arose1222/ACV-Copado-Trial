public class GreaterOperation extends Operation
{    
    public GreaterOperation(String symbol)
    {
        super(symbol);
    } 
    
    public override Boolean resolve(BaseType a,BaseType b){ 
        if( (a.getType() == BaseType.enumType.INTEGER_TYPE || a.getType() == BaseType.enumType.DECIMAL_TYPE)
			&& b.getType() == BaseType.enumType.LIST_DECIMAL )			
		{
			for(Decimal bVal : b.getValuesSet()){
				if((Decimal) a.getValue() > bVal){
					return true;
				}
			}
			return false;
		}else if( (a.getType() == BaseType.enumType.INTEGER_TYPE || a.getType() == BaseType.enumType.DECIMAL_TYPE) 
           			&& 
            	(b.getType() == BaseType.enumType.INTEGER_TYPE || b.getType() == BaseType.enumType.DECIMAL_TYPE))
        	{    
            return (Decimal) a.getValue() >  (Decimal) b.getValue() ;
           }
		   else if(a.getType() == BaseType.enumType.DATE_TYPE && b.getType() == BaseType.enumType.DATE_TYPE ){
			return ( a.getDateValue() > b.getDateValue());
		   }
        return false;  
    }  
}