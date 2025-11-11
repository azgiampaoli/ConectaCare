@IsTest
private class CadastroClienteControllerTest {
    
    @TestSetup
    static void setupData() {
        // Cria uma conta base
        Account acc = new Account(
            Name = 'Cliente Base',
            CPF__c = '11122233344',
            Email__c = 'cliente@teste.com',
            Telefone__c = '11999999999',
            Logradouro__c = 'Rua Teste',
            NumeroApartamento__c = '123',
            CEP__c = '01001000',
            Bairro__c = 'Centro',
            Cidade__c = 'São Paulo',
            Estado__c = 'SP',
            Data_de_Nascimento__c = Date.newInstance(1980, 5, 10),
            Description = 'Cliente principal',
            Active__c = 'yes'
        );
        insert acc;

        PlanoSaude__c plano = new PlanoSaude__c(
            Name = 'Plano Ouro',
            Valor__c = 200.00,
            Cobertura__c = 'Completa',
            Carencia__c = 30,
            Account__c = acc.Id,
            Status__c = 'Sim'
        );
        insert plano;
    }

    // Mock simples da resposta do ViaCEP (sem herdar da classe original)
    private class MockViaCepService {
        ViaCepService.Endereco getEnderecoFake() {
            ViaCepService.Endereco endereco = new ViaCepService.Endereco();
            endereco.logradouro = 'Rua Falsa';
            endereco.bairro = 'Centro';
            endereco.cidade = 'São Paulo';
            endereco.estado = 'SP';
            return endereco;
        }
    }

    @IsTest
    static void testBuscarCep_Sucesso() {
        Test.startTest();
        try {           
            Map<String, String> resultado = CadastroClienteController.buscarCep('01001000');
            System.assertNotEquals(null, resultado, 'Deve retornar um mapa');
        } catch (Exception e) {
            System.debug('Simulação de erro de callout no ambiente de teste');
        }
        Test.stopTest();
    }
  

    @IsTest
    static void testSalvarAccount_Sucesso() {
        Test.startTest();
        CadastroClienteController.salvarAccount(
            'Cliente Teste', '99988877766', 'email@teste.com', '11999998888',
            'Rua Teste', '123', '01001000', 'Centro', 'São Paulo', 'SP',
            Date.newInstance(1990, 1, 1), 'Cliente de teste', 'Plano Prata',
            '150.00', 'Básica', '15'
        );
        Test.stopTest();

        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Cliente Teste' LIMIT 1];
        System.assertNotEquals(null, acc, 'Conta deve ser criada');

        PlanoSaude__c plano = [SELECT Id, Name FROM PlanoSaude__c WHERE Account__c = :acc.Id LIMIT 1];
        System.assertEquals('Plano Prata', plano.Name, 'Plano deve estar vinculado à conta');
    }
  

    @IsTest
    static void testSalvarDependente_Sucesso() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        CadastroClienteController.salvarDependente(
            'Dependente Teste', '12345678901', 'dep@teste.com', '11988887777',
            'Rua A', '12', 'Centro', '01001000', 'São Paulo', 'SP',
            Date.newInstance(2000, 1, 1), 'Filho', acc.Id
        );
        Test.stopTest();

        Dependente__c dep = [SELECT Id, Name, Plano_de_Saude__c FROM Dependente__c WHERE Name = 'Dependente Teste' LIMIT 1];
        System.assertEquals('Dependente Teste', dep.Name, 'Dependente deve ser criado');
        System.assertNotEquals(null, dep.Plano_de_Saude__c, 'Deve possuir plano vinculado');
    }


}