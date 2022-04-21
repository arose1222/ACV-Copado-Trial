/**
 * @description A component to display related fields specified in the Display_Related_Fields__mdt custom metadata.
 * 
 * @configuration
 * panelTitle -   Set the title of this LWC.
 * metadataTypeRecName - Multiple instances of this component could be configured on the same page and we need a mechanism to display 
 *                       different related fields on each LWC. Each configuration is specified in the Display_Related_Fields__mdt custom metadata
 *                       record. This field uses the record's DeveloperName field in the custom metadata to configure the LWC i.e. it specifies which configuration 
 *                       in the custom metadata will be used to display the list of related fields in the LWC.
 *
 * 
 * This LWC uses Display_Related_Fields__mdt custom metadata.
 * Action_Type__c - This informs what type of action to be executed. Currently, only SOQL action is supported i.e. it will execute the SOQL specified in Action__c.
 * Action__c - Execute the SOQL specified in this field. The query ':id:' token will be replace by the record id where the LWC component is being displayed.
 * 			   All fields in the query must be relative to the object page where the LWC is being displayed. That is, if you have LWC configured on the Quality Control record page
 * 			   then the query should have 'FROM Quality_Control__c' and all the fields used in the query should be from the Quality_Control__c object.
 * Fields_Display_Order__c - After the execution of the Action__c/SOQL, the result is converted into JSON and the properties/fields in the JSON are ordered specified in this field.
 * 							 It is a comma separated list of name=value pairs e.g. Odometer=Case__r.Odometer_Reading__c, Payment Status=Case__r.Payment_Status__c
 *
 * 
 * @name DisplayRelatedFields
 * @author Manmeet Vaseer
 * @date 09/24/2021
 * 
 */
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getFieldLabelValuePairs from '@salesforce/apex/DisplayRelatedFieldsController.getFieldLabelValuePairs';

export default class DisplayRelatedFields extends LightningElement {
 
    @api recordId;
    @api panelTitle;
    @api metadataTypeRecName;

    @track fieldLabelValuePair= [];

    /*
     * Sample JSON message returned by the APEX controller:
     *
     * [
			{"value":"0031100001rJrLhAAK","label":"Contact Id"},
			{"value":"ee949fa1-59da-4fbf-91d1-4884d9a29321@test.com","label":"Contact Email"},
			{"value":"00111000029EBxUAAW","label":"Seller Id"},
			{"value":"7161234560","label":"Seller Phone"},
			{"value":"12 Test St","label":"Selling Billing Street"}
	 * ]
     */
    @wire(getFieldLabelValuePairs, {
        recId: '$recordId',
        metadataTypeRecName: '$metadataTypeRecName',
    })
    wiredFieldLabelValuePairs({ error, data }) {
        if (data) {
            this.fieldLabelValuePair = JSON.parse(data);
        } else if (error) {
            this.showError = true;
            this.error = JSON.stringify(error);
            console.log('> > > > > Error: ' + this.error);
            this.showToastError('Unable to load the Fields: ' + error.body.message + ', **STACK TRACE**: ' + error.body.stackTrace);
        }
    }

    /* Specifically to show Sticky error. */
    showToastError(msg) {
        const evt = new ShowToastEvent({
            title: 'ERROR',
            message: msg,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    /* Specifically to show Dismissable message. */
    showToastSuccess(msg) {
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    
}