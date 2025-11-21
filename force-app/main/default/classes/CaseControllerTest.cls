@IsTest
private class CaseControllerTest {
    
    @TestSetup
    static void setupData() {
        
        // Setar  Business Hours usado pelo método criarCase
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        System.debug('businesshours :' + bh.Id);
        
        // Criar Account (Titular)
        Account acc = new Account(
        Name = 'Maria Silva',
        Email__c = 'maria@test.com',
        Telefone__c = '11999999999',
        CPF__c = '11122233344',
        SLA__c = 'Premium'
            );
        insert acc;
        
        // Criar Dependente
        Dependente__c dep = new Dependente__c(
        Name = 'João Silva',
        Email__c = 'joao@test.com',
        Telefone__c = '11888888888',
        CPF__c = '55566677700',
        Account__c = acc.Id
            );
        insert dep;
        
        // Criar Plano vinculado à account
        PlanoSaude__c plano = new PlanoSaude__c(
        Name = 'Plano Premium',
        Account__c = acc.Id,
        Cobertura__c = 'Completa',
        DataVencimento__c = Date.today().addDays(30)
        );
        insert plano;       
         PlanoSaude__c ps = [SELECT Id, Name FROM PlanoSaude__c where Account__c = :acc.Id LIMIT 1];
        System.debug('Plano de Saúde vinculado à Account: ' + ps);
        
    }
    
   
    
    @IsTest
    static void testBuscarRegistros() {
        
        Test.startTest();
        
        List<Map<String, Object>> resultados = CaseController.buscarRegistros('Silva');
        
        Test.stopTest();
        
        System.assert(!resultados.isEmpty(), 'A busca deveria retornar registros');
        
        Boolean encontrouAccount = false;
        Boolean encontrouDependente = false;
        Boolean encontrouPlano = false;
        
        for (Map<String, Object> row : resultados) {
            if ((String)row.get('Tipo') == 'Titular') encontrouAccount = true;
            if ((String)row.get('Tipo') == 'Dependente') encontrouDependente = true;
            if (row.get('NomePlano') != null) encontrouPlano = true;
        }
        
        System.assert(encontrouAccount, 'Deveria ter retornado a Account');
        System.assert(encontrouDependente, 'Deveria ter retornado o Dependente');
        System.assert(encontrouPlano, 'O Plano de saúde deveria ser preenchido');
    }
    
    
    @IsTest
    static void testCriarCaseComAccount() {
        
        Account acc = [SELECT Id, name FROM Account where Name = 'Maria Silva'];
        System.debug('Account: testCriarCaseComAccount ' + acc);
        
        Test.startTest();
        
        CaseController.criarCase(
        acc.Id,
        'Assunto Teste',
        'Descrição Teste',
        'Autorização de Exame'
        );       
        
        
        Test.stopTest();
        
        Case c = [SELECT Id, AccountId, Assunto__c, Priority, TipoAtendimento__c FROM Case where tipoAtendimento__c = 'Autorização de Exame'];
              
        System.assertEquals(acc.Id, c.AccountId);               
        System.assertEquals('High', c.Priority);
    }
    
    
    @IsTest
    static void testCriarCaseComDependente() {
        
        Dependente__c dep = [SELECT Id, Account__c FROM Dependente__c where Name = 'João Silva' LIMIT 1];
        
        Test.startTest();
        
        CaseController.criarCase(
        dep.Id,
        'Assunto Dependente Unico',
        'Descricao Dependente',
        'Autorização de Exame'
        );

        Test.stopTest();
        
        // Case deve ter sido criado relacionado à account do dependente
        Case c = [SELECT Id, AccountId FROM Case WHERE Assunto__c = 'Assunto Dependente Unico' LIMIT 1];
        
        System.assertEquals(dep.Account__c, c.AccountId);
    }    

    @IsTest
    static void testBuscarRegistrosParametroVazio() {
        Test.startTest();
        List<Map<String, Object>> resultadosVazio = CaseController.buscarRegistros('');
        List<Map<String, Object>> resultadosNulo = CaseController.buscarRegistros(null);
        Test.stopTest();

        System.assertEquals(0, resultadosVazio.size());
        System.assertEquals(0, resultadosNulo.size());
    }
  
}