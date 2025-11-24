import { LightningElement, track, wire } from 'lwc';
import buscarRegistrosApex from '@salesforce/apex/BuscaClienteController.buscarRegistros';
import criarCaseApex from '@salesforce/apex/CaseController.criarCase';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TIPO_ATENDIMENTO_FIELD from '@salesforce/schema/Case.TipoAtendimento__c';
import CASE_OBJECT from '@salesforce/schema/Case';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ClienteSearch extends LightningElement {
    termo = '';
    @track registros = [];
    @track selected = null;
    @track isLoading = false;
    mensagemErro = '';
    @track showModal = false;
    clienteSelecionadoNome = '';
    assunto = '';
    descricao = '';
    tipoAtendimento = '';
    opcoesTipo = [];
    salvando = false;
    handleChange(event) {
        this.termo = event.target.value;
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            this.buscarRegistros();
        }
    }

    async buscarRegistros() {
        this.mensagemErro = '';
        this.selected = null;
        this.registros = [];
        if (!this.termo || this.termo.trim().length === 0) {
            this.mensagemErro = 'Digite CPF, e-mail ou nome para buscar.';
            return;
        }

        this.isLoading = true;
        try {
            const resultado = await buscarRegistrosApex({ termo: this.termo.trim() });
            if (Array.isArray(resultado) && resultado.length > 0) {
                const somenteClientes = resultado.filter(r =>
                    r.objectApiName !== 'Case'
                );
                this.registros = somenteClientes.map(item => {
                    return {
                        Id: item.Id || '',
                        AccountId: item.AccountId || '',
                        Nome: item.Nome || '',
                        Email: item.Email || '',
                        CPF: item.CPF || '',
                        Telefone: item.Telefone || '',
                        Tipo: item.Tipo || '',
                        NomePlano: item.NomePlano || '',
                        Cobertura: item.Cobertura || '',
                        DataVencimento: item.DataVencimento ? new Date(item.DataVencimento).toLocaleDateString('pt-BR') : '',
                        StatusPlano: item.StatusPlano ? 'Sim' : 'Não',
                        isSelected: false
                    };
                });
                this.mensagemErro = '';
            } else {
                this.registros = [];
                this.mensagemErro = 'Nenhum registro encontrado.';
            }
        } catch (error) {
            console.error('Erro ao buscar registros:', error);
            this.mensagemErro = error?.body?.message || 'Erro ao buscar registros. Veja o console para detalhes.';
        } finally {
            this.isLoading = false;
        }
    }

    handleSelectItem(event) {
        
        const index = event.currentTarget.dataset.index;
        const idx = parseInt(index, 10);
        console.log('Evento de seleção disparado linha 81');
        console.log('Index selecionado: ' + idx);
        console.log('Registros atuais: ' + JSON.stringify(this.registros));
        if (isNaN(idx)) return;

        const selectedId = this.registros[idx].Id;
        console.log('ID selecionado: ' + selectedId);
        this.selected = selectedId;
        console.log('Evento de seleção disparado linha 86');        

        this.registros = this.registros.map(item => {
            return {
                ...item,
                isSelected: item.Id === selectedId                
            };         
            
        });
        console.log('Selected item: ' + this.selected);
    }

    handleAbrirCaso(event) {
        console.log('handle abrir o caso');
        const item = this.registros.find(r => r.Id === this.selected);
        console.log('Selected item: abri case' + this.item);
        if (!item) return;
        this.clienteSelecionadoNome = item.Nome;
        this.showModal = true;
    }

    fecharModal() {
        this.showModal = false;
        this.assunto = '';
        this.descricao = '';
        this.tipoAtendimento = '';
    }

    handleAssunto(event) {
        this.assunto = event.target.value;
    }

    handleDescricao(event) {
        this.descricao = event.target.value;
    }

    handleTipo(event) {
        this.tipoAtendimento = event.target.value;
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TIPO_ATENDIMENTO_FIELD
    })
    wiredPicklist({ error, data }) {
        if (data) {
            this.opcoesTipo = data.values.map(v => ({ label: v.label, value: v.value }));
        } else if (error) {
            console.error('Erro ao carregar picklist:', error);
        }
    }

    handlecriarCaso(event) {
        this.criarCaso();
    }

    async criarCaso() {
        if (!this.selected) {
            this.showToast('Atenção', 'Selecione um cliente antes de criar o caso.', 'warning');
            return;
        }

        const registro = this.registros.find(r => r.Id === this.selected);

        const accountId = registro.Id;
        console.log('accountId selecionado para criar o caso:', accountId);

        if (!this.assunto || this.assunto.trim().length === 0) {
            this.showToast('Atenção', 'Preencha o assunto.', 'warning');
            return;
        }

        this.salvando = true;

        try {
            const novoCaseId = await criarCaseApex({
                accountId: accountId,
                assunto: this.assunto,
                descricao: this.descricao,
                tipoAtendimento: this.tipoAtendimento
            });
            console.log('accountId para o caso:', accountId);

            this.fecharModal();
            this.showToast('Sucesso', 'Caso criado com sucesso. ', 'success');


        } catch (error) {
            console.error('Erro ao criar caso', error);
            this.showToast('Erro', error?.body?.message || error?.message || 'Erro ao criar caso', 'error');
        } finally {
            this.salvando = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}