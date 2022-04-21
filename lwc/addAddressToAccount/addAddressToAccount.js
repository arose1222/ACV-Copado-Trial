import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getCountryOptions, getCountryProvinceMap, getAddressTypes} from 'c/acvUtilHelper';
import createAddress from '@salesforce/apex/AddAddressToAccountController.GenerateAddress';

export default class AddAddressToAccount extends LightningElement {
    countryOptions;
    _country = 'US';
    stateMap;
    addressType;


    @track newAddress = {
        street:"",
        city:"",
        country:"",
        province:"",
        postalCode:""
    };
    @track activeSpinner = false;
    @track selectedType;
    @track addressNotes;
    @track altName;
    @api recordId;


    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleSave(){
        this.activeSpinner = true;
        var validationPassed = this.validateInputs();
        if(validationPassed){
            var addyWrap = this.generateApexStructure(this.newAddress, this.addressNotes, this.selectedType, this.altName);
            createAddress({inputAddy:addyWrap, accountId: this.recordId}).then( result => {
                this.notifyUser('Address Successfully Added', 'Address Successfully Added','success');
                this.closeQuickAction();
                this.activeSpinner = false;
            }).catch(error => {
                console.log(error);
                console.log(error.message);
                this.notifyUser('Address Error', error.body.message ,'error');
                this.activeSpinner = false;
            });
            
        }
        //this.activeSpinner = false;
    }

    generateApexStructure(addInput, noteInput, typeInput, altNameInput){
        return JSON.stringify({
            street : addInput.street,
            city : addInput.city,
            state : addInput.province,
            postalCode : addInput.postalCode,
            country : addInput.country,
            type : typeInput,
            note : noteInput,
            altName : altNameInput
        });
    }

    connectedCallback(){
        this.countryOptions = getCountryOptions();
        this.stateMap = getCountryProvinceMap();
        this.addressType = getAddressTypes();
    }


    get getStateOptions() {
        return this.stateMap[this._country];
    }

    get getCountryOptions() {
        return this.countryOptions;
    }

    handleNoteChange(event){
        this.addressNotes = event.detail.value;
    }
    handleTypeChange(event){
        this.selectedType = event.detail.value;
    }
    handleAltNameChange(event){
        this.altName = event.detail.value;
    }

    handleAddressChange(event) {
        this._country = event.detail.country;
        this.newAddress.street = event.detail.street;
        this.newAddress.city = event.detail.city;
        this.newAddress.province = event.detail.province;
        this.newAddress.country = event.detail.country;
        this.newAddress.postalCode = event.detail.postalCode;
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts){
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

    validateInputs(){
        if(!this.selectedType){
            this.notifyUser('Missing Data', 'Address Type is required','warning');
            return false;
        }
        if(!this.newAddress.country){
            this.notifyUser('Missing Data', 'Country is required','warning');
            return false;
        }
        if(!this.newAddress.street){
            this.notifyUser('Missing Data', 'Street is required','warning');
            return false;
        }
        if(!this.newAddress.city){
            this.notifyUser('Missing Data', 'City is required','warning');
            return false;
        }
        if(!this.newAddress.province){
            this.notifyUser('Missing Data', 'State is required','warning');
            return false;
        }
        if(!this.newAddress.postalCode){
            this.notifyUser('Missing Data', 'Street is required','warning');
            return false;
        }
        return true;
    }

}