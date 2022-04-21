/* eslint-disable no-console */
/* eslint-disable vars-on-top */

import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processMassRows from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.processMassRows';
import getTemplateDownloadLink from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.getTemplateDownloadLink';
import { verifyUUID, createUUID } from 'c/acvUtilHelper';

export default class ImportManager extends NavigationMixin(LightningElement) {

    @track initialSelection = [];
    @track errors = [];
    fileUploaded = [];
    file;
    @track filename;
    fileContents;
    fileReader;
    accountId;
    inspectionType;
    @track showLoadingSpinner; // Loading Spinner on Button if needed
    @track isTrue = false; // Disable Save button to avoid issues
    @track uploaderFlag = true;
    // @track errorFlag = false;
    @track bulkErrRows = [];
    @track showErrorLoadingSpinner;
    @track showTemplateDownloadButton = true;
    templateDownloadLink = '';

    connectedCallback(){
        getTemplateDownloadLink({})
            .then( result => {
                if( result != null ){
                    this.templateDownloadLink = result;
                }else{
                    this.showTemplateDownloadButton = false;
                }
            })
            .catch( error => {
                console.log( JSON.stringify(error));
            })
        ;
    }

    get options() {
        return [{label:'Standard Inspection',value:'inspection'},{label:'Asset Verification',value:'verification'},{label:'True360 Inspection',value:'true360'}];
    }

