import { LightningElement, track } from 'lwc';

import getData from '@salesforce/apex/WorkRequestSearchController.getData';
import  { loadStyle } from 'lightning/platformResourceLoader';
import cssResource from '@salesforce/resourceUrl/InventoryLifeCycleViewCssFile';

const dataTableColumns = [
    { label: 'Service Appointment', fieldName: 'serviceApptLink', type: 'url', typeAttributes: { label: { fieldName: 'serviceApptName' },
    target: '_blank'} },
    { label: 'Work Order Line Item', fieldName: 'woliLink', type: 'url', typeAttributes: { label: { fieldName: 'woliName' } } },
    { label: 'VIN', fieldName: 'vin', type: 'text' },
    { label: 'Assignment Id', fieldName: 'assignmentId', type: 'text' },
    { label: 'Account', fieldName: 'acctLink', type: 'url', typeAttributes: { label: { fieldName: 'acctName' } } },
    { label: 'Address', fieldName: 'address', type: 'text' },
    { label: 'Appointment Status', fieldName: 'serviceApptStatus', type: 'text' },
    { label: 'Earliest Start Date', fieldName: 'earlyStartTime', type: 'text' },
    { label: 'Original Due Date', fieldName: 'dueDate', type: 'text' },
    { label: 'Assigned Inspector', fieldName: 'assignedUser', type: 'text' },
    { label: 'Created Date', fieldName: 'createdDate', type: 'text' }
];

export default class WorkRequestSearch extends LightningElement {
     // Spinner variables
     @track activeSpinner = false;

    // Search Bar Variables
    searchValue = '';                                       // search bar value. Default blank
    lastOnBlurValue = '';                                   // Used to confirm search value has actually changed

    // Table Variables
    filteredRows = [];                                      // Filtered Rows are the rows available based on the page filters (like search)
    columns = dataTableColumns;                             // columns for datatable

    // Header Section Variables
    @track lastRefreshed;                                   // Used as the relative time of the last refresh.

     /***********************Intialization****************************/
    //Runs on Page Load
    connectedCallback(){
        this.toggleSpinner();
        loadStyle(this, cssResource);
        getData({})
            .then(result => {
                this.intializeData(result);
            })
            .catch(error => {
                //Javascrupt Failed Error
                console.log(error);
            })
            .finally(() => {
                this.toggleSpinner();
            })
        ;
    }

    /***********************Helper Methods***************************/
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    intializeData( result ){
        var returnVal = JSON.parse( result );
        this.filteredRows = returnVal.allRows;
        this.totalNumOfRows = this.filteredRows.length;
        this.lastRefreshed = Date.now();
    }

    // On refresh click, refresh the table with server side data.
    handleRefreshTable( event ){
        this.searchDB();
    }

    // Runs onChange of the serachbar and is a running value of what is changing. actual search happens onBlur
    handleSearchValueAssignment( event ){
        this.searchValue = event.detail.value;
    }

    handleSearchTable(){
        if( this.searchValue != this.lastOnBlurValue ){
            this.searchDB();
        }
    }

    handleKeyUp( event ) {
        if( event.keyCode == 13) {
            this.searchDB();
        }
    }

    searchDB() {
        this.toggleSpinner();
        // Call APEX
        getData( { searchVar : this.searchValue } )
            .then(result => {
                this.intializeData(result);
            })
            .catch(error => {
                //Javascrupt Failed Error
                console.log(error);
            })
            .finally(() => {
                this.toggleSpinner();
            });
    }
}