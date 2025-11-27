@IsTest
private class CaseTriggerHandlerTest {
    
    @TestSetup
    static void setupData() {
        
        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        
        SlaProcess slaProcess = [SELECT Id, Name FROM SlaProcess WHERE Name = 'Gold' LIMIT 1];
        
        Account acc = new Account(Name = 'Conta Teste', SLA__c = 'Gold');
        insert acc;
        
        Entitlement ent = new Entitlement(Name = 'Gold', AccountId = acc.Id, slaProcessId = slaProcess.Id, BusinessHoursId = bh.Id);
        insert ent;
        
        Account acc2 = new Account(Name = 'Sem SLA');
        insert acc2;
    }  
  
    
    @IsTest
    static void testCaseTriggerHandler_NoSLA_NoEntitlement() {

        Account acc2 = [SELECT Id FROM Account WHERE SLA__c = null LIMIT 1];

        Case c2 = new Case(
            Subject = 'Case sem SLA',
            AccountId = acc2.Id
        );

        Test.startTest();
        insert c2;
        Test.stopTest();

        c2 = [SELECT Id, EntitlementId FROM Case WHERE Id = :c2.Id];

        System.assertEquals(null, c2.EntitlementId,
            'Cases sem SLA não devem receber Entitlement.');
    }

    
    @IsTest
    static void testCaseTriggerHandler_NoAccount() {

        Case c3 = new Case(
            Subject = 'Case sem conta'
        );

        Test.startTest();
        insert c3;
        Test.stopTest();

        c3 = [SELECT Id, EntitlementId FROM Case WHERE Id = :c3.Id];

        System.assertEquals(null, c3.EntitlementId,
            'Case sem Account não deve receber Entitlement.');
    }
}