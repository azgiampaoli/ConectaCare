public with sharing class SLAEmailService {
    
    private static final String TEMPLATE_PRIMEIRA_RESPOSTA = 'SLAPrimeiraResposta';
    private static final String TEMPLATE_EM_ATENDIMENTO    = 'SLAEmAtendimento';
    private static final String TEMPLATE_VIOLADO          = 'SLAViolado';
    private static final String TEMPLATE_FINALIZADO       = 'SLAFinalizado';
    
    public static void handleAfterInsert(List<Case> newCases) {
        for (Case c : newCases) {
            sendEmailUsingTemplate(c, TEMPLATE_PRIMEIRA_RESPOSTA);
        }
    }
    
    public static void handleAfterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        
        for (Case newC : newCases) {
            Case oldC = oldMap.get(newC.Id);
        // Em Atendimento
            if ((newC.Status == 'Em Andamento' || newC.Status == 'Working') && (oldC.Status != newC.Status) ) {
                sendEmailUsingTemplate(newC, TEMPLATE_EM_ATENDIMENTO);
                System.debug('EMAIL: Em Atendimento enviado.');
            }
            
            // Finalizado
            if ((newC.Status == 'Finalizado' || newC.Status == 'Closed') && (oldC.Status != newC.Status)) {
                sendEmailUsingTemplate(newC, TEMPLATE_FINALIZADO);
                System.debug('EMAIL: Finalizado enviado.');
            }
            
           // Violado
            if (oldC.SLAViolation__c != 'Yes' && newC.SLAViolation__c == 'Yes'){
                sendEmailUsingTemplate(newC, TEMPLATE_VIOLADO);
                System.debug('EMAIL: SLA Violado enviado.');
            }
        }
    }
   private static void sendEmailUsingTemplate(Case c, String templateDevName) {

    EmailTemplate template = [
        SELECT Id, Name 
        FROM EmailTemplate 
        WHERE Name = :templateDevName 
        LIMIT 1
    ];

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateId(template.Id);

    List<String> destinatarios = new List<String>();

    if (c.ContactId != null) {
        String contactEmail = [
            SELECT Email FROM Contact WHERE Id = :c.ContactId
        ].Email;
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

    
    if (Test.isRunningTest()) {
        System.debug('Simulando envio em teste. Nenhum email enviado.');
        return;
    }

    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}
