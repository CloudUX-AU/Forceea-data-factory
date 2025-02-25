/*
  Forceea data factory (2.7.0)
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
global with sharing class Forceea {

    /* CLASSES */

    /**
     * @description The class for asynchronous transaction.
     */
    public class AsyncTransaction {

        public Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
        public List<Forceea.FObjectAsynchronous> sObjectsToUpdateOrDelete = new List<Forceea.FObjectAsynchronous>();
        public Map<String, Forceea.FObjectAsynchronous> template = new Map<String, Forceea.FObjectAsynchronous>();

        public Integer batchId = 1;
        public Datetime dateTimeNow;
        public Boolean hasPartitioning = true;
        public Boolean isBenchmark = false;
        public Boolean isExcludedOnAsyncUpdateOrDelete = false;
        public Integer jobId = 0;

        public String locality = '';
        public String language = '';

        public Integer numErrors = 0;
        public Integer numJobs = 0;
        public Integer numJobUnitsExecuted = 0; // the iterations that have been inserted in the job
        public Integer numJobUnitsToExecute = 0; // the units that should be executed in the job
        public Integer numMaxRecordOnAsyncDelete = 0;
        public Integer numMaxRecordOnAsyncUpdate = 0;
        public Integer numTotalJobUnits = 0; // the units that should be executed in the job
        public Integer numMaxUnitsPerBatch = 1; // the max units allowed to be executed per batch
        public Integer numProcessUnitsToExecute = 0; // the total units (iterations/records) that should be executed

        public ForceeaService.OperationType operationType;
        public String partitionFieldValue = '';
        public String processId = '';
        public Long seed = 0;
        public Integer sector = 0;

        public String sObjectApiName = '';
        public Integer sObjectToUpdateOrDeleteIndex = 0;
        public Integer timeFrameForUpdateInMinutes = 0;
        public String verbose = '';
    }

    /**
     * @description The class for a cluster.
     */
    public class Cluster {

        public List<String> arguments = new List<String>();
        public String parameter { get; set; }

        public Cluster(String parameter, List<String> arguments) {
            this.arguments = new List<String>(arguments);
            this.parameter = parameter;
        }

        /**
         * @description Sets the source parameter for all related definitions..
         * @param source The source (forceea or salesforce).
         */
        public void setSourceParameter(String source) {
            this.arguments.clear();
            this.arguments.add(source);
        }
    }

    /**
     * @description The class for the cluster type.
     */
    public class ClusterType {

        public Boolean allowsMultipleArguments { get; set; } // true if the value allows multiple arguments
        public String parameter { get; set; } // the parameter, e.g. "from"
        public String value { get; set; } // the parameter value , e.g. "10"
        public ForceeaService.ValueType valueType { get; set; } // the parameter value type, e.g. TYPE_DECIMAL

        public ClusterType(String parameter, ForceeaService.ValueType valueType, String value, Boolean allowsMultipleArguments) {
            this.allowsMultipleArguments = allowsMultipleArguments;
            this.parameter = parameter;
            this.value = value;
            this.valueType = valueType;
        }
    }

    /**
     * @description The class for a field definition.
     */
    public class FieldDefinition {
        public String definitionString = '';
        public String fieldApiName = '';
    }

    /**
     * @description The class for field information.
     */
    public class FieldInfo {

        /* COLLECTIONS */

        public List<Schema.SObjectType> parents = new List<Schema.SObjectType>();
        public List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();

        /* VARIABLES & PROPERTIES */

        public Boolean allowsMultipleDefinitions { get; set; }
        public Boolean canHaveMultipleTypesAsParents { get; set; }
        public String controllingFieldApiName { get; set; } // the API name of the controlling picklist field
        public Schema.DisplayType dataType { get; set; }

        public String fieldApiName { get; set; } // the field API name
        public String fieldName { get; set; } // the field API name in lowercase

        public Boolean isAccessible { get; set; } // the current user can see this field
        public Boolean isCreateable { get; set; } // can be created by the current user
        public Boolean isRequired { get; set; } // is required when inserting/updating a record
        public Boolean isRestrictedPicklist { get; set; }

        public String label { get; set; } // the text label that is displayed next to the field in the user interface
        public Integer length { get; set; } // for string fields, the maximum size

    }

    /**
     * @description The class for asynchronous.
     */
    public class FObjectAsynchronous {
        public List<Forceea.FieldDefinition> definitions = new List<Forceea.FieldDefinition>();
        public String bigObjectIndexFieldsString = '';
        public Boolean isExcludedOnUpdateOrDelete = false;
        public Integer numMaxRecordOnDelete = 0;
        public Integer numMaxRecordOnUpdate = 0;
        public Integer numOfRecords = 0;
        public Boolean numOfRecordsIsAuto = false;
        public Integer timeFrameForUpdateInMinutes = 0;
        public String partitionFieldName = '';
        public Boolean setRequiredFields = false;
        public String sObjectApiName = '';
        public String whereClauseOnDelete = '';
        public String whereClauseOnUpdate = '';
    }

    /**
     * @description the class for sObject info.
     */
    public class SObjectInfo {
        public String sObjectApiName { get; set; }
        public Schema.SObjectType sObjType { get; set; }
    }

    /**
     * @description The class for template.
     */
    global class Template {

        /* COLLECTIONS */

        private Map<String, FObject> templateMap = new Map<String, FObject>();
        private Map<String, List<Database.SaveResult>> insertResults = new Map<String, List<Database.SaveResult>>();

        /* CONSTRUCTORS */

        global Template() {
            this.templateMap = new Map<String, FObject>();
        }

        global Template(String key, FObject obj) {
            this.templateMap.put(key, obj);
        }

        global Template(Map<String, FObject> newTemplate) {
            this.templateMap.putAll(newTemplate);
        }

        global Template(Template newTemplate) {
            this.add(newTemplate);
        }

        /* METHODS */

        /**
         * @description Adds a template into the current template.
         * @param newTemplate The new template to add.
         * @return The current Template.
         */
        global Template add(Template newTemplate) {
            this.templateMap.putAll(newTemplate.templateMap);
            return this;
        }

        /**
         * @description Adds a template map into the current template.
         * @param newMapTemplate The new template map to add.
         * @return The current Template.
         */
        global Template add(Map<String, FObject> newMapTemplate) {
            this.templateMap.putAll(newMapTemplate);
            return this;
        }

        /**
         * @description Adds an FObject into the current template.
         * @param key The FObject key.
         * @param obj The FObject.
         * @return The current Template.
         */
        global Template add(String key, FObject obj) {
            this.templateMap.put(key, obj);
            return this;
        }

        /**
         * @description Retrieves an FObject from the template.
         * @param key The FObject key.
         * @return An FObject.
         */
        global FObject getFObject(String key) {
            return this.templateMap.get(key);
        }

        /**
         * @description Retrieves the results of the last insertion.
         * @return A map of save results.
         */
        global Map<String, List<Database.SaveResult>> getInsertResults() {
            return this.insertResults;
        }

        /**
         * @description Retrieves the template map.
         * @return A map with key: FObject key, value: FObject.
         */
        global Map<String, FObject> getMap() {
            return this.templateMap;
        }

        /**
         * @description Retrieves a new Template with the specified keys of the current Template.
         * @param keys The list of map keys.
         * @return The map with the FObjects of the given keys.
         */
        private Map<String, FObject> getTemplate(List<String> keys) {
            Map<String, FObject> results = new Map<String, FObject>();

            for (String key : keys) {
                results.put(key, this.templateMap.get(key));
            }

            return results;
        }

        /**
         * @description Generates and insert the template records.
         * @param allOrNone If true, the operation allows partial success.
         * @return The current Template.
         */
        global Template insertRecords(Boolean allOrNone) {
            this.insertResults = FObject.insertRecordsFromTemplate(this.templateMap, allOrNone);
            return this;
        }

        /**
         * @description Keeps the FObject of the given key and removes all other FObjects.
         * @param key The key to keep.
         * @return The current template with only the given key.
         */
        global Template keep(String key) {
            if (this.templateMap.containsKey(key)) {
                this.templateMap = new Map<String, FObject> {
                    key => this.templateMap.get(key)
                };
            }
            return this;
        }

        /**
         * @description Keeps all FObjects after (but not including) the pivot key and removes all other FObjects.
         * @param pivotKey The pivot key.
         * @return The current template with only the keys after the pivot key.
         */
        global Template keepAfter(String pivotKey) {
            if (!this.templateMap.containsKey(pivotKey)) {
                return this;
            }

            Boolean hasFoundPivot = false;
            Map<String, FObject> results = new Map<String, FObject>();

            for (String key : this.templateMap.keySet()) {
                if (hasFoundPivot) {
                    results.put(key, this.templateMap.get(key));
                }
                if (pivotKey.equalsIgnoreCase(key)) {
                    hasFoundPivot = true;
                }
            }
            this.templateMap = results;

            return this;
        }

        /**
         * @description Keeps all FObjects before (but not including) the pivot key and removes all other FObjects.
         * @param pivotKey The pivot key.
         * @return The current template with only the keys before the pivot key.
         */
        global Template keepBefore(String pivotKey) {
            if (!this.templateMap.containsKey(pivotKey)) {
                return this;
            }

            Map<String, FObject> results = new Map<String, FObject>();
            for (String key : this.templateMap.keySet()) {
                if (key.equalsIgnoreCase(pivotKey)) {
                    break;
                }
                results.put(key, this.templateMap.get(key));
            }
            this.templateMap = results;

            return this;
        }

        /**
         * @description Keeps the FObjects of the given keys and removes all other FObjects.
         * @param keysToKeep The list of keys to keep.
         * @return The current template with only the given keys.
         */
        global Template keep(List<String> keysToKeep) {
            List<String> existingMapKeys = new List<String>(this.templateMap.keySet());
            List<String> keys = ForceeaService.keepValuesInList(existingMapKeys, keysToKeep);
            Forceea.Template result = new Forceea.Template();

            for (String key : keys) {
                result.add(key, this.templateMap.get(key));
            }

            this.templateMap = result.getMap();
            return this;
        }

        /**
         * @description Removes the FObject of the given key.
         * @param keyToRemove The key to remove.
         * @return The current template without the given key.
         */
        global Template remove(String keyToRemove) {
            this.templateMap.remove(keyToRemove);
            return this;
        }

        /**
         * @description Removes all FObjects after (but not including) the pivot key.
         * @param pivotKey The pivot key.
         * @return The current template without the FObjects with key after the given key.
         */
        global Template removeAfter(String pivotKey) {
            if (!this.templateMap.containsKey(pivotKey)) {
                return this;
            }

            Boolean hasFoundPivot = false;
            Map<String, FObject> results = new Map<String, FObject>();

            for (String key : this.templateMap.keySet()) {
                if (!hasFoundPivot) {
                    results.put(key, this.templateMap.get(key));
                } else {
                    break;
                }
                if (pivotKey.equalsIgnoreCase(key)) {
                    hasFoundPivot = true;
                }
            }
            this.templateMap = results;

            return this;
        }

        /**
         * @description Removes all FObjects before (but not including) the pivot key.
         * @param pivotKey The pivot key.
         * @return The current template without the FObjects with key before the given key.
         */
        global Template removeBefore(String pivotKey) {
            if (!this.templateMap.containsKey(pivotKey)) {
                return this;
            }

            Boolean hasFoundPivot = false;
            Map<String, FObject> results = new Map<String, FObject>();

            for (String key : this.templateMap.keySet()) {
                if (pivotKey.equalsIgnoreCase(key)) {
                    hasFoundPivot = true;
                }
                if (hasFoundPivot) {
                    results.put(key, this.templateMap.get(key));
                }
            }
            this.templateMap = results;

            return this;
        }

        /**
         * @description Removes the FObjects of the given keys.
         * @param keysToRemove The keys to remove.
         * @return The current template without the given keys.
         */
        global Template remove(List<String> keysToRemove) {
            List<String> existingMapKeys = new List<String>(this.templateMap.keySet());
            List<String> keys = ForceeaService.removeValuesFromList(existingMapKeys, keysToRemove);
            this.templateMap = getTemplate(keys);
            return this;
        }

    }

    /**
     * @description The class of a definition variable.
     */
    public class Variable {

        public String name { get; set; }

        public Boolean booleanValue { get; set; }
        public Date dateValue { get; set; }
        public Datetime datetimeValue { get; set; }
        public Decimal decimalValue { get; set; }
        public Integer integerValue { get; set; }
        public String stringValue { get; set; }

        public Boolean isGlobalVariable { get; set; }

        /* CONSTRUCTORS */

        public Variable(String name, Boolean value, Boolean isGlobalVariable) {
            this.name = name;
            this.booleanValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Date value, Boolean isGlobalVariable) {
            this.name = name;
            this.dateValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Datetime value, Boolean isGlobalVariable) {
            this.name = name;
            this.datetimeValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Decimal value, Boolean isGlobalVariable) {
            this.name = name;
            this.decimalValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, String value, Boolean isGlobalVariable) {
            this.name = name;
            this.stringValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

    }

}