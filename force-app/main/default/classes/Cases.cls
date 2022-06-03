/**
 * @author Nicholas Schumacher
 * @date May 2022
 * 
 * @description A Domain class for the Case object. This will control the general data and behavior for Cases within
 * the trigger context regardless of Type. There are Type specific domain classes containing logic solely for a given
 * Case Type (ex. CasesCreditCard for Credit Card Cases)
 */
public virtual with sharing class Cases {

    /* Define properties for each Case Type so we aren't typing the strings out repeatedly */
    public static final String CREDIT_CARD_TYPE_LABEL = 'Credit Card';
    public static final String RETAIL_TYPE_LABEL = 'Retail';
    public static final String COMMERCIAL_TYPE_LABEL = 'Commercial';

    /* Define the collections to be used during processing of all Cases regardless of Type */
    Map<Id,Case> oldMap {get; private set;}
    Map<Id,Case> newMap {get; private set;}
    List<Case> newCasesList {get; private set;}
    Set<Id> associatedAccountIds {get; private set;}
    Set<Id> associatedContactIds {get; private set;}
    public Map<String,List<Case>> businessUnitToCasesMap {get; private set;}


    /* A basic Constructor to set the newMap and oldMap values */
    public Cases(Map<Id,Case> oldMap, Map<Id,Case> newMap, List<Case> newCases) {
        this.oldMap = oldMap != null ? oldMap : null;
        this.newMap = newMap != null ? newMap : null;
        this.newCasesList = newCases != null ? newCases : null;
    }

    /**
     * @description a single spot to loop through all records in the context to build relevant collections.
     * This helps cut down on repeated for-loops in later methods to reiterate through our records
     * @param oldMap The values from Trigger.oldMap
     * @param newMap The values from Trigger.newMap
     * @param newCases The values from Trigger.new for before insert logic
     */
    public void buildCollections(Map<Id,Case> oldMap, Map<Id,Case> newMap, List<Case> newCases) {
        // Instantiate any new collections that will be used for later logic
        this.associatedAccountIds = new Set<Id>();
        this.associatedContactIds = new Set<Id>();
        this.businessUnitToCasesMap = new Map<String,List<Case>>();
        
        // A single loop to generate all related collections. Loop through newCases if newMap is null (before insert context)
        for (Case myCase : newCasesList)
        {
            if (myCase.AccountId != null) {
                this.associatedAccountIds.add(myCase.AccountId);
            }

            if (myCase.ContactId != null) {
                this.associatedContactIds.add(myCase.contactId);
            }

            if (myCase.Type.contains(CREDIT_CARD_TYPE_LABEL)) {
                if (this.businessUnitToCasesMap.get(CREDIT_CARD_TYPE_LABEL) != null) {
                    this.businessUnitToCasesMap.get(CREDIT_CARD_TYPE_LABEL).add(myCase);
                } else {
                    this.businessUnitToCasesMap.put(CREDIT_CARD_TYPE_LABEL, new List<Case>{myCase});
                }
            }
            else if (myCase.Type.contains(RETAIL_TYPE_LABEL)) {
                if (this.businessUnitToCasesMap.get(RETAIL_TYPE_LABEL) != null) {
                    this.businessUnitToCasesMap.get(RETAIL_TYPE_LABEL).add(myCase);
                } else {
                    this.businessUnitToCasesMap.put(RETAIL_TYPE_LABEL, new List<Case>{myCase});
                }
            }
            else if (myCase.Type.contains(COMMERCIAL_TYPE_LABEL)) {
                if (this.businessUnitToCasesMap.get(COMMERCIAL_TYPE_LABEL) != null) {
                    this.businessUnitToCasesMap.get(COMMERCIAL_TYPE_LABEL).add(myCase);
                } else {
                    this.businessUnitToCasesMap.put(COMMERCIAL_TYPE_LABEL, new List<Case>{myCase});
                }
            }
        }
    }



    /**
     * @description This method coordinates before insert logic for all Cases. It shouldn't be overridden,
     *  but the methods inside should be for the various Case Types
     */
    public void handleBeforeInsert() { // notice it isn't a virtual method, this means it cannot be overridden by the child classes
        for (Case myCase : this.newCasesList) {
            onValidate(myCase);
            onApplyDefaults(myCase);
        }
        onBeforeInsert();
    }


    /**
     * @description This method is called from the handleAfterInsert and will validate fields regardless of Type
     *  invocation that then calls onAfterInsert 
     */
	public virtual void onValidate(Case myCase) {
        /**
         * Verify information regardless of case type.
         * TIP: use service methods for heavy lifting and this method for coordination
         * 
         * if (myCase.Reason == null) {
         *   newMap.get(myCase.Id).addError('The Case must have a Reason.'); // yes, this could be a validation rule, but it's a sample
         * }
         * ...
         */

        // Example
        CasesService.validateDescriptionDetails(myCase);
	}

    /**
     * @description This method is called from the handleBeforeInsert and will set default values for all cases 
     *  regardless of Type
     */
	public virtual void onApplyDefaults(Case myCase) {
        /**
         * Set default values for all cases regardless of type. 
         * TIP: use service methods for heavy lifting and this method for coordination
         * 
         * myCase.SLA__c = 'Standard';
         * myCase.Subject = myCase.Type + ' - ' + myCase.Subject;
         * ...
         */

        // Example
        CasesService.addDefaultsToDescription(myCase);
    }

    /**
     * @description This should house logic to be executed for all Cases regardless of Type during the 
     * before insert execution of the trigger context
     */
	public virtual void onBeforeInsert() {
        /**
         * Perform any further processing per your business needs, calling helper methods
         * as necessary. It is suggested to put these helper methods in a service class for Cases
         * where the logic will apply regardless of type
         * 
         * If possible, try to loop through the records as few times as possible, maybe even once
         * in this method, and call helpers to perform actions on single records
         */

        // Example
        for(Case myCase : this.newCasesList) {
            CasesService.addAdditionalDetailsToDescription(myCase);
        }
	}


    /**
     * @description This method coordinates after insert logic for all Cases. It shouldn't be overridden,
     *  but the methods inside should be for the various Case Types
     */
    public void handleAfterInsert() { // notice it isn't a virtual method, this means it cannot be overridden by the child classes
        onAfterInsert();
        onAfterInsertAsynchronousActions();
    }

    /**
     * @description This should house logic to be executed for all Cases regardless of Type during the
     * after insert execution of the trigger context
     */
	public virtual void onAfterInsert() {
        /**
         * Perform any further processing per your business needs, calling helper methods
         * as necessary. It is suggested to put these helper methods in a service class for Cases
         * where the logic will apply regardless of type
         * 
         * If possible, try to loop through the records as few times as possible, maybe even once
         * in this method, and call helpers to perform actions on single records
         */

        // Example
        List<FeedItem> newSimpleChatterRemindersOnAccount = new List<FeedItem>();

        for(Case myCase : this.newCasesList) {
            newSimpleChatterRemindersOnAccount.add(CasesService.buildSimpleChatterReminderOnAccount(myCase));
        }

        try {
            insert newSimpleChatterRemindersOnAccount;
        } catch (Exception e) {
            // Handle how best your project sees fit. Perhaps log to a custom object for capturing Exceptions?
        }
	}

    /**
     * @description Coordinate and kick off any asynchronous jobs that need to happen after inserting
     * a new collection of Cases regardless of their type
     */
    public virtual void onAfterInsertAsynchronousActions() {
        /**
         * In complex orgs, it can be a useful practice to delay some trigger actions as asynchronous jobs.
         * Some examples can include creating or updating related objects, making callouts to external systems, etc.
         * 
         * As of the Summer '19 Release, it would be an even better practice to enable Change Data Capture for the Case
         * Object and move any and all asynchronous processing to an CaseChangeAsyncTrigger on the CaseChangeEvent
         * Object.
         * https://developer.salesforce.com/blogs/2019/06/get-buildspiration-with-asynchronous-apex-triggers-in-summer-19  
         */

        // Example
        CasesService.exportNewCaseDetails(Trigger.newMap.keySet());
    }
    
    
    
    /* --------------------------------------------------------------------------------------------------- */
    
    
    
    /**
     * @description This method is called from the handleAfterUpdate base class method during a trigger
     *  invocation that then calls onAfterUpdate
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public virtual void onValidate(Map<Id, SObject> existingRecords) {
	}

    

    /**
     * @description houses the logic to be executed in when Trigger.isBefore && Trigger.isUpdate
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public virtual void onBeforeUpdate(Map<Id, SObject> existingRecords) {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isBefore && Trigger.isDelete
     */
	public virtual void onBeforeDelete() {
	}

    

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isUpdate
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public virtual void onAfterUpdate(Map<Id, SObject> existingRecords) {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isDelete
     */
	public virtual void onAfterDelete() {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isUndelete
     * * The after undelete trigger event may not be supported for a given object. Custom objects
     * * and several standard objects are supported, but not all
     */
	public virtual void onAfterUndelete() {
	}



    
}
