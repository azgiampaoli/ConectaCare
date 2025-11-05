public with sharing class ViaCepService {
    // criação do construtor da classe Endereco
    public class Endereco {
        public String cep;
        public String logradouro;
        public String bairro;
        public String cidade;
        public String estado;
        public String erro;
    }
    //Tratamento casocampo esteja vazio
    public static Endereco buscarEnderecoPorCep(String cep) {
        if (String.isBlank(cep)) {
            throw new IllegalArgumentException('CEP não pode estar vazio.');
        }
        // chamada HTTP para o serviço ViaCEP
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ViaCep/ws/' + cep + '/json/');
        req.setMethod('GET');
        // envio da requisição HTTP
        Http http = new Http();
        HttpResponse res = http.send(req);
        // tratamento da resposta caso não seja 200 = ok
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Erro ao consultar ViaCEP: ' + res.getStatus());
        }
        // desserialização da resposta JSON
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        // tratamento caso o CEP não seja encontrado
        if (jsonMap.containsKey('erro') && (String)jsonMap.get('erro') == 'true') {
            throw new CalloutException('CEP não encontrado.');
        }
        // mapeamento dos dados para o objeto Endereco de acordo com os campos que tenho no objeto
        Endereco endereco = new Endereco();
        endereco.cep = (String)jsonMap.get('cep');
        endereco.logradouro = (String)jsonMap.get('logradouro');
        endereco.bairro = (String)jsonMap.get('bairro');
        endereco.cidade = (String)jsonMap.get('localidade');
        endereco.estado = (String)jsonMap.get('uf'); 
        //verificação final caso o campo erro seja true
        if (endereco.erro == 'true') {
            throw new CalloutException('CEP não encontrado.');
        }
        // retorno do endereço preenchido
        return endereco;
    }
}