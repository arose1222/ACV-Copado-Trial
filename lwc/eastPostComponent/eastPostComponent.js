import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

//all the fields we need, probably a better way to do this
import USER_ID from '@salesforce/user/Id';
import USER_PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

import ACCBILLINGSTREET from '@salesforce/schema/Case.Account.BillingStreet';
import ACCBILLINGCOUNTRY from '@salesforce/schema/Case.Account.BillingCountry';
import ACCBILLINGCITY from '@salesforce/schema/Case.Account.BillingCity';
import ACCBILLINGSTATE from '@salesforce/schema/Case.Account.BillingState';
import ACCBILLINGPOSTCODE from '@salesforce/schema/Case.Account.BillingPostalCode';
import ACCLEGALSTREET from '@salesforce/schema/Case.Account.Legal_Street__c';
import ACCLEGALCOUNTRY from '@salesforce/schema/Case.Account.Legal_Country__c';
import ACCLEGALGCITY from '@salesforce/schema/Case.Account.Legal_City__c';
import ACCLEGALSTATE from '@salesforce/schema/Case.Account.Legal_State__c';
import ACCLEGALPOSTCODE from '@salesforce/schema/Case.Account.Legal_Zip_Code__c';
import ACCLEGALNOTE from '@salesforce/schema/Case.Account.Legal_Address_Note__c';
import ACCPICKUPNOTE from '@salesforce/schema/Case.Account.Pickup_Notes__c';
import ACCDEALERSHIPNOTE from '@salesforce/schema/Case.Account.Dealership_Notes__c'
import CaseId from '@salesforce/schema/Case.Id';
import trackingNumber from '@salesforce/schema/Case.Easypost_Tracker__c';
import labelURL from '@salesforce/schema/Case.Easypost_PostageLabel_Label_URL__c';
import accountName from '@salesforce/schema/Case.Account.Name';
import sellerName from '@salesforce/schema/Case.Seller_Dealership__r.Name';
import caseStatus from '@salesforce/schema/Case.Status';
import caseUpdateStatus from '@salesforce/schema/Case.Update_Status__c';

//Adding new fields to account for Titles Addresses
import TITLENOTE from '@salesforce/schema/Case.Account.Title_Mailing_Address_Note__c';
import TITLECITY from '@salesforce/schema/Case.Account.Title_Mailing_City__c';
import TITLECOUNTRY from '@salesforce/schema/Case.Account.Title_Mailing_Country__c';
import TITLESTATE from '@salesforce/schema/Case.Account.Title_Mailing_State__c';
import TITLESTREET from '@salesforce/schema/Case.Account.Title_Mailing_Street__c';
import TITLEZIP from '@salesforce/schema/Case.Account.Title_Mailing_Zip_Code__c';

import TITLENOTESELLER from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_Address_Note__c';
import TITLECITYSELLER from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_City__c';
//import TITLECOUNTRYSELLER  from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_Country__c';
import TITLESTATESELLER from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_State__c';
import TITLESTREETSELLER from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_Street__c';
import TITLEZIPSELLER from '@salesforce/schema/Case.Seller_Dealership__r.Title_Mailing_Zip_Code__c';


const fieldList = [
    'Case.Easypost_Parcel_Predefined_Package__c',
    'Case.Easypost_Parcel_Weight__c',
    'Case.Buyer_Name__c',
    'Case.ContactPhone',
    'Case.EasyPost_Shipping_Service__c',
    ACCBILLINGSTREET,
    ACCBILLINGCITY,
    ACCBILLINGSTATE,
    ACCBILLINGCOUNTRY,
    ACCBILLINGPOSTCODE,
    ACCLEGALSTREET,
    ACCLEGALCOUNTRY,
    ACCLEGALGCITY,
    ACCLEGALSTATE,
    ACCLEGALPOSTCODE,
    ACCLEGALNOTE,
    ACCPICKUPNOTE,
    ACCDEALERSHIPNOTE,
    TITLENOTE,
    TITLECITY,
    TITLECOUNTRY,
    TITLESTATE,
    TITLESTREET,
    TITLEZIP,
    CaseId,
    trackingNumber,
    labelURL,
    accountName,
    sellerName,
    caseStatus,
    caseUpdateStatus,    
    TITLENOTESELLER,
    TITLECITYSELLER,
    TITLESTATESELLER,
    TITLESTREETSELLER,
    TITLEZIPSELLER
];

