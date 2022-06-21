import { LightningElement, track, api, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getCountryOptions, getCountryProvinceMap, getAddressTypes} from 'c/acvUtilHelper';
import { refreshApex } from '@salesforce/apex';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import AssociatedLocation_OBJECT from '@salesforce/schema/AssociatedLocation';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import formFactorPropertyName from '@salesforce/client/formFactor'
// import TYPE_FIELD from '@salesforce/schema/AssociatedLocation.Type';
import SUBTYPE_FIELD from '@salesforce/schema/AssociatedLocation.Address_Subtype__c';
import AFTER_HOUR_DELIVERY_FIELD from '@salesforce/schema/AssociatedLocation.After_hour_deliveries_allowed__c';
import createAddress from '@salesforce/apex/AddAddressToAccountController.GenerateAddress';
import retrieveAddressList from '@salesforce/apex/AddAddressToAccountController.getAddressList';
import TIMEZONE_FIELD from '@salesforce/schema/AssociatedLocation.TimeZone__c';

import MONFRI_START_FIELD from '@salesforce/schema/AssociatedLocation.Monday_Friday_Start_Time__c';
import MONFRI_END_FIELD from '@salesforce/schema/AssociatedLocation.Monday_Friday_End_Time__c';
import SAT_START_FIELD from '@salesforce/schema/AssociatedLocation.Saturday_Start_Time__c';
import SAT_END_FIELD from '@salesforce/schema/AssociatedLocation.Saturday_End_Time__c';
import SUN_START_FIELD from '@salesforce/schema/AssociatedLocation.Sunday_Start_Time__c';
import SUN_END_FIELD from '@salesforce/schema/AssociatedLocation.Sunday_End_Time__c';

export default class AddAddressToAccount extends LightningElement {
    countryOptions;
    _country = 'US';
    stateMap;
    addressType;


    @track newAddress = {
        street: "",
        city: "",
        country: "",
        province: "",
        postalCode: ""
    };
    @track activeSpinner = false;
    @track selectedType;
    @track addressNotes;
    @track altName;
    @api recordId;

    @track checkAddressType = false;
    @track selectedMonFriStartTime;
    @track selectedMonFriEndTime;
    @track selectedSatStartTime;
    @track selectedSatEndTime;
    @track selectedSunStartTime;
    @track selectedSunEndTime;
    @track addresslist = [];
    @track addressSubTypeDisabled = false;
    @track afterHourDisabled = false;
    @track selectedContact;
    @track selectedSubType;
    @track selectedAfterHoursDelivery;
    @track showDeletePopup;
    @track showEditPopup;
    @track addressId;
    @track selectedTimeZone;

    @wire(getObjectInfo, {objectApiName: AssociatedLocation_OBJECT })
    associatedLocationInfo;

    @track addressSubType;
    @track addressSubOptions;

    @track afterHourDelivery;
    @track afterHourDeliveryOptions;
    
    @track mondayFridayStartTimeOptions;
    @track mondayFridayEndTimeOptions;
    @track saturdayStartTimeOptions;
    @track saturdayEndTimeOptions;
    @track sundayStartTimeOptions;
    @track sundayEndTimeOptions;
    @track timeZone;
    @track onMobile = false;

