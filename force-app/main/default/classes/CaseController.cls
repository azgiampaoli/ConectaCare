public with sharing class CaseController {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> buscarRegistros(String termo) {
        String AccountId;
        
        if (String.isBlank(termo)) return new List<Map<String, Object>>();
        
        List<Map<String, Object>> resultados = new List<Map<String, Object>>();
        String busca = '%' + termo + '%';
        
        // Buscar em Account
        for (Account acc : [
            SELECT Id, Name, Email__c, Telefone__c, CPF__c
            FROM Account
            WHERE Name LIKE :busca OR CPF__c LIKE :busca OR Email__c LIKE :busca
            LIMIT 20
        ]) {
            resultados.add(new Map<String, Object>{
                'Id' => acc.Id,
                'AccountId' => acc.Id,
                'Nome' => acc.Name,
                'Email' => acc.Email__c,
                'CPF' => acc.CPF__c,
                'Telefone' => acc.Telefone__c,
                'Tipo' => 'Titular'
            });
        }
        
        // Buscar em Dependente__c
        for (Dependente__c dep : [
            SELECT Id, Name, CPF__c, Email__c, Telefone__c, Account__c
            FROM Dependente__c
            WHERE Name LIKE :busca OR CPF__c LIKE :busca OR Email__c LIKE :busca
            LIMIT 20
        ]) {
            resultados.add(new Map<String, Object>{
                'Id' => dep.Id,
                'Nome' => dep.Name,
                'Email' => dep.Email__c,
                'CPF' => dep.CPF__c,
                'Telefone' => dep.Telefone__c,
                'AccountId' => dep.Account__c,
                'Tipo' => 'Dependente'
            });
        }
        
        Set<Id> accountIds = new Set<Id>();
        for (Map<String, Object> row : resultados) {
            if (row.containsKey('AccountId') && row.get('AccountId') != null) {
                accountIds.add((Id) row.get('AccountId'));
                System.debug('ID >>' + row.get('AccountId'));
            }
        }
        
        if (!accountIds.isEmpty()) {
            
            Map<Id, PlanoSaude__c> planosPorAccount = new Map<Id, PlanoSaude__c>();
            for (PlanoSaude__c plano : [
            SELECT Id, Name, Account__c, Cobertura__c, DataVencimento__c, StatusPlano__c FROM PlanoSaude__c WHERE Account__c IN :accountIds]) {
                planosPorAccount.put(plano.Account__c, plano);
                System.debug('PLANO >>' + plano);
            }
            
            
            for (Map<String, Object> row : resultados) {
                Id accId = (Id) row.get('AccountId');
                if (accId != null && planosPorAccount.containsKey(accId)) {
                    PlanoSaude__c p = planosPorAccount.get(accId);
                    row.put('NomePlano', p.Name);
                    row.put('Cobertura', p.Cobertura__c);
                    row.put('DataVencimento', p.DataVencimento__c);
                    row.put('StatusPlano', p.StatusPlano__c);
                } else {
                    
                    row.put('NomePlano', null);
                    row.put('Cobertura', null);
                    row.put('DataVencimento', null);
                    row.put('StatusPlano', null);
                }
            }
        }
        
        return resultados;
        
    }
    
    @AuraEnabled
    public static Id criarCase(Id accountId, String assunto, String descricao, String tipoAtendimento) {
        if (accountId == null) {
            throw new AuraHandledException('ID da Conta/Dependente não informado.');
        }
            Account acc = null;
            Dependente__c dep  = null;
            String sla = null;
            Id accountIdStr = null;
            String emailContato = null;
            String telefoneContato = null;
            String contatoNome = null;
            Id bh = null;
        
        try {
                      
            String prefix = accountId.getSObjectType().getDescribe().getKeyPrefix();
            if (prefix == Account.SObjectType.getDescribe().getKeyPrefix()){
                System.debug('Entrei no if da Account');
                acc = [SELECT Id, Name, Email__c, Telefone__c, SLA__c FROM Account WHERE Id = :accountId LIMIT 1];
                sla = acc.SLA__c;
                accountIdStr = acc.id;
                emailContato = acc.email__c;
                telefoneContato = acc.Telefone__c;
                contatoNome = acc.Name;
                System.debug('acc>>' + acc);
            }else if (prefix == Dependente__c.SObjectType.getDescribe().getKeyPrefix()) {
                System.debug('Entrei no if do Dependente');
                dep = [SELECT Id, Name, Email__c, Telefone__c,Account__c, Account__r.Id, Account__r.Name, Account__r.Email__c, Account__r.Telefone__c, Account__r.SLA__c FROM Dependente__c WHERE Id = :accountId LIMIT 1];
                accountIdStr = dep.Account__r.Id;
                sla = dep.Account__r.SLA__c;
                emailContato = dep.email__c;
                telefoneContato = dep.Telefone__c;
                contatoNome = dep.Name;
            }else {
                System.debug('Entrei no exception dos ifs');
                throw new AuraHandledException('Nenhuma conta vinculada foi encontrada.');
            }
            
            // Buscar Business Hours
           
            System.debug('Antes do Business Hours ID: ');
            BusinessHours bhs = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
            bh = bhs.id;
            System.debug('Business Hours ID: ' + bh);
            System.debug('ID>>' + accountIdStr);
            System.debug('SLA>>' + sla);
            // Definir prioridade conforme o plano
            System.debug('Antes do priority');
            String prioridade = 'Low';
            if (sla == 'Premium') prioridade = 'High';
            else if (sla == 'Gold') prioridade = 'Medium';
            System.debug('priority: ' + prioridade);
                       
            System.debug('Contato Nome: ' + contatoNome + ' Email: ' + emailContato + ' Telefone: ' + telefoneContato);
            System.debug('Account: ' + accountIdStr + ' Assunto: ' + assunto + ' Descricao: ' + descricao + ' TipoAtendimento: ' + tipoAtendimento);
            System.debug('Prioridade: ' + prioridade + ' BusinessHoursId: ' + bh);
            
            // Criar o caso
            Case novoCase = new Case();
            novoCase.AccountId = accountIdStr;
            novoCase.Assunto__c = assunto;
            novoCase.Descricao__c = descricao;
            novoCase.Origin = 'Web';
            novoCase.TipoAtendimento__c = tipoAtendimento;
            novoCase.Email__c = emailContato;
            novoCase.Telefone__c = telefoneContato;
            novoCase.BusinessHoursId = bh;
            novoCase.Priority = prioridade;
            novoCase.Contato__c = contatoNome;
                  
            
            insert novoCase;
            return novoCase.Id;
            System.debug('Case criado com ID: ' + novoCase.Id);
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao criar o caso: ' + e.getMessage());
        }
    }    
}