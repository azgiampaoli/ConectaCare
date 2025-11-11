@IsTest
private class BuscaClienteControllerTest {

    @TestSetup
    static void setupData() {
        // Cria uma conta (Titular)
        Account acc = new Account(
            Name = 'João da Silva',
            CPF__c = '12345678900',
            Email__c = 'joao@email.com',
            Telefone__c = '11999999999'
        );
        insert acc;

        // Cria um dependente
        Dependente__c dep = new Dependente__c(
            Name = 'Maria da Silva',
            CPF__c = '09876543211',
            Email__c = 'maria@email.com',
            Telefone__c = '11988888888',
            Account__c = acc.Id
        );
        insert dep;
    }

    @IsTest
    static void testBuscarRegistrosPorNome() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('Silva');
        Test.stopTest();

        System.assertNotEquals(0, resultados.size(), 'Deve retornar registros');
        System.assert(resultados.size() >= 2, 'Deve retornar pelo menos 2 registros');

        // Verifica se trouxe Account e Dependente
        Boolean encontrouAccount = false;
        Boolean encontrouDependente = false;

        for (Map<String, Object> r : resultados) {
            if (String.valueOf(r.get('objectApiName')) == 'Account') {
                encontrouAccount = true;
                System.assertEquals('Titular', r.get('Tipo'));
            }
            if (String.valueOf(r.get('objectApiName')) == 'Dependente__c') {
                encontrouDependente = true;
                System.assertEquals('Dependente', r.get('Tipo'));
            }
        }

        System.assert(encontrouAccount, 'Deve encontrar pelo menos uma Account');
        System.assert(encontrouDependente, 'Deve encontrar pelo menos um Dependente');
    }

    @IsTest
    static void testBuscarRegistrosPorCPF() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('12345678900');
        Test.stopTest();

        System.assertEquals(1, resultados.size(), 'Deve retornar apenas um resultado para o CPF do titular');
        System.assertEquals('Titular', resultados[0].get('Tipo'));
        System.assertEquals('Account', resultados[0].get('objectApiName'));
    }

    @IsTest
    static void testBuscarRegistrosSemResultado() {
        Test.startTest();
        List<Map<String, Object>> resultados = BuscaClienteController.buscarRegistros('Inexistente');
        Test.stopTest();

        System.assertEquals(0, resultados.size(), 'Não deve retornar resultados para termo inexistente');
    }
}
