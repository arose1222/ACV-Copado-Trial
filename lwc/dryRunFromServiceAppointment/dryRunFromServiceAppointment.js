import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import getServiceAppointment from '@salesforce/apex/DryRunFromServiceAppointmentController.getServiceAppointment';
import markAsDryRun from '@salesforce/apex/DryRunFromServiceAppointmentController.markAsDryRun';

export default class DryRunFromServiceAppointment extends LightningElement {
    // id of the record that invoke the action
    @api recordId;
    // denotes if the component is opened from the gantt or the record page itself
    @api fromGantt = false;

    // boolean that control the spinner displaying
    @track showSpinner = true;

    // list of fields to display
    selectedFields = ['Cannot_Complete_Reason__c', 'ActualStartTime', 'ActualEndTime'];

    // string error sufix
    ERROR_SUFIX = 'Error - If the issue is unclear, Please open an R&I with the following details: ';
    
    //Service Appointment Object
    @track record = new Object();

    // cannot complete reason values
    @track _cannotCompleteOptions = [];

    // denotes if the current record has been marked as dryrun
    @track alreadyDryRun = false;

    // error variables
    showError = false;

    @track errorMsg = '';

    @track showForm = false;

    connectedCallback(){
        console.log('spinner: ' , this.showSpinner);

        this.getRecordInformation();
    }

    renderedCallback(){
        this.showSpinner = false;
    }

    // get the record information from DB
    async getRecordInformation(){
        const jsonObj = await getServiceAppointment({recordId: this.recordId});

        this.record['recordId'] = this.recordId;

        const responseObj = JSON.parse(jsonObj);

        // the backend response is successfull
        if (responseObj.Status === 'SUCCESS'){
            this.record = JSON.parse(responseObj.Record);

            //add the picklist current picklist value
            this._cannotCompleteOptions.push({value: this.record.cannotCompleteReason, label:this.record.cannotCompleteReason});
            this.setPicklistValues(JSON.parse(responseObj.CannotCompleteValues));
            
            // it is already marked as a dryrun
            if (this.record.dryRun == true){
                this.alreadyDryRun = true;
            } else {
                this.showForm = true;
            }
        } else {
            if (responseObj.Message){
                if (this.fromGantt) { 
                    this.showError = true;
                    this.errorMsg = this.ERROR_SUFIX + responseObj.Message;
                } else {
                    this.showErrorToast(this.ERROR_SUFIX + responseObj.Message);
                }
            }
        }

        this.showAlreadyDryRun = (this.fromGantt && this.alreadyDryRun);
    }

    // method to set the picklist 
    setPicklistValues(picklistValues){
        if(picklistValues){
            let keys = Object.keys(picklistValues);

            keys.forEach(key => {
                this._cannotCompleteOptions.push({value: picklistValues[key], label: key});
            })
        }
    }

    // method to get the values for the picklist field
    get cannotCompleteOptions(){
        let options = [];

        if(this._cannotCompleteOptions){
            this._cannotCompleteOptions.forEach(option => {
                options.push({value: option['value'], label: option['label']});
            })
        }

        return options;
    }

    // method to set actual start input on the record
    setStartDate(event){
        this.record['actualStart'] = event.detail.value;
    }

    // method to set actual end input on the record
    setEndDate(event){
        this.record['actualEnd'] = event.detail.value;
    }

    // method to set cannot complete reason input on the record
    setCannotCompleteReason(event){
        this.record['cannotCompleteReason'] = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    // method to mark as dry run
    async markAsDryRun(){
        this.showSpinner = true;

        // reset the errors
        this.showError = false;

        // validate form
        if (this.isFormValidated()){
            const serviceAppointmenJson = JSON.stringify(this.record);
            const jsonObj = await markAsDryRun({serializedWrapper: serviceAppointmenJson});
            const responseObj = JSON.parse(jsonObj);

            if (responseObj.Status === 'SUCCESS'){
                this.showSpinner = false;
                
                if (this.fromGantt){
                    this.showSuccessForGantt = true;
                } else {
                    this.showSuccessToast('Updated Service Appointment with Dry Run Reason');
                }

                if (!this.fromGantt){
                    eval("$A.get('e.force:refreshView').fire();");
                }
            } else {
                if (responseObj.Message){
                    if (this.fromGantt) { 
                        this.showError = true;
                        this.errorMsg = this.ERROR_SUFIX + responseObj.Message;
                    } else {
                        this.showErrorToast(this.ERROR_SUFIX + responseObj.Message);
                    }
                }
            }
        }
    }

    // method that check if the form is fullfiled correctly
    isFormValidated(){
        let allOk = true;
        
        // check actual start input
        if (this.isEmpty(this.record, 'actualStart')){
            if (this.fromGantt){
                this.showError = true;
                this.errorMsg = 'Start Date is Required.';
            } else {
                this.showErrorToast('Start Date is Required.');
            }
            allOk = false;
        } 
        
        // check actual end input
        if(allOk && this.isEmpty(this.record, 'actualEnd')){
            if (this.fromGantt){
                this.showError = true;
                this.errorMsg = 'End Date is Required.';
            } else {
                this.showErrorToast('End Date is Required.');
            }
            allOk = false
        } 
        
        // check cannot complete reason input
        if(allOk && this.isEmpty(this.record, 'cannotCompleteReason')){
            if (this.fromGantt){
                this.showError = true;
                this.errorMsg = 'A Cannot Complete Reason is Required.';
            } else {
                this.showErrorToast('A Cannot Complete Reason is Required.');
            }
            allOk = false;
        } else if(allOk && !this.isEmpty(this.record, 'cannotCompleteReason') && !this.record['cannotCompleteReason'].toLowerCase().includes('dry run')){
            if (this.fromGantt){
                this.showError = true;
                this.errorMsg = 'Select a Valid Dry Run Reason.';
            } else {
                this.showErrorToast('Select a Valid Dry Run Reason.');
            }
            allOk = false;
        }

        this.showSpinner = allOk;

        return allOk;
    }

    // method to check if any field of the record isnt fulfilled
    isEmpty(obj, property){
        let result = true;
        if (obj[property] != null){
            result = false;
        }
        return result;
    }

    // method to get field mapping values
    getFieldMap(){
        let fieldMapping = {};
            fieldMapping['ActualStartTime'] = 'actualStart';
            fieldMapping['ActualEndTime'] = 'actualEnd';
            fieldMapping['Cannot_Complete_Reason__c'] = 'cannotCompleteReason';

        return fieldMapping;
    }

    // show error toast
    showErrorToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // show info toast
    showInfoToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Info',
            message: msg,
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // show success toast
    showSuccessToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}