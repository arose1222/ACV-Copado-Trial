public abstract class CoreObject{
    public Object get(String path ){
        return get(JSON.serialize(this), path);
    }
    public Object get( String jsonString, String path ){
        Map<String,Object> jsonObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        List<String> pathSplit = path.split('\\.');
        Object value = jsonObject.get(pathSplit.remove(0));
        if( pathSplit.size() > 0 ){
            Map<String,Object> thisTier = (Map<String,Object>)value;
            return get( JSON.serialize(thisTier), String.join(pathSplit, '.' ) );
        }else{
            return value;
        }
    }
}