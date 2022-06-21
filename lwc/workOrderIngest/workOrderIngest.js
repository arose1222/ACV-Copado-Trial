import { getRecord } from 'lightning/uiRecordApi';
import {LightningElement,track,wire,api} from 'lwc';
import FIELD_ACCOUNT_CONTACT_ID from '@salesforce/schema/Account.Primary_Contact__c';
import FIELD_ACCOUNT_OWNERID from '@salesforce/schema/Account.OwnerId';
import FIELD_ACCOUNT_CITY from '@salesforce/schema/Account.BillingCity';
import FIELD_ACCOUNT_STATE from '@salesforce/schema/Account.BillingState';
import FIELD_ACCOUNT_ZIP from '@salesforce/schema/Account.BillingPostalCode';
import FIELD_ACCOUNT_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import FIELD_ACCOUNT_STREET from '@salesforce/schema/Account.BillingStreet';
import FIELD_ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import FIELD_ACCOUNT_SERVICE_TERRITORY from '@salesforce/schema/Account.Service_Territory__c';
import FIELD_ACCOUNT_LIVE_APPRAISAL_SELLER from '@salesforce/schema/Account.Live_Appraisal_Seller__c';
import FIELD_ACCOUNT_HALT_TRUE360_APPOINTMENTS from '@salesforce/schema/Account.Halt_True360_Appointments__c';

import submitWOs from '@salesforce/apex/workOrderIngestController.submitWorkOrders';
import getContacts from '@salesforce/apex/workOrderIngestController.getContacts';
import checkRevolvingAppt from '@salesforce/apex/workOrderIngestPermissions.checkToDisplayRevolving';
import retrieveOffers from '@salesforce/apex/OffersAPI.retrieveOffers';
import saveOffer from '@salesforce/apex/workOrderIngestController.saveOffer';
import saveOfferNoAvailability from '@salesforce/apex/workOrderIngestController.saveOfferNoAvailability';
import updateWork from '@salesforce/apex/workOrderIngestController.updateWork';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';

const ACCOUNT_FIELDS = [
    FIELD_ACCOUNT_NAME,
    FIELD_ACCOUNT_CONTACT_ID,
    FIELD_ACCOUNT_OWNERID,
    FIELD_ACCOUNT_CITY,
    FIELD_ACCOUNT_STATE,
    FIELD_ACCOUNT_ZIP,
    FIELD_ACCOUNT_COUNTRY,
    FIELD_ACCOUNT_STREET,
    FIELD_ACCOUNT_SERVICE_TERRITORY,
    FIELD_ACCOUNT_LIVE_APPRAISAL_SELLER,
    FIELD_ACCOUNT_HALT_TRUE360_APPOINTMENTS,
];

export default class workOrderIngest extends LightningElement {

    @api recordId;
    @track account = {};

    workOrderInfo = {};

    isMultiEntry = false;
    @track displayLiveAppraisal = true;
    @track initialSelection = [];
    @track errors = [];
    @track selectedList;
    today;
    showLoadingSpinner = false;

    toggleSpinner() {
        this.showLoadingSpinner = !this.showLoadingSpinner;
    }

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccountRecord(result) {
        if(result.data) {
            this.account['Id'] = this.recordId;
            for(let prop in result.data.fields) {
                this.account[prop] = result.data.fields[prop].value;
            }
            if(this.account.Live_Appraisal_Seller__c == false) {
                this.displayLiveAppraisal = false;
            }
        } else if(result.error) {
            alert('error loading fields for account.');
        }

        this.workOrderInfo.city = this.account.BillingCity;
        this.workOrderInfo.state = this.account.BillingState;
        this.workOrderInfo.zip = this.account.BillingPostalCode;
        this.workOrderInfo.country = this.account.BillingCountry;
        this.workOrderInfo.street = this.account.BillingStreet;
        this.workOrderInfo.accountName = this.account.Name;
        this.workOrderInfo.serviceTerritory = this.account.Service_Territory__c;
        this.initialSelection.push({"icon":"standard:avatar","id":this.account.Primary_Contact__c,"sObjectType":"Contact","subtitle":"","title":"Default Contact"});
        this.workOrderInfo.contact = this.account.Primary_Contact__c;
        this.workOrderInfo.userId = Id;
    };