const USER_PROFILE_NAMES = ["Titles", "Title Manager"];

//get Apex clases we need
import generateShipping from '@salesforce/apex/EasyPostComponentController.GenerateShipping';

export default class EasyPostComponent extends LightningElement {

    @api recordId;
    @wire(getRecord,{recordId:'$recordId', fields:fieldList})Case;
    @track selectedAddress;
    @track loaded = true;
    @track address = {name:'', street:'',city:'',state:'',country:'',zip:''};
    @track error = false;
    @track shippingResponse = {trackingCode : '',link : ''};
    @track showscreen1 = true;
    test = [];

    @track isThisTitlesUser = false;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_PROFILE_NAME_FIELD]
    }) 
    wiredUser({
        error,
        data
    }) {
        if (error) {
            this.showEasyPostError(error);
        } else if (data) {
            this.isThisTitlesUser = USER_PROFILE_NAMES.includes(data.fields.Profile.displayValue);
        }
    }    

   get pickupNote(){return getFieldValue(this.Case.data, ACCPICKUPNOTE);}
   get legalNote(){return getFieldValue(this.Case.data, ACCLEGALNOTE);}
   get dealershipNote(){return getFieldValue(this.Case.data, ACCDEALERSHIPNOTE);}
   get titleNote(){return getFieldValue(this.Case.data, TITLENOTE);}
   get titleNoteseller(){return getFieldValue(this.Case.data, TITLENOTESELLER);}
    get options(){
    return [
        {label:'Title Address - '+ getFieldValue(this.Case.data, TITLESTREET), value:'title'},
        {label:'Billing Address - '+ getFieldValue(this.Case.data, ACCBILLINGSTREET), value:'billing'},
        {label : 'Legal Address - '+ getFieldValue(this.Case.data, ACCLEGALSTREET), value: 'legal'},
        {label : 'Seller Title Mailing Address - '+ getFieldValue(this.Case.data, TITLESTREETSELLER), value: 'seller'},
        {label : 'Other', value : 'other'}];
    }

     generateSelectedAddress(event) {
        console.log('detail value::',event.detail.value);
         console.log('target value::',event.target.value);
        if(event.detail.value === 'title'){
            this.selectedAddress = 'title';
            this.address = {
                name : getFieldValue(this.Case.data, accountName),
                street: getFieldValue(this.Case.data, TITLESTREET),
                city : getFieldValue(this.Case.data, TITLECITY),
                state : getFieldValue(this.Case.data, TITLESTATE),
                country : 'US',//getFieldValue(this.Case.data, ACCBILLINGCOUNTRY),
                zip : getFieldValue(this.Case.data, TITLEZIP)
            };
         }
         else if(event.detail.value === 'seller'){
           this.selectedAddress = 'seller';
            this.address = {
                name : getFieldValue(this.Case.data, sellerName),
                street: getFieldValue(this.Case.data, TITLESTREETSELLER),
                city : getFieldValue(this.Case.data, TITLECITYSELLER),
                state : getFieldValue(this.Case.data, TITLESTATESELLER),
                country : 'US',//getFieldValue(this.Case.data, ACCBILLINGCOUNTRY),
                zip : getFieldValue(this.Case.data, TITLEZIPSELLER)
            };
         }
         else if(event.detail.value === 'billing'){
            this.selectedAddress = 'billing';
            this.address = {
                name : getFieldValue(this.Case.data, accountName),
                street: getFieldValue(this.Case.data, ACCBILLINGSTREET),
                city : getFieldValue(this.Case.data, ACCBILLINGCITY),
                state : getFieldValue(this.Case.data, ACCBILLINGSTATE),
                country : 'US',//getFieldValue(this.Case.data, ACCBILLINGCOUNTRY),
                zip : getFieldValue(this.Case.data, ACCBILLINGPOSTCODE)
            };
         }
         else if (event.detail.value === 'legal'){
             this.selectedAddress = 'legal';
             this.address = {
                name : getFieldValue(this.Case.data, accountName),
                street: getFieldValue(this.Case.data, ACCLEGALSTREET),
                city : getFieldValue(this.Case.data, ACCLEGALGCITY),
                state : getFieldValue(this.Case.data, ACCLEGALSTATE),
                country : 'US',//getFieldValue(this.Case.data, ACCLEGALCOUNTRY),
                zip : getFieldValue(this.Case.data, ACCLEGALPOSTCODE)
            };
         }
         else{
            this.selectedAddress = 'other';
            this.address = {
                name : getFieldValue(this.Case.data, accountName),
                street : '',
                city : '',
                state : '',
                country : 'US',
                zip : ''
            };
         }
    }

    clearAddress(){
        this.selectedAddress = 'other';
        this.address = {
            name : 'Other',
            street : '',
            city : '',
            state : '',
            country : 'US',
            zip : ''
        };
    }

    onNameUpdate(evt){
        this.address.name = evt.detail.value;
    }

    onAddressUpdate(evt){
        if(evt.target.street){
            this.address.street = evt.target.street;
        }
        if(evt.target.city){
            this.address.city = evt.target.city;
        }
        if(evt.target.province){
            this.address.state = evt.target.province;
        }
        if(evt.target.country){
            this.address.country = evt.target.country;
        }
        if(evt.target.postalCode){
            this.address.zip = evt.target.postalCode;
        }
    }

    showEasyPostError(msg){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error getting EasyPost label',
                message: msg,
                //message: 'Unable to get EasyPost label, please use FedEx',
                variant: 'error'
            })
        );
    }

    submitToEasyPost(){
        var tn;
        var li;
        this.loaded = false;
        if(this.Case.data){
            tn = getFieldValue(this.Case.data, trackingNumber);
            li = getFieldValue(this.Case.data, labelURL);
            if(tn){
                this.shippingResponse.trackingCode = tn;
                this.shippingResponse.link = li;
                this.showscreen1 = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error getting EasyPost label',
                        message: 'Easy Post Label Already Generated',
                        variant: 'error'
                    })
                );
            }
            else{
                generateShipping({jsonAddress : JSON.stringify(this.address)}).then((result) =>{
                    if(result){        
                        try{
                          this.shippingResponse = JSON.parse(result);
                            if ( !this.shippingResponse.trackingCode ) {
                                this.showEasyPostError(result);
                                this.showscreen1 = false;
                                this.loaded = true;
                                this.error = true;
                                return;
                            }
                        }      
                        catch(e){
                            this.showEasyPostError(result);
                            this.showscreen1 = false;
                            this.loaded = true;
                            this.error = true;
                            return;
                        }
                        //very important to have the const be called fields, the updateRecord method has this hard coded as a proerty of the input
                        const fields = {};
                        fields[CaseId.fieldApiName] = getFieldValue(this.Case.data, CaseId);
                        fields[trackingNumber.fieldApiName] = this.shippingResponse.trackingCode;
                        fields[labelURL.fieldApiName] = this.shippingResponse.link;
                        if(this.isThisTitlesUser)    {
                            fields[caseUpdateStatus.fieldApiName] = 'Sent';
                        }
                        else {
                            fields[caseStatus.fieldApiName] = 'Sent';
                        }
                        const recordUpdate = {fields};
                        updateRecord(recordUpdate).then(()=>{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Tracking Information Captured',
                                    variant: 'success'
                                })
    
                            );
                            this.loaded = true;
                            this.showscreen1 = false;
                            this.error = false;
                            
                            // Display fresh data in the form
                            return refreshApex(this.Case);
                        }).catch(error => {
                            var errorMessage = "";
                            // UI API read operations return an array of objects
                            if (Array.isArray(error.body)) {
                                errorMessage = 'Errors while updating: ' + error.body.map(e => e.message).join(', ');
                                console.log(errorMessage);
                            } 
                            // UI API write operations, Apex read and write operations 
                            // and network errors return a single object
                            else if (typeof error.body.message === 'string') {
                                errorMessage = 'Error while updating: ' + error.body.message;
                                console.log(errorMessage);
                            }                            

                            this.showEasyPostError(result + '->' + errorMessage);
                            this.loaded = true;
                            this.showscreen1 = false;
                            this.error = true;
                        });
    
                    }
                    else{
                        this.showEasyPostError('No Result');
                        this.showscreen1 = false;
                        this.loaded = true;
                        this.error = true;
                    }
                }).catch(Error =>{
                    this.showEasyPostError(Error.name);
                    this.loaded = true;
                    this.showscreen1 = false;
                    this.error = true;
                });
            }
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Submitting EasyPost label',
                    message: 'Please Reload the page and try again, if this error persists contact your system administrator',
                    variant: 'error'
                })
            );
            this.loaded = true;
        }
       
        
    }
}