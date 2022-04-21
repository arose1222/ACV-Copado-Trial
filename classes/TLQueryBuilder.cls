/**
 *  @description Ability to create a dynamic query
 *  @author      Graham Barnard, Traction on Demand.
 *  @date        2016-02-18
 */
public with sharing class TLQueryBuilder {
    public final static String FIELD_SEPARATOR = ', ';
    public final static String STRING_VALUE_SEPARATOR = '\', \'';

    public final static String AND_OPERATOR = 'AND';
    public final static String OR_OPERATOR = 'OR';

    public final static String EQUALS_OPERATOR = '=';
    public final static String NOT_EQUALS_OPERATOR = '!=';
    public final static String LIKE_OPERATOR = 'LIKE';
    public final static String IN_OPERATOR = 'IN';
    public final static String NOT_IN_OPERATOR = 'NOT IN';
    public final static String LESS_THAN_OPERATOR = '<';
    public final static String GREATER_THAN_OPERATOR = '>';
    public final static String LESS_THAN_OR_EQUAL_OPERATOR = '<=';
    public final static String GREATER_THAN_OR_EQUAL_OPERATOR = '>=';

    private static final List<String> LIST_OPERATORS = new List<String>{NOT_IN_OPERATOR,IN_OPERATOR};
    private static final List<String> SINGLE_OPERATORS = new List<String>{
            EQUALS_OPERATOR,
            NOT_EQUALS_OPERATOR,
            LIKE_OPERATOR,
            LESS_THAN_OPERATOR,
            GREATER_THAN_OPERATOR,
            LESS_THAN_OR_EQUAL_OPERATOR,
            GREATER_THAN_OR_EQUAL_OPERATOR};

    private final static String EXCEPTION_INVALID_OPERATOR = 'Operator "{0}" is not valid for comparing type "{1}"';

    private final static String EXCEPTION_MISSING_OBJECT_FIELD = 'Object must be set';
    private final static String EXCEPTION_OPERATOR = 'Conditions don\'t have an OR or AND operator';

    public final static String INTEGER_TYPE = 'Integer';
    public final static String DECIMAL_TYPE = 'Decimal';
    public final static String BOOLEAN_TYPE = 'Boolean';
    public final static String STRING_TYPE  = 'String';


    private String objectName;
    private Integer queryLimit;
    private Set<String> fields;
    public BaseOperator baseOperator;

    public TLQueryBuilder() {
        baseOperator = new BaseOperator();
        fields = new Set<String>();
    }

    public void setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit;
    }

    public void setFields(Set<String> fields) {
        this.fields = fields;
    }

    public void setFields(List<String> fields) {
        this.fields = new Set<String>(fields);
    }

    public void setObject(String objectName) {
        this.objectName = objectName;
    }

    public void setLogicalOperator(String operator) {
        this.baseOperator.setLogicalOperator(operator);
    }

    public String build() {
        if(objectName == null) throw new TLQueryBuilderException(EXCEPTION_MISSING_OBJECT_FIELD);

        String queryString = 'SELECT ' + buildFieldString() + ' FROM ' + objectName;
        if(baseOperator.conditions.size() > 0 || baseOperator.operators.size() > 0) {
            queryString += ' WHERE ' + baseOperator.build();
        }

        if(queryLimit != null) {
            queryString += ' LIMIT ' +  queryLimit;
        }

        return queryString;
    }

    public String buildFieldString() {
        if(fields.size() == 0) return 'Id';
        return String.join(new List<String>(fields), FIELD_SEPARATOR);
    }

    public virtual class Operator {
        private Boolean isTopLevel;
        private String logicalOperator;
        private List<Condition> conditions;
        private List<Operator> operators;

        public Operator() {
            isTopLevel = false;
            conditions = new List<Condition>();
            operators = new List<Operator>();
        }

        public void setLogicalOperator(String logicalOperator) {
            this.logicalOperator = logicalOperator;
        }

        public String build() {
            List<String> conditionStrings = new List<String>();
            for(Condition condition : conditions) {
                conditionStrings.add(condition.build());
            }

            for(Operator operator : operators) {
                conditionStrings.add(operator.build());
            }

            if(logicalOperator == null && conditionStrings.size() > 1) throw new TLQueryBuilderException(EXCEPTION_MISSING_OBJECT_FIELD);
            if(isTopLevel) {
                return String.join(conditionStrings, ' ' + logicalOperator + ' ');
            }
            else {
                return '(' + String.join(conditionStrings, ' ' + logicalOperator + ' ') + ')';
            }
        }

        public void addCondition(Condition condition) {
            this.conditions.add(condition);
        }

        public void addConditions(List<Condition> conditions) {
            this.conditions.addAll(conditions);
        }

        public void addOperator(Operator operator) {
            this.operators.add(operator);
        }

        public void addOperators(List<Operator> operators) {
            this.operators.addAll(operators);
        }
    }

    public class BaseOperator extends Operator {
        public BaseOperator() {
            super();
            isTopLevel = true;
        }
    }

    public class AndOperator extends Operator {
        public AndOperator() {
            super();
            logicalOperator = AND_OPERATOR;
        }
    }

    public class OrOperator extends Operator {
        public OrOperator() {
            super();
            logicalOperator = OR_OPERATOR;
        }
    }


    public class Condition {
        private String field;
        private String operator;
        private String value;
        private List<String> values;
        private String type;

        private String QUOTE = '\'';


        public Condition(String field, String operator, String value) {
            this.field = field;
            this.operator = operator;
            this.value = value;

            if(LIST_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,'String'}));
            }
        }

        public Condition(String field, String operator, List<String> values) {
            this.field = field;
            this.operator = operator;
            this.values = values;

            if(SINGLE_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,'List<String>'}));
            }
        }

        public Condition(String field, String operator, Set<String> values) {
            this.field = field;
            this.operator = operator;
            this.values = new List<String>(values);

            if(SINGLE_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,'List<String>'}));
            }
        }

        public Condition(String field, String operator, String value, String type) {
            this.field = field;
            this.operator = operator;
            this.value = value;
            this.type = type;

            if(LIST_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,this.type}));
            }
        }

        public Condition(String field, String operator, List<String> values, String type) {
            this.field = field;
            this.operator = operator;
            this.values = values;
            this.type = type;

            if(SINGLE_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,'List<' + this.type + '>'}));
            }
        }

        public Condition(String field, String operator, Set<String> values, String type) {
            this.field = field;
            this.operator = operator;
            this.values = new List<String>(values);
            this.type = type;

            if(SINGLE_OPERATORS.contains(this.operator)) {
                throw new TLQueryBuilderException(String.format(EXCEPTION_INVALID_OPERATOR,new List<Object>{this.operator,'List<' + this.type + '>'}));
            }
        }

        public String build() {
            String conditionString = '';
            if(SINGLE_OPERATORS.contains(this.operator)) {
                if (type == INTEGER_TYPE || type == DECIMAL_TYPE || type == BOOLEAN_TYPE) {
                    conditionString = this.field + ' ' + this.operator + ' ' + this.value;
                }
                else {
                    conditionString = this.field + ' ' + this.operator + ' ' + QUOTE + this.value + QUOTE;
                }
            }
            else if(LIST_OPERATORS.contains(this.operator)) {
                if (type == INTEGER_TYPE || type == DECIMAL_TYPE || type == BOOLEAN_TYPE) {
                    conditionString = this.field + ' ' + this.operator + ' (' + String.join(this.values, FIELD_SEPARATOR);
                }
                else {
                    for(String s : this.values)
                    conditionString = this.field + ' ' + this.operator + ' (' + QUOTE + String.join(this.values, STRING_VALUE_SEPARATOR) + QUOTE + ')';
                }
            }
            return conditionString;
        }
    }
}