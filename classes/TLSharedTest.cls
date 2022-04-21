/**
 * Tests for TLShared
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 */
@IsTest
private class TLSharedTest {

    @IsTest
    private static void getFieldValueNullSObject() {
        Exception caughtException;

        Test.startTest();

        try {
            TLShared.getFieldValue(null, Account.Name);
        } catch (Exception e) {
            caughtException = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'An exception should have been thrown');
        System.assert(caughtException instanceof TLShared.TLFieldException, 'It should be of the correct type');
        System.assertEquals(TLShared.NULL_SOBJECT_ERROR, caughtException.getMessage(),
                'It should have the correct error message');
    }

    @IsTest
    private static void getFieldValueNullField() {
        final Account a = new Account(Name = 'test');
        final String badString = null;

        Exception caughtException;

        Test.startTest();

        try {
            TLShared.getFieldValue(a, badString);
        } catch (Exception e) {
            caughtException = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'An exception should have been thrown');
        System.assert(caughtException instanceof TLShared.TLFieldException, 'It should be of the correct type');
        System.assertEquals(TLShared.NULL_FIELD_ERROR, caughtException.getMessage(),
                'It should have the correct error message');
    }

    @IsTest
    private static void getFieldValueSObjectField() {
        final Account a = new Account(Name = 'test');

        Test.startTest();

        final String result = (String)TLShared.getFieldValue(a, Account.Name);

        Test.stopTest();

        System.assertEquals(a.Name, result, 'The result should be the value of the name field');
    }

    @IsTest
    private static void getFieldValueString() {
        final Account a = new Account(Name = 'test');

        Test.startTest();

        final String result = (String)TLShared.getFieldValue(a, 'Name');

        Test.stopTest();

        System.assertEquals(a.Name, result, 'The result should be the value of the name field');
    }

    @IsTest
    private static void getFieldValueFromParent() {
        final Account parent = new Account(Name = 'Parent');
        final Account a = new Account(Name = 'test', Parent = parent);
        final Contact c = new Contact(LastName = 'Tester', Account = a);

        Test.startTest();

        final String result = (String)TLShared.getFieldValue(c, 'Account.Parent.Name');

        Test.stopTest();

        System.assertEquals(parent.Name, result, 'The result should be the value of the parent name field');
    }

    @IsTest
    private static void getFieldValueFromParentNullParent() {
        final Account a = new Account(Name = 'test');
        final Contact c = new Contact(LastName = 'Tester', Account = a);

        Test.startTest();

        final String result = (String)TLShared.getFieldValue(c, 'Account.Parent.Name');

        Test.stopTest();

        System.assertEquals(null, result, 'If the parent is null, the return value should be null');
    }
}