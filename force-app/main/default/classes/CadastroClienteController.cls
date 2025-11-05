public with sharing class CadastroClienteController {
    // Método para buscar endereço pelo CEP usando o serviço ViaCepService
     @AuraEnabled(cacheable=true)
    public static Map<String, String> buscarCep(String cep) {
        try {
            ViaCepService.Endereco endereco = ViaCepService.buscarEnderecoPorCep(cep);

            Map<String, String> resultado = new Map<String, String>();
            resultado.put('logradouro', endereco.logradouro);
            resultado.put('bairro', endereco.bairro);
            resultado.put('cidade', endereco.cidade);
            resultado.put('estado', endereco.estado);

            return resultado;

        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar CEP: ' + e.getMessage());
        }
    }
    // Método para salvar um novo Account (Cliente)
    @AuraEnabled
    public static void salvarAccount(String nome, String email, String telefone, String logradouro, String numero, String cep, String bairro, String cidade, String estado, Date dataNascimento, String descricao) {
        Account acc = new Account();
        acc.Name = nome;
        acc.Email__c = email;
        acc.Telefone__c = telefone;
        acc.Logradouro__c = logradouro; 
        acc.NumeroApartamento__c = numero;
        acc.CEP__c = cep;  
        acc.Bairro__c = bairro; 
        acc.Cidade__c = cidade;
        acc.Estado__c = estado; 
        acc.Data_de_Nascimento__c = dataNascimento;
        acc.Description = descricao;  
        acc.Active__c = 'yes';
        insert acc;
        System.debug('Telefone :' + telefone);
    }
    // Método para salvar um novo Dependente__c relacionado a um Account
    @AuraEnabled
    public static void salvarDependente(String nome, String email, String telefone, String logradouro, String numero, String bairro, String cep, String cidade, String estado,  Date dataNascimento, String descricao, Id accountId) {
        Dependente__c dep = new Dependente__c();
        dep.Name = nome;        
        dep.Email__c = email;
        dep.Telefone__c = telefone;
        dep.Logradouro__c = logradouro;
        dep.NumeroApartamento__c = numero;
        dep.CEP__c = cep;
        dep.Bairro__c = bairro;
        dep.Cidade__c = cidade;
        dep.Estado__c = estado;
        dep.DataNascimento__c = dataNascimento;
        dep.Account__c = accountId;
        dep.Descricao__c = descricao;
        dep.Ativo__c = true;
        insert dep;
        System.debug('Telefone :' + telefone);
    }

 

}