import { LightningElement, track } from 'lwc';

export default class HomeScreen extends LightningElement {
    @track isCadastro = false;
    @track isBusca = false;
    @track isAbertura = false;
    @track isLista = false;

    resetViews() {
        this.isCadastro = false;
        this.isBusca = false;
        this.isAbertura = false;
        this.isLista = false;
    }

    handleShowCadastro() {
        this.resetViews();
        this.isCadastro = true;
    }

    handleShowBusca() {
        this.resetViews();
        this.isBusca = true;
    }

    handleShowAbertura() {
        this.resetViews();
        this.isAbertura = true;
    }

    handleShowLista() {
        this.resetViews();
        this.isLista = true;
    }
}