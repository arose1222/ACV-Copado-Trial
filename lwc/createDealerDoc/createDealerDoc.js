import { LightningElement, track, api, wire } from 'lwc';
import apexSearch from '@salesforce/apex/CreateDealerDocHandler.getLookupInfo';
import isProd from '@salesforce/apex/ACVUtility.isProd';
import getLicenseNumber from '@salesforce/apex/CreateDealerDocHandler.getLicenseNumber';
import getSplunkLog from '@salesforce/apex/DealerDocsS3UploadHandler.getSplunkLog';
import getFile from '@salesforce/apex/DealerDocsS3UploadHandler.getFile';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import DEALER_ID from '@salesforce/schema/Account.Dealership_ID__c'

import Dealer_Docs__c from '@salesforce/schema/Dealer_Docs__c';
import Account__c from '@salesforce/schema/Dealer_Docs__c.Account__c';
import RecordTypeId from '@salesforce/schema/Dealer_Docs__c.RecordTypeId';
import Document_State__c from '@salesforce/schema/Dealer_Docs__c.Document_State__c';
import Expiration_Date__c from '@salesforce/schema/Dealer_Docs__c.Expiration_Date__c';
import No_Expiration__c from '@salesforce/schema/Dealer_Docs__c.No_Expiration__c';
import Review_Status__c from '@salesforce/schema/Dealer_Docs__c.Review_Status__c';
import Compliant__c from '@salesforce/schema/Dealer_Docs__c.Compliant__c';
import Compliance_Issues__c from '@salesforce/schema/Dealer_Docs__c.Compliance_Issues__c';
import Document_Notes__c from '@salesforce/schema/Dealer_Docs__c.Document_Notes__c';
import License_Number__c from '@salesforce/schema/Dealer_Docs__c.License_Number__c';
import Insurance_Company_Name__c from '@salesforce/schema/Dealer_Docs__c.Insurance_Company_Name__c';
import Inventory_Coverage_Amount__c from '@salesforce/schema/Dealer_Docs__c.Inventory_Coverage_Amount__c';
import Permit_Resale_Number__c from '@salesforce/schema/Dealer_Docs__c.Permit_Resale_Number__c';
import MTC__c from '@salesforce/schema/Dealer_Docs__c.MTC__c';
import AL_Sales_Tax__c from '@salesforce/schema/Dealer_Docs__c.AL_Sales_Tax__c';
import Related_Dealer_License__c from '@salesforce/schema/Dealer_Docs__c.Related_Dealer_License__c';
import S3_Link__c from '@salesforce/schema/Dealer_Docs__c.S3_Link__c';

const fieldList = [
    'Account.Id',
    DEALER_ID
];

export default class CreateDealerDoc extends LightningElement {
    @track loading = false;
    @track recordTypeName = '';
    @track recordType = '';
    @track fileUploaded = false;
    @track objectInfo;
    @track initialSelection = [];
    @track relDealLic = '';

    //doc creation form variables
    accountId = Account__c;
    recordTypeField = RecordTypeId;
    dealerDocs = Dealer_Docs__c;
    stateField = Document_State__c;
    expDateField = Expiration_Date__c;
    noExpField = No_Expiration__c;
    reviewField = Review_Status__c;
    compliantField = Compliant__c;
    compIssuesField = Compliance_Issues__c;
    notesField = Document_Notes__c;
    licNumField = License_Number__c;
    resNumField = Permit_Resale_Number__c;
    mtcField = MTC__c;
    alSalesTaxField = AL_Sales_Tax__c;
    relLicenseField = Related_Dealer_License__c;
    s3Link = S3_Link__c;
    insuranceCompanyField= Insurance_Company_Name__c;
    inventoryAmountField= Inventory_Coverage_Amount__c; 

    //error message variables
    @track typeError = false;
    @track fileError = false;
    @track errors = [];
    @track fileAttachedMessage = false; //no an error, but wanted to put it with the rest of the message variables

    //page display variables
    @track selectType = true; //starts off as true so they start on the page to select the record type
    @track uploadDoc = false; //this is the page to upload a doc
    @track enterLicenseInfos = false; //page for entering license information
    @track enterCertInsuranceInfo = false;
    @track enterResaleInfos = false; //page for entering resale information
    @track enterConfirmationInfos = false; //page for entering confirmation doc information
    @track finishPage = false; //finish page. will reset LWC

    //button display variables
    @track nextOnly = true;
    @track nextAndPrev = false;
    @track cancelOnly = false;
    @track finishOnly = false;

