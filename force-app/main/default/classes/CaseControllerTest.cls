@IsTest
private class CaseControllerTest {
    
    @TestSetup
    static void setupData() {

        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];        
       
        Account acc = new Account(
            Name = 'Maria Silva',
            Email__c = 'maria@test.com',
            Telefone__c = '11999999999',
            CPF__c = '11122233344',
            SLA__c = 'Premium'
        );
        insert acc;

        
        Contact cAcc = new Contact(
            LastName = 'Silva',
            FirstName = 'Maria',
            Email = 'maria@test.com',
            AccountId = acc.Id
        );
        insert cAcc;
        
      
        Dependente__c dep = new Dependente__c(
            Name = 'João Silva',
            Email__c = 'joao@test.com',
            Telefone__c = '11888888888',
            CPF__c = '55566677700',
            Account__c = acc.Id
        );
        insert dep;

       
        Contact cDep = new Contact(
            LastName = dep.Name,     
            FirstName = 'João',
            Email = 'joao@test.com',
            AccountId = acc.Id
        );
        insert cDep;

       
        PlanoSaude__c plano = new PlanoSaude__c(
            Name = 'Plano Premium',
            Account__c = acc.Id,
            Cobertura__c = 'Completa',
            DataVencimento__c = Date.today().addDays(30)
        );
        insert plano;
    }

    
    @IsTest
    static void testCriarCaseComAccount() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Maria Silva' LIMIT 1];

        Test.startTest();
        
        Id caseId = CaseController.criarCase(
            acc.Id,
            'Assunto Teste',
            'Descrição Teste',
            'Autorização de Exame'
        );
        
        Test.stopTest();
        
        Case c = [
            SELECT Id, AccountId, Priority, TipoAtendimento__c
            FROM Case
            WHERE Id = :caseId
        ];
        
        System.assertEquals(acc.Id, c.AccountId);
        System.assertEquals('High', c.Priority); 
    }
    
    
    @IsTest
    static void testCriarCaseComDependente() {
        
        Dependente__c dep = [
            SELECT Id, Account__c 
            FROM Dependente__c 
            WHERE Name = 'João Silva' 
            LIMIT 1
        ];
        
        Test.startTest();
        
        Id caseId = CaseController.criarCase(
            dep.Id,
            'Assunto Dependente Unico',
            'Descricao Dependente',
            'Autorização de Exame'
        );

        Test.stopTest();
        
        Case c = [SELECT Id, AccountId FROM Case WHERE Id = :caseId];
        
        System.assertEquals(dep.Account__c, c.AccountId);
    }
}
