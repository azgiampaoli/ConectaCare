import { LightningElement, track, wire } from 'lwc';
import buscarRegistros from '@salesforce/apex/BuscaClienteController.buscarRegistros';
import buscarDetalhes from '@salesforce/apex/AtualizarCaseController.buscarDetalhes';
import atualizarCase from '@salesforce/apex/AtualizarCaseController.atualizarCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

export default class BuscarCases extends LightningElement {

    @track searchTerm = '';
    @track resultados = [];
    @track modalAberto = false;
    @track caseDetalhes = {};
    @track novoStatus = '';
    @track novaDescricao = '';
    @track novoTelefone = '';
    @track novoEmail = '';
    @track novoTipoAtendimento = '';
    @track ContatoNome = '';

    statusOptions = [];
    defaultRecordTypeId;


    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo({ data, error }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    picklistHandler({ data, error }) {
        if (data) {
            this.statusOptions = data.values;
        }
    }

    /** Busca */
    buscar() {
        buscarRegistros({ termo: this.searchTerm })
            .then(res => this.resultados = res.filter(r => r.objectApiName === 'Case'))
            .catch(err => console.error(err));
    }

    handleabrirModal(e) {
        this.abrirModal(e);
    }

    handleSearchChange(e) {
        this.searchTerm = e.target.value;
        this.buscar();
    }

    formatPhone(value) {
        if (!value) return "";
        let v = value.replace(/\D/g, "");
        if (v.length >= 11) {
            return v.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
        }
        if (v.length >= 10) {
            return v.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
        }
        return value;
    }


    handleTelefoneChange(e) {
        let value = e.target.value;
        value = this.formatPhone(value);

        this.novoTelefone = value;
    }

    handleEmailChange(e) {
        this.novoEmail = e.target.value;
    }


    /** Abrir modal */
    abrirModal(e) {
        const id = e.target.dataset.id;


        buscarDetalhes({ caseId: id })
            .then(res => {
                this.caseDetalhes = { ...res };
                this.ContatoNome = res.contato__c;
                this.novoTelefone = this.formatPhone(res.Telephone__c);
                this.novoEmail = res.Email__c;
                this.novoTipoAtendimento = res.TipoAtendimento__c;
                this.novoStatus = res.Status;
                this.modalAberto = true;
            });
    }


get descricaoLista() {
    return this.resultados?.map(item => {

        
        const descricaoFormatada = this.formatarDescricao(item.Descricao);
        let entitlementName = item.Entitlement?.Name || '—';
        let milestone = item.CaseMilestones && item.CaseMilestones.length > 0
            ? item.CaseMilestones[0]
            : null;
        let targetDate = milestone?.TargetDate ? new Date(milestone.TargetDate) : null;
        let targetDateFormatted = targetDate ? targetDate.toLocaleString() : '—';        
        let timeRemaining = '—';
        let timeColor = 'color: gray; font-weight: bold;';

        if (targetDate) {
            const now = new Date();
            const diffMs = targetDate - now;

            if (diffMs <= 0) {
                timeRemaining = 'Expirado';
                timeColor = 'color: red; font-weight: bold;';
            } else {
                const diffMinutes = Math.floor(diffMs / 1000 / 60);
                const hours = Math.floor(diffMinutes / 60);
                const minutes = diffMinutes % 60;

                timeRemaining = `${hours}h ${minutes}min`;
                
                if (diffMinutes > 120) {
                    timeColor = 'color: green; font-weight: bold;';
                } else if (diffMinutes > 30) {
                    timeColor = 'color: goldenrod; font-weight: bold;';
                } else {
                    timeColor = 'color: red; font-weight: bold;';
                }
            }
        }
        return {
            ...item,
            descricaoFormatada,
            entitlementName,
            targetDateFormatted,
            timeRemaining,
            timeColor  
        };
    });
}



    formatarDescricao(texto) {
    if (!texto) return '';
    
    texto = texto.replace(/<\/?p>/g, '');
    texto = texto.replace(/\n/g, '<br>');
    texto = texto.replace(
        /\[(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2})]/g,
        '<br><b>[$1]</b>'
    );

    return texto;
}



    fecharModal() {
        this.modalAberto = false;
        window.location.reload();
    }

    handleStatusChange(e) {
        this.novoStatus = e.detail.value;
    }

    handleDescricaoChange(e) {
        this.novaDescricao = e.target.value;
    }

    salvarCase() {
        console.log('Chamando Apex...');

        try {

            atualizarCase({
                caseId: this.caseDetalhes.Id,
                novoStatus: this.novoStatus,
                novaDescricao: this.novaDescricao,
                novoTelefone: this.novoTelefone,
                novoEmail: this.novoEmail

            })
                .then(() => {



                    this.caseDetalhes = {
                        ...this.caseDetalhes,
                        Descricao__c: this.novaDescricao,
                        Status: this.novoStatus,
                        Telephone__c: this.novoTelefone,
                        Email__c: this.novoEmail
                    };

                    // Fecha modal
                    this.fecharModal();
                    this.buscar();

                    // Toast
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Sucesso',
                            message: 'Case atualizado com sucesso!',
                            variant: 'success'
                        })
                    );

                })
                .catch(err => {
                    console.error('ERRO NO APEX:', err);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erro',
                            message: err.body?.message || 'Erro ao atualizar o case',
                            variant: 'error'
                        })
                    );
                });

        } catch (e) {
            console.error('ERRO NO LWC:', e);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro no LWC',
                    message: e.message,
                    variant: 'error'
                })
            );
        }
    }

}
