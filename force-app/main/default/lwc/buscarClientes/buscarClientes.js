import { LightningElement, track } from 'lwc';
import buscarRegistros from '@salesforce/apex/BuscaClienteController.buscarRegistros';

export default class BuscaClientes extends LightningElement {
    @track searchTerm = '';
    @track results;

    columns = [
        { label: 'Nome', fieldName: 'Nome', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Telefone', fieldName: 'Telefone', type: 'phone' },
        { label: 'CPF', fieldName: 'CPF', type: 'text' },
        { label: 'Tipo', fieldName: 'Tipo', type: 'text' },
        { type: 'button', typeAttributes: { label: 'Selecionar', name: 'selecionar', variant: 'brand' } }
    ];

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        if (this.searchTerm && this.searchTerm.length >= 2) {
            this.buscar();
        } else {
            this.results = null;
        }
    }

    async buscar() {
        try {
            const data = await buscarRegistros({ termo: this.searchTerm });

            const somenteClientes = data.filter(r =>
                r.objectApiName !== 'Case'
            );

            this.results = somenteClientes;
        } catch (error) {
            console.error('Erro na busca', error);
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        if (!row?.Id) return;

        window.location.assign('/' + row.Id);
    }



}