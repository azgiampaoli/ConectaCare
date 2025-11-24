public with sharing class SLAEmailService {
    
    // DeveloperNames dos templates
    private static final String TEMPLATE_PRIMEIRA_RESPOSTA = 'SLAPrimeiraResposta';
    private static final String TEMPLATE_EM_ATENDIMENTO    = 'SLAEmAtendimento';
    private static final String TEMPLATE_VIOLADO          = 'SLAViolado';
    private static final String TEMPLATE_FINALIZADO       = 'SLAFinalizado';
    
    
    public static void handleAfterInsert(List<Case> newCases) {
        
        for (Case c : newCases) {
            
            // evento PRIMEIRA RESPOSTA
            sendEmailUsingTemplate(c, TEMPLATE_PRIMEIRA_RESPOSTA);
        }
    }
    
    public static void handleAfterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        
        for (Case newC : newCases) {
            
            Case oldC = oldMap.get(newC.Id);
            
            if (newC.Status == 'Em Atendimento' || newC.Status == 'Working' && oldC.Status != 'Em Atendimento' && oldC.Status != 'Working') {
                sendEmailUsingTemplate(newC, TEMPLATE_EM_ATENDIMENTO);
                System.debug('passou pelo if do email Em Atendimento');
                System.debug('Status oldC: ' + oldC.Status);
                System.debug('Status newC: ' + newC.Status);
            }
            
            if ( (newC.Status == 'Finalizado' || newC.Status == 'Closed')
            && (oldC.Status != newC.Status) ) {
                
                sendEmailUsingTemplate(newC, TEMPLATE_FINALIZADO);
            }
            
            if (oldC.SLAViolation__c != 'Yes' && newC.SLAViolation__c == 'Yes') {
                sendEmailUsingTemplate(newC, TEMPLATE_VIOLADO);
            }
        }
    }
    
    
    private static void sendEmailUsingTemplate(Case c, String templateDevName) {
        
        if (Test.isRunningTest()) {
            return;
        }
        
        
        EmailTemplate template = [SELECT Id, name  FROM EmailTemplate where name = :templateDevName LIMIT 1];
        System.debug('Email template:' + template);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(template.Id);
        
        List<String> destinatarios = new List<String>();
        
        if (c.ContactId != null) {
            String contactEmail = [SELECT Email FROM Contact WHERE Id = :c.ContactId].Email;
            if (contactEmail != null) destinatarios.add(contactEmail);
        }
        
        if (c.AccountId != null && c.Email__c != null) {
            destinatarios.add(c.Email__c);
        }
        
        mail.setToAddresses(destinatarios);
        
        if (c.ContactId != null) {
            mail.setTargetObjectId(c.ContactId);
        }
        
        mail.setWhatId(c.Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}