/**
 * Utilities for List processing and generation
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLList
 */
public class TLList {
    private static final Set<Schema.SoapType> DECIMAL_TYPES = new Set<Schema.SoapType>{
            Schema.SoapType.INTEGER, Schema.SoapType.DOUBLE, Schema.SoapType.TIME
    };
    private static final Set<Schema.SoapType> STRING_TYPES = new Set<Schema.SoapType>{
            Schema.SoapType.STRING, Schema.SoapType.ID, Schema.SoapType.BASE64BINARY
    };
    private static final Set<Schema.SoapType> DATE_TYPES = new Set<Schema.SoapType>{
            Schema.SoapType.DATE, Schema.SoapType.DATETIME
    };

    /**
     * Extracts Id values from source
     * @param source    The list to retrieve values from
     * @return      Set of Ids extracted from source
     */
    public static Set<Id> collectIds(List<SObject> source) {
        final Set<Id> result = new Set<Id>();

        for (SObject sobj : source) {
            if (sobj.Id != null) {
                result.add(sobj.Id);
            }
        }

        return result;
    }

    /**
     * Extracts Id values from source with order preserved. Includes nulls
     * @param source    The list to retrieve values from
     * @return      List of Ids extracted from source
     */
    public static List<Id> collectIdsAsList(List<SObject> source) {
        final List<Id> result = new List<Id>();

        for (SObject sobj : source) {
            result.add(sobj.Id);
        }

        return result;
    }

    /**
     * Extracts Id values from source, for the field provided
     * @param source    The list to retrieve values from
     * @param field     The field to read values from
     * @return      Set of Ids extracted from source
     */
    public static Set<Id> collectIds(List<SObject> source, SObjectField field) {
        return collectIdsInternal(source, field);
    }

    /**
     * Extracts Id values from source, for the field provided
     * @param source : The list to retrieve values from
     * @param field : The field to read values from
     * @return      Set of Ids extracted from source
     */
    public static Set<Id> collectIds(List<SObject> source, String field) {
        return collectIdsInternal(source, field);
    }

    private static Set<Id> collectIdsInternal(List<SObject> source, Object field) {
        final Set<Id> result = new Set<Id>();

        for (SObject sobj : source) {
            Id value = (Id)TLShared.getFieldValue(sobj, field);

            if (value != null) {
                result.add(value);
            }
        }
        return result;
    }

    /**
     * Extracts Id values from source, for the field provided, preserving order. Includes nulls
     * @param source    The list to retrieve values from
     * @param field     The field to read values from
     * @return      List of Ids extracted from source
     */
    public static List<Id> collectIdsAsList(List<SObject> source, SObjectField field) {
        return collectIdsAsListInternal(source, field);
    }

    /**
     * Extracts Id values from source, for the field provided, preserving order. Includes nulls
     * @param source : The list to retrieve values from
     * @param field : The field to read values from
     * @return      List of Ids extracted from source
     */
    public static List<Id> collectIdsAsList(List<SObject> source, String field) {
        return collectIdsAsListInternal(source, field);
    }

    private static List<Id> collectIdsAsListInternal(List<SObject> source, Object field) {
        final List<Id> result = new List<Id>();

        for (SObject sobj : source) {
            Id value = (Id)TLShared.getFieldValue(sobj, field);
            result.add(value);
        }

        return result;
    }

    /**
    * Extracts String values from source, for the field provided
    * @param source    The list to retrieve values from
    * @param field     The field to read values from
    * @return      Set of Ids extracted from source
    */
    public static Set<String> collectStrings(List<SObject> source, SObjectField field) {
        return collectStringsInternal(source, field);
    }

    /**
    * Extracts String values from source, for the field provided
    * @param source    The list to retrieve values from
    * @param field     The field to read values from
    * @return      Set of Ids extracted from source
    */
    public static Set<String> collectStrings(List<SObject> source, String field) {
        return collectStringsInternal(source, field);
    }

    private static Set<String> collectStringsInternal(List<SObject> source, Object field) {
        final Set<String> result = new Set<String>();

        for (SObject sobj : source) {
            String value = (String)TLShared.getFieldValue(sobj, field);

            if (value != null) {
                result.add(value);
            }
        }
        return result;
    }

