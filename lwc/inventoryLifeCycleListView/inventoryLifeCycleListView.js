/* This is the Inventory Life Cycle View table 
 * @author James Andre LaCour
*/
import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doInit from '@salesforce/apex/InventoryLifeCycleListViewController.doInit';
import getUpdatedData from '@salesforce/apex/InventoryLifeCycleListViewController.getUpdatedData';
import launchAuction from '@salesforce/apex/LaunchAuctionCont.launchAuction';
/***********************Final Variables**************************/
// Table Columns
const dataTableColumns = [
    { sortable: true, hideDefaultActions: true, label: 'Client', fieldName: 'clientURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'clientName' }
        } 
    },
    { sortable: true, hideDefaultActions: true, label: 'Location', fieldName: 'locationURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'locationName' }
        } 
    },
    { sortable: true, hideDefaultActions: true, label: 'Stock Number', fieldName: 'stockNumber', type: 'text' },
    { sortable: true, hideDefaultActions: true, label: 'VIN', fieldName: 'vinURL', type:'url', 
        typeAttributes:{ 
            label: { fieldName: 'vinName' }
        } 
    },
    { sortable: true, hideDefaultActions: true, label: 'Status', fieldName: 'status', type: 'text' },
    { sortable: true, hideDefaultActions: true, label: 'Year, Make, Model, Trim', fieldName: 'yearMakeModelTrimURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'yearMakeModelTrim' }
        } 
    },
    { sortable: true, hideDefaultActions: true, label: 'Odometer', fieldName: 'odometer', type: 'number' },
    { sortable: true, hideDefaultActions: true, label: 'Reserve', fieldName: 'reserve', type: 'currency' },
    { sortable: true, hideDefaultActions: true, label: 'Lights', type: 'auctionLights',
        typeAttributes: { lights: { fieldName: 'lightObjList'} }
    }
];
// Pagination Options
const rowsPerPageOptions = [ 
    { label: '10', isSelected: true },
    { label: '20', isSelected: false },
    { label: '50', isSelected: false },
    { label: '100', isSelected: false },
    { label: 'All', isSelected: false }
];
const displayedPageLimit = 10;
/***********************JS Code**********************************/
export default class InventoryLifeCycleListView extends NavigationMixin(LightningElement) {    
    // Spinner variables
    @track activeSpinner = false;
    // Table Variables 
    columns = dataTableColumns;                              // columns for datatable
    allIlcRows = [];                                         // All rows is considered the All the records with the Current Filter on
    filteredIlcRows = [];                                    // Filtered Rows are the rows available based on the page filters (like search)
    rowNumberOffset = 0;                                     // Used to indicate where in the filteredIlcRows should we grab the next X rows to set as displayedIlcRows
    @track displayedIlcRows = [];                            // Rows you see on the screen
    selectedRows = [];
    sortedBy = 'clientURL';                                  // Default is sorted by Client
    @track sortedByLabel = 'Client';                         // Default is sorted by Client
    sortedDirection = 'asc';                                 // Default is Ascending
    // Search Bar Variables
    searchValue = '';                                        // search bar value. Default blank
    lastOnBlurValue = '';                                    // Used to confirm search value has actually changed
    // Pagination Variables
    displayedPageLimit = displayedPageLimit;                 // controls how many pagination options can show
    rowsDisplayedOptions = rowsPerPageOptions;               // options of how many rows can be seen on the page
    @track tableMaxRowSize = '10';                           // max amount of rows that can be see on screen. Defaults 10
    @track rowsPerPageLabel = '10';                          // value of rows per page label. Default 10
    @track pagesList = [];                                   // pagination pages list. Holds the page number and the css look of each page
    @track disableFP = false;                                // Disabling of First and Previous buttons
    @track disableNL = false;                                // Disabling of Next and Last buttons
    totalNumOfPages;                                         // maximum amount of pages. round up of total filteredIlcRows / tableMaxRowSize;
    currentPage = 1;                                         // Current Pagination page. Used in previous and next
    // Header Section Variables
    @track rangedShowing;                                    // the range of values in the header section. IE 1-10 rows or 11-20 rows
    @track totalNumOfRows;                                   // Total number of rows showed in the Header Section
    @track sortedByColumnName = 'Client';                    // The Sorted By Column Name in header section. Default 'Client'
    @track lastRefreshed;                                    // Used as the relative time of th elast refresh.
    @track filterManagerIsSelected = false;                  // used in the stateful button of Filter Manager. Default False
    @track filterManagerVariant = 'neutral';                 // Used in the stateful button of Filter Manager. Default neutral
    newFilterChanges = {};                                   // Used to check for changes in the Filter Manager
    currentFilterId = '';                                    // Id of the current Filter activated
    @track filterName = '';                                  // Name of the current filter, used in the header
    @track showActions = false;                              // Controls whether you can see the Bulk actinos when rows are selected
    // Modal Variables    
    @track showLaunchAuction = false;                        // Used when the Launch Auction selection has been chosen
    editScheduleClicked = false;
    ilcsToPass = '';                                         // Used to pass the selected ilcs to various modals
    @track showTerminateAuction = false;                     // Handles the viewing of the Terminate Auction screen
    //Confirmation Mode
    @track showConfirmationVariables = false;                // Switches pieces of the UI to Confirmation mode
    @track confirmationVariables = {}                        // Object containing what was returned from the event for Confirmation
    confirmationSelectedRows = null;
    @track confirmationSelectedRowsShow = false;
    @track suppressBottomBar = true;
    /***********************Intialization****************************/
    //Runs on Page Load
    connectedCallback( ){
        this.toggleSpinner();
        doInit({})
            .then(result => {
                this.initialize(result);
            })
            .catch(error => {
                this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
            })
            .finally(() => {
                this.toggleSpinner();
            })
        ;
    }
    /***********************Helper Methods***************************/
    // Used in the Download Table Component to compile the Name of th eFile
    @api
    get downloadFileName(){
        return this.filterName + ' - ' + new Date().toDateString();
    }
    // Used in the Download Table Component to get the header row
    @api
    get columnNames(){
        let nameArray = [];
        if( this.columns != null && this.columns !== undefined ){
            this.columns.forEach( thisRow => {
                nameArray.push( '"' + thisRow.label + '"' );
            });
        }
        return nameArray;
    }
    // Used in the Download Table Component to get the data
    @api
    get filteredIlcRowsCleaned(){
        let dataCleaned = [];
        if( this.filteredIlcRows != null && this.filteredIlcRows !== undefined ){
            this.filteredIlcRows.forEach( thisRow =>{
                let thisRowClean = [];
                thisRowClean.push( '"' + (thisRow.clientName != null && thisRow.clientName !== undefined ? thisRow.clientName : '') + '"' );
                thisRowClean.push( '"' + (thisRow.locationName != null && thisRow.locationName !== undefined ? thisRow.locationName : '') + '"' );
                thisRowClean.push( '"' + (thisRow.stockNumber != null && thisRow.stockNumber !== undefined ? thisRow.stockNumber : '') + '"' );
                thisRowClean.push( '"' + (thisRow.vinName != null && thisRow.vinName !== undefined ? thisRow.vinName : '') + '"' );
                thisRowClean.push( '"' + (thisRow.status != null && thisRow.status !== undefined ? thisRow.status : '') + '"' );
                thisRowClean.push( '"' + (thisRow.yearMakeModelTrim != null && thisRow.yearMakeModelTrim !== undefined ? thisRow.yearMakeModelTrim : '') + '"' );
                thisRowClean.push( '"' + (thisRow.odometer != null && thisRow.odometer !== undefined ? thisRow.odometer : '') + '"' );
                thisRowClean.push( '"' + (thisRow.reserve != null && thisRow.reserve !== undefined ? thisRow.reserve : '') + '"' );
                let auctionLights = '';
                if( thisRow.lightObjList != null && thisRow.lightObjList !== undefined ){
                    thisRow.lightObjList.forEach(thisLight =>{
                        auctionLights += thisLight.color + ',';
                    })
                    auctionLights = auctionLights.replace(/,\s*$/, "");
                }
                thisRowClean.push('"' + auctionLights + '"' );
                dataCleaned.push(thisRowClean);
            });
        }
        return dataCleaned;
    }
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Fires the Toast message for notifications to the user
    fireToast( title, message, variant="info", mode="dismissable", messageData=[]){
        // title = Title of the Toast, displayed as a Heading (Required)
        // message = String message (Required), can contain {0}...{N} indicating an index a messageData will replace
        // messageData = list of string or object{url,label} to replace the index in message. Default = []
        // variant = info (default) (gray), success (green), warning (yellow), error (red)
        // mode = dismissable (default) (remains 3 seconds or can be closed), pester (remains 3 seconds), sticky (has to be closed)
        const event = new ShowToastEvent({
            "title" : title,
            "message" : message,
            "messageData" : messageData,
            "mode" : mode,
            "variant" : variant
        });
        this.dispatchEvent( event );
    }
    // Inatializes the table back to how it is on load. Used on
    // Page load, refresh table button, and when the filter is changed
    initialize( result ){
        var returnVal = JSON.parse( result );
        if( returnVal.hasError ){
            this.fireToast( returnVal.messgeTitle, returnVal.message, "warning", "dismissable" );
        }else{
            var allIlcRows = this.setSpecialTableValues( returnVal.allIlcRows );
            this.allIlcRows = allIlcRows;
            this.filteredIlcRows = allIlcRows;
            this.totalNumOfRows = this.filteredIlcRows.length;
            this.setDisplayedIlcRows(0);
            this.calculatePages();
            this.navigateToPaginationPage(1);
        }
        this.lastRefreshed = Date.now();
        this.filterName = returnVal.filterName;
        this.newFilterChanges.filterId = returnVal.filterId;
        this.newFilterChanges.reloadTable = false;
        this.currentFilterId = returnVal.filterId;
        this.showActions = false;
        this.searchValue = '';
        this.lastOnBlurValue = '';
    }
    // Sets the table specific things that happen in JS
    setSpecialTableValues( ilcRows ){
        var ilcList;
        ilcRows.forEach( thisRow => {
            thisRow.lightObjList = [];
            if( thisRow.lights !== undefined && thisRow.lights != null && thisRow.lights != '' ){
                if( thisRow.lights.includes('g') ) thisRow.lightObjList.push({class:'greenLight', color:'Green'});
                if( thisRow.lights.includes('y') ) thisRow.lightObjList.push({class:'yellowLight', color:'Yellow'});
                if( thisRow.lights.includes('b') ) thisRow.lightObjList.push({class:'blueLight', color:'Blue'});
                if( thisRow.lights.includes('r') ) thisRow.lightObjList.push({class:'redLight', color:'Red'});
            }
        });
        ilcList = ilcRows;
        return ilcList;
    }
    // Sets the displayed Ilc Rows and the Header values needed based on pagination and rows per page
    setDisplayedIlcRows( startingIndex ){
        this.displayedIlcRows = this.filteredIlcRows.slice( startingIndex, startingIndex + parseInt(this.tableMaxRowSize) );;
        var endRange = startingIndex + parseInt(this.tableMaxRowSize) > this.totalNumOfRows ? this.totalNumOfRows : startingIndex + parseInt(this.tableMaxRowSize);
        this.rangedShowing = (startingIndex + 1) + ' - ' + endRange;
    }
    // Updates how many total pages should be available. Changes when Rows Per Page change (or how many records there are like on refresh or new filter)
    calculatePages(){
        this.totalNumOfPages = Math.ceil( this.filteredIlcRows.length / parseInt(this.tableMaxRowSize) );
    }
    // Handles the navigation to a specifc page number, what rows should be displayed, and the pagination stylign of the bar
    navigateToPaginationPage( selectedPageNumber ){
        var pageWrappersList = [];
        var lowerBound;
        var upperBound;
        if( selectedPageNumber + this.displayedPageLimit/2 >= this.totalNumOfPages ){
            upperBound = this.totalNumOfPages;
            lowerBound = upperBound - this.displayedPageLimit < 0 ? 0 : upperBound - this.displayedPageLimit;
        }else if( selectedPageNumber - this.displayedPageLimit/2 < 0 ){
            lowerBound = 0;
            upperBound = this.displayedPageLimit;
        }else{
            lowerBound = selectedPageNumber - this.displayedPageLimit/2;
            upperBound = selectedPageNumber + this.displayedPageLimit/2;
        }
        for( var i=lowerBound+1; i <= upperBound; i++ ){
            var newPW = {};
            newPW.label = i;
            if( i == selectedPageNumber ){
                newPW.variant = 'brand'
            }else{
                newPW.variant = 'neutral';
            }
            pageWrappersList.push(newPW);  
        }
        if( selectedPageNumber == 1 ){
            this.disableFP = true;
        }else{
            this.disableFP = false;
        }
        if( selectedPageNumber == this.totalNumOfPages ){
            this.disableNL = true;
        }else{
            this.disableNL = false;
        }
        this.currentPage = selectedPageNumber;
        this.pagesList = pageWrappersList;
        this.rowNumberOffset =  (selectedPageNumber - 1) * this.tableMaxRowSize;
        this.setDisplayedIlcRows(this.rowNumberOffset);
    }
    // Sorts data in a specific direction by a certain field
    sortData(fieldName, sortDirection){
        if( sortDirection == 'asc' ){
            this.filteredIlcRows.sort( (a,b) => (a[fieldName] > b[fieldName]) ? 1 : -1 );
        }else if( sortDirection == 'desc' ){
            this.filteredIlcRows.sort( (a,b) => (a[fieldName] < b[fieldName]) ? 1 : -1 );
        }
        this.navigateToPaginationPage(1);
    }
    /***********************Event Methods****************************/
    // Handles logic when the launch auction close event fires
    handleLaunchAuctionClose( event ){
        if( event.detail.showConfirmationScreen ){
            this.showConfirmationVariables = event.detail.showConfirmationScreen;
            this.launchType = event.detail.launchType;
            if( this.editScheduleClicked ){
                let currentTableRows = this.confirmationVariables.tableRows;
                // Merge new data to the table
                event.detail.tableRows.forEach( adjustedRow => {
                    var foundRowIndex = currentTableRows.findIndex( thisRow => { return adjustedRow.Id == thisRow.Id } );
                    if( foundRowIndex != -1 ){
                        currentTableRows[foundRowIndex] = adjustedRow;
                    }
                } );
                event.detail.tableRows = currentTableRows;
            }
            this.confirmationVariables = event.detail;
        }
        this.editScheduleClicked = false;
        this.showLaunchAuction = false;
    }
    // catches the close event for Terminate Auction
    handleTerminateAuctionClose( event ){
        this.showTerminateAuction = false;
        if( event.detail.refreshTable ){
            this.handleRefreshTable('');
        }
    }
    // Navigates the page to the Import Manager
    handleImportManagerNavigation( event ){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Import_Manager'
            }
        });
    }
    // Opens the Launch Auction Modal
    handleLaunchAuctionClick( event ){
        this.ilcsToPass = JSON.stringify( this.selectedRows );
        this.showLaunchAuction = true;
    }
    // Opens the Terminate Auction Model
    handleTerminateAuctionClick( event ){
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/AuctionKillWrapper?ilcJson=' + JSON.stringify( this.selectedRows )
        //     }
        // });
        this.ilcsToPass = JSON.stringify( this.selectedRows );
        this.showTerminateAuction = true;
    }
    // Opens and Closes the Filter Manager
    handleFilterManager( event ){
        if( this.filterManagerIsSelected ){
            this.filterManagerIsSelected = false;
            this.filterManagerVariant = 'neutral';
            // checks whether the filters change and we need to reload the table
            if( this.newFilterChanges.reloadTable ){
                this.handleRefreshTable( event );
            }
        }else{
            this.filterManagerIsSelected = true;
            this.filterManagerVariant = 'brand';
        }
    }
    // Updates what the Filter Id is when the Filter Manager changes it
    handleUpdateFilterId(event){
        this.newFilterChanges = event.detail;
    }
    // Handles the logic when updating the rows per page size
    handleRowPerPageChange( event ){
        this.toggleSpinner();
        setTimeout( () => {
            if( event.detail.value == 'All' ){
                this.tableMaxRowSize = this.filteredIlcRows.length
                this.rowsPerPageLabel = 'All';
            }else{
                this.tableMaxRowSize = event.detail.value;
                this.rowsPerPageLabel = event.detail.value;
            }
            this.rowsDisplayedOptions.forEach(rowPerPageOption => {
                if( event.detail.value == rowPerPageOption.label && !rowPerPageOption.isSelected ){
                    rowPerPageOption.isSelected = true;
                }else if( event.detail.value != rowPerPageOption.label && rowPerPageOption.isSelected ){
                    rowPerPageOption.isSelected = false;
                }
            });
            this.calculatePages();
            this.navigateToPaginationPage(1);
            this.toggleSpinner();
        },0);
    }
    // Handles what page to go to in Pagination bar
    handlePaginationOnclick( event ){
        var pageIndex;
        if( event.target.label == 'First' ){
            pageIndex = 1;
        }else if( event.target.label == 'Previous' ){
            pageIndex = this.currentPage - 1;
        }else if( event.target.label == 'Next' ){
            pageIndex = this.currentPage + 1;
        }else if( event.target.label == 'Last' ){
            pageIndex = this.totalNumOfPages;
        }else{
            pageIndex = event.target.label;
        }
        this.toggleSpinner();
        setTimeout( () => {
            this.navigateToPaginationPage( pageIndex );
            this.selectedRows = [];
            this.toggleSpinner();
        },0);
    }
    // Runs onChange of the serachbar and is a running value of what is changing. actual search happens onBlur
    handleSearchValueAssignment( event ){
        this.searchValue = event.detail.value;
    }
    // Runs on keyup, which is button press more or less, of the search. Looks for enter and searches.
    handleOnKeyUpSearch( event ){
        if( event.keyCode == 13 ) this.handleSearchTable();
    }
    // Handles Searching the table. 
    // Search happens via contains. It is case insensitve.
    handleSearchTable(){
        if( this.searchValue != this.lastOnBlurValue ){
            this.toggleSpinner();
            setTimeout(() => {
                this.lastOnBlurValue = this.searchValue;
                var searchVal = this.searchValue.toLowerCase().trim();
                
                if( searchVal === undefined || searchVal == '' ){
                    this.filteredIlcRows = this.allIlcRows;
                    this.displayedIlcRows = this.filteredIlcRows.slice( 0,this.tableMaxRowSize );
                }else{
                    var newFilteredIlcRows = [];
                    var newDisplayedIlcRows = [];
                    var commaSeparatedSearch = [];
                    if( searchVal.includes(',') ){
                        commaSeparatedSearch = searchVal.split(',');
                        commaSeparatedSearch.forEach( thisVal => {
                            thisVal.trim();
                        });
                    }else{
                        commaSeparatedSearch.push(searchVal);
                    }
                    for( var i=0; i<this.allIlcRows.length; i++ ){
                        var thisIlcRow = this.allIlcRows[i];
                        // VIN stays as top if to make search faster as thats the most common serach value.
                        if( (thisIlcRow.vinName != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.vinName.toLowerCase().includes(thisSearchValue))) ||
                            (thisIlcRow.clientName != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.clientName.toLowerCase().includes(thisSearchValue))) ||
                            (thisIlcRow.locationName != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.locationName.toLowerCase().includes(thisSearchValue))) || 
                            (thisIlcRow.stockNumber != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.stockNumber.toLowerCase().includes(thisSearchValue))) || 
                            (thisIlcRow.status != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.status.toLowerCase().includes(thisSearchValue))) || 
                            (thisIlcRow.yearMakeModelTrim != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.yearMakeModelTrim.toLowerCase().includes(thisSearchValue))) || 
                            (thisIlcRow.odometer != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.odometer.toString().toLowerCase().includes(thisSearchValue))) || 
                            (thisIlcRow.reserve != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.reserve.toString().toLowerCase().includes(thisSearchValue))) ||
                            (thisIlcRow.lights != null && commaSeparatedSearch.some(thisSearchValue => thisIlcRow.lights.toLowerCase().includes(thisSearchValue))) 
                        ){
                            newFilteredIlcRows.push( thisIlcRow );
                            if( newDisplayedIlcRows.length < this.tableMaxRowSize ) newDisplayedIlcRows.push( thisIlcRow );
                        }
                    }
                    this.filteredIlcRows = newFilteredIlcRows;
                    this.displayedIlcRows = newDisplayedIlcRows;
                }
                this.totalNumOfRows = this.filteredIlcRows.length;
                this.calculatePages();
                this.navigateToPaginationPage(1);
                this.toggleSpinner();
            });
        }
    }
    // On refresh click, refresh the table with server side data.
    handleRefreshTable( event ){
        this.toggleSpinner();
        getUpdatedData({filterId : JSON.stringify(this.newFilterChanges.filterId)})
            .then(result => {
                this.initialize(result);
            })
            .catch(error => {
                this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
            })
            .finally(() => {
                this.toggleSpinner();
            })
        ;
    }
    // on sort, updates header values and sorts data
    handleOnSort(event){
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortData(fieldName, sortDirection);
        var sortByCol = this.columns.find(column => fieldName === column.fieldName);
        this.sortedBy = fieldName;
        this.sortedByLabel = sortByCol.label;
        this.sortedDirection = sortDirection;
    }
    // On Selection of row, handles setting those selected Rows and hiding/showing the actions bar
    handleRowSelection( event ){
        this.selectedRows = event.detail.selectedRows;
        this.showActions = event.detail.selectedRows.length > 0 ? true : false;
    }
    // On Selection of Row on Confirmation Screen, shows and hides actions in the header
    handleConfirmationRowSelection( event ){
        this.confirmationSelectedRows = event.detail.selectedRows;
        this.confirmationSelectedRowsShow = event.detail.selectedRows.length > 0 ? true : false;
    }
    // On Click of Cancel on the Confirmation screen, 
    // it throws a "are you sure" message and then returns the table to pre-confirmation page
    handleConfirmationCancel( event ){
        if( window.confirm( 'Are you sure you want to cancel?' ) ){
            this.toggleSpinner();
            setTimeout( () => {
                this.showConfirmationVariables = false;
                this.handleRefreshTable( event );
                this.toggleSpinner();
            },0);
        }
    }
    // On Click of Confirm, runs the needed action
    handleConfirmationConfirm( event ){
        if( this.confirmationVariables.actionExecutedTitle == 'Bulk Launch' ){
            console.log(JSON.stringify(this.confirmationVariables.tableRows));
            var errorRows = '';
            for( var i=0; i<this.confirmationVariables.tableRows.length; i++ ){
                let thisRow = this.confirmationVariables.tableRows[i];
                if( thisRow.reserve == null || thisRow.reserve === undefined || thisRow.reserve == 0 ){
                    errorRows = errorRows + (i+1) + ',';
                }
            }
            if( errorRows != '' ){
                errorRows = errorRows.slice(0, -1);
                this.fireToast( 'Please update the Reserve Price of the following rows:', errorRows, 'error', 'pester');
                return;
            }
            this.toggleSpinner();
            launchAuction({
                    ilcRowsJson : JSON.stringify(this.confirmationVariables.tableRows),
                    launchType : this.confirmationVariables.launchType 
                }).then(result => {
                    var data = JSON.parse(result);
                    if( data.statusCode >= 400 ){
                        this.fireToast( 'There was an issue launching your cars', data.statusMessage, "error", "sticky" );
                    }else if( data.statusCode == 205 ){
                        this.confirmationVariables.tableRows = data.ilcsToShowList;
                        this.fireToast( 'There was an issue scheduling some of your cars.', data.statusMessage, "warning", "sticky" );
                    }else{
                        this.showConfirmationVariables = false;
                        this.handleRefreshTable( event );
                        this.fireToast( 'Your cars were succesfully launched', 'Please wait a couple of minutes for the data to update in Salesforce', "success", "pester" );
                    }
                })
                .catch(error => {
                    this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
                })
                .finally( () => {
                    this.toggleSpinner();
                })
            ;
            }
    }
    // On Confirmation page, if selected, a modal shows up to edit the schedule
    handleEditSchedule( event ){
        this.ilcsToPass = JSON.stringify(this.confirmationSelectedRows);
        this.editScheduleClicked = true;
        this.showLaunchAuction = true;
    }
    // On Confirmation Page, handle save of inline edit. Currently onlw works on reserve
    handleConfirmationInlineEdit( event ){
        event.detail.draftValues.forEach( edittedValue => {
            let thisRow = this.confirmationVariables.tableRows.find( thisRow => {return thisRow.Id == edittedValue.Id});
            thisRow.reserve = edittedValue.reserve;
        });
        this.suppressBottomBar = true;
    }
    // On Confirmation Page, handles hiding and showing bottom bar
    handleConfirmationInlineCellChange( event ){
        this.suppressBottomBar = false;
    }
}