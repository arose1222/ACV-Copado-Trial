import { LightningElement, api, wire } from 'lwc';
import getOpenInquiries from '@salesforce/apex/CloseSupportCase.getOpenChildInquiries';
import closeInquiries from '@salesforce/apex/CloseSupportCase.closeChildInquiries';
import { fireToast } from 'c/acvUtilHelper';
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/relatedListChildAdded__c';

const columns = [
    { label: 'Call Type', fieldName: 'Call_Type__c' },
    { label: 'Call Bucket', fieldName: 'Call_Bucket__c'},
    { label: 'Vin Last 6', fieldName: 'VIN_Last_6__c'},
    { label: 'Status', fieldName: 'Status__c' },
];

export default class CloseSupportCase extends LightningElement {
    @api recordId;
    modalOpen = false;
    isSaving = false;

    data = [];
    columns = columns;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
    }

    openModal() {
        getOpenInquiries({recordId:this.recordId})
            .then(results => {
                this.data = results;
                this.modalOpen = true;
            }
        );
    }

    closeModal() {
        this.modalOpen = false;
    }

    closeAll() {
        this.isSaving = true;
        closeInquiries({openInquiries:this.data})
            .then(results => {
                fireToast('Success', 'Support Case and Customer Inquiries Closed.', 'success');
                const payload = { data: 'child_list_modified'};
                publish(this.messageContext, recordSelected, payload);
            })
            .catch(error => {
                fireToast('Error', 'Error closing Support Case: ' + error.body.message, 'error', 'sticky');
            })
            .finally(() => {
                this.modalOpen = false;
                this.isSaving = false;
            });

    }
}