    /**
     * Combine a set of lists into a single set.
     * @param idSetLIst     The list of sets to combine.
     * @return              Set of Id containing all the Ids from the specified set list.
     */
    public static Set<Id> combineSetList(List<Set<Id>> idSetList) {
        final Set<Id> allIds = new Set<Id>();

        for (Set<Id> idSet : idSetList) {
            allIds.addAll(idSet);
        }

        allIds.remove(null);

        return allIds;
    }

    /**
     * Given a List of Strings, subdivide the list in nested lists of the length specified by chunkSize
     *
     * @param elements List of Strings to split
     * @param chunkSize Maximum size of sub-lists
     *
     * @return Nested List of Strings
     */
    public static List<List<String>> split(List<String> elements, Integer chunkSize) {
        List<List<String>> result = new List<List<String>>();

        List<String> subList = new List<String>();
        for (String element : elements) {
            if (subList.size() == chunkSize) {
                result.add(subList.clone());
                subList.clear();
            }

            subList.add(element);
        }

        result.add(subList);

        return result;
    }

    /**
     * Given a List of SObjects, subdivide the list in nested lists of the length specified by chunkSize
     * Note that this method DOES NOT USE deepClone() when creating the sub-lists. Modifications to the SObjects in the
     * original list will be reflected in the split lists, and vice versa.
     *
     * @param elements List of SObjects to split
     * @param chunkSize Maximum size of sub-lists
     *
     * @return Nested List of SObjects
     */
    public static List<List<SObject>> split(List<SObject> elements, Integer chunkSize) {
        List<List<SObject>> result = new List<List<SObject>>();

        List<SObject> subList = new List<SObject>();
        for (SObject element : elements) {
            if (subList.size() == chunkSize) {
                result.add(subList.clone());
                subList.clear();
            }

            subList.add(element);
        }

        result.add(subList);

        return result;
    }

    // QuickSort capabilities adapted from https://github.com/ChuckJonas/apex-sort-sobs

    /**
     * Sort Sobjects ascending using a relationship field
     * @param records List of SObjects to sort
     * @param fields List of SObjectField to capture sorting field. The last item will be the value sorted on.
     * All preceding items must be relationship fields
     */
    public static void sort(SObject[] records, SObjectField[] fields) {
        sortInternal(records, fields, false);
    }

    /**
     * Sort Sobjects descending using a relationship field
     * @param records List of SObjects to sort
     * @param fields List of SObjectField to capture sorting field. The last item will be the value sorted on.
     * All preceding items must be relationship fields
     */
    public static void sortDesc(SObject[] records, SObjectField[] fields) {
        sortInternal(records, fields, true);
    }

    /**
     * Sort SObjects ascending
     * @param records List of SObjects to sort
     * @param field SObjectField to sort on
     */
    public static void sort(SObject[] records, SObjectField field) {
        sortInternal(records, new SObjectField[]{ field }, false);
    }

    /**
     * Sort SObjects descending
     * @param records List of SObjects to sort
     * @param field SObjectField to sort on
     */
    public static void sortDesc(SObject[] records, SObjectField field) {
        sortInternal(records, new SObjectField[]{ field }, true);
    }

    //extracts values, determines type, runs sort
    private static void sortInternal(SObject[] records, SObjectField[] fields, Boolean reverse) {
        SObjectField sortField = fields.remove(fields.size() - 1);

        Object[] values = new Object[]{};
        for (SObject sob : records) {
            values.add(getValueFromRelationship(sob, fields, sortField));
        }

        BaseSOBQuickSort quickSort = getQuickSortTypeForField(sortField);
        quickSort.sort(values, records, reverse);
    }

    private static BaseSOBQuickSort getQuickSortTypeForField(SObjectField sortField) {
        BaseSOBQuickSort result;

        Schema.SoapType sType = sortField.getDescribe().getSoapType();
        if (DECIMAL_TYPES.contains(sType)) {
            result = new DecimalSOBQuicksort();
        } else if (STRING_TYPES.contains(sType)) {
            result = new StringSOBQuicksort();
        } else if (DATE_TYPES.contains(sType)) {
            result = new DatetimeSOBQuicksort();
        } else if (sType == Schema.SoapType.BOOLEAN) {
            result = new BooleanSOBQuicksort();
        }

        return result;
    }

