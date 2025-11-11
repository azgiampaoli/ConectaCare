//chamada do mock dos planos de saude no postman
public with sharing class PlanosSaudeService {
    public class Plano {
        @AuraEnabled public String tipoPlano;
        @AuraEnabled public Decimal valorMensalidade;
        @AuraEnabled public String cobertura;
        @AuraEnabled public String carencia;
    }

    @AuraEnabled(cacheable=true)
    public static List<Plano> buscarPlanos() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PlanoSaude/planos');
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return (List<Plano>) JSON.deserialize(response.getBody(), List<Plano>.class);
        } else {
            throw new AuraHandledException('Erro ao buscar planos: ' + response.getStatus());
        }
    }
  
}