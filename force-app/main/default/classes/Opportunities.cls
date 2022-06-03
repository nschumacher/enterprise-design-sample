/**
 * @author Nicholas Schumacher
 * @date May 2022
 * 
 * @description A Domain class for the Opportunity object. This will control the data and behavior for Opportunities.
 * 
 * *Note: we don't have to use "with sharing" or without as we could let this inherit the calling class's security
 * *Note: the sample logic below was built as part of completing the Apex Enterprise Patterns Trailhead module
 */
public class Opportunities extends fflib_SObjectDomain {
    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList);
        
        // Disable default Object Security checking    
        //Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * @description This allows us to create an instance and let the OpportunitiesTrigger call this class
     */ 
	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<sObject> sObjectLIst) {
			return new Opportunities(sObjectList);
		}
	}
    
    /**
     * @description This method is called from the handleBeforeInsert base class method during a trigger 
     *  invocation that also calls onBeforeInsert
     */
	public override void onApplyDefaults() {
        for(Opportunity opportunity : (List<Opportunity>) Records) {
            /*if(opportunity.DiscountType__c == null) {
                opportunity.DiscountType__c = OpportunitySettings__c.getInstance().DiscountType__c;
            } */              
        }
	}

    /**
     * @description This method is called from the handleAfterInsert base class method during a trigger
     *  invocation that then calls onAfterInsert. 
     */
	public override void onValidate() {
        for(Opportunity opp : (List<Opportunity>) Records) {
            if(opp.Type.startsWith('Existing') && opp.AccountId == null) {
                opp.AccountId.addError('You must provide an Account when ' +
                    'creating Opportunities for existing Customers.');
            }
        }
	}

    /**
     * @description This method is called from the handleAfterUpdate base class method during a trigger
     *  invocation that then calls onAfterUpdate. Should be used to validate changes to records
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public override void onValidate(Map<Id, SObject> existingRecords) {
        for(Opportunity opp : (List<Opportunity>) Records) {
            Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
            if(opp.Type != existingOpp.Type) {
                opp.Type.addError('You cannot change the Opportunity type once it has been created');
            }
        }
	}

    /**
     * @description houses the logic to be executed in when Trigger.isBefore && Trigger.isInsert
     */
	public override void onBeforeInsert() {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isBefore && Trigger.isUpdate
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		
	}

    /**
     * @description houses the logic to be executed in when Trigger.isBefore && Trigger.isDelete
     */
	public override void onBeforeDelete() {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isInsert
     */
	public override void onAfterInsert() {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isUpdate
     * @param existingRecords Populated with the records in Trigger.oldMap
     */
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isDelete
     */
	public override void onAfterDelete() {
	}

    /**
     * @description houses the logic to be executed in when Trigger.isAfter && Trigger.isUndelete
     * * The after undelete trigger event may not be supported for a given object. Custom objects
     * * and several standard objects are supported, but not all
     */
	public override void onAfterUndelete() {
	}
}
