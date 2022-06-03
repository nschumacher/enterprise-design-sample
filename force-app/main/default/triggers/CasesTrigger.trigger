trigger CasesTrigger on Case (after delete, after insert, after update, after undelete, 
    before delete, before insert, before update
) {
    // Pass execution to the handler where logic is housed
    CaseTriggerHandler.handleTriggerContext(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
}