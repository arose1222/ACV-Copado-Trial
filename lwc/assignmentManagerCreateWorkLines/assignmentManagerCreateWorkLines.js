/* eslint-disable no-console */
/* eslint-disable vars-on-top */
import { LightningElement,track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import apexSearch from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.getAccounts';
import createWorkOrders from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.createWorkOrders';
import getInspectionNotesFromAccount from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.getInspectionNotesFromAccount';
import processMassRows from '@salesforce/apex/assignmentManagerCreateWorkLinesCont.processMassRows';
import { getRecord } from 'lightning/uiRecordApi';
import caseStatus from '@salesforce/schema/Case.Status';

const FIELDS = [
    caseStatus
]
//test
export default class AssignmentManagerCreateWorkLines extends LightningElement {

    @track rows = [];//[{ uuid: this.createUUID(), vin:'123456789', make:'Tesla',model:'X3',color:'Blue',lotId:'', inspectiontype:'inspection' }];
    @track initialSelection = [];
    @track errors = [];
    @track selectedType = '';
    @track openmodel = false;
    @track selectedRecord;
    @track accountNotes;
    @track selectedAccountId = '';

    @api recordId;
    @wire(getRecord,{recordId:'$recordId', fields :FIELDS})case;

    isMultiEntry = false;

    closeModel() {
        this.rows.forEach(item=> {
            if (item.uuid === this.selectedRecord.uuid) {
                //console.log(this.selectedRecord.lineNote);
                item.lineNote = this.selectedRecord.lineNote;
                if (item.lineNote) {
                    item.hasNote = true;
                }
                else {
                    item.hasNote = false;
                }
            }
        });
        this.openmodel = false;
    }

    addNote(event) {
        this.rows.forEach(item=> {
            if (event.currentTarget.dataset.key === item.uuid) {
                this.selectedRecord = item;
            }
        });
        //this.getAccountNotes(this.selectedAccountId);
        this.openmodel = true;
    }

    handleFieldChange(event) {
        if (event.target.name === 'lineNote') {
            this.selectedRecord.lineNote = event.target.value;
        }
        else{
            this.rows.forEach(item=> {
                if (event.currentTarget.dataset.key === item.uuid) {
                    if (event.target.name === 'vin') {
                        // eslint-disable-next-line vars-on-top
                        var vinValue = event.target.value;
                        if (vinValue.includes('o') || vinValue.includes('O') || vinValue.includes('i') || vinValue.includes('I') || vinValue.includes('q') || vinValue.includes('Q')) {
                            this.notifyUser('Error', 'Vin contains an illegal charater (o,i,or q)', 'error' );
                            event.target.value = '';
                        }
                        else {
                            item.vin = event.target.value;
                        }
                        
                    }
                    if (event.target.name === 'year'){
                        item.year = event.target.value;
                    }
                    if (event.target.name === 'make') {
                        item.make = event.target.value;
                    }
                    if (event.target.name === 'model') {
                        item.model = event.target.value;
                    }
                    if (event.target.name === 'color') {
                        item.color = event.target.value;
                    }
                    if (event.target.name === 'type') {
                        item.inspectiontype = event.target.value;
                    }
                    if (event.target.name === 'reservePrice'){
                        item.reservePrice = event.target.value;
                    }
                    if (event.target.name === 'stock number') {
                        item.stockNumber = event.target.value;
                    }
                }
            });
        }
    }

    connectedCallback() {
        this.addRow();
    }

    get options() {
        return [{label:'Standard Inspection',value:'inspection'},{label:'Asset Verification',value:'verification'}];
    } 

    submit() {
        var hasError = false;
        this.rows.forEach(item => {
            if (!item.vin) {
                this.notifyUser('Error', 'All Rows Need a Vin', 'error' );
                hasError = true;
            }
            else if (!item.acctId) {
                this.notifyUser('Error', 'All Rows Need an Account', 'error');
                hasError = true;
            }
            else if (!item.lotId) {
                this.notifyUser('Error', 'All Rows Need a Lot', 'error' );
                hasError = true;
            }
            else if (!item.inspectiontype) {
                this.notifyUser('Error', 'All Rows Need an Inspection Type', 'error' );
                hasError = true;
            }
        });
        if (!hasError) {
            createWorkOrders({inboundJSON:JSON.stringify(this.rows)}).then(results =>{
                if(results){
                    this.notifyUser('Records Created', 'The records were created succesfully. Please refresh the page to confirm a closed status.', 'success');
                        //find all c-lookup tags and set values to null
                        this.template.querySelectorAll("c-lookup").forEach(item => {
                            item.selection = [];
                        });
                        this.rows = [];
                        this.addRow();
                    const fields = {};
                    // eslint-disable-next-line dot-notation
                    fields['Id'] = this.recordId;
                    fields[caseStatus.fieldApiName] = 'Closed';
                    const recordInput = {fields};
                    updateRecord(recordInput).then(()=>{
                        //refreshApex(this.Case);
                    }).catch(error => {
                        this.notifyUser('Error Updating The Case', 'The Case Status was not updated, please do this manually! Error Details: '+error, 'error');
                    });
                }
                else{
                    this.notifyUser('Creation Error', 'An error occured while trying to create the records.', 'error');
                }
            }).catch(error => {
                this.notifyUser('Creation Error', 'An error occured while trying to create the records.', 'error');
                // eslint-disable-next-line no-console
                console.error('Creation Error', JSON.stringify(error));
                this.errors = [error];
            });
        }
    }

    massChangeType(event) {
        this.rows.forEach(item => {
            item.inspectiontype = event.target.value;
        });
    }

    removeRow(event){
        this.rows.forEach(function(item, index, object){
            if(event.currentTarget.dataset.key === item.uuid){
                object.splice(index,1);
            }
        });
    }

    handleMassSelectionChangeforAccount(event) {
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        //var allLookups = this.template.querySelectorAll("c-lookup");
        var allLookups = this.template.querySelectorAll(".account");
        // eslint-disable-next-line no-console
        this.rows.forEach(item => {
                if (selectedValue.length > 0) {
                    item.acctId = selectedValue[0].id;
                }
                else {
                    item.acctId = '';
                }
        });
        
        allLookups.forEach(element => {
            if (selectedValue.length > 0) {
                element.selection = selectedValue;
            }
            else {
                element.selection = [];
            }
        });
    }

    handleMassSelectionChange(event) {
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        var allLotLookups = this.template.querySelectorAll(".lot");
        // eslint-disable-next-line no-console
        this.rows.forEach(item => {
                if (selectedValue.length > 0) {
                    item.lotId = selectedValue[0].id;
                }
                else {
                    item.lotId = '';
                }
        });
        
        allLotLookups.forEach(element => {
            if (selectedValue.length > 0) {
                element.selection = selectedValue;
            }
            else {
                element.selection = [];
            }
        });
        if (selectedValue[0] !== undefined) {
            this.getMassAccountNotes(selectedValue[0].id);
        }
    }

    async getMassAccountNotes(searchId) {
        if (searchId) {
            const accountNotes = await getInspectionNotesFromAccount({accountId:searchId});
            this.accountNotes = accountNotes;
            //this.savePrePopulatedNote();
            this.rows.forEach(item=> {
                item.lineNote = this.accountNotes;
                item.hasNote = true;
            });
        }
    }

    handleSelectionChangeforAccount(event) {
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        var key = event.target.getKey();
        // eslint-disable-next-line no-console
        this.rows.forEach(item => {
            if(item.uuid === key){
                if(selectedValue.length > 0){
                    item.acctId = selectedValue[0].id;
                }
                else{
                    item.acctId = '';
                }
                
            }
        });
    }

    handleSelectionChange(event) {
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        var key = event.target.getKey();
        // eslint-disable-next-line no-console
        this.rows.forEach(item => {
            if(item.uuid === key){
                if(selectedValue.length > 0){
                    item.lotId = selectedValue[0].id;
                    this.selectedAccountId = item.lotId;
                    //this.getAccountNotes(this.selectedAccountId);
                }
                else{
                    item.lotId = '';
                }
                
            }
        });
        this.getAccountNotes(selectedValue[0].id, key);
    }

    async getAccountNotes(searchId, uuid) {
        if (searchId) {
            const accountNotes = await getInspectionNotesFromAccount({accountId:searchId});
            this.accountNotes = accountNotes;
            //this.savePrePopulatedNote();
            this.rows.forEach(item=> {
                if (item.uuid === uuid) {
                    item.lineNote = this.accountNotes;
                    item.hasNote = true;
                }
            });
        }
    }

    // Mass File Uploader
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
    @track errorFlag = false;
    @track bulkErrRows = [];
    @track showErrorLoadingSpinner;
    

    handleFileChange(event) {
console.log( event.target.files );        
        if(event.target.files.length > 0 ) { //&& event.target.files[0].type === 'text/csv' - Removed for now due to Windows issue            
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            this.template.querySelector('[data-id="fileNameDiv"]').style.display = 'block';
        } else {
            this.notifyUser( 'Error with Upload', 'A CSV File is the only acceptable File for Uploading', 'error' );
        }
    }

    handleSave() {
        if( typeof this.filesUploaded != 'undefined' && this.filesUploaded.length > 0 && typeof this.accountId != 'undefined' && typeof this.inspectionType != 'undefined' ) {
            this.uploadHelper();
        } else {
            this.notifyUser( 'Error with Upload', 'A validly formatted CSV File, a selected Account, and an Inspection Type are required', 'error' );
        }
    }

    async uploadHelper() {
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
                    // VIN, Dealership Id, & Address are required
                    if ( typeof row[2] == 'undefined' || typeof row[1] == 'undefined' || row[2].length === 0 || row[1].length === 0 ) {
                        this.bulkErrRows.push(
                            {
                                uuid: this.createUUID(),
                                originalRow: {
                                    vin: row[2],
                                    make: row[4],
                                    model: row[5],
                                    year: row[3],
                                    acctId: this.accountId,
                                    stockNumber: row[0],
                                    address: row[1],
                                    color: row[6],
                                    inspectiontype: this.inspectionType
                                },
                                error: 'VIN, Address, & Dealership ID are required on all rows'
                            }
                        );
                    } else {
                        rowArray[rowIndex] = {
                            uuid: this.createUUID(),
                            vin: row[2],
                            make: row[4],
                            model: row[5],
                            acctId: this.accountId,
                            stockNumber: row[0],
                            year: row[3],
                            address: row[1],
                            color: row[6],
                            inspectiontype: this.inspectionType
                        }
                    }
                }
            }
            
            if ( rowArray.length > 0 ) {
                // call the uploadProcess method 
                await processMassRows( { successRows : JSON.stringify( rowArray ) } ).then(
                    result => {
                        var returnVar = JSON.parse( result );
                        if ( typeof returnVar.successRows != 'undefined' && returnVar.successRows > 0 ) {
                            this.handlePuralLanguage( returnVar.successRows, 'success' );
                        }
                        if ( typeof returnVar.errorRowLst != 'undefined' && returnVar.errorRowLst.length > 0 ) {
                            for( var errorRowIndex = 0; errorRowIndex < returnVar.errorRowLst.length; errorRowIndex++ ) {
                                this.bulkErrRows.push(
                                    {
                                        uuid: returnVar.errorRowLst[errorRowIndex].row.uuid,
                                        originalRow: {
                                            vin: returnVar.errorRowLst[errorRowIndex].row.vin,
                                            make: returnVar.errorRowLst[errorRowIndex].row.make,
                                            model: returnVar.errorRowLst[errorRowIndex].row.model,
                                            year: returnVar.errorRowLst[errorRowIndex].row.year,
                                            acctId: returnVar.errorRowLst[errorRowIndex].row.acctId,
                                            stockNumber: returnVar.errorRowLst[errorRowIndex].row.stockNumber,
                                            address: returnVar.errorRowLst[errorRowIndex].row.address,
                                            color: returnVar.errorRowLst[errorRowIndex].row.color,
                                            inspectiontype: returnVar.errorRowLst[errorRowIndex].row.inspectiontype
                                        },
                                        error: returnVar.errorRowLst[errorRowIndex].errorMsg
                                    }
                                );
                            }
                        }
                    }
                ).catch( error => {
console.log( error );
                    this.notifyUser( 'Error Processing Records', 'There was an error processing your records. Please open a Request and Inquries Ticket in Salesforce and provide the CSV you were attempting to upload, thank you!', 'error' );
                });
            }

            // Any errors identified? Then switch flags for display
            if ( this.bulkErrRows.length > 0 ) {
                this.flagBooleans( false, true );
                this.handlePuralLanguage( this.bulkErrRows.length, 'error' );
            } else { // If no errors, move to original screen
                this.flagBooleans( true, false );
            }
        });
    }

    async handleModifiedSave(){
        var changedAssignRows = this.bulkErrRows;
        var databaseRows = [];
        this.showErrorLoadingSpinner = true;

        for ( var rowIndex = 0; rowIndex < changedAssignRows.length; rowIndex++ ) {       
            if ( changedAssignRows[rowIndex].originalRow.vin.length !== 0 && changedAssignRows[rowIndex].originalRow.acctId.length !== 0 && changedAssignRows[rowIndex].originalRow.address.length !== 0 ) {
                // There are no errors javascript can declare, remove
                databaseRows.push( {
                    uuid: changedAssignRows[rowIndex].uuid,
                    vin: changedAssignRows[rowIndex].originalRow.vin,
                    make: changedAssignRows[rowIndex].originalRow.make,
                    model: changedAssignRows[rowIndex].originalRow.model,
                    year: changedAssignRows[rowIndex].originalRow.year,
                    acctId: changedAssignRows[rowIndex].originalRow.acctId,
                    stockNumber: changedAssignRows[rowIndex].originalRow.stockNumber,
                    address: changedAssignRows[rowIndex].originalRow.address,
                    color: changedAssignRows[rowIndex].originalRow.color,
                    inspectiontype: changedAssignRows[rowIndex].originalRow.inspectiontype
                } );
                this.bulkErrRows.splice( rowIndex, 1 );
                rowIndex--;
            }
        }
   
        await processMassRows( { successRows : JSON.stringify( databaseRows ) } ).then(
            result => {
                var returnVar = JSON.parse( result );
                if ( typeof returnVar.successRows != 'undefined' && returnVar.successRows > 0 ) {                       
                    this.handlePuralLanguage( returnVar.successRows, 'success' );
                }
                if ( typeof returnVar.errorRowLst != 'undefined' && returnVar.errorRowLst.length > 0 ) {
                    for( var errorRowIndex = 0; errorRowIndex < returnVar.errorRowLst.length; errorRowIndex++ ) {
                        this.bulkErrRows.push(
                            {
                                uuid: returnVar.errorRowLst[errorRowIndex].row.uuid,
                                originalRow: {
                                    vin: returnVar.errorRowLst[errorRowIndex].row.vin,
                                    make: returnVar.errorRowLst[errorRowIndex].row.make,
                                    model: returnVar.errorRowLst[errorRowIndex].row.model,
                                    year: returnVar.errorRowLst[errorRowIndex].row.year,
                                    acctId: returnVar.errorRowLst[errorRowIndex].row.acctId,
                                    stockNumber: returnVar.errorRowLst[errorRowIndex].row.stockNumber,
                                    address: returnVar.errorRowLst[errorRowIndex].row.address,
                                    color: returnVar.errorRowLst[errorRowIndex].row.color,
                                    inspectiontype: returnVar.errorRowLst[errorRowIndex].row.inspectiontype
                                },
                                error: returnVar.errorRowLst[errorRowIndex].errorMsg
                            }
                        );
                    }
                }
            }
        ).catch( error => {
            console.log( error );
            this.notifyUser( 'Error Processing Records', 'There was an error processing your records. Please open a Request and Inquiries Ticket in Salesforce and provide the CSV you were attempting to upload, thank you!', 'error' );
        });

        // Any errors identified? Then switch flags for display
        if ( this.bulkErrRows.length > 0 ) {
            this.flagBooleans( false, true );
            this.handlePuralLanguage( this.bulkErrRows.length, 'error' );
        } else { // If no errors, move to original screen
            this.flagBooleans( true, false );
        }
        this.showErrorLoadingSpinner = false;
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
            }
        });
    }

    handleUploaderSelectionChangeforAccount(event) {
        //set the selected value to the field that triggered the event
        var selectedValue = event.target.getSelection();
        if ( typeof selectedValue != 'undefined' && selectedValue.length > 0 ) {
            this.accountId = selectedValue[0].id;        
        }
    }

    handleTypeChange(event) {
        if ( event.target.name === 'type' ) {
            this.inspectionType = event.target.value;
        }
    }

    flagBooleans( uploderBoolean, errorBoolean ) {
        this.uploaderFlag = uploderBoolean;
        if ( uploderBoolean ) {
            this.isTrue = false;
            this.showLoadingSpinner = false;        
            if ( this.template.querySelector('[data-id="fileNameDiv"]') != null ) {
                this.template.querySelector('[data-id="fileNameDiv"]').style.display = 'none';
            }
        }
        this.errorFlag = errorBoolean;
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

    handleAccountLookup(event) {
        var key = event.detail.dataitem;
        apexSearch(event.detail)
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                    if(element.key === key){
                        element.setSearchResults(results);
                    }
                });
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
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

    createUUID() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c === 'x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }

    addRow() {
        var newRow = {
            uuid: this.createUUID(),
            reservePrice:'',
            vin:'',
            make:'',
            model:'',
            acctId:'',
            lotId:'',
            lineNote: '',
            stockNumber:'',
            inspectiontype:'inspection',
            hasNote: false
        }
        this.rows.push(newRow);
    }
}