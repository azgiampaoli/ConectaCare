public with sharing class ViaCepService {
    
    public class Endereco {
        public String cep;
        public String logradouro;
        public String bairro;
        public String cidade;
        public String estado;
        public String erro;
    }

    public static Endereco buscarEnderecoPorCep(String cep) {
        if (String.isBlank(cep)) {
            throw new IllegalArgumentException('CEP não pode estar vazio.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ViaCep/ws/' + cep + '/json/');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('Erro ao consultar ViaCEP: ' + res.getStatus());
        }

        Endereco endereco = (Endereco) JSON.deserialize(res.getBody(), Endereco.class);

        if (endereco.erro == 'true') {
            throw new CalloutException('CEP não encontrado.');
        }

        return endereco;
    }
}