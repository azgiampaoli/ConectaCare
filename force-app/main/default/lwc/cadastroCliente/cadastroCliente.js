import { LightningElement, track } from 'lwc';
import buscarCep from '@salesforce/apex/CadastroClienteController.buscarCep';
import salvarAccount from '@salesforce/apex/CadastroClienteController.salvarAccount';
import salvarDependente from '@salesforce/apex/CadastroClienteController.salvarDependente';
import buscarPlanos from '@salesforce/apex/PlanosSaudeService.buscarPlanos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CadastroCliente extends LightningElement {
    @track tipoSelecionado = false;
    @track isCliente = false;
    @track isDependente = false;
    @track isAbrirTelaPlano = false;

    @track nome;
    @track email;
    @track telefone;
    @track cep;
    @track cpf;
    @track logradouro;
    @track numero;
    @track bairro;
    @track cidade;
    @track estado;
    @track dataNascimento;
    @track descricao;
    @track accountId;
    @track tipoPlano;
    @track valorMensalidade;
    @track cobertura;
    @track carencia;

    @track accounts = [];
    @track accountSearchKey = '';
    @track accountId = null;
    @track accountName = '';

    @track planoOptions = [];
    @track planos = [];
    @track planoSelecionado;
    @track selectedPlano;

     connectedCallback() {
        this.carregarPlanos();
    }

    handleCliente() {
        this.tipoSelecionado = true;
        this.isCliente = true;
    }

    handleDependente() {
        this.tipoSelecionado = true;
        this.isDependente = true;
    }

    handleAbrirTelaPlano() {
        this.isAbrirTelaPlano = true;
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }
    //não estou utilizando uma classe pq o <lightning-input-field> cria automaticamente um lookup padrão do Salesforce
    handleLookupChange(event) {
    const value = event.detail.value;
    this.accountId = Array.isArray(value) ? value[0] : value;
    }

    handleDescricaoChange(event) {
        this.descricao = event.target.value;
    }

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
    }

    handleCpfChange(event) {
    // remove tudo que não é número
    let valor = event.target.value.replace(/\D/g, '');
    this.cpf = valor;
    }
  
    handleTelefoneChange(event) {
        // remove tudo que não é número
        let valor = event.target.value.replace(/\D/g, ''); 
        //limita para 11 digitos (DDD + 9 digitos)
        if (valor.length > 11) valor = valor.substring(0, 11);
        //aplicando a formatação
        if (valor.length > 6) {
            //pega os dois primeiros digitos coloca entre parênteses, depois os próximos 5 digitos, um hífen e o resto
            valor = valor.replace(/^(\d{2})(\d{5})(\d{0,4}).*/, '($1) $2-$3');
        } else if (valor.length > 2) {
            //quando tem mais de 2 digitos, coloca os dois primeiros entre parênteses e os proximos digitos ainda sem o hífen
            valor = valor.replace(/^(\d{2})(\d{0,5})/, '($1) $2');
        } else if (valor.length > 0) {
            //quando tiver até 2 digitos, só coloca entre parênteses
            valor = valor.replace(/^(\d*)/, '($1');
        }

        this.telefone = valor;
        
    }
    //faz a chamada da API do ViaCep para preencher os campos de endereço
    async handleCepChange(event) {
        this.cep = event.target.value;
        if (this.cep && this.cep.length >= 8) {
            try {
                const endereco = await buscarCep({ cep: this.cep });
                if (endereco) {
                    this.logradouro = endereco.logradouro;
                    this.bairro = endereco.bairro;
                    this.cidade = endereco.cidade;
                    this.estado = endereco.estado;
                }
            } catch (error) {
                this.showToast('Erro', 'Erro ao buscar CEP: ' + error.body.message, 'error');
            }
        }
    }
    //envia os dados para a classe apex salvar o cliente e o plano selecionado
    async salvarCliente() {
        try {
            
            await salvarAccount({
                nome: this.nome,
                cpf: this.cpf,
                email: this.email,
                cep: this.cep,
                dataNascimento: this.dataNascimento,
                telefone: this.telefone,
                logradouro: this.logradouro,
                numero: this.numero,
                bairro: this.bairro,
                cidade: this.cidade,
                estado: this.estado,
                descricao: this.descricao,
                tipoPlano: this.tipoPlano,
                valorMensalidade: this.valorMensalidade,
                cobertura: this.cobertura,
                carencia: this.carencia        

            });
            console.log('telefone no titular :' + this.telefone);
            this.showToast('Sucesso', 'Cliente salvo com sucesso', 'success');
            this.resetTela();
            this.isAbrirTelaPlano = false;
        } catch (error) {
            this.showToast('Erro', error.body.message, 'error');
        }
    }
    //envia os dados para a classe apex salvar o dependente relacionado ao titular
    async salvarDependente() {
        try {

            await salvarDependente({
                nome: this.nome,
                cpf: this.cpf,
                email: this.email,
                dataNascimento: this.dataNascimento,
                telefone: this.telefone,
                cep: this.cep,
                logradouro: this.logradouro,
                numero: this.numero,
                bairro: this.bairro,
                cidade: this.cidade,
                estado: this.estado,
                descricao: this.descricao,
                accountId: this.accountId
            });
            console.log('telefone no dependente :' + this.telefone);
            this.showToast('Sucesso', 'Dependente salvo com sucesso', 'success');
            this.resetTela();
        } catch (error) {
            console.log('Erro ao salvar dependente:', error);
            this.showToast('Erro', error.body.message, 'error');
        }
    }
    // limpa a tela senão os dados aparecem da tela do cliente para a tela do dependente e vice e versa
    resetTela() {
        this.tipoSelecionado = false;
        this.isCliente = false;
        this.isDependente = false;
        this.nome = '';
        this.cpf = '';
        this.email = '';
        this.telefone = '';
        this.cep = '';
        this.logradouro = '';
        this.numero = '';
        this.bairro = '';
        this.cidade = '';
        this.estado = '';
        this.dataNascimento = '';
        this.descricao = '';
        this.accountId = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
//chamada assincrona para buscar os planos de saúde disponíveis no mock
   async carregarPlanos() {
    try {
        const data = await buscarPlanos();

        // Garante que o array está salvo corretamente
        this.planos = [...data];

        // Monta as opções do combobox
        this.planoOptions = data.map(p => ({
            label: p.tipoPlano,
            value: p.tipoPlano
        }));

        console.log('Retorno Apex:', JSON.stringify(data));
        console.log('Planos carregados:', JSON.stringify(this.planoOptions));
    } catch (error) {
        console.error(' Erro ao carregar planos:', error);
    } finally {
        console.log('Planos disponíveis:', JSON.stringify(this.planos));
        console.log('Finalizou carregamento dos planos');
    }
}

handlePlanoChange(event) {
    this.selectedPlano = event.detail.value;
    console.log('Plano selecionado:', this.selectedPlano);

    // Verifica se o array existe antes de tentar acessar
    if (!this.planos || this.planos.length === 0) {
        console.error('Nenhum plano carregado antes da seleção');
        return;
    }

    this.planoSelecionado = this.planos.find(p => p.tipoPlano === this.selectedPlano);
    if (this.planoSelecionado) {
            this.tipoPlano = this.planoSelecionado.tipoPlano;
            this.valorMensalidade = this.planoSelecionado.valorMensalidade;
            this.cobertura = this.planoSelecionado.cobertura;
            this.carencia = this.planoSelecionado.carencia;
        }

    if (this.planoSelecionado) {
        console.log('Detalhes do plano selecionado:', JSON.stringify(this.planoSelecionado));
    } else {
        console.error('Plano não encontrado no array:', this.selectedPlano);
    }  
}
}