public with sharing class CaseTriggerHandler {

    public static void handleBeforeInsert(List<Case> newCases) {

       Set<Id> accountIds = new Set<Id>();

        // Coletar Accounts dos Cases
        for (Case c : newCases) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        if (accountIds.isEmpty()) return;

        // Buscar Accounts com SLA definido
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, SLA__c FROM Account WHERE Id IN :accountIds]
        );

        // Buscar Entitlements das Accounts
        List<Entitlement> entitlements = [ SELECT Id, Name, Status FROM Entitlement where Status = 'Active'];

        // Organizar Entitlements por Account e Nome (SLA)
        Map<String, Entitlement> entMap = new Map<String, Entitlement>();
        for (Entitlement e : entitlements) {
            entMap.put(e.Name, e);
        }

        // Relacionar Entitlement ao Case
        for (Case c : newCases) {
            if (c.AccountId != null && accMap.containsKey(c.AccountId)) {

                String sla = accMap.get(c.AccountId).SLA__c;

                if (sla != null && entMap.containsKey(sla)) {
                    c.EntitlementId = entMap.get(sla).Id;
                }
                }
            }
        }
    

}
