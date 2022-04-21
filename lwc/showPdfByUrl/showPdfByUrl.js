import { LightningElement, api } from 'lwc';

export default class ShowPdfById extends LightningElement {
    @api pdfUrl;
    @api heightInRem;
    @api setUrl( urlString ) {
        this.pdfUrl = urlString;
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }
}