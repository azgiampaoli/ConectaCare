@IsTest
private class AtualizarCaseControllerTest {
    
    
    @TestSetup
    static void setupData() {
        
        Account acc = new Account(
            Name = 'Conta Teste',
        SLA__c = 'Premium'
            
        );
        insert acc;
        
        
        Entitlement ent = new Entitlement(
            Name = 'Premium',
        AccountId = acc.Id
            );
        insert ent;
        
        Contact con = new Contact(
            FirstName = 'Contato',
        LastName = 'Teste',
        Email = 'email@teste.com',
        AccountId = acc.Id
            );
        insert con;
        
        Case c = new Case(
            AccountId = acc.Id,
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Phone',
        Assunto__c = 'Teste Assunto',
        TipoAtendimento__c = 'Autorização de Exame',
        Contato__c = 'Fulano de Tal',
        Descricao__c = 'Descrição Inicial',
        Telephone__c = '1111111111',
        Email__c = 'email@teste.com'
            );
        insert c;
    }
    
    
    @IsTest
    static void testAtualizarCase() {
        
        
        Case c = [SELECT Id, Status, Descricao__c, Telephone__c, Email__c
                  FROM Case LIMIT 1];
        
        
        String novoStatus = 'Working';
        String novaDescricao = 'Nova linha adicionada. ';
        String novoTelefone = '999999999';
        String novoEmail = 'novoemail@teste.com';
        
        Test.startTest();
        Case atualizado = AtualizarCaseController.atualizarCase(
            c.Id,
        novoStatus,
        novaDescricao,
        novoTelefone,
        novoEmail
            );
        Test.stopTest();
        
        
        Case cUpdated = [
            SELECT Status, Descricao__c, Telephone__c, Email__c
            FROM Case
            WHERE Id = :c.Id
        ];
        
        
        
        System.assertEquals(novoStatus, cUpdated.Status, 'Status deve ter sido atualizado');
        System.assertEquals(novoTelefone, cUpdated.Telephone__c, 'Telefone atualizado incorretamente');
        System.assertEquals(novoEmail, cUpdated.Email__c, 'Email atualizado incorretamente');
    }
    
    
    @IsTest
    static void testBuscarDetalhes() {
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Case resultado = AtualizarCaseController.buscarDetalhes(c.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultado, 'O método deve retornar um Case');
        System.assertEquals(c.Id, resultado.Id, 'ID retornado deve ser o mesmo do buscado');
        System.assertNotEquals(null, resultado.CaseNumber, 'CaseNumber deve ser trazido pela query');
        System.assertNotEquals(null, resultado.Status, 'Status deve estar presente');
    }
}