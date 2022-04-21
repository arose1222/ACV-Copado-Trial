import { LightningElement, api, wire } from 'lwc';
import NOTES_FIELD from '@salesforce/schema/Inquiry_Comment__c.Inquiry_Notes__c';
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/relatedListChildAdded__c';
import { fireToast } from 'c/acvUtilHelper';

export default class logComment extends LightningElement {
    @api recordId;
    @api objectApiName;

    fields = [NOTES_FIELD];
    isSaving = false;

    @wire(MessageContext)
    messageContext;

    // On save: disable save button and link new Inquiry_comment to current Customer Inquiry
    handleSubmit(event){
        this.isSaving = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Customer_Inquiry__c = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    // On Success publish message to relatedListChildAdded messageChannel
    // The relatedList LWC that is already subscribed to that messageChannel will see the message and will run handleMessage()
    handleSuccess(event) {
        fireToast('Success', 'Comment created successfully!', 'success');
        const payload = { data: 'child_list_modified'};
        publish(this.messageContext, recordSelected, payload);
        this.closeQuickAction();
    }

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }
}