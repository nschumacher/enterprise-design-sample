public with sharing class CaseTriggerHandler {

    /** 
     *  @description This is a simple code approach to bypassing the trigger. Other trigger logic can
     *  set this to true to avoid unwanted recursion.
     */
    public static final Boolean BYPASS_CASE_TRIGGER = false; 

    /**
     * @description This will coordinate the execution of all Case trigger logic
     */
    public static void handleTriggerContext(List<Case> oldCasesList, List<Case> newCasesList, Map<Id,Case> oldMap, Map<Id,Case> newMap) {

        // First thing's first, check custom setting for bypass
        if (TriggerService.isTriggerBypassed('Case')) {
            return;
        }

        Cases allCases;
        Cases creditCardCases;
        Cases retailCases;
        Cases commercialCases;
        
        // Instantiate a Cases object to build all relevant collections (shared across the types)
        allCases = new Cases(oldMap, newMap, newCasesList);
        allCases.buildCollections(oldMap, newMap, newCasesList);

        // Build child objects based off the businessUnitToCasesMap
        for (String caseType : allCases.businessUnitToCasesMap.keySet()) {
            if (caseType == Cases.CREDIT_CARD_TYPE_LABEL) {
                creditCardCases = new CasesCreditCard(oldMap, newMap, newCasesList, allCases.businessUnitToCasesMap.get(Cases.CREDIT_CARD_TYPE_LABEL));
            } 
            else if (caseType == Cases.RETAIL_TYPE_LABEL) {
                // TODO add this class
                //retailCases = new CasesRetail(oldMap, newMap, allCases.businessUnitToCasesMap.get(Cases.RETAIL_TYPE_LABEL));
            }
            else if (caseType == Cases.COMMERCIAL_TYPE_LABEL) {
                // TODO add this class
                //commercialCases = new CasesCommercial(oldMap, newMap, allCases.businessUnitToCasesMap.get(Cases.COMMERCIAL_TYPE_LABEL));
            }
        }

        // ------------ Before Insert ------------
        if (Trigger.isBefore && Trigger.isInsert) {
            if(creditCardCases != null) {
                creditCardCases.handleBeforeInsert();
            }
            /* // TODO
            if(retailCases != null) {
                retailCases.handleBeforeInsert();
            }

            if(commercialCases != null) {
                commercialCases.handleBeforeInsert();
            }*/
        }

        // ------------ After Insert ------------
        if (Trigger.isAfter && Trigger.isInsert) {
            if(creditCardCases != null) {
                creditCardCases.handleAfterInsert();
            }
            /**
             * if(retailCases != null) {
             *   retailCases.handleAfterInsert();
             * }
             * 
             * if(commercialCases != null) {
             *   commercialCases.handleAfterInsert();
             * }
             */
        }
    }
}