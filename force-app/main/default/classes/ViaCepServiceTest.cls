@IsTest
private class ViaCepServiceTest {

    private class MockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // JSON real do ViaCEP
            res.setBody('{' +
                '"cep": "01001-000",' +
                '"logradouro": "Praça da Sé",' +
                '"bairro": "Sé",' +
                '"localidade": "São Paulo",' +
                '"uf": "SP"' +
            '}');

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

        System.assertEquals('01001-000', e.cep);
        System.assertEquals('Praça da Sé', e.logradouro);
        System.assertEquals('Sé', e.bairro);
        System.assertEquals('São Paulo', e.cidade);   // localidade
        System.assertEquals('SP', e.estado);          // uf
    }
}
