/**
 * @description A component to generate EasyPost tracking number and postage labels on Case & Quality Control objects.
 * 
 *
 * @name EasyPost
 * @author Manmeet Vaseer
 * @date 07/20/2021
 * 
 */
import { LightningElement, api, track, wire } from "lwc";
import { getRecordNotifyChange  } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAddresses from '@salesforce/apex/EasyPostController.getAddresses';
import generateShippingLabels from '@salesforce/apex/EasyPostController.generateShippingLabels';
import saveShippingLabels from '@salesforce/apex/EasyPostController.saveShippingLabels';

import {createSplunkLog} from 'c/acvUtilHelper';

export default class EasyPost extends LightningElement {
    /* error handling */
    @track error;
    @track showError = false;

    /* Spinner on Submit button */
    @track isSpinner = false;

    /* parameters to fetch various addresses - used during component configuration */
    @api recordId;
    @api isQualityControl = false;
    @api isRetrieveBuyerAddress = false;
    @api isRetrieveSellerAddress = false;
    @api isRetrieveBuyerFloorPlanAddress = false;

    /* parameters used in ui/html to display info */
    @track selectedAddress = '';
    @track addressOptions = [];
    @track notes = { legalNotes: '', pickupNotes: '', dealershipNotes: '', titleMailingAddressNotes: '' };
    @track address = { name: '', company: '', street: '', street2: '', city: '', state: '', country: '', zip: '', email: '' };

    /* misc variables to suppurt the workflow */
    shipToName = null; // the Name used to generate the shipping label
    //contactEmail = null; // buyer/floorplan email to send Return Adress Postage Label
    shipToAddress = { name: '', company: '', street: '', street2: '', city: '', state: '', country: '', zip: '', email: '' }; // the Address used to generate the shipping label
    submitButtonVisible = true; // Enable/disable the Submit button based on Tracking Code value.
    selectedLabel = null; // Label of the address selected by the user from the combobox.

    /* Fetch all the addresses (billing, legal, & title) for buyer &/or seller accounts.

       Sample Message:

        {
            "trackingCode":null,
            "addressOptions":[
                {
                    "value":{
                        "notes":{
                            "titleMailingAddressNotes":"seller title mailing address note....",
                            "pickupNotes":"my seller pickup notes....",
                            "legalNotes":"my seller legal addres note....",
                            "dealershipNotes":"my seller dealership notes...."
                        },
                        "miscInfo":{
                            "caseNumber":"03049735"
                        },
                        "address":{
                            "zip":"14228",
                            "street":"12 Test St",
                            "state":"NY",
                            "name":"Account Bulk#A (Seller)",
                            "country":"US",
                            "city":"Buffalo",
                            "email": ''
                        }
                    },
                    "label":"Seller Billing Address"
                }
            ]
        }
    */
    @wire(getAddresses, {
        recordId: '$recordId',
        isQualityControl: '$isQualityControl',
        isRetrieveBuyerAddress: '$isRetrieveBuyerAddress',
        isRetrieveSellerAddress: '$isRetrieveSellerAddress',
        isRetrieveBuyerFloorPlanAddress: '$isRetrieveBuyerFloorPlanAddress'
    })
    wiredAddresses({ error, data }) {
        var options = [];
        if (data) {
            var dataObj = JSON.parse(data);

            // Disable the Submit button if tracking code field is already populated.
            //if(dataObj.trackingCode) this.submitButtonVisible = false; // For now the User does not want to disable the Submit button.

            // Setup address picklist based on the address info fetched
            var addrOptions = dataObj.addressOptions
            for (var f = 0; addrOptions && f < addrOptions.length; f++) {
                var obj = addrOptions[f];
                if(!obj.value.address.company) obj.value.address.company = '';

                options.push({
                    value: JSON.stringify(obj.value),
                    label: obj.label,
                    description: obj.value.address.company + ' (' + obj.value.address.city + ', ' + obj.value.address.state + ', ' + obj.value.address.zip + ')'
                });
            }

            this.addressOptions = options;
        } else if (error) {
            this.showError = true;
            this.error = JSON.stringify(error);
            console.log('> > > > > Error: ' + this.error);
            this.showToastError('Unable to load Addresses: ' + error.body.message + ', **STACK TRACE**: ' + error.body.stackTrace);
        }
    }

    /* Enable/disable the Submit button. */
    get hideSubmitButton() {
        return !this.submitButtonVisible;
    }

