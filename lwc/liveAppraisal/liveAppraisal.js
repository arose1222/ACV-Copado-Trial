import getServiceResources from '@salesforce/apex/liveAppraisalController.getServiceResources';
import {LightningElement,track,api} from 'lwc';
import getContacts from '@salesforce/apex/workOrderIngestController.getContacts';
import submitWOs from '@salesforce/apex/liveAppraisalController.submitWorkOrders';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LiveAppraisal extends LightningElement {

@api recordId; // record id of the parent container (account record)
@api accountRec;
@api workOrderInfoRec;
@api serviceResourceSelection = [];
@api serviceResourceSelectionIds = [];

@track currentState;
@track initialSelection = [];
@track errors = [];

    workOrderInfo = {};
    account = {};
    steps = ["Date", "ServiceResource", "Address", "Contact", "Result"];
    nextIconName = 'utility:forward';
    previousIconName = 'utility:back';
    finishIconName = 'utility:like';
    serviceResourceMultiEntry = true;
    contactMultiEntry = false;
    showLoadingSpinner = false;

    /**
     * @description on component load
     */
    connectedCallback() {
        this.workOrderInfo = Object.assign({}, this.workOrderInfoRec);
        this.workOrderInfo.timeSelection = 'Live Appraisal';
        this.account = this.accountRec;

        this.initialSelection.push({"icon":"standard:avatar","id":this.account.Primary_Contact__c,"sObjectType":"Contact","subtitle":"","title":"Default Contact"});
        this.workOrderInfo.contact = this.account.Primary_Contact__c;
        this.workOrderInfo.startTime = '09:00:00.000';
        this.workOrderInfo.endTime = '17:00:00.000';

        this.currentState = "Date";
    }

    get isStateDate(){
        return (this.currentState == 'Date');
    }
    get isStateServiceResource(){
        return (this.currentState == 'ServiceResource');
    }
    get isStateAddress(){
        return (this.currentState == 'Address');
    }
    get isStateContact(){
        return (this.currentState == 'Contact');
    }
    get isStateResult(){
        return (this.currentState == 'Result');
    }
    get isProcessing(){
        return (this.currentState == 'Processing');
    }
    get isHideButtons(){
        return this.isStateResult;
    }
    get hidePrevious(){
        return this.isStateDate;
    }
    get hideNext(){
        return this.isStateContact;
    }
    get hideSave(){
        return !this.isStateContact;
    }
    
    handleDateChange(event){
        this.workOrderInfo.date = event.detail.value;
    }

    handleStartTimeChange(event) {
        if(event.detail.value >= this.workOrderInfo.endTime) {
            this.displayToast('Error', 'Start time has to be before end time.', 'error', 'dismissable');
        } else if(event.detail.value === '') {
            this.displayToast('Error', 'Start time must be populated.', 'error', 'dismissable');
        } 
        this.workOrderInfo.startTime = event.detail.value;
    }

    handleEndTimeChange(event) {
        if(this.workOrderInfo.startTime >= event.detail.value) {
            this.displayToast('Error', 'End time has to be after start time.', 'error', 'dismissable');
        } else if(event.detail.value === '') {
            this.displayToast('Error', 'End time must be populated.', 'error', 'dismissable');
        } 
        this.workOrderInfo.endTime = event.detail.value;
    }

    handleAddressChange(event){
        this.workOrderInfo.city = event.detail.city;
        this.workOrderInfo.state = event.detail.province;
        this.workOrderInfo.zip = event.detail.postalCode;
        this.workOrderInfo.country = event.detail.country;
        this.workOrderInfo.street = event.detail.street;
    }

    handleContactSearch(event){
        getContacts(event.detail)
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                        //console.log('Search Results: ' + JSON.stringify(results[0].id));
                        element.setSearchResults(results);
                });
            })
            .catch(error => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleContact(){
        var selectedValue = this.template.querySelector('c-lookup').getSelection();
        if(selectedValue[0]){
            if(selectedValue[0].hasOwnProperty('id')){
                //console.log(selectedValue[0].id);
                this.workOrderInfo.contact = selectedValue[0].id;
            }
        }
        else{
            this.workOrderInfo.contact = undefined;
        }

    }

    handleNextClick(){
        var stay = false;
        if(this.currentState == 'Date') {
            if(this.workOrderInfo.date == null || this.workOrderInfo.startTime == null || this.workOrderInfo.endTime == null || 
                this.workOrderInfo.date == "" || this.workOrderInfo.startTime == "" || this.workOrderInfo.endTime == "") {
                    this.displayToast('Error', 'All fields on this page must be populated.', 'error', 'dismissable');
                stay = true;
            }
            else if(this.workOrderInfo.startTime > this.workOrderInfo.endTime) {
                this.displayToast('Error', 'Start time has to be before end time.', 'error', 'dismissable');
                stay = true;
            }
        }

        if(this.currentState == 'ServiceResource') {
            if(this.serviceResourceSelection.length == 0) {
                this.displayToast('Error', 'You must select at least one service resource before continuing.', 'error', 'dismissable');
                stay = true;
            }
        }

        if(!stay) {
            var numOfSteps = this.steps.length;
            for(var i = 0; i < numOfSteps-1; i++) {
                if(this.currentState == this.steps[i]) {
                    this.currentState = this.steps[i+1];
                    break;
                }
            }
        }
    }

    handlePreviousClick(){
        var numOfSteps = this.steps.length;
        for(var i = numOfSteps-1; i > 0; i--) {
            if(this.currentState == this.steps[i]) {
                this.currentState = this.steps[i-1];
                break;
            }
        }
    }

    handleServiceResourceLookup(evt) {
        const target = evt.target;
        getServiceResources(evt.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.displayToast('Lookup Error', 'An error occured while trying to find the Service Resource. Please try again or submit an R&I ticket if the error persists.', 'error');
                this.errors = [error];
            }
        );
    }

    handleSelectionChange(event) {
        this.serviceResourceSelectionIds = [];
        var selectedServiceResources = this.template.querySelector('c-lookup').getSelection();
        selectedServiceResources.forEach(item => {
            this.serviceResourceSelectionIds.push(item.id);
        });
        this.serviceResourceSelection = selectedServiceResources;
    }

    handleSaveClick() {
        this.handleNextClick();
        this.toggleSpinner();

        //console.log('MGF Saving Work Orders.');
        submitWOs({woInfoJSON: JSON.stringify(this.workOrderInfo), serviceResourceIds: this.serviceResourceSelectionIds}).then(result =>{

            if(result.status == 'Success'){
                this.toggleSpinner();
                this.displayToast('Success', 'Your work order has been submitted.', 'success', 'dismissable');
                this.closeModal();
            } else {
                this.toggleSpinner();
                this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', result.message, 'error', 'sticky');
                this.closeModal();
            }

        }).catch(error =>{
            this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
            this.closeModal();
        })
    }

    toggleSpinner() {
        this.showLoadingSpinner = !this.showLoadingSpinner;
    }

    displayToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    /**
     * @description exit
     */
     closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}