    //file upload veriables
    bucket = 'dealer-docs'; //this needs to be changed for prod (prod bucket: dealer-docs)
    region = 'us-east-1';
    file;
    myFile;
    fileName;
    fileType;
    fileReaderObj;
    fileData; //used to be base64FileData
    fileSplit = [];
    reader;
    s3Url; //for storing and populating the s3 link to the file on the SF record
    folderName;
    fileNameWDate;
    documentId;

    @api recordId;
    @api objectApiName;
    @wire(getRecord, {recordId: '$recordId', fields: fieldList})account;
    @wire(getObjectInfo, {objectApiName: Dealer_Docs__c})objectInfo;

    get recordTypeNames() {
        return [
            {label: 'Dealer License', value: 'Dealer License'},
            {label: 'Resale Certificate', value: 'Resale Certificate'},
            {label: 'Certificate of Insurance', value: 'Certificate of Insurance'},
            {label: 'License Renewal Confirmation', value: 'License Renewal Confirmation'}
        ]
    }

    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        if (this.recordTypeName == '') {
            return Object.keys(rtis).find(rti => rtis[rti].name); //can i do DeveloperName instead? doesn't look like it... talk to gerald/bill
        }
        else {
            return Object.keys(rtis).find(rti => rtis[rti].name === this.recordTypeName);
        }
    }


    connectedCallback(){
        isProd().then((result) => {
            this.bucket= result==true?'dealer-docs':'dealer-doc-uat';
        });
    }
    
    handleDealerDocLookup(event) {
        event.preventDefault();
        apexSearch(event.detail)
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                    element.setSearchResults(results);
                });
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleUploaderSelectionChangeforDealerDocs(event) {
        event.preventDefault();
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        if ( typeof selectedValue != 'undefined' && selectedValue.length > 0 ) {
            this.relDealLic = selectedValue[0].id;
            getLicenseNumber({relLicId: this.relDealLic}) //set the licNumField value automatically
            .then(result => {
                this.licNumField = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Getting License Number - Please check that the license selected has a value in the License Number field.',
                        message: error,
                        variant: 'error',
                    }),
                );
            });
        }
    }

    setRecordTypeName(evt) {
        this.recordTypeName = evt.detail.value;
        this.recordType = this.recordTypeId;
    }

    handleFileSelection(evt) {
        this.documentId = evt.detail.files[0].documentId;

        let today = new Date();
        let dd = today.getDate();
        let mm = today.getMonth() + 1;
        let yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
        today = yyyy + '-' + mm + '-' + dd;

        let urlDocType = this.recordTypeName;
        let dealerId = this.account.data.fields.Dealership_ID__c.value;
        this.folderName = dealerId + '/' + urlDocType;
        this.fileName = evt.detail.files[0].name;
        this.fileNameWDate = today + '_' + this.fileName;

        this.s3Url = 'https://' + this.bucket + '.s3.amazonaws.com/' + this.folderName + '/' + this.fileNameWDate;
        console.log(this.s3Url);
        //this.s3Ur)l = encodeURI();
        this.s3Url = this.s3Url.replace(/ /g, '+');

        this.fileUploaded = true;
        this.fileAttachedMessage = true;
    }

    handleFileUpload() {
        if(this.fileUploaded == true) {
            this.loading = true;
            // this.fileUpload();
            getFile({ documentId: this.documentId, strFileName: this.fileNameWDate, folderName: this.folderName })
            .then(result => {
                if (result == 200)  {
                    this.loading = false;
                    this.fileUploaded = true;
                    //Show success message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.fileName + ' - Uploaded Successfully!!!',
                            variant: 'success',
                        }),
                        this.handleNext()
                    );
                }
                else {
                    this.loading = false;
                    //Show error message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'There was an error in uploading the file to S3. Please try again or submit a Salesforce Requests & Inquiries ticket.',
                            message: error.message,
                            variant: 'error',
                        }),
                    );
                }
            })
            .catch(error => {
                this.loading = false;
                //Show error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'There was an error in uploading the file. Please try again or submit a Salesforce Requests & Inquiries ticket.',
                        message: 'Please check the size of the file and try again. Limit of 6MB.', //error.message doesn't work
                        variant: 'error',
                    }),
                    //call splunk log here too
                    getSplunkLog({ documentId: this.documentId, logLevel: 'ERROR'})
                );
            });
        }
        else {
            this.fileError = true;
        }
    }

    // fileUpload() {
    // }

    async handleSubmit(evt) {
        this.loading = true;
        evt.preventDefault(); // stop the form from submitting
        let fields = evt.detail.fields;
        fields.S3_Link__c = this.s3Url;
        if (this.enterLicenseInfos == true) {
            this.template.querySelector('.licenseForm').submit(fields);
        }
        else if (this.enterResaleInfos == true) {
            this.template.querySelector('.resaleForm').submit(fields);
        }
        else if (this.enterCertInsuranceInfo == true) {
            this.template.querySelector('.certInsuranceForm').submit(fields);
        }
    }

    async handleConfirmationSubmit(evt) {
        console.log('handling submit');
        this.loading = true;
        evt.preventDefault(); // stop the form from submitting
        let fields = evt.detail.fields;
        fields.Related_Dealer_License__c = this.relDealLic;
        fields.License_Number__c = this.licNumField;
        fields.S3_Link__c = this.s3Url; //won't be populated for now
        this.template.querySelector('.confirmationDocForm').submit(fields);
    }

    handleError() {
        console.log('errors');
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Dealer Doc Creation Error',
                message: 'There was an error creating a new record. Please try again or submit a Salesforce Requests & Inquiries ticket.',
                variant: 'error'
            })
        );
    }

    handleSuccess() {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Dealer Document Created',
                variant: 'success'
            })
        );
        this.enterLicenseInfos = false;
        this.enterResaleInfos = false;
        this.enterCertInsuranceInfo = false;
        this.enterConfirmationInfos = false;
        this.cancelOnly = false;
        this.finishPage = true;
        this.finishOnly = true;
    }

    handleNext() {
        if (this.selectType == true && this.recordTypeName != '') {
            this.selectType = false;
            this.uploadDoc = true;
            this.nextOnly = false;
            this.nextAndPrev = true;
            this.typeError = false; //make sure it's false even if it was never true
        }
        else if (this.selectType == true && this.recordTypeName == '') {
            this.typeError = true;
        }
        else if(this.uploadDoc == true && this.fileUploaded == true) {
            if (this.recordTypeName == 'Dealer License') {
                this.uploadDoc = false;
                this.enterLicenseInfos = true;
                this.fileError = false; //make sure it's false even if it was never set to true
                this.nextAndPrev = false;
                this.cancelOnly = true;
            }
            else if (this.recordTypeName == 'Resale Certificate') {
                this.uploadDoc = false;
                this.enterResaleInfos = true;
                this.fileError = false; //make sure it's false even if it was never set to true
                this.nextAndPrev = false;
                this.cancelOnly = true;
            }
            else if (this.recordTypeName == 'Certificate of Insurance') {
                this.uploadDoc = false;
                this.enterCertInsuranceInfo = true;
                this.fileError = false; //make sure it's false even if it was never set to true
                this.nextAndPrev = false;
                this.cancelOnly = true;
            }
            else if (this.recordTypeName == 'License Renewal Confirmation') {
                this.uploadDoc = false;
                this.enterConfirmationInfos = true;
                this.fileError = false; //make sure it's false even if it was never set to true
                this.zeroError = false; //make sure it's false even if it was never set to true
                this.nextAndPrev = false;
                this.cancelOnly = true;
            }
        }
        else if (this.uploadDoc == true && this.fileUploaded == false) {
            this.fileError = true;
        }
    }

    handlePrevious() {
        if (this.uploadDoc == true) {
            this.uploadDoc = false;
            this.nextAndPrev = false;
            this.nextOnly = true;
            this.fileError = false; //just in case
            this.selectType = true;
        }
        else if (this.enterLicenseInfos == true || this.enterResaleInfos == true || this.enterCertInsuranceInfo == true || this.enterConfirmationInfos == true) {
            this.enterLicenseInfos = false;
            this.enterResaleInfos = false;
            this.enterCertInsuranceInfo = false;
            this.enterConfirmationInfos = false;
            this.zeroError = false; //just in case
            this.cancelOnly = false;
            this.nextAndPrev = true;
            this.uploadDoc = true;
        }
    }

    handleFinish() {
        //use this to reset all of the variables so the LWC goes back to the first page
        this.loading = false;
        this.recordTypeName = '';
        this.fileUploaded = false;

        //error message variables
        this.typeError = false;
        this.fileError = false;
        this.zeroError = false;
        this.fileAttachedMessage = false;

        //page display variables
        this.selectType = true; //starts off as true so they start on the page to select the record type
        this.uploadDoc = false;
        this.enterLicenseInfos = false;
        this.enterResaleInfos = false;
        this.enterCertInsuranceInfo = false;
        this.enterConfirmationInfos = false;
        this.finishPage = false;

        //button display variables
        this.nextOnly = true;
        this.nextAndPrev = false;
        this.cancelOnly = false;
        this.finishOnly = false;
    }
}