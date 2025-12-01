public with sharing class AtualizarCaseController {
    
    @AuraEnabled
    public static Case atualizarCase(String caseId, String novoStatus, String novaDescricao, String novoTelefone, String novoEmail) {
        Case c = [
            SELECT Id, Status, Descricao__c
            FROM Case
            WHERE Id = :caseId
        ];
        
        // Adiciona a nova descrição com timestamp no formato brasileiro
        String dataAgora = '[' + Datetime.now().format('dd/MM/yyyy HH:mm', 'America/Sao_Paulo') + '] ';
        String novaLinhaDescricao = dataAgora + novaDescricao;
        String descAnterior = String.isBlank(c.Descricao__c) ? '' : c.Descricao__c;
        
        c.Status = novoStatus;
         // Atualização da descrição (concatenação preservando histórico)
        if (String.isBlank(descAnterior)) {
            c.Descricao__c = novaLinhaDescricao;
        } else {
            c.Descricao__c = descAnterior + novaLinhaDescricao;
        }
        if(novoTelefone != null && novoTelefone != ''){
            c.Telephone__c = novoTelefone;
        }
        if(novoEmail != null && novoEmail != ''){
            c.Email__c = novoEmail;
        }
        
        
        update c;
        return c;
    }
    //Busco Detalhes pois apresento os dados antes de editar o Caso
    @AuraEnabled(cacheable=true)
    public static Case buscarDetalhes(String caseId) {
        return [
            SELECT Id, CaseNumber, Assunto__c, Status, Priority, Origin,
                   Account.Name, Contato__c, Descricao__c, Telephone__c, Email__c, TipoAtendimento__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }
}