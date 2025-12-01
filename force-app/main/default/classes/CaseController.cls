public with sharing class CaseController {
    
     
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
        Id ContactsId = null;
        
        try {
             // Identifica o tipo de SObject analisando o prefixo do ID
            String prefix = accountId.getSObjectType().getDescribe().getKeyPrefix();
            if (prefix == Account.SObjectType.getDescribe().getKeyPrefix()){
                
                acc = [SELECT Id, Name, Email__c, Telefone__c, SLA__c FROM Account WHERE Id = :accountId LIMIT 1];
                List<Contact> contacts = [SELECT id,LastName, Name, email FROM Contact WHERE AccountId = :acc.Id  LIMIT 1];
                Contact cc = contacts[0];

               

                ContactsId = cc.id;
                sla = acc.SLA__c;
                accountIdStr = acc.id;
                emailContato = cc.email;
                telefoneContato = acc.Telefone__c;
                contatoNome = cc.Name;

            }else if (prefix == Dependente__c.SObjectType.getDescribe().getKeyPrefix()) {
                
                dep = [SELECT Id, Name, Email__c, Telefone__c,Account__c, Account__r.Id, Account__r.Name, Account__r.Email__c, Account__r.Telefone__c, Account__r.SLA__c FROM Dependente__c WHERE Id = :accountId LIMIT 1];
                List<Contact> contacts = [SELECT id,LastName, Name, email FROM Contact WHERE AccountId = : dep.Account__c and LastName =: dep.Name  LIMIT 1];
                Contact cc = contacts[0];
                
                ContactsId = cc.id;
                accountIdStr = dep.Account__r.Id;
                sla = dep.Account__r.SLA__c;
                emailContato = cc.Email;
                telefoneContato = dep.Telefone__c;
                contatoNome = cc.Name;
            }else {
                throw new AuraHandledException('Nenhuma conta vinculada foi encontrada.');
            }
            
            // Buscar Business Hours
          
            BusinessHours bhs = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
            bh = bhs.id;
            // Definir prioridade com base no SLA
            String prioridade = 'Low';
            if (sla == 'Premium') prioridade = 'High';
            else if (sla == 'Gold') prioridade = 'Medium';
          
            
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
            novoCase.ContactId = ContactsId;
            
            
            insert novoCase;
            return novoCase.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao criar o caso: ' + e.getMessage());
        }
    }
}