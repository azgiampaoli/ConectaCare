@IsTest
private class PlanosSaudeServiceTest {

    // Mock para simular retorno do endpoint Postman (caso de sucesso)
    private class MockPlanoSaudeCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simula resposta JSON vinda do Postman
            String mockBody = '[{"tipoPlano": "Plano Ouro", "valorMensalidade": 200.50, "cobertura": "Completa", "carencia": "30"},' +
                              '{"tipoPlano": "Plano Prata", "valorMensalidade": 150.00, "cobertura": "Básica", "carencia": "15"}]';
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockBody);
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock para simular erro (ex: status 500)
    private class MockPlanoSaudeErroCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"erro":"falha"}');
            res.setStatusCode(500);
            return res;
        }
    }

    
    @TestSetup
    static void setupData() {
        // Nenhum dado é necessário para esse teste, mas o método existe para manter o padrão de projeto
        System.debug('Setup inicial executado.');
    }

    
    @IsTest
    static void testBuscarPlanos_Sucesso() {
        Test.setMock(HttpCalloutMock.class, new MockPlanoSaudeCallout());
        Test.startTest();
        List<PlanosSaudeService.Plano> planos = PlanosSaudeService.buscarPlanos();
        Test.stopTest();

        System.assertNotEquals(null, planos, 'Lista não deve ser nula');
        System.assertEquals(2, planos.size(), 'Deve retornar 2 planos');
        System.assertEquals('Plano Ouro', planos[0].tipoPlano, 'Primeiro plano deve ser Ouro');
        System.assertEquals(200.50, planos[0].valorMensalidade, 'Valor deve ser 200.50');
    }

    
    @IsTest
    static void testBuscarPlanos_Erro() {
        Test.setMock(HttpCalloutMock.class, new MockPlanoSaudeErroCallout());
        Test.startTest();
        try {
            PlanosSaudeService.buscarPlanos();
            System.assert(false, 'Deveria lançar exceção');
        } catch (AuraHandledException e) {
            System.debug('Mensagem da exceção: ' + e.getMessage());
            System.assertNotEquals(null, e.getMessage(), 'Mensagem da exceção não deve ser nula');
        Test.stopTest();
    }
}
}
