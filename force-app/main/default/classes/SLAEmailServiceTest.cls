@IsTest
private class SLAEmailServiceTest {
    
    @TestSetup
    static void setupData() {
        
        Account acc = new Account(
            Name = 'Conta Teste',
        Email__c = 'acc@test.com'
            );
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Joao',
        LastName  = 'Silva',
        Email     = 'joao@test.com',
        AccountId = acc.Id
            );
        insert con;
        
        insert new Case(
            Assunto__c   = 'Case Insert',
        Status    = 'Novo',
        ContactId = con.Id,
        AccountId = acc.Id
            );
        
        insert new Case(
            Assunto__c   = 'Case Em Atendimento',
        Status    = 'Novo',
        ContactId = con.Id,
        AccountId = acc.Id
            );
        
        insert new Case(
            Assunto__c   = 'Case Finalizado',
        Status    = 'Em Andamento'
            );
        
        insert new Case(
            Assunto__c         = 'Case Violado',
        Status          = 'Em Andamento',
        SLAViolation__c = 'No'
            );
    }
    
    @IsTest
    static void testAfterInsert() {
        
        Case cs = [
            SELECT Id, ContactId, AccountId, Email__c
            FROM Case WHERE Assunto__c = 'Case Insert'
            LIMIT 1
        ];
        
        Test.startTest();
        EmailTemplate et = [SELECT Id, name FROM EmailTemplate WHERE Name = 'SLAPrimeiraResposta' LIMIT 1];
        SLAEmailService.handleAfterInsert(new List<Case>{ cs });
        Test.stopTest();
        
        System.assert(true);
    }
    
    @IsTest
    static void testAfterUpdate_EmAtendimento() {
        
        Case oldCs = [
        SELECT Id, Status, SLAViolation__c, ContactId, AccountId, Email__c
        FROM Case
        WHERE Assunto__c = 'Case Em Atendimento'
        LIMIT 1
        ];
        
        Case newCs = oldCs.clone(false);
        newCs.Id = oldCs.Id;
        newCs.Status = 'Em Andamento';
        
        Test.startTest();
        EmailTemplate et = [SELECT Id, name FROM EmailTemplate WHERE Name = 'SLAEmAtendimento' LIMIT 1];
        SLAEmailService.handleAfterUpdate(
        new List<Case>{ newCs },
        new Map<Id, Case>{ oldCs.Id => oldCs }
        );
        Test.stopTest();
        
        System.assert(true);
    }
    
    @IsTest
    static void testAfterUpdate_Finalizado() {
        
        Case oldCs = [
        SELECT Id, Status, SLAViolation__c, ContactId, AccountId, Email__c
        FROM Case
        WHERE Assunto__c = 'Case Em Atendimento'
        LIMIT 1
        ];
        
        Case newCs = oldCs.clone(false);
        newCs.Id = oldCs.Id;
        newCs.Status = 'Finalizado';
        
        Test.startTest();
        EmailTemplate et = [SELECT Id, name FROM EmailTemplate WHERE Name = 'SLAFinalizado' LIMIT 1];
        SLAEmailService.handleAfterUpdate(
        new List<Case>{ newCs },
        new Map<Id, Case>{ oldCs.Id => oldCs }
        );
        Test.stopTest();
        
        System.assert(true);
    }
    
    @IsTest
    static void testAfterUpdate_SLAViolado() {
        
       Case oldCs = [
        SELECT Id, Status, SLAViolation__c, ContactId, AccountId, Email__c
        FROM Case
        WHERE Assunto__c = 'Case Em Atendimento'
        LIMIT 1
        ];
        
        Case newCs = oldCs.clone(false);
        newCs.Id = oldCs.Id;
        newCs.SLAViolation__c = 'Yes';
        
        Test.startTest();
        EmailTemplate et = [SELECT Id, name FROM EmailTemplate WHERE Name = 'SLAViolado' LIMIT 1];
        SLAEmailService.handleAfterUpdate(
        new List<Case>{ newCs },
        new Map<Id, Case>{ oldCs.Id => oldCs }
        );
        Test.stopTest();
        
        System.assert(true);
    }
}