    @wire(checkRevolvingAppt, { })
    handleRevolvingApptResult(result) {
        if(result.data != null) {
            this.displayRevolvingAppts = result.data;
            if(result.data == false) {
                this.displayLiveAppraisal = false;
            }
        } else if(result.error) {
            this.errors = [result.error];
            alert('error loading Revolving Appointment priveledges');
        }
    };

    connectedCallback(){
        this.currentState = 'Time';
        this.isMultiEntry = false;

        var now = new Date();
        var dd = String(now.getDate()).padStart(2, '0');
        var mm = String(now.getMonth() + 1).padStart(2, '0');
        var yyyy = now.getFullYear();
        this.today = yyyy + '-' + mm + '-' + dd;

        this.workOrderInfo.accountId = this.recordId;
        this.workOrderInfo.WSCount = '0';
        this.workOrderInfo.AVCount = '0';
        this.workOrderInfo.T360Count = '0';
        this.workOrderInfo.SXMCount = '0';
        this.workOrderInfo.BSUCheck = false;
        this.workOrderInfo.date = this.today;
        this.workOrderInfo.NotificationRequest = false;

    }

    handleContactSearch(event){
        getContacts(event.detail)
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                        console.log('Search Results: ' + JSON.stringify(results[0].id));
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
                console.log(selectedValue[0].id);
                this.workOrderInfo.contact = selectedValue[0].id;
            }
        }
        else{
            this.workOrderInfo.contact = undefined;
        }

        this.isContactUpdated = true;

    }



    nextButtonLabel = 'Next';
    nextIconName = 'utility:forward';

    finishButtonLabel = 'Finish';
    finishIconName = 'utility:like';

    previousButtonLabel = 'Previous';
    previousIconName = 'utility:back';

    viewStates = ['Time', 'Revolving', 'Day', 'Vehicles', 'Address', 'Contact', 'Inspection Notes', 'Summary', 'Processing', 'RevolvingModal'];
    @track currentState;

    inspectionOffers = [];
    true360Offers = [];
    siriusxmOffers = [];
    showOffers = true;

    inspectionWOId;
    true360WOId;
    siriusXMWOId;

    inspectionDuration;
    true360Duration;
    siriusXMDuration;

    offerButtonClass = 'slds-button slds-button_stretch ';

    inspectionAMOffer;
    inspectionPMOffer;
    true360AMOffer;
    true360PMOffer;
    siriusXMAMOffer;
    siriusXMPMOffer;

    isAddressChanged = false;
    isContactUpdated = false;
    isSpecialInstructionsAdded = false;

    handleRevolvingClose(){
        this.closeModal();
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    get OpenRevolvingModal(){
        return (this.currentState == 'RevolvingModal');
    }
    get isStateTime(){
        return (this.currentState == 'Time');
    }
    get isStateRevolving(){
        return (this.currentState == 'Revolving');
    }
    get isStateDay(){
        return (this.currentState == 'Day');
    }
    get isStateLiveAppraisal(){
        return (this.currentState == 'Appraisal');
    }
    get isStateVehicles(){
        return (this.currentState == 'Vehicles');
    }
    get isStateAddress(){
        return (this.currentState == 'Address');
    }
    get isStateContact(){
        return (this.currentState == 'Contact');
    }
    get isStateNotes(){
        return (this.currentState == 'Notes');
    }
    get isStateSummary(){
        return (this.currentState == 'Summary');
    }
    // get isStateFetchOffers(){
    //     return (this.currentState == 'FetchOffers');
    // }
    get isStateInspection(){
        return (this.currentState == 'Inspection');
    }
    get isStateTrue360(){
        return (this.currentState == 'True360');
    }
    get isStateSiriusXM(){
        return (this.currentState == 'SiriusXM');
    }
    get isASAP(){
        return (this.workOrderInfo.timeSelection === 'ASAP');
    }
    get isLater(){
        return (this.workOrderInfo.time === 'Later');
    }
    get isProcessing(){
        return (this.currentState == 'Processing');
    }
    get isInspectionOffers(){
        return (this.inspectionOffers.length > 0);
    }
    get isTrue360Offers(){
        return (this.true360Offers.length > 0);
    }
    get isSiriusXMOffers(){
        return (this.siriusxmOffers.length > 0);
    }
    get isHideButtons(){
        return (this.currentState == 'Inspection' || this.currentState == 'True360' || this.currentState == 'SiriusXM' || this.currentState == 'Appraisal');
    }
    get isInspectionUnavailable(){
        return (!this.inspectionAMOffer && !this.inspectionPMOffer);
    }
    get isInspectionAMUnavailable(){
        return (!this.inspectionAMOffer);
    }
    get isInspectionPMUnavailable(){
        return (!this.inspectionPMOffer);
    }
    get isInspectionFullDayAvailable(){
        return (!this.inspectionAMOffer || !this.inspectionPMOffer)
    }

    get isTrue360Unavailable(){
        return (!this.true360AMOffer && !this.true360PMOffer);
    }
    get isTrue360AMUnavailable(){
        return (!this.true360AMOffer);
    }
    get isTrue360PMUnavailable(){
        return (!this.true360PMOffer);
    }
    get isTrue360FullDayAvailable(){
        return (!this.true360AMOffer || !this.true360PMOffer)
    }

    get isSiriusXMUnavailable(){
        return (!this.siriusXMAMOffer && !this.siriusXMPMOffer);
    }
    get isSiriusXMAMUnavailable(){
        return (!this.siriusXMAMOffer);
    }
    get isSiriusXMPMUnavailable(){
        return (!this.siriusXMPMOffer);
    }
    get isSiriusXMFullDayAvailable(){
        return (!this.siriusXMAMOffer || !this.siriusXMPMOffer)
    }


    timeSelection = '';
    get timeSelectionOptions() {
        return [
            { label: 'A specific date in the future', value:'Later'},
            { label: 'As soon as we can', value:'ASAP' },
            { label: 'Self assign now', value: 'Now'},
        ];
    }

    revolvingAppointmentSelection = '';
    get revolvingAppointmentOptions() {
        var lst = [];
        lst.push( { label:'Single Appointment', value:'Single' } );
        if ( this.displayRevolvingAppts ) { lst.push( { label:'Revolving Appointments', value:'Revolving' } ); }
        if( this.displayLiveAppraisal ) lst.push( { label:'Live Appraisal', value:'Live' } );
        return lst;
    }

    handleDate(event){
        console.log(event.detail.value);
        this.workOrderInfo.date = event.detail.value;
    }

    handleTimeSelection(event){
        this.timeSelection = event.detail.value;
        this.workOrderInfo.timeSelection = event.detail.value;
    }

    handleRevolvingSelection(event){
        this.revolvingAppointmentSelection = event.detail.value;
    }

    handleWS(event){
        this.workOrderInfo.WSCount = event.detail.value;
        if(this.workOrderInfo.WSCount == ""){
            this.workOrderInfo.WSCount = 0;
        }
    }
    handleAV(event){
        this.workOrderInfo.AVCount = event.detail.value;
        if(this.workOrderInfo.AVCount == ""){
            this.workOrderInfo.AVCount = 0;
        }
    }
    handleT360(event){
        this.workOrderInfo.T360Count = event.detail.value;
        if(this.workOrderInfo.T360Count == ""){
            this.workOrderInfo.T360Count = 0;
        }
        else if(this.account.Halt_True360_Appointments__c && event.detail.value > 0) {
            this.displayToast('True 360', 'This dealership is not approved for any True 360 inspections at this time. Please direct the dealer to call (716) 954-9515 or email ar@true360.com with questions.', 'error', 'sticky');
        }
    }
    handleSXM(event){
        this.workOrderInfo.SXMCount = event.detail.value;
        if(this.workOrderInfo.SXMCount == ""){
            this.workOrderInfo.SXMCount = 0;
        }
    }
    handleBSU(event){
        this.workOrderInfo.BSUCheck = event.detail.checked;
    }
    handleNotificationRequest(event){
        this.workOrderInfo.NotificationRequest = event.detail.checked;
    }


    handleAddress(event){
        if(this.workOrderInfo.city != event.detail.city || this.workOrderInfo.state != event.detail.province || this.workOrderInfo.zip != event.detail.postalCode || this.workOrderInfo.country != event.detail.country || this.workOrderInfo.street != event.detail.street){

            this.isAddressChanged = true;

            this.workOrderInfo.city = event.detail.city;
            this.workOrderInfo.state = event.detail.province;
            this.workOrderInfo.zip = event.detail.postalCode;
            this.workOrderInfo.country = event.detail.country;
            this.workOrderInfo.street = event.detail.street;
        }
    }
    handleNotes(event){
        this.workOrderInfo.notes = event.detail.value;
        this.isSpecialInstructionsAdded = true;
    }

    handleNextClick(){
        console.log(this.currentState);
        switch(this.currentState){
            case 'Time':
                if(this.timeSelection === 'ASAP' || this.timeSelection === 'Now'){
                    this.currentState = 'Vehicles';
                    this.workOrderInfo.time = 'ASAP';
                }
                if(this.timeSelection === 'Later'){
                    this.workOrderInfo.time = 'Later';
                    if ( this.displayRevolvingAppts  || this.displayLiveAppraisal) {
                        this.currentState = 'Revolving';
                    } else {
                        this.currentState = 'Day';
                    }
                }
                break;

            case 'Revolving':
                if(this.revolvingAppointmentSelection === 'Revolving'){
                    //go to revolving appointment lwc
                    this.currentState = 'RevolvingModal';
                }
                if(this.revolvingAppointmentSelection === 'Single'){
                    this.currentState = 'Day';
                }
                if(this.revolvingAppointmentSelection === 'Live'){
                    this.currentState = 'Appraisal';
                }
                //do stuff
                break;

            case 'Day':
                this.currentState = 'Vehicles';
                //do stuff
                break;

            case 'Vehicles':
                // Check A value is entered for either vehicle set
                if ( this.workOrderInfo.T360Count <= 0 && this.workOrderInfo.WSCount <= 0  && this.workOrderInfo.SXMCount <= 0 && this.workOrderInfo.BSUCheck == false) {
                    // Error
                    var message = 'You need to select at least 1 job type';
                    this.displayToast('Warning', message, 'warning', 'dismissable');
                } else if(this.workOrderInfo.T360Count > 0 && this.account.Halt_True360_Appointments__c) {
                    this.displayToast('True 360', 'This dealership is not approved for any True 360 inspections at this time. Please direct the dealer to call (716) 954-9515 or email ar@true360.com with questions.', 'error', 'sticky');
                } else {

                    if(this.workOrderInfo.time != 'Later'){
                        this.currentState = 'Address';
                    } else {

                        this.currentState = 'Processing';
                        this.toggleSpinner();

                        submitWOs({woInfoJSON: JSON.stringify(this.workOrderInfo), isProcessingOffers: true}).then(result =>{
                            if(result.status == 'Success'){

                                this.inspectionWOId = result.inspectionWOId;
                                this.true360WOId = result.true360WOId;
                                this.siriusXMWOId = result.siriusXMWOId;

                                if(result.inspectionDuration){this.inspectionDuration = this.processDuration(result.inspectionDuration)};
                                if(result.true360Duration){this.true360Duration = this.processDuration(result.true360Duration)};
                                if(result.siriusXMDuration){this.siriusXMDuration = this.processDuration(result.siriusXMDuration)};

                                this.toggleSpinner();
                                this.currentState = 'Address';

                            } else {
                                this.toggleSpinner();
                                this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', result.message, 'error', 'sticky');
                            }

                        }).catch(error =>{

                            this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
                            this.closeModal();

                        })
                    }
                }

                break;

            case 'Address':

                this.currentState = 'Contact';
                break;

            case 'Contact':
                this.currentState = 'Notes';
                break;

            case 'Notes':

                if(this.workOrderInfo.timeSelection == 'Later' && !this.isOnlyBSU()){
                    this.nextButtonLabel = 'Check Availability';
                    if(this.isAddressChanged || this.isSpecialInstructionsAdded || this.isContactUpdated){
                        this.currentState = 'Processing';
                        this.toggleSpinner();
                        updateWork({woInfoJSON: JSON.stringify(this.workOrderInfo), inspectionWOId: this.inspectionWOId, true360WOId: this.true360WOId, siriusXMWOId: this.siriusXMWOId}).then(result =>{
                            if(result.status == 'Success'){
                                this.toggleSpinner();
                                this.currentState = 'Summary';
                            } else {
                                this.toggleSpinner();
                                this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', result.message, 'error', 'sticky');
                            }

                        }).catch(error =>{
                            this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
                            this.closeModal();
                        })
                    } else {
                        this.currentState = 'Summary';
                        break;
                    }

                } else {

                    this.nextButtonLabel = 'Finish';
                    this.nextIconName = 'utility:like';
                    this.currentState = 'Summary';
                }

                break;

            case 'Summary':
                if(this.workOrderInfo.timeSelection == 'Later' && !this.isOnlyBSU()){
                    this.currentState = 'Processing';
                    this.toggleSpinner();
                    this.nextButtonLabel = 'next';
                    this.nextIconName = 'utility:like';

                    this.processGetOffers(this.inspectionWOId, this.true360WOId, this.siriusXMWOId);

                } else {
                    this.currentState = 'Processing';
                    this.toggleSpinner();

                    submitWOs({woInfoJSON: JSON.stringify(this.workOrderInfo), isProcessingOffers: false}).then(result =>{

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

                break;


            case 'Inspection':
                this.processGetOffers(this.inspectionWOId, this.true360WOId, this.siriusXMWOId);
                break;


            case 'True360':
                this.processGetOffers(this.inspectionWOId, this.true360WOId, this.siriusXMWOId);
                break;


            case 'SiriusXM':
                this.processGetOffers(this.inspectionWOId, this.true360WOId, this.siriusXMWOId);
                break;



        }
    }

    processGetOffers(inspectionWOId, true360WOId, siriusXMWOId){

        if(this.currentState == 'Processing'){
            if(inspectionWOId){
                this.retrieveOffers(inspectionWOId, 'Inspection');
            } else if(true360WOId){
                this.retrieveOffers(true360WOId, 'True360');
            } else if(siriusXMWOId){
                this.retrieveOffers(siriusXMWOId, 'SiriusXM');
            } else {
                this.closeModal();
            }
        } else if(this.currentState == 'Inspection'){
            if(true360WOId){
                this.currentState = 'Processing';
                this.retrieveOffers(true360WOId, 'True360');
            } else if(siriusXMWOId){
                this.currentState = 'Processing';
                this.retrieveOffers(siriusXMWOId, 'SiriusXM');
            } else {
                this.closeModal();
            }
        } else if(this.currentState == 'True360'){
            if(siriusXMWOId){
                this.currentState = 'Processing';
                this.showLoadingSpinner = true;
                this.retrieveOffers(siriusXMWOId, 'SiriusXM');
            } else {
                this.closeModal();
            }
        } else {
            this.closeModal();
        }
    }


    retrieveOffers(workOrderId, nextState){
        retrieveOffers({workOrderId: workOrderId}).then(result =>{
                if(result.savedOfferMap['inspection']){
                    this.inspectionOffers = result.savedOfferMap['inspection'];
                    this.inspectionOffers.map(offer =>{
                        if(this.getOfferSlot(offer) == 'AM'){

                            if(!this.inspectionAMOffer){
                                this.inspectionAMOffer = offer;
                            } else if(this.inspectionAMOffer.Grade__c < offer.Grade__c){
                                this.inspectionAMOffer = offer;
                            }

                        } else if(this.getOfferSlot(offer) == 'PM'){

                            if(!this.inspectionPMOffer){
                                this.inspectionPMOffer = offer;
                            } else if(this.inspectionPMOffer.Grade__c < offer.Grade__c){
                                this.inspectionPMOffer = offer;
                            }
                        }
                    })
                }

                if(result.savedOfferMap['true360']){
                    this.true360Offers = result.savedOfferMap['true360'];
                    this.true360Offers.map(offer =>{
                        if(this.getOfferSlot(offer) == 'AM'){

                            if(!this.true360AMOffer){
                                this.true360AMOffer = offer;
                            } else if(this.true360AMOffer.Grade__c < offer.Grade__c){
                                this.true360AMOffer = offer;
                            }

                        } else if(this.getOfferSlot(offer) == 'PM'){
                            if(!this.true360PMOffer){
                                this.true360PMOffer = offer;
                            } else if(this.true360PMOffer.Grade__c < offer.Grade__c){
                                this.true360PMOffer = offer;
                            }
                        }
                    })
                }

                if(result.savedOfferMap['siriusxm']){
                    this.siriusxmOffers = result.savedOfferMap['siriusxm'];
                    this.siriusxmOffers.map(offer =>{
                        if(this.getOfferSlot(offer) == 'AM'){

                            if(!this.siriusXMAMOffer){
                                this.siriusXMAMOffer = offer;
                            } else if(this.siriusXMAMOffer.Grade__c < offer.Grade__c){
                                this.siriusXMAMOffer = offer;
                            }

                        } else if(this.getOfferSlot(offer) == 'PM'){
                            if(!this.siriusXMPMOffer){
                                this.siriusXMPMOffer = offer;
                            } else if(this.siriusXMPMOffer.Grade__c < offer.Grade__c){
                                this.siriusXMPMOffer = offer;
                            }
                        }
                    })
                }

                this.showOffers = true;
                this.toggleSpinner();
                this.currentState = nextState;

             }).catch(error =>{
                this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
                this.closeModal();
             })
    }

    processDuration(durationInMinutes){
        var durationString = '';
        var minutesToHours = 60;
        var remindingMinutes = durationInMinutes;

        if ( durationInMinutes >= minutesToHours ) {
            var hours = Math.floor( durationInMinutes / minutesToHours );
            var lingeringMinutes = durationInMinutes - ( hours * minutesToHours );
            if ( hours > 0 ) {
                durationString += hours + ' hour';
                if ( hours >= 2 ) { durationString += 's'; }
            }
            if ( lingeringMinutes > 0 ) {
                durationString += ' and ';
                // remindingMinutes = lingeringMinutes;
                durationString += lingeringMinutes + ' minutes';
            }
        } else {
            durationString += remindingMinutes + ' minutes';
        }
        // if ( remindingMinutes > 0 ) { durationString += remindingMinutes + ' minutes'; }
        return durationString;
    }

    getOfferSlot(offer){
        if(new Date(offer.Start_Time__c).getHours() == 8){
            return 'AM';
        } else if(new Date(offer.Start_Time__c).getHours() == 12){
            return 'PM';
        }
    }

    handleSaveOffer(event){
        if(event.target.name){
            this.toggleSpinner();
        }

        switch(event.target.name){
            case 'amInspectionOffer':
                this.saveOffer(this.inspectionAMOffer.Id);
                break;
            case 'pmInspectionOffer':
                this.saveOffer(this.inspectionPMOffer.Id);
                break;
            case 'amTrue360Offer':
                this.saveOffer(this.true360AMOffer.Id);
                break;
            case 'pmTrue360Offer':
                this.saveOffer(this.true360PMOffer.Id);
                break;
            case 'amSiriusXMOffer':
                this.saveOffer(this.siriusXMAMOffer.Id);
                break;
            case 'pmSiriusXMOffer':
                this.saveOffer(this.siriusXMPMOffer.Id);
                break;
        }
    }

    saveOffer(apptOfferId){
        if(apptOfferId == null){
            this.toggleSpinner();
            this.displayToast('Unavailable', 'There are no offers available for the timeslot you have selected.', 'error', 'dismissable');
        }else{
            this.showOffers = false;
            saveOffer({apptOfferId: apptOfferId}).then(result =>{
                this.displayToast('Success', 'Your appointment has been scheduled.', 'success', 'dismissable');
                this.handleNextClick();
            }).catch(error =>{
                this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
                this.closeModal();
            })
        }
    }

    isOnlyBSU(){
        return(this.workOrderInfo.BSUCheck == true && (this.workOrderInfo.WSCount == 0 && this.workOrderInfo.T360Count == 0 && this.workOrderInfo.SXMCount == 0));
    }


    handlePreviousClick(){
        switch(this.currentState){
            case 'Time':
                //do stuff
                break;
            case 'Revolving':
                this.currentState = 'Time';
                //do stuff
                break;
            case 'Day':
                this.workOrderInfo.date = this.today;
                if ( this.displayRevolvingAppts ) {
                    this.currentState = 'Revolving';
                } else {
                    this.currentState = 'Time';
                }
                //do stuff
                break;
            case 'Vehicles':
                if(this.workOrderInfo.time === 'ASAP'){
                    this.currentState = 'Time';
                }
                else{
                    this.currentState = 'Day';
                }
                //do stuff
                break;
            case 'Address':
                this.currentState = 'Vehicles';
                //do stuff
                break;
            case 'Contact':
                this.currentState = 'Address';
                //do stuff
                break;
            case 'Notes':
                this.currentState = 'Contact';
                //do stuff
                break;
            case 'Summary':
                this.currentState = 'Notes';
                this.nextButtonLabel = 'Next';
                this.nextIconName = 'utility:forward';
                //do stuff
                break;
        }
    }

    handleFullDayWithoutAvail(){
        this.showOffers = false;
        this.toggleSpinner();

        var fullDayOfferWOID;
        if(this.currentState == 'Inspection'){
            this.fullDayOfferWOID = this.inspectionWOId;
        } else if(this.currentState == 'True360'){
            this.fullDayOfferWOID = this.true360WOId;
        } else if(this.currentState == 'SiriusXM'){
            this.fullDayOfferWOID = this.siriusXMWOId;
        }

        saveOfferNoAvailability({workOrderId: this.fullDayOfferWOID}).then(result =>{
            this.displayToast('Warning', 'Your request has been saved. As a reminder, this appointment will need to be scheduled manually.', 'warning', 'sticky');
            this.handleNextClick();
        }).catch(error =>{
            this.displayToast('Error - If the issue is unclear, Please open an R&I with the following details:', error.body.message, 'error', 'sticky');
            this.closeModal();
        })
    }

    handleAnytime(){
        this.toggleSpinner();
        var bestOfferId;
        if(this.currentState == 'Inspection'){
            if(this.inspectionAMOffer.Grade__c > this.inspectionPMOffer.Grade__c){
                this.bestOfferId = this.inspectionAMOffer.Id;
            } else {
                this.bestOfferId = this.inspectionPMOffer.Id;
            }
        } else if(this.currentState == 'True360'){
            if(this.true360AMOffer.Grade__c > this.true360PMOffer.Grade__c){
                this.bestOfferId = this.true360AMOffer.Id;
            } else {
                this.bestOfferId = this.true360PMOffer.Id;
            }
        } else if(this.currentState == 'SiriusXM'){
            if(this.siriusXMAMOffer.Grade__c > this.siriusXMPMOffer.Grade__c){
                this.bestOfferId = this.siriusXMAMOffer.Id;
            } else {
                this.bestOfferId = this.siriusXMPMOffer.Id;
            }
        }

        this.saveOffer(this.bestOfferId);
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
}