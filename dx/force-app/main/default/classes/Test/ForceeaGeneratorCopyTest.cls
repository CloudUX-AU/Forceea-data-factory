/*
  Forceea data factory (v2.5)
  Copyright (C) 2022 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
@IsTest
public class ForceeaGeneratorCopyTest {

    @IsTest
    private static void copy_valid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(" 100 ") scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestDecimal__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDecimal__c.intValue() != Integer.valueOf(objRecord.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyVirtualField_valid_expectSuccess() {
        List<String> arguments = new List<String>{
            '1.0', '2.0', '3.0', '0.0'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(1, 2, 3, 0)')
            .setDefinition('$Test', 'copy field(TestText__c)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'copy field($Test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestInteger__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'copy list - errors found');
    }

    @IsTest
    private static void copy_invalidField_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestDecimalX__c)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid copy field [TestDecimalX__c] in definition [copy field(TestDecimalX__c)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copy_insertFieldNotDefined_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_insertVirtualFieldNotDefined_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestInteger)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_insertFieldDefinedAfter_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_insertFieldDefinedInPreviousInsertion_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .removeAllDefinitions()
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_insertVirtualFieldDefinedAfter_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestInteger)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_updateFieldDefinedAfter_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .createRecords();

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)')
            .updateFields();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(record.TestText__c) || record.TestInteger__c == null) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_updateFieldDefinedBefore_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .createRecords();

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .updateFields();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isBlank(record.TestText__c) || record.TestInteger__c == null) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_updateFieldDefinedPreviously_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'copy field(TestDecimal__c)')
            .createRecords();

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'copy field(TestInteger__c)')
            .updateFields();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isBlank(record.TestText__c) || record.TestInteger__c != counter) {
                errors++;
            }
            counter++;
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copy_fieldEqualsDefinitionField_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestText__c', 'copy field(TestText__c)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
            'in definition [copy field(TestText__c)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromText_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestLookup__c) from(FObjectTwo__c.TestpicklistA__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestText__c != null &&
                records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistA__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromReference_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition('$Lookup', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Lookup) from(FObjectTwo__c.TestPicklistDRequired__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestText__c == null &&
                records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistDRequired__c) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromId_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestLookup__c) from(FObjectTwo__c.Id)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : [SELECT TestLookup__c, TestText__c FROM FObjectOne__c]) {
            if (record.TestLookup__c != record.TestText__c) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromDate_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('Testdate__c', 'random type(date) from(2018-01-01) to(2018-12-31)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('Testdate__c', 'copy field(TestLookup__c) from(FObjectTwo__c.Testdate__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestDate__c != null &&
                records1.get(counter).TestDate__c != lookupRecordsMap.get(lookupId).TestDate__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromDatetimeToDatetime_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestDatetime__c, 'random type(datetime) from(2018-01-01) to(2018-12-31)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'copy field(TestLookup__c) from(FObjectTwo__c.TestDateTime__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;

            if (String.valueOf(lookupRecordsMap.get(lookupId).TestDatetime__c) !=
                String.valueOf(records1.get(counter).TestDatetime__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromDatetimeToText_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('Testdatetime__c', 'random type(datetime) from(2018-01-01) to(2018-12-31)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject('FObjectOne__c', 20)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('TestText__c', 'copy field(TestLookup__c) from(FObjectTwo__c.Testdatetime__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            Datetime dt = lookupRecordsMap.get(lookupId).TestDatetime__c;
            if (String.valueOfGmt(dt) != records1.get(counter).TestText__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromTime_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('Testtime__c', 'static value(23:59:59)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('Testtime__c', 'copy field(TestLookup__c) from(FObjectTwo__c.Testtime__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestTime__c != null &&
                records1.get(counter).TestTime__c != lookupRecordsMap.get(lookupId).TestTime__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromPicklist_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field(TestLookup__c) from(FObjectTwo__c.TestPicklistA__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (String.isBlank(records1.get(counter).TestText__c) ||
                records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistA__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromCurrency_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('TestCurrency__c', 'random type(number) from(1) to(100) scale(2)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('TestCurrency__c', 'copy field(TestLookup__c) from(FObjectTwo__c.TestCurrency__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestCurrency__c != null &&
                records1.get(counter).TestCurrency__c != lookupRecordsMap.get(lookupId).TestCurrency__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromCheckbox_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('TestCheckbox__c', 'random type(boolean)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('TestCheckbox__c', 'copy field(TestLookup__c) from(FObjectTwo__c.TestCheckbox__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestCheckbox__c != null &&
                records1.get(counter).TestCheckbox__c != lookupRecordsMap.get(lookupId).TestCheckbox__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromUrl_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition('TestUrl__c', 'random type(url)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('TestUrl__c', 'copy field(TestLookup__c) from(FObjectTwo__c.TestUrl__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestUrl__c != null &&
                records1.get(counter).TestUrl__c != lookupRecordsMap.get(lookupId).TestUrl__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_invalidCopyField_expectFailure() {
        FObject.setExceptionHandling('continue');
        String definitionString = 'copy field(TestlookupX__c) from(FObjectTwo__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition(FObjectOne__c.TestText__c, definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid copy field [TestlookupX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_invalidLookupObject_expectFailure() {
        FObject.setExceptionHandling('continue');
        String definitionString = 'copy field(TestLookup__c) from(FObjecttwoX__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition('TestText__c', definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [FObjecttwoX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_invalidLookupField_expectFailure() {
        FObject.setExceptionHandling('continue');
        String definitionString = 'copy field(TestLookup__c) from(FObjectTwo__c.TestpicklistX__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('TestText__c', definitionString)
            .createRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup field [FObjectTwo__c.TestpicklistX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_lookupFieldEqualsDefinitionField_expectFailure() {
        FObject.setExceptionHandling('continue');
        String definitionString = 'copy field(TestText__c) from(FObjectTwo__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
            'in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookup_fromFieldIsNotLookup_expectFailure() {
        FObject.setExceptionHandling('continue');
        String definitionString = 'copy field(TestInteger__c) from(FObjectTwo__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, definitionString)
            .createRecords();
        Test.stopTest();

        String expectedResult = 'The [from] field [TestInteger__c] is not a lookup or virtual field';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy - errors found');
    }

    @IsTest
    private static void copyLookupVirtualField_valid_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition('$Test', 'copy field(TestLookup__c) from(FObjectTwo__c.TestPicklistA__c)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestText__c != null &&
                records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistA__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'copy - errors found');
    }

}
