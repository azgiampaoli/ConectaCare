public with sharing class CadastroClienteController {
    // Método para buscar endereço pelo CEP usando o serviço ViaCepService, precisei setar aqui tbm para fazer o mapeamento correto
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
    // Método para salvar um novo Account (Cliente) e plano, vindo do mock, vinculado ao cliente
    @AuraEnabled
    public static void salvarAccount(String nome, String cpf, String email, String telefone, String logradouro, String numero, String cep, String bairro, String cidade, String estado, Date dataNascimento, String descricao, String tipoPlano,
        String valorMensalidade, String cobertura, String carencia) {
            if (String.isBlank(nome)) throw new AuraHandledException('O nome do cliente é obrigatório.');
            if (String.isBlank(tipoPlano)) throw new AuraHandledException('O plano precisa ser selecionado.');
        Account acc = new Account();
        acc.Name = nome;
        acc.CPF__c = cpf;
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

        PlanoSaude__c plano = new PlanoSaude__c();
        plano.Name = tipoPlano;
        plano.Valor__c = Decimal.valueOf(valorMensalidade);
        plano.Cobertura__c = cobertura;
        plano.Carencia__c =  Decimal.valueOf(carencia);
        plano.Account__c = acc.Id;
        insert plano;

        Contact c = new Contact();
        c.LastName = nome;       
        c.Email = email;
        c.Phone = telefone;
        c.AccountId = acc.Id;
        c.Description = 'Contato criado automaticamente para o titular.';
        insert c;
        acc.SLA__c = plano.Name;
        update acc;
    }
    // Método para salvar um novo Dependente__c relacionado a um Account e já setando o nome do plano baseado no titular
    @AuraEnabled
    public static void salvarDependente(String nome, String cpf, String email, String telefone, String logradouro, String numero, String bairro, String cep, String cidade, String estado,  Date dataNascimento, String descricao, Id accountId) {
        if (String.isBlank(nome)) throw new AuraHandledException('O nome do dependente é obrigatório.');
        if (accountId == null) throw new AuraHandledException('Selecione o titular.');

        PlanoSaude__c planoTitular = [SELECT Id, Name FROM PlanoSaude__c WHERE Account__c = :accountId LIMIT 1];  
             

        Dependente__c dep = new Dependente__c();
        dep.Name = nome; 
        dep.CPF__c = cpf;       
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
        dep.Plano_de_Saude__c = planoTitular.Name;     
        insert dep;   

        Contact c = new Contact();
        c.LastName = nome;        
        c.Email = email;
        c.Phone = telefone;
        c.AccountId = accountId;
        c.Description = 'Contato criado automaticamente para o dependente.';
        insert c;
        
    }
}