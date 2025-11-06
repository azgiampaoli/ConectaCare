public with sharing class BuscaClienteController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> buscarRegistros(String termo) {
        List<Map<String, Object>> resultados = new List<Map<String, Object>>();
        String busca = '%' + termo + '%';

        // Buscar em Account
        for (Account acc : [
            SELECT Id, Name, Email__c, Telefone__c, CPF__c
            FROM Account
            WHERE Name LIKE :busca OR CPF__c LIKE :busca
            LIMIT 20
        ]) {
            resultados.add(new Map<String, Object>{
                'Id' => acc.Id,
                'Nome' => acc.Name,
                'Email' => acc.Email__c,
                'CPF' => acc.CPF__c,
                'Tipo' => 'Titular',
                'Telefone' => acc.Telefone__c,
                'objectApiName' => 'Account'
            });
        }

        // Buscar em Dependente__c
        for (Dependente__c dep : [
            SELECT Id, Name, CPF__c, Email__c, Telefone__c
            FROM Dependente__c
            WHERE Name LIKE :busca OR CPF__c LIKE :busca
            LIMIT 20
        ]) {
            resultados.add(new Map<String, Object>{
                'Id' => dep.Id,
                'Nome' => dep.Name,
                'Email' => dep.Email__c,
                'Tipo' => 'Dependente',
                'CPF' => dep.CPF__c,
                'Telefone' => dep.Telefone__c,
                'objectApiName' => 'Dependente__c'
            });
        }

        return resultados;
    }
}