    // @wire(getPicklistValues, {recordTypeId: '$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    // typeFieldInfo({ data, error }) {
    //     if (data) this.addressType = data.values;
    // }
    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: SUBTYPE_FIELD })
    subTypeFieldInfo({ data, error }) {
        if (data) this.addressSubOptions = data; 
        
    }
    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: AFTER_HOUR_DELIVERY_FIELD })
    afterHoursDeliveryFieldInfo({ data, error }) {
        if (data) this.afterHourDeliveryOptions = data; 
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: TIMEZONE_FIELD })
    timeZoneFieldInfo({ data, error }) {
        if (data) this.timeZone = data.values; 
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: MONFRI_START_FIELD })
    monFriStartFieldInfo({ data, error }) {
        if (data) this.mondayFridayStartTimeOptions = data.values; 
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: MONFRI_END_FIELD })
    monFriEndFieldInfo({ data, error }) {
        if (data) this.mondayFridayEndTimeOptions = data.values;
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: SAT_START_FIELD })
    satStartFieldInfo({ data, error }) {
        if (data) this.saturdayStartTimeOptions = data.values;
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: SAT_END_FIELD })
    satEndFieldInfo({ data, error }) {
        if (data) this.saturdayEndTimeOptions = data.values;
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: SUN_START_FIELD })
    sunStartFieldInfo({ data, error }) {
        if (data) this.sundayStartTimeOptions = data.values;
    }

    @wire(getPicklistValues, {recordTypeId:'$associatedLocationInfo.data.defaultRecordTypeId', fieldApiName: SUN_END_FIELD })
    sunEndFieldInfo({ data, error }) {
        if (data) this.sundayEndTimeOptions = data.values;
    }

    connectedCallback() {
        if(formFactorPropertyName == 'Small'){
            this.onMobile = true;
        }
        this.countryOptions = getCountryOptions();
        this.stateMap = getCountryProvinceMap();
        this.addressType = getAddressTypes();
        this.getActiveAddresses();
        return refreshApex(this._wiredAddData);
    }

    getActiveAddresses() {
        retrieveAddressList({
            'accountId': this.recordId
        })
        .then(result => {
            console.log('got results');
            this.addresslist = result;
        })
        .catch(error => {
            console.log(error);
        });
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleSave() {
        this.activeSpinner = true;
        var validationPassed = this.validateInputs();

        if (validationPassed) {
            var addyWrap = this.generateApexStructure(this.newAddress, this.addressNotes, this.selectedType, this.altName, this.selectedSubType, this.selectedAfterHoursDelivery, this.selectedContact,this.selectedMonFriStartTime,this.selectedMonFriEndTime,this.selectedSatStartTime,this.selectedSatEndTime,this.selectedSunStartTime,this.selectedSunEndTime,this.selectedTimeZone);
            createAddress({
                inputAddy: addyWrap,
                accountId: this.recordId
            }).then(result => {
                this.refreshAddressData();
                this.notifyUser('Address Successfully Added', 'Address Successfully Added', 'success');
                this.closeQuickAction();
                this.activeSpinner = false;
            }).catch(error => {
                this.notifyUser('Address Error', error.body.message, 'error');
                this.activeSpinner = false;
            });
        } else {
            this.activeSpinner = false;
        }
    }

    generateApexStructure(addInput, noteInput, typeInput, altNameInput,subTypeInput, afterHourDeliveryInput, contactInput,monFriStartInput,monFriEndInput,satStartInput,satEndInput,sunStartInput,sunEndInput,timeZoneInput) {
        return JSON.stringify({
            street: addInput.street,
            city: addInput.city,
            state: addInput.province,
            postalCode: addInput.postalCode,
            country: addInput.country,
            type: typeInput,
            note: noteInput,
            altName: altNameInput,
            monfriStartTime: monFriStartInput,
            monfriEndTime: monFriEndInput,
            satStartTime: satStartInput,
            satEndTime: satEndInput,
            sunStartTime: sunStartInput,
            sunEndTime: sunEndInput,
            subType: subTypeInput,
            afterHourDelivery:afterHourDeliveryInput,
            primaryContact:contactInput,
            timeZone:timeZoneInput
        });
    }
    
    _wiredAddData;
    @wire(retrieveAddressList, {
        accountId: '$recordId'
    })
    addData(result) {
        this._wiredAddData = result;
        if (result.data) {
            this.addresslist = result.data;
        } else if (result.error) {
            this.error = result.error;
        }
    }

    get getStateOptions() {
        return this.stateMap[this._country];
    }

    get getCountryOptions() {
        return this.countryOptions;
    }

    handleNoteChange(event) {
        this.addressNotes = event.detail.value;
    }

    handleTypeChange(event) {
        let key = this.addressSubOptions.controllerValues[event.target.value];
        this.addressSubType = this.addressSubOptions.values.filter(opt => opt.validFor.includes(key));
        if(this.addressSubType == null || this.addressSubType.length === 0){
            this.addressSubTypeDisabled = true;
        }else{
            this.addressSubTypeDisabled = false;
        }

        let key1 = this.afterHourDeliveryOptions.controllerValues[event.target.value];
        this.afterHourDelivery = this.afterHourDeliveryOptions.values.filter(opt => opt.validFor.includes(key1));
        if(this.afterHourDelivery == null || this.afterHourDelivery.length === 0){
           this.afterHourDisabled = true;
        }else{
            this.afterHourDisabled = false;
        }

        this.selectedType = event.detail.value;
        if (this.selectedType == 'billing' || this.selectedType == 'delivery' || this.selectedType == 'pickup') {
            this.checkAddressType = true;
        } else {
            this.checkAddressType = false;
        }
    }

    handleAddressSubTypeChange(event){
        this.selectedSubType = event.target.value;

    }
    handleAfterHourDelivery(event){
        this.selectedAfterHoursDelivery = event.target.value;

    }
    
    handleTimeZone(event){
        this.selectedTimeZone = event.target.value;
    }
    

    handleContactSelection(event){
        this.selectedContact = event.target.value;
    }

    handleEdit(event) {
        this.addressId = event.currentTarget.dataset.id;
        this.showEditPopup = true
    }

    handleChildEdit(event) {
        this.showEditPopup = event.detail;     
        this.connectedCallback();
    }

    handleDelete(event){
        this.addressId = event.currentTarget.dataset.id;
        this.showDeletePopup = true;
    }

    handleChildCancel(event) {
        this.showDeletePopup = event.detail;
        this.connectedCallback();
        if(event.action=='delete'){
            this.closeQuickAction();
        }
    }

    refreshAddressData() {
        return refreshApex(this._wiredAddData);
    }
    
    changeOperatingHours(event) {
        switch (event.currentTarget.dataset.id) {
            case 'MonFriStartTime':
                this.selectedMonFriStartTime = event.target.value;
                break;
            case 'MonFriEndTime':
                this.selectedMonFriEndTime = event.target.value;
                break;

            case 'SaturdayStartTime':
                this.selectedSatStartTime = event.target.value;
                break;
            case 'SaturdayEndTime':
                this.selectedSatEndTime = event.target.value;
                break;

            case 'SundayStartTime':
                this.selectedSunStartTime = event.target.value;
                break;
            case 'SundayEndTime':
                this.selectedSunEndTime = event.target.value;
                break;
        }
    }

    handleAltNameChange(event) {
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
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({
                title,
                message,
                variant
            });
            this.dispatchEvent(toastEvent);
            this.activeSpinner = false;
        }
    }

    validateInputs() {        
        //Address Types
        if (!this.selectedType) {
            this.notifyUser('Missing Data', 'Address Type is required', 'warning');
            return false;
        }
        if(this.selectedType == 'billing') {
            this.selectedSubType = undefined;          
        }
        if(this.selectedType == 'legal' || this.selectedType == 'title_mailing' || this.selectedType == 'payment') {
            this.selectedSubType = undefined;
            this.selectedAfterHoursDelivery = undefined;      
        }
        if(this.selectedType == 'pickup') {
            this.selectedAfterHoursDelivery = undefined;             
        }
        if (!this.newAddress.country) {
            this.notifyUser('Missing Data', 'Country is required', 'warning');
            return false;
        }
        if (!this.newAddress.street) {
            this.notifyUser('Missing Data', 'Street is required', 'warning');
            return false;
        }
        if (!this.newAddress.city) {
            this.notifyUser('Missing Data', 'City is required', 'warning');
            return false;
        }
        if (!this.newAddress.province) {
            this.notifyUser('Missing Data', 'State is required', 'warning');
            return false;
        }
        if (!this.newAddress.postalCode) {
            this.notifyUser('Missing Data', 'Street is required', 'warning');
            return false;
        }

        //Validations for Operation hours         
        var operationHours = false;
      
        if(this.selectedType == 'billing' || this.selectedType == 'delivery' || this.selectedType == 'pickup') {    
            var monFriSelected = 0;
            var saturdaySelected = 0;
            var sundaySelected = 0;                    
            //Monday to Friday
            if((this.selectedMonFriStartTime && !this.selectedMonFriEndTime) || (!this.selectedMonFriStartTime && this.selectedMonFriEndTime)) {
                this.notifyUser('Missing Data', 'Monday-Friday: Start and End Time are required', 'warning');       
            } else if((this.selectedMonFriStartTime && this.selectedMonFriEndTime) && (this.selectedMonFriStartTime == this.selectedMonFriEndTime)) {
                this.notifyUser('', 'Monday-Friday: Start and End Time cannot be equals', 'warning');
            } else if((this.selectedMonFriStartTime && this.selectedMonFriEndTime) && this.selectedTimeZone == undefined) {
                this.notifyUser('Missing Data', 'Select a Time Zone', 'warning');
            } else if((this.selectedMonFriStartTime && this.selectedMonFriEndTime) && this.selectedTimeZone != undefined) {
                monFriSelected = 1;
            } else if((!this.selectedMonFriStartTime && !this.selectedMonFriEndTime) && this.selectedTimeZone == undefined) {
                monFriSelected = 1;
            } else if((!this.selectedMonFriStartTime && !this.selectedMonFriEndTime) && this.selectedTimeZone != undefined) {
                monFriSelected = 1;
            }

            //Saturday
            if((this.selectedSatStartTime && !this.selectedSatEndTime) || (!this.selectedSatStartTime && this.selectedSatEndTime)) {
                this.notifyUser('Missing Data', 'Saturday: Start and End Time are required', 'warning');
            } else if((this.selectedSatStartTime && this.selectedSatEndTime) && (this.selectedSatStartTime == this.selectedSatEndTime)) {
                this.notifyUser('', 'Saturday: Start and End Time cannot be equals', 'warning');
            } else if((this.selectedSatStartTime && this.selectedSatEndTime) && this.selectedTimeZone == undefined) {
                this.notifyUser('Missing Data', 'Select a Time Zone', 'warning');
            } else if((this.selectedSatStartTime && this.selectedSatEndTime) && this.selectedTimeZone != undefined) {
                saturdaySelected = 1;
            } else if((!this.selectedSatStartTime && !this.selectedSatEndTime) && this.selectedTimeZone == undefined) {
                saturdaySelected = 1;
            } else if((!this.selectedSatStartTime && !this.selectedSatEndTime) && this.selectedTimeZone != undefined) {
                saturdaySelected = 1;
            }

            //Sunday
            if((this.selectedSunStartTime && !this.selectedSunEndTime) || (!this.selectedSunStartTime && this.selectedSunEndTime)) {
                this.notifyUser('Missing Data', ' Sunday: Start and End Time are required', 'warning');
            } else if((this.selectedSunStartTime && this.selectedSunEndTime) && (this.selectedSunStartTime == this.selectedSunEndTime)) {
                this.notifyUser('', 'Sunday: Start and End Time cannot be equals', 'warning');
            } else if((this.selectedSunStartTime && this.selectedSunEndTime) && this.selectedTimeZone == undefined) {
                this.notifyUser('Missing Data', 'Select a Time Zone', 'warning');
            } else if((this.selectedSunStartTime && this.selectedSunEndTime) && this.selectedTimeZone != undefined) {
                sundaySelected = 1;
            } else if((!this.selectedSunStartTime && !this.selectedSunEndTime) && this.selectedTimeZone == undefined) {
                sundaySelected = 1;
            } else if((!this.selectedSunStartTime && !this.selectedSunEndTime) && this.selectedTimeZone != undefined) {
                sundaySelected = 1;
            }
            operationHours = monFriSelected == 1 && saturdaySelected == 1 && sundaySelected == 1;
        } else {
            this.selectedMonFriStartTime = undefined;
            this.selectedMonFriEndTime = undefined;
            this.selectedSatStartTime = undefined;
            this.selectedSatEndTime = undefined;
            this.selectedSunStartTime = undefined;
            this.selectedSunEndTime = undefined;
            this.selectedTimeZone = undefined;
            operationHours = true;
        }     
        return true && operationHours;
    }
}