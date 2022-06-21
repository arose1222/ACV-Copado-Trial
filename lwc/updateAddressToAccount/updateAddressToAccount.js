import { LightningElement,track, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import updateAddress from '@salesforce/apex/AddAddressToAccountController.updateAddress';
import retrieveCurrentAddress from '@salesforce/apex/AddAddressToAccountController.retrieveCurrentAddress';
import retrieveAddressList from '@salesforce/apex/AddAddressToAccountController.getAddressList';
import AssociatedLocation_OBJECT from '@salesforce/schema/AssociatedLocation';
import TIMEZONE_FIELD from '@salesforce/schema/AssociatedLocation.TimeZone__c';
import MONFRI_START_FIELD from '@salesforce/schema/AssociatedLocation.Monday_Friday_Start_Time__c';
import MONFRI_END_FIELD from '@salesforce/schema/AssociatedLocation.Monday_Friday_End_Time__c';
import SAT_START_FIELD from '@salesforce/schema/AssociatedLocation.Saturday_Start_Time__c';
import SAT_END_FIELD from '@salesforce/schema/AssociatedLocation.Saturday_End_Time__c';
import SUN_START_FIELD from '@salesforce/schema/AssociatedLocation.Sunday_Start_Time__c';
import SUN_END_FIELD from '@salesforce/schema/AssociatedLocation.Sunday_End_Time__c';

export default class UpdateAddressToAccount extends NavigationMixin(LightningElement) {

    @api recordid;
    @api addressid;
    
    @track cancel;
    @track addressAlternate;
    @track addressNotes;
    @track disabledButton = false;
    @track activeSpinner = false;
    @track isOperatingHours = false;

    @track addressType;

    @track selectedTimeZone;
    @track selectedMonFriStartTime;
    @track selectedMonFriEndTime;
    @track selectedSatStartTime;
    @track selectedSatEndTime;
    @track selectedSunStartTime;
    @track selectedSunEndTime;
    
    @track afterHourDelivery;
    @track mondayFridayStartTimeOptions;
    @track mondayFridayEndTimeOptions;
    @track saturdayStartTimeOptions;
    @track saturdayEndTimeOptions;
    @track sundayStartTimeOptions;
    @track sundayEndTimeOptions;
    @track timeZone;

    //Operationg hours
    @wire(getObjectInfo, {objectApiName: AssociatedLocation_OBJECT })
    associatedLocationInfo;

    //Alternate/Notes Fields
    alternateChange(event) {this.addressAlternate= event.target.value;}
    addressNotesChange(event) {this.addressNotes= event.target.value;}

    //Time Zone
    handleTimeZone(event) {this.selectedTimeZone = event.target.value;}

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

    connectedCallback() {
        this.activeSpinner = true;    
        retrieveCurrentAddress({ 'accountId': this.recordid, 'addressId': this.addressid })    
            .then(result => {        
                result.forEach(addr => {
                    this.addressType = addr.Type;
                    this.addressAlternate = addr.Alternate_Address_Name__c;
                    this.addressNotes = addr.Notes__c;

                    if(this.addressType == 'billing' || this.addressType == 'delivery' || this.addressType == 'pickup') {                        
                        this.isOperatingHours = true;
                        this.selectedTimeZone = addr.TimeZone__c;
                        this.selectedMonFriStartTime = addr.Monday_Friday_Start_Time__c;
                        this.selectedMonFriEndTime = addr.Monday_Friday_End_Time__c;
                        this.selectedSatStartTime = addr.Saturday_Start_Time__c;
                        this.selectedSatEndTime = addr.Saturday_End_Time__c;
                        this.selectedSunStartTime = addr.Sunday_Start_Time__c;
                        this.selectedSunEndTime = addr.Sunday_End_Time__c;
                    }            
                });
                this.activeSpinner = false;    
            })
            .catch(error => {
                this.activeSpinner = false;    
                this.notifyUser('', error, 'error');
            });
    }

    //Save button
    handleUpdateAddress() {        
            this.disabledButton = true;
            this.activeSpinner = true;
        if(this.validateDates()) {
            updateAddress({ 'accountId': this.recordid, 'addressId': this.addressid, 
                            'addressAlternate': this.addressAlternate, 'addressNotes': this.addressNotes,
                            'timeZone': this.selectedTimeZone,
                            'monFriStartTime': this.selectedMonFriStartTime, 'monFriEndTime': this.selectedMonFriEndTime,
                            'satStartTime': this.selectedSatStartTime, 'satEndTime': this.selectedSatEndTime,
                            'sunStartTime': this.selectedSunStartTime, 'sunEndTime': this.selectedSunEndTime })    
            .then(result => {    
                    this.notifyUser('', 'Success! Address updated Successfully', 'success');
                    this.handleCloseModal();                               
            })
            .catch(error => {
                this.notifyUser('', 'The update failed, please try again or contact a Salesforce Administrator', 'error');
                this.handleCloseModal();   
            });
        } else {
            this.disabledButton = false;
            this.activeSpinner = false;
        }
    }

    handleCloseModal() {        
        this.disabledButton = false;
        this.activeSpinner = false;
        this.cancel = false;
        let event = new CustomEvent('update', { detail: this.cancel });
        this.dispatchEvent(event);    
    }
    
    validateDates() {
        var operationHours = true;
        if(this.addressType == 'billing' || this.addressType == 'delivery' || this.addressType == 'pickup') {                        
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
        }  
        return operationHours;
    }
    
    notifyUser(title, message, variant) {
         const toastEvent = new ShowToastEvent({
            title, message, variant
        });
        this.dispatchEvent(toastEvent);
    }
}