    private static Object getValueFromRelationship(SObject sob, SObjectField[] relationships, SObjectField sortField) {
        if (relationships.size() == 0) {
            return sob.get(sortField);
        }

        SObject parentSob = sob;
        for (Integer i = 0; i < relationships.size(); i++) {
            parentSob = parentSob.getSObject(relationships[i]);
            if (parentSob == null) {
                return null;
            }
        }
        return parentSob.get(sortField);
    }

    private class DecimalSOBQuicksort extends BaseSOBQuickSort {

        private override Integer compareToPivot(Object value, Object pivot) {
            Decimal val = (Decimal)value;
            Decimal piv = (Decimal)pivot;
            if (val == piv) {
                return 0;
            }
            if (val > piv) {
                return 1;
            }
            return -1;
        }
    }

    private class StringSOBQuicksort extends BaseSOBQuickSort {

        private override Integer compareToPivot(Object value, Object pivot) {
            String val = (String)value;
            String piv = (String)pivot;
            if (val == piv) {
                return 0;
            }
            if (val > piv) {
                return 1;
            }
            return -1;
        }
    }

    private class DatetimeSOBQuicksort extends BaseSOBQuickSort {

        private override Integer compareToPivot(Object value, Object pivot) {
            Datetime val = (Datetime)value;
            Datetime piv = (Datetime)pivot;
            if (val == piv) {
                return 0;
            }
            if (val > piv) {
                return 1;
            }
            return -1;
        }
    }

    private class BooleanSOBQuicksort extends BaseSOBQuickSort {

        private override Integer compareToPivot(Object value, Object pivot) {
            Boolean val = (Boolean)value;
            Boolean piv = (Boolean)pivot;
            if (val && piv || !val && !piv) {
                return 0;
            }
            if (val) {
                return 1;
            }
            return -1;
        }
    }

    private abstract class BaseSOBQuickSort {
        private SObject[] sobs;
        private Integer length;
        private Object[] values;
        private Boolean reverse;

        public void sort(Object[] inputValues, SObject[] sobs, Boolean reverse) {
            this.reverse = reverse;

            // check for empty or null array
            if (inputValues == null || inputValues.size() == 0) {
                return;
            }

            this.sobs = sobs;
            values = inputValues;

            length = values.size();
            quicksort(0, length - 1);
        }

        // returns 1 if greater, -1 if less than, 0 if equals
        private abstract Integer compareToPivot(Object value, Object pivot);

        private void quicksort(Integer low, Integer high) {
            Integer i = low, j = high;

            Object pivot = values[low + (high - low) / 2];

            Integer negator = reverse == true ? -1 : 1;

            // into two array
            while (i <= j) {

                // if current item from left array < pivot
                while (compareToPivot(values[i], pivot) * negator == -1) {
                    //get the next item in left array
                    i++;
                }
                // if current item from right array > pivot
                while (compareToPivot(values[j], pivot) * negator == 1) {
                    //get the next item in right array
                    j--;
                }

                //if left is larger than pivot and right is smaller, exchange
                if (i <= j) {
                    exchangeObject(i, j);
                    i++;
                    j--;
                }
            }

            // recursion
            if (low < j) {
                quicksort(low, j);
            }
            if (i < high) {
                quicksort(i, high);
            }
        }

        private void exchangeObject(Integer i, Integer j) {
            Object temp = values[i];
            values[i] = values[j];
            values[j] = temp;

            exchangeSob(i, j);
        }

        private void exchangeSob(Integer i, Integer j) {
            SObject temp = sobs[i];
            sobs[i] = sobs[j];
            sobs[j] = temp;
        }
    }

    public static SObject find(List<SObject> records, SObjectField field, Object value) {
        for(SObject record : records) {
            if(record.get(field) == value) {
                return record;
            }
        }
        return null;
    }
}