@IsTest
private class ViaCepServiceTest {

    private class MockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"cep":"01001-000","logradouro":"Praça da Sé","bairro":"Sé","cidade":"São Paulo","estado":"SP"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testBuscarEnderecoPorCepSucesso() {
        Test.setMock(HttpCalloutMock.class, new MockResponse());
        Test.startTest();
        ViaCepService.Endereco e = ViaCepService.buscarEnderecoPorCep('01001000');
        Test.stopTest();

        System.assertEquals('Praça da Sé', e.logradouro);
        System.assertEquals('SP', e.estado);
    }
}