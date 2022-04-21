/**
 * Helper methods used by the various TL* Library classes
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 */
public class TLShared {
    public static final String NULL_SOBJECT_ERROR = 'SObject provided must not be null';
    public static final String NULL_FIELD_ERROR = 'Field provided must not be null';

    /**
     * Given an sobject and field (either a String or SObjectField), return the value from that field
     * Used by TLList, TLMap, and TLTrigger to support both String and SObjectField versions of various methods
     * @param sobj  SObject to extract field value from
     * @param field The field to query, in String or SObjectField form. Parent fields are supported when using Strings
     * @return      The field value, or throws a TLFieldException if null inputs provided
     */
    public static Object getFieldValue(SObject sobj, Object field) {
        validateInputs(sobj, field);

        if(field instanceof SObjectField) {
            return sobj.get((SObjectField)field);
        }

        return getFieldValueFromString(sobj, (String)field);
    }

    private static void validateInputs(SObject sobj, Object field) {
        if(sobj == null) {
            throw new TLFieldException(NULL_SOBJECT_ERROR);
        }

        if(field == null) {
            throw new TLFieldException(NULL_FIELD_ERROR);
        }
    }

    private static Object getFieldValueFromString(SObject sobj, String field) {
        List<String> fieldParts = field.split('\\.');

        Integer index = 0;
        SObject current = sobj;

        while (index < (fieldParts.size() - 1)) {
            current = current.getSObject(fieldParts[index]);
            index++;
        }

        if(current == null) {
            return null;
        }

        return current.get(fieldParts[index]);
    }

    public class TLFieldException extends Exception {}
}