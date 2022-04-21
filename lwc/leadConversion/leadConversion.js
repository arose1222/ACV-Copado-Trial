import { LightningElement, api, track, wire } from 'lwc';
import { fireToast } from 'c/acvUtilHelper';
import { NavigationMixin } from 'lightning/navigation';
import {CloseActionScreenEvent} from 'lightning/actions';
import {getCountryOptions, getCountryProvinceMap} from 'c/acvUtilHelper';
import FORM_FACTOR from '@salesforce/client/formFactor'
import updateAddAndConvertLead from '@salesforce/apex/LeadConversion.updateAddAndConvertLead';
import getLeadAddress from '@salesforce/apex/LeadConversion.getLeadAddress';

export default class LeadConversion extends NavigationMixin(LightningElement) {
    isProcessing = false;
    disableConvert= true;
    @api recordId;
    @track countryOptions;
    _country = 'US';
    @track stateMap;
    hasRendered = false;
    @track newAddress = {
        street:"",
        city:"",
        country:"",
        state:"",
        postalCode:""
    };
    isModalOpen = false;
    showMobileButton = false;
    connectedCallback(){
        if( FORM_FACTOR != 'Large' ){
            this.showMobileButton = true;
        }else{
            this.isModalOpen = true;
        }
        this.countryOptions = getCountryOptions();
        this.stateMap = getCountryProvinceMap();
    }
    handleConvertLeadClick( event ){
        if( event.detail.openSections.length === 0 ){
            this.isModalOpen = false;
        }else{
            this.isModalOpen = true;
        }
    }
    renderedCallback(){
        if(this.recordId != undefined && this.recordId != null && this.hasRendered == false){
            this.getAddress();
            this.hasRendered = true;
        }
    }

    getAddress(){
        getLeadAddress({
            'recordId': this.recordId
        })
        .then( result => {
            if(result != null && result != undefined){
                this.newAddress.street = result.street;
                this.newAddress.city = result.city;
                this.newAddress.country = (result.country == null || result.country == undefined || result.country == '')  ? 'US' :  result.country; 
                this._country = result.country;
                this.newAddress.state = result.state;
                this.newAddress.postalCode = result.postalCode;
            }
        })
        .catch(error =>{
            fireToast( 'Error Occured', error.body.message, 'error', "sticky" );
        })
    }

    updateAddAndConvertLead() {
        this.isProcessing = true;
        this.disableConvert= true;
        updateAddAndConvertLead({
            'recordId': this.recordId,
            'addWrapper':this.newAddress
        })
        .then(result => {
            if(result.hasError)
            {
                fireToast('Lead Conversion Failed!', result.message, 'error');
            }
            else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId:result.accountId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                });
                fireToast( 'Success!!', 'Lead Converted Successfully!!', 'success', "dismissable" );
            }                   
        })
        .catch(error => {
            fireToast( 'Error Occured', error.body.message, 'error', "dismissable" );
        }).finally(()=>{
            this.isProcessing = false;
            this.disableConvert = false;
            this.closeModal();
        });
    }

    closeModal(){
        if( FORM_FACTOR != 'Large' ){
            this.isModalOpen = false;
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    handleAddressChange(event) {
        this.disableConvert= true;
        this._country = ( event.detail.country == null ||  event.detail.country == undefined ||  event.detail.country == '')  ? 'US' :   event.detail.country.trim(); 
        this.newAddress.street = event.detail.street.trim();
        this.newAddress.city = event.detail.city.trim();
        this.newAddress.state = event.detail.province.trim();
        this.newAddress.country = this._country.trim();
        this.newAddress.postalCode = event.detail.postalCode.trim();
        if( this.newAddress.street!=null && this.newAddress.street!=undefined &&  this.newAddress.street.trim()!='' &&
        this.newAddress.city!=null && this.newAddress.city!=undefined &&  this.newAddress.city.trim()!='' &&
        this.newAddress.state!=null && this.newAddress.state!=undefined &&  this.newAddress.state.trim()!='' &&
        this.newAddress.country!=null && this.newAddress.country!=undefined &&  this.newAddress.country.trim()!='' &&
        this.newAddress.postalCode!=null && this.newAddress.postalCode!=undefined &&  this.newAddress.postalCode.trim()!='')
        {
            this.disableConvert= false;
        }
    }

    get getStateOptions() {
        return this.stateMap[this._country];
    }

    get getCountryOptions() {
        return this.countryOptions;
    }

}