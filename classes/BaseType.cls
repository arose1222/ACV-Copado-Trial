public class BaseType implements Expression {
   
    public enum enumType {NULL_TYPE,STRING_TYPE,INTEGER_TYPE,DECIMAL_TYPE,BOOLEAN_TYPE,RESULT_TYPE,LIST_DECIMAL,DATE_TYPE}    
    public Object value;  
    public enumType valType;	
	public Set<Decimal> setDecimalval = null;
	

    public BaseType(Object value, enumType valType)
    {
		if(valType == enumType.LIST_DECIMAL){
			this.setDecimalval = new Set<Decimal>();
			for(String s : ((String)value).split(',')){
				this.setDecimalval.add(Decimal.valueOf(s));
			}
		}else{
			this.value = value; 
		} 
		this.valType = valType;
    }
	
	public Set<Decimal> getValuesSet(){
		if(valType == enumType.LIST_DECIMAL && setDecimalval != null){
			return setDecimalval;
		}
		return null;
	}

    public Object getValue()
    {
        /*
        if(getType() == enumType.STRING_TYPE){
            String s = String.valueOf(this.value) ; 
        } */
        return this.value;
    }
    public Datetime getDateValue(){
        //System.debug('Inside getDateVal');
        Datetime d1=Datetime.valueOf(string.valueOf(this.value));
        return d1;
    }
    
    public Boolean getBooleanValue() 
    { 
        return Boolean.valueOf(getValue());
    }

    public enumType getType() 
    {
        return this.valType;
    } 

    public static boolean isDate(String dateString){
        try{
            Date d = Date.valueOf(dateString);  
            System.debug('data :'+d);
            return true;
        }catch(exception e){
            return false;
        }
    }

    public static BaseType instantiate(String str)
    {

		//is Base type all calculated and saved in static map
		BaseType ret = Rule.mpPreviousCalculatedBaseType.get(str);
        if (str == null){
            ret = new BaseType(str,BaseType.enumType.NULL_TYPE);
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
          //  throw new ExpressionException('The provided string must not be null');
        } 
		if(ret != null){
			return ret;
		}
        if (str.toLowerCase() == 'true' || str.toLowerCase() == 'false'){
			ret = new BaseType(Boolean.valueOf(str),BaseType.enumType.BOOLEAN_TYPE);
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
        }
         else  if (Pattern.matches('^[-+]?[0-9]+$', str) ){
            try{
                Integer num=Integer.valueOf(str); 
                ret = new BaseType( Integer.valueOf(str),BaseType.enumType.INTEGER_TYPE);
            }
            catch(Exception e){
                System.debug('Exception : '+e.getMessage());
                ret = new BaseType(str,BaseType.enumType.STRING_TYPE);
            }  
            Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
        } else if (Pattern.matches('^[-+]?[0-9]*\\.?[0-9]+$', str) ) {
            ret = new BaseType(Decimal.valueOf(str),BaseType.enumType.DECIMAL_TYPE); 
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
        } else if (Pattern.matches('^(\\s*-?\\d+(\\.\\d+)?)(\\s*,\\s*-?\\d+(\\.\\d+)?)+$', str) ) {
            ret = new BaseType(str,BaseType.enumType.LIST_DECIMAL); 
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
        }else if (str.startsWith('\'') || str.startsWith('"') || str.isAlphanumeric() || str.isAlpha() || str.containsIgnoreCase('_'))
        {
            //remove first and last single quotes
            if( (str.startsWith('\'') && str.endsWith('\'')) || (str.startsWith('"') && str.endsWith('"')) ){
                str = str.substring(1, str.length()-1) ;
            }
            str=str.trim().replaceAll('\\s','_').toLowerCase();                
			ret = new BaseType (str,BaseType.enumType.STRING_TYPE);
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret; 
            
        } else if(isDate(str)){
            ret = new BaseType(str,BaseType.enumType.DATE_TYPE);
			Rule.mpPreviousCalculatedBaseType.put(str,ret);
            return ret;
        }
        return null;
    }
}