    handleDownloadTemplateClick(){
        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes: {
                url: this.templateDownloadLink
            }
        }, false);
    }

    handleFileChange(event) {
        if(event.target.files.length > 0 ) { // && event.target.files[0].type === 'text/csv' - Removed for now due to Windows issue
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            this.template.querySelector('[data-id="fileNameDiv"]').style.display = 'block';
        } else {
            this.notifyUser( 'Error with Upload', 'A CSV File is the only acceptable File for Uploading', 'error' );
        }
    }

    handleSave() {
        console.log('handleSave');
        if( typeof this.filesUploaded != 'undefined' && this.filesUploaded.length > 0 && typeof this.inspectionType != 'undefined' ) {
            this.uploadHelper();
        } else {
            this.notifyUser( 'Error with Upload', 'A validly formatted CSV File and an Inspection Type are required', 'error' );
        }
    }

    async uploadHelper() {
        console.log('uploadhelper');
        this.file = this.filesUploaded[0];
        this.showLoadingSpinner = true;
        // create a FileReader object
        this.fileReader= new FileReader();

        this.fileReader.readAsText( this.file );

        // set onload function of FileReader object
        this.fileReader.onloadend = (async () => {
            this.fileContents = this.fileReader.result;

            // Create File Split into rows
            var rows = this.csvToArray( this.fileContents );
            rows.shift();

            var rowArray = [];
            for ( var rowIndex = 0; rowIndex < rows.length; rowIndex++ ) {
                var row = rows[rowIndex];
                if ( typeof row != 'undefined' && row.length > 1 ) {
                    if( row.toString().replaceAll(',','') == '' ){
                        continue;
                    } else {
                        var innerRow = {
                            stockNumber: row[0],
                            address: row[1],
                            vin: row[2],
                            year: row[3],
                            make: row[4],
                            model: row[5],
                            color: row[6],
                            // New Fields
                            //reservePrice: row[7], - Requested to be removed by SAL-414
                            titleStatus: row[7],
                            titleWithDealer: row[8],
                            dealerContact: row[9],
                            residential: row[10],
                            addToRunList: row[11],
                            floorPrice: row[12],
                            dateInspected: row[13],
                            // Newer Fields
                            transportStatus: row[14],
                            inspectionNotes: row[15],
                            dealershipName: row[16],

                            acctId: row[17],
                            inspectiontype: this.inspectionType,
                            uuid: createUUID()
                        };

                        try {
                            innerRow.earlyStartDate = row[18];
                            innerRow.dueDate = row[19];
                        } catch ( error ) {} // Don't do anything
                        try {
                            if ( verifyUUID( row[20]) ) {
                                innerRow.uuid = row[20];
                            }
                        } catch ( error ) {} // Don't do anything

                        rowArray[rowIndex] = innerRow;
                    }
                }
            }

            if ( rowArray.length > 0 ) {
                // call the uploadProcess method
                await processMassRows( { successRows : JSON.stringify( rowArray ) } ).then(
                    result => {
                        if(result != null){
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Import_Manager_Job__c',
                                    actionName: 'view'
                                }
                            });
                        } else {
                            this.notifyUser( 'Test 1 Error Processing Records', 'There was an error processing your records. Please open a Request and Inquiries Ticket in Salesforce and provide the CSV you were attempting to upload, thank you!', 'error' );
                        }
                    }
                ).catch( error => {
                    console.log( error );
                    this.notifyUser( 'Test 2 Error Processing Records', 'There was an error processing your records. Please open a Request and Inquries Ticket in Salesforce and provide the CSV you were attempting to upload, thank you!', 'error' );
                });
            }
        });
    }


    handlePuralLanguage( intLength, messageType) {
        var title;
        var message;
        if ( messageType === 'success' ) {
            if ( intLength > 1 ) {
                title = 'Records Created';
                message = '' + intLength + ' records were created succesfully';
            } else {
                title = 'Record Created';
                message = '' + intLength + ' record was created succesfully';
            }
        } else if ( messageType === 'error') {
            if ( intLength > 1 ) {
                title = 'Errors Identified';
                message = 'There was an issue with ' + intLength + ' rows. Please see the screen to fix the identified issue!';
            } else {
                title = 'Error Identified';
                message = 'There was an issue with ' + intLength + ' row. Please see the screen to fix the identified issues!';
            }
        }
        this.notifyUser( title, message, messageType );
    }

    handelErrorFieldChange(event) {
        this.bulkErrRows.forEach(item=> {
            if (event.currentTarget.dataset.key === item.uuid) {
                if (event.target.name === 'vin') {
                    var vinValue = event.target.value;
                    if (vinValue.includes('o') || vinValue.includes('O') || vinValue.includes('i') || vinValue.includes('I') || vinValue.includes('q') || vinValue.includes('Q')) {
                        this.notifyUser('Error', 'Vin contains an illegal charater (o,i,or q)', 'error' );
                        event.target.value = '';
                    }
                    else {
                        item.originalRow.vin = event.target.value;
                    }

                }
                if (event.target.name === 'make') {
                    item.originalRow.make = event.target.value;
                }
                if (event.target.name === 'model') {
                    item.originalRow.model = event.target.value;
                }
                if (event.target.name === 'year') {
                    item.originalRow.year = event.target.value;
                }
                if (event.target.name === 'stock number') {
                    item.originalRow.stockNumber = event.target.value;
                }
                if (event.target.name === 'address') {
                    item.originalRow.address = event.target.value;
                }
                if (event.target.name === 'color') {
                    item.originalRow.color = event.target.value;
                }
                if (event.target.name === 'title status') {
                    item.originalRow.titleStatus = event.target.value;
                }
                if (event.target.name === 'title with dealer') {
                    item.originalRow.titleWithDealer = event.target.value;
                }
                if (event.target.name === 'dealer contact') {
                    item.originalRow.dealerContact = event.target.value;
                }
                if (event.target.name === 'residential') {
                    item.originalRow.residential = event.target.value;
                }
                if (event.target.name === 'add to run list') {
                    item.originalRow.addToRunList = event.target.value;
                }
                if (event.target.name === 'floor price') {
                    item.originalRow.floorPrice = event.target.value;
                }
                if (event.target.name === 'date inspected') {
                    item.originalRow.dateInspected = event.target.value;
                }
                if (event.target.name === 'transport status') {
                    item.originalRow.transportStatus = event.target.value;
                }
                if (event.target.name === 'inspection notes') {
                    item.originalRow.inspectionNotes = event.target.value;
                }
                if (event.target.name === 'dealership name') {
                    item.originalRow.dealershipName = event.target.value;
                }
                if (event.target.name === 'account dealer id') {
                    item.originalRow.accountId = event.target.value;
                }
                // We purposefully do not display 'Secret' Fields
            }
        });
    }

    handleTypeChange(event) {
        if ( event.target.name === 'type' ) {
            this.inspectionType = event.target.value;
        }
    }

    csvToArray(text) {
        let p = '', row = [''], ret = [row], i = 0, r = 0, s = !0, l;
        for (l of text) {
            if ('"' === l) {
                if (s && l === p) row[i] += l;
                s = !s;
            } else if (',' === l && s) l = row[++i] = '';
            else if ('\n' === l && s) {
                if ('\r' === p) row[i] = row[i].slice(0, -1);
                row = ret[++r] = [l = '']; i = 0;
            } else row[i] += l;
            p = l;
        }
        return ret;
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts){
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title:title, message:message, variant:variant, mode:'sticky' });
            this.dispatchEvent(toastEvent);
        }
    }
}