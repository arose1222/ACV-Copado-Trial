import {LightningElement, api, track, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import S3 from '@salesforce/apex/S3.getPreSignedFileUrl';
import IMAGESLOCATION from '@salesforce/schema/Dealer_Docs__c.S3_Link__c';

const fieldList = [IMAGESLOCATION];

export default class DealerDocS3Image extends LightningElement {
    @api recordId;
    @api pdfUrl;
    @track showError = false;
    @wire(getRecord, {recordId: '$recordId', fields: fieldList})
    wireException({error, data}) {
        if (data) {
            (async () => {
                this.record = data;
                let link = await getFieldValue(this.record, IMAGESLOCATION);
                this.pdfUrl = await S3({url: link});
                this.template.querySelector('c-show-pdf-by-url').setUrl(this.pdfUrl);
            })();
        } else if (error) {
            (async () => {
                this.record = error;
                let link = await getFieldValue(this.record, IMAGESLOCATION);
                this.template.querySelector('c-show-pdf-by-url').setUrl(link);
            })();
        }
    }
}