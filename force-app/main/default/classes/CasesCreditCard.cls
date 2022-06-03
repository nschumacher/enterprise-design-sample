/**
 * @author Nicholas Schumacher
 * @date May 2022
 * 
 * @description A domain class for Credit Card Cases. It inherits properties from the base domain class: Cases. This class
 * controls the data and behavior for Credit Card Cases within the trigger context. 
 * 
 * *Note* Think of this as a trigger handler class specifically for Credit Card Cases - it coordinates logic, 
 * calling service classes to do heavy lifting.
 */


public with sharing class CasesCreditCard extends Cases {

    List<Case> creditCardCases {get; private set;}

    public CasesCreditCard(Map<Id,Case> oldMap, Map<Id,Case> newMap, List<Case> newCases, List<Case> initialCreditCardCases) {
        super(oldMap, newMap, newCases);
        this.creditCardCases = initialCreditCardCases;
    }


    /**
     * @description add behavior to the validation specific to Credit Card Cases
     */
    public override void onValidate(Case myCase) {
        // Perform the same validation as all Cases. Remove this if it doesn't align with your business needs
        super.onValidate(myCase);

        /* Verify additional information specific to Credit Card Cases

        if (someCondition) {
           myCase.addError('The Case must have...');
        }
        */

        CasesCreditCardService.validateDescriptionDetails(myCase);
    }

    /**
     * @description add behavior to the apply defaults specific to Credit Card Cases
     */
    public override void onApplyDefaults(Case myCase) {
        // Perform the same defaults as all Cases. Remove this if it doesn't align with your business needs
        super.onApplyDefaults(myCase);

        /**
         * Apply defaults specific to Credit Card Cases
         * TIP: use service methods for heavy lifting and this method for coordination
         * 
         * myCase.Priority = 'High'; // Elevated Priority
         * myCase.SLA__c = 'Expedited'; // A tighter SLA
         * ...
         */
        
        CasesCreditCardService.addDefaultsToDescription(myCase);
    }

    /**
     * @description This will house logic to be executed specifically for Credit Card Cases in the before
     *  insert execution of the trigger context.
     */
    public override void onBeforeInsert() {
        // Perform the shared before insert actions for all Cases. Remove this if it doesn't align with your business needs
        super.onBeforeInsert();

        /**
         * Perform any further processing per your business needs SPECIFIC TO Credit Card Cases, 
         * calling service methods as necessary. It is suggested to put these helper methods 
         * in a service class specific to Credit Card Cases (CasesCreditCardService)
         *
         * If possible, try to loop through the records as few times as possible, maybe even once
         * in this method, and call services to perform actions on single records
         */

        // Example
        for(Case myCase : this.creditCardCases) {
            CasesCreditCardService.addAdditionalDetailsToDescription(myCase);
        }
    }

    /**
     * @description This should house logic to be executed for Credit Card Cases during the
     * after insert execution of the trigger context
     */
	public override void onAfterInsert() {
        // Perform the shared before insert actions for all Cases. Remove this if it doesn't align with your business needs
        super.onAfterInsert();

        /**
         * Perform any further processing per your business needs SPECIFIC TO Credit Card Cases, 
         * calling service methods as necessary. It is suggested to put these helper methods 
         * in a service class specific to Credit Card Cases (CasesCreditCardService)
         *
         * If possible, try to loop through the records as few times as possible, maybe even once
         * in this method, and call services to perform actions on single records
         */

        // Example
        List<FeedItem> newCreditCardChatterRemindersOnAccount = new List<FeedItem>();

        for(Case myCase : this.creditCardCases) {
            newCreditCardChatterRemindersOnAccount.add(CasesCreditCardService.buildSimpleChatterReminderOnAccount(myCase));
        }

        try {
            insert newCreditCardChatterRemindersOnAccount;
        } catch (Exception e) {
            // Handle how best your project sees fit. Perhaps log to a custom object for capturing Exceptions?
        }
	}

    /**
     * @description Coordinate and kick off any asynchronous jobs that need to happen after inserting
     * a new collection of Cases regardless of their type
     */
    public override void onAfterInsertAsynchronousActions() {
        // Perform the shared before insert actions for all Cases. Remove this if it doesn't align with your business needs
        super.onAfterInsertAsynchronousActions();

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
        // This keySet would actually need to be built along with the list of creditcardcases in the Cases super class.
        // Using the newMap keySet simplifies the implementation for basic scalable testing
        CasesCreditCardService.exportNewCreditCardCaseDetails(Trigger.newMap.keySet()); 
    }
}
