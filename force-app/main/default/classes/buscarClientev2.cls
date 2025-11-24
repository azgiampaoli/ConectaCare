public with sharing class BuscaClientev2 {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> buscarRegistros(String termo) {

        List<Map<String, Object>> resultados = new List<Map<String, Object>>();
        String busca = '%' + termo + '%';

        Boolean termoEhNumero = termo != null && Pattern.matches('^[0-9]+$', termo);

        /* ----------------------------------------
         *              BUSCA ACCOUNT
         * ---------------------------------------- */
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

        /* ----------------------------------------
         *          BUSCA DEPENDENTE__c
         * ---------------------------------------- */
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

        /* ----------------------------------------
         *                  BUSCA CASE
         * ----------------------------------------
         * - quando termo é número → buscar por CaseNumber
         * - quando não é número → buscar por Nome (Account.Name ou Contact.Name)
         * ---------------------------------------- */
        List<Case> casos;

        if (termoEhNumero) {
            // BUSCA POR NÚMERO DO CASO
            casos = [
                SELECT Id, CaseNumber, Subject, Status, AccountId, ContactId
                FROM Case
                WHERE CaseNumber LIKE :busca
                LIMIT 20
            ];
        } else {
            // BUSCA POR NOME DO TITULAR OU CONTATO
            casos = [
                SELECT Id, CaseNumber, Subject, Status,
                       Account.Name, AccountId,
                       Contact.Name, ContactId
                FROM Case
                WHERE (Account.Name LIKE :busca OR Contact.Name LIKE :busca)
                LIMIT 20
            ];
        }

        // Montagem dos resultados do Case
        for (Case c : casos) {

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
