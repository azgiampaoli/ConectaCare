trigger CaseTrigger on Case (before insert, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        CaseTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        SLAEmailService.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        SLAEmailService.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }

    
}