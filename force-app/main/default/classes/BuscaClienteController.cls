public with sharing class BuscaClienteController {    
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> buscarRegistros(String termo) {
        
        List<Map<String, Object>> resultados = new List<Map<String, Object>>();
        String busca = '%' + termo + '%';
        
        
        //BUSCA ACCOUNT
        
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
        
        //BUSCA DEPENDENTE__c
        
        for (Dependente__c dep : [
            SELECT Id, Name, CPF__c, Email__c, Telefone__c, Account__c
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
                'AccountId' => dep.Account__c,
                'objectApiName' => 'Dependente__c'
            });
        }
        Set<Id> accountIds = new Set<Id>();
        for (Map<String, Object> row : resultados) {
            if (row.containsKey('AccountId') && row.get('AccountId') != null) {
                accountIds.add((Id) row.get('AccountId'));
            }
        }
        
        if (!accountIds.isEmpty()) {
            Map<Id, PlanoSaude__c> planosPorAccount = new Map<Id, PlanoSaude__c>();
            
            for (PlanoSaude__c plano : [
        SELECT Id, Name, Account__c, Cobertura__c, DataVencimento__c, StatusPlano__c
        FROM PlanoSaude__c 
        WHERE Account__c IN :accountIds
    ]) {
                planosPorAccount.put(plano.Account__c, plano);
            }
            
            for (Map<String, Object> row : resultados) {
                Id accId = (Id) row.get('AccountId');
                
                if (accId != null && planosPorAccount.containsKey(accId)) {
                    PlanoSaude__c p = planosPorAccount.get(accId);
                    row.put('NomePlano', p.Name);
                    row.put('Cobertura', p.Cobertura__c);
                    row.put('DataVencimento', p.DataVencimento__c);
                    row.put('StatusPlano', p.StatusPlano__c);
                }
            }
        }
        
        
        
        
        // BUSCA CASE
        
        for (Case c : [
            SELECT Id, CaseNumber, Subject, Status,
                   Account.Name, AccountId,
                   Contact.Name, ContactId
            FROM Case
            WHERE CaseNumber LIKE :busca
               OR Account.Name LIKE :busca
               OR Contact.Name LIKE :busca
            LIMIT 20
        ]) {
            
            String nomeRelacionado = c.AccountId != null ? c.Account.Name :
                c.ContactId != null ? c.Contact.Name :
                'Sem Nome Relacionado';
            
            resultados.add(new Map<String, Object>{
                'Id' => c.Id,
                'NumeroCaso' => c.CaseNumber,
                'Nome' => nomeRelacionado,
                'Status' => c.Status,
                'Assunto' => c.Subject,
                'Tipo' => 'Case',
                'AccountId' => c.AccountId,
                'ContactId' => c.ContactId,
                'objectApiName' => 'Case'
            });
        }
        
        return resultados;
    }
}