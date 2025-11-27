@IsTest
private class BuscaClienteControllerTest {
    
    @TestSetup
    static void setupData() {
        
        // ACCOUNT (Titular)
        Account acc = new Account(
        Name = 'João Silva',
        CPF__c = '12345678900',
        Email__c = 'joao@email.com',
        Telefone__c = '11999999999'
            );
        insert acc;
        
        // DEPENDENTE
        Dependente__c dep = new Dependente__c(
        Name = 'Maria Silva',
        CPF__c = '12387654311',
        Email__c = 'maria@email.com',
        Telefone__c = '11988888888',
        Account__c = acc.Id
            );
        insert dep;
        
        // PLANO SAÚDE PARA O DEPENDENTE
        PlanoSaude__c plano = new PlanoSaude__c(
            Name = 'Premium',
        Account__c = acc.Id,
        Cobertura__c = 'Total',
        DataVencimento__c = Date.today().addMonths(1)
            );
        insert plano;
        
        // CRIA ENTITLEMENT
        Entitlement ent = new Entitlement(
            Name = 'Premium',
        AccountId = acc.Id
            );
        insert ent;
        
        
        Case c = new Case(
        Assunto__c = 'Teste Assunto',
        Status = 'Novo',
        Descricao__c = 'Desc teste',
        TipoAtendimento__c = 'Autorização de Exame',
        Email__c = 'c@test.com',
        Telephone__c = '1122334455',
        Contato__c = acc.Name,
        EntitlementId = ent.Id
            );
        insert c;
      
    }
    
    @IsTest
    static void testBuscarRegistrosPorNome() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('Silva');
        Test.stopTest();
        
        System.assert(resultados.size() >= 2, 'Deve retornar pelo menos Account e Dependente');
        
        Boolean encontrouAccount = false;
        Boolean encontrouDependente = false;
        
        for (Map<String, Object> r : resultados) {
            if (r.get('objectApiName') == 'Account') encontrouAccount = true;
            if (r.get('objectApiName') == 'Dependente__c') encontrouDependente = true;
        }
        
        System.assert(encontrouAccount, 'Account deve ser retornada');
        System.assert(encontrouDependente, 'Dependente deve ser retornado');
    }
    
    @IsTest
    static void testBuscarRegistrosPorCPF() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('12345678900');
        Test.stopTest();
        
        System.assertEquals(1, resultados.size(), 'Apenas o titular deve ser retornado');
        System.assertEquals('Account', resultados[0].get('objectApiName'));
    }
    
    @IsTest
    static void testBuscarCases() {
        Test.startTest();        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'João Silva' LIMIT 1];
        Case c = [SELECT Id, CaseNumber, Contato__c FROM Case WHERE Contato__c =: acc.Name LIMIT 1];
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros(c.CaseNumber);
        Test.stopTest();
        
        Boolean encontrouCase = false;
        
        for (Map<String, Object> r : resultados) {
            if (r.get('objectApiName') == 'Case') {
                encontrouCase = true;
                
                System.assertEquals(null, r.get('CaseMilestones'));
            }
        }
        
        System.assertEquals(true, encontrouCase);
    }
    
    
    @IsTest
    static void testBuscarRegistrosSemResultado() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('NadaAqui');
        Test.stopTest();
        
        System.assertEquals(0, resultados.size());
    }
}