    /* Concatenate and return Address Street1 & Street2. */
    get bothAddressStreets() {
        var streets = '';
        if(this.address) streets = this.address.street;
        if(this.address && this.address.street2) streets = streets + '\n' + this.address.street2;

        return streets;
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

    /* Once an address is selected from the Picklist, set all the supporting variables. */
    onSelectedAddress(event) {
        var valObj = JSON.parse(event.detail.value); // get the selected address
        this.notes = valObj.notes; // set Notes
        this.address = valObj.address; // set ship address
        this.shipToAddress = this.address; // set ship address (to be used to generate shippint label). 
        this.shipToName = this.address.name; // set shipping Account Name (to be used to generate shipping label)
        //this.contactEmail = this.address.email; // set dealership/floorplan email to send Return Addressed Postage Label
        this.selectedLabel = event.target.options.find(opt => opt.value === event.detail.value).label; // find and store the Label associated with the selected value.
    }

    /* Update the shipping Account Name. */
    onNameUpdate(event) {
        this.shipToName = event.target.value;
        this.shipToAddress.name = this.shipToName;
    }

    /* Called when a user manually change the ship address. */
    onAddressUpdate(event) {
        this.shipToAddress = { name: this.shipToName, company: this.address.company, street: event.target.street, street2: '', city: event.target.city, state: event.target.province, country: event.target.country, zip: event.target.postalCode, email: this.address.email };
        this.address = this.shipToAddress;
        this.selectedAddress = null; // unselect the previous address so that we can again select address from the Picklist to overwrite the user changes.
    }

    /* Called when the Clear button is pressed. The will reset all the values. */
    onClearAddress() {
        this.shipToName = null;
        //this.contactEmail = null;
        this.shipToAddress = { name: '', company: '', street: '', street2: '', city: '', state: '', country: '', zip: '', email: '' };
        this.address = { name: '', company: '', street: '', street2: '', city: '', state: '', country: '', zip: '', email: '' };
        this.notes = { legalNotes: '', pickupNotes: '', dealershipNotes: '', titleMailingAddressNotes: '' };
        this.selectedAddress = null;
    }

    /* Called when the Submit button is pressed to generate the shipping labels. */
    onSubmitToEasyPost() {
        this.isSpinner = true;
        this.generateShippingLabel();
    }

    /* 
        Generate Shipping Lables.

        Sample message passed in:

        {
            "zip":"14228",
            "street":"12 Test St",
            "state":"NY",
            "name":"Account Bulk#A (Seller)",
            "country":"US",
            "city":"Buffalo"
        }
    */
    async generateShippingLabel() {
        try {
            console.log('--- INFO --- Generate Shipping Tracking Info for this Address: ' + JSON.stringify(this.shipToAddress));
            let shippingLabels = await generateShippingLabels({ jsonAddress: JSON.stringify(this.shipToAddress), needReturnAddressPostageLabel: this.isQualityControl,
                isQualityControl: this.isQualityControl, recordId: this.recordId, namePrefix: 'Title Specialist: '});
            console.log('--- INFO --- Shipping Labels generated by Easy Post API: ' + shippingLabels);

            this.generateSplunkLog('Shipping Address used: ' + JSON.stringify(this.shipToAddress) + '\n Shipping Labels generated: ' + shippingLabels);

            try {
                let shippingLabelList = JSON.parse(shippingLabels);
                if(shippingLabelList.length > 0 && shippingLabelList[0].trackingCode) this.persistShippingLabels(shippingLabels);
                else throw shippingLabels;
            }
            catch(e) {
                throw shippingLabels;
            }
        } catch (error) {
            this.showError = true;
            if(String(error).includes("SyntaxError")) {
                this.showToastError('Unable to generate shipping label: ' + error);
            }
            else {
                this.error = JSON.stringify(error);
            
                console.log('> > > > > Error (generateShippingLabel): ' + this.error); 
                this.generateSplunkLog('> > > > > Error (generateShippingLabel): ' + this.error);

                if(error && error.body && error.body.message) this.showToastError('Unable to generate shipping label: ' + error.body.message);
                else this.showToastError('Unable to generate shipping label: ' + this.error);
            }
        }
        finally {
            this.isSpinner = false;
        }
    }

    /*
        Save Shipping Tracking number and Postate Label in Case or Quality Control object.
        
        The first JSON record has tracking info for 'Ship To' address.
        The 2nd JSON record has tracking info for 'Return To ACV' address.

        Sample messaged passed:

        [
            {
                "trackingCode":"281659026431",
                "link":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/e6730fd4062b45d3acb53d648d3f24d0.png",
                "label_zpl_url":"null"
            },
            {
                "trackingCode":"281659029967",
                "link":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/540c3cf8f1e547e493c60e190420f058.png",
                "label_zpl_url":"null"
            }
        ]
    */
    persistShippingLabels(shippingLabels) {
        saveShippingLabels({ recordId: this.recordId, jsonShippingLabels: shippingLabels, isQualityControl: this.isQualityControl, 
            buyerSellerIndicator: this.selectedLabel, contactEmail: this.shipToAddress.email, contactName: this.shipToAddress.name })
            .then(result => {
                if (result) {
                    // Notify LDS that you've changed the record outside its mechanisms.
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    this.showToastSuccess('Shipping Label is Created Successfully.');
                }
            })
            .catch(error => {
                this.showError = true;
                this.error = JSON.stringify(error);

                console.log('> > > > > Error (persistShippingLabels): ' + this.error); 
                this.generateSplunkLog('> > > > > Error (persistShippingLabels): ' + this.error);

                if(error.body.message) this.showToastError('Unable to persist shipping label: ' + error.body.message);
                else this.showToastError('Unable to persist shipping label: ' + this.error);
            })
    }

    generateSplunkLog(message) {
        createSplunkLog('ERROR', message, 'easyPost.js', ['TITLES'], this.recordId, 'Case, Quality Control');
    }

}