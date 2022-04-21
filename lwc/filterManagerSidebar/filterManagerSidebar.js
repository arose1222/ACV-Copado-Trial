/* This is the Filter Manager Sidebar javascript file
 * @author James Andre LaCour
*/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUpdateFilterManager from '@salesforce/apex/FilterManagerSidebarController.createUpdateFilter';
import doinit from '@salesforce/apex/FilterManagerSidebarController.getAllFiltersAndSets';
import createUpdateFilterSet from '@salesforce/apex/FilterManagerSidebarController.createUpdateFilterSet';
import deleteFilter from '@salesforce/apex/FilterManagerSidebarController.deleteFilter';
import activateDeactivateFilter from '@salesforce/apex/FilterManagerSidebarController.modifyFilterPinnedFlag';
// import apexSearch from '@salesforce/apex/FilterManagerSidebarController.getLookupSearch';

/***********************Final Variables**************************/
const visibilityOptions = [ {label: 'Private', value: 'Private'}, {label: 'Public', value: 'Public'} ];
const filtersDropdownOptions = 
    [
        {label: 'Cars to Show', value:'AllOrMyCars', filterType: 'dropdown', options:[{label:'All', value:'All'}, {label:'My', value:'My'}], apiField:false},
        // {label: 'Dealer Group', value: 'DealerGroup', apiName:'Group__c', filterType: 'Text', apiField:false},
        {label: 'Client', value: 'Client__r.Name', filterType: 'text', apiField:true},
        {label: 'Year, Make, Model, Trim', value: 'Year_Make_Model_Trim_Text__c', filterType: 'text', apiField:true},
        {label: 'Dealer Id', value: 'Dealer_Id__c', filterType: 'text', apiField:true},
        {label: 'Status', value: 'Status__c', filterType: 'dropdown', options:[
            {label: 'Blank', value: ''},
            {label:'Vehicle Received',value:'Vehicle Received'},
            {label:'Vehicle Scheduled for Inspection',value:'Vehicle Scheduled for Inspection'},
            {label:'Vehicle Inspected, Ready for Auction',value:'Vehicle Inspected, Ready for Auction'},
            {label:'Vehicle Scheduled for Auction',value:'Vehicle Scheduled for Auction'},
            {label:'Vehicle in Auction',value:'Vehicle in Auction'},
            {label:'Vehicle in Negotiation',value:'Vehicle in Negotiation'},
            {label:'Vehicle Sold',value:'Vehicle Sold'},
            {label:'Vehicle Unsold',value:'Vehicle Unsold'},
            {label:'Vehicle Archived',value:'Vehicle Archived'}], apiField:true},
        {label: 'Archived', value: 'Archived__c', filterType: 'dropdown', options:[{label:'True', value:'True'}, {label:'False', value:'False'}], apiField:true},
        {label: 'Location', value: 'Location_Text__c', filterType: 'text', apiField:true},
        {label: 'Stock Number', value: 'Stock_Number__c', filterType: 'text', apiField:true},
        {label: 'Lights', value: 'Auction_Lights_Concatenation__c', filterType: 'dropdown', options:[{label: 'Blank', value: ''},{label:'Green',value:'Green'},{label:'Yellow',value:'Yellow'},{label:'Red',value:'Red'},{label:'Blue',value:'Blue'}], apiField:false},
        {label: 'Last Modified Date', value: 'LastModifiedDate', filterType: 'text', apiField:false},
        {label: 'Auction Start Date', value: 'Auction_Start_Datetime__c', filterType: 'text', apiField:false},
        {label: 'Dealer Type', value: 'Dealer_Type__c', filterType: 'dropdown', options:[
            {label: 'Blank', value: ''},{label:'Franchise', value:'Franchise'}, {label:'Independent', value:'Independent'}, {label:'Independent - ACV Certified', value:'Independent - ACV Certified'}, {label:'Wholesaler', value:'Wholesaler'}, {label:'Commercial', value:'Commercial'}
        ], apiField:true},
        {label: 'Reserve', value: 'Reserve__c', filterType: 'text', apiField:true}
    ];
const fsOperatorOptions = 
    [
        { label: 'Equals', value: 'Equals' },
        { label: 'Does Not Equals', value: 'Does Not Equals'},
        { label: 'Contains', value: 'Contains'},
        { label: 'Does Not Contain', value: 'Does Not Contain'}
    ];
/***********************JS Code**********************************/
export default class FilterManagerSidebar extends LightningElement {
    // Spinner Variables
    @track activeSpinner = false;                                                       // Spinner Variable
    // Filter Variables                 
    @track filterList = [];                                                             // Holds list of All Filters Available to this User
    permissiontypeOptions = visibilityOptions;                                          // Options for Visibility (Public or Private)
    @track showFilterScreen = true;                                                     // whether to render the see all Filters screen    
    @track showCreateEditFilterScreen = false;                                          // whether to render the edit/create filter screen
    permissionTypeValue = 'Private';                                                    // value Visibility will be set to
    filterManagerNameValue = '';                                                        // value name will be set to
    // Filter Set Variables                 
    @track filterSetList = [];                                                          // Holds the list of Filter Sets a filter has
    filterOptions = filtersDropdownOptions;                                             // Options you can filter the table on
    filterSetOperatorOptions = fsOperatorOptions;                                       // Operators you can use in the filter set
    @track showFilterSetScreen = false;                                                 // whether to render the see all fitler set screen
    @track showCreateEditFilterSetScreen = false;                                       // whether to render the edit/create filter screen
    filterSetField = '';                                                                // value of the field the filter set will have
    filterSetOperator = '';                                                             // value of the operator the filter set will have
    filterSetValue = '';                                                                // value of the value the filter set will have
    lookupErrors = [];
    @track showFilterSetValueInput = false;                                             // whether to render a text box for the value of a fitler set during edit/creation
    @track showFilterSetValueCombobox = false;                                          // whether to render a dropdown for the value of a filter set during edit/creation
    @track showFilterSetValueLookup = false;
    @track filterSetValueOptions = [];                  
    // Delete Modal Variables                   
    @track showDeleteModal = false;                                                     // Whether to show the delete model
    // Screen Variables                 
    @track hasChanged = false;                                                          // Indicates if the table should be reloaded due to the active filter being changed
    originalActiveFilter = {};                                                          // The filter last at load on the screen. used to compare whether filter has changed
    originalActiveFilterSet = {};                                                       // The filter set at load on the screen. used to compare whether filter sets changed
    activeFilter = null;                                                                // the current active filter
    @track headerLabel = 'Filters';                                                     // the header of the sidebar
    wizardStates = {                                                                    // the 4 states the wizard can be in.
        1 : {
            headerLabel: 'Filters',
            showBackButton: false,
            hasFilters: false
        },
        1.5 : {
            headerLabel: '',            // For Create, will say "Filters", for Edit will say "Edit {SelectedFilters Name}"
            showBackButton: true,
            negativeAction: '',         // Cancel or Delete
            positiveAction: '',         // Create or Save
            selectedFilterName : '',
            selectedFilterVisibility: ''
        },
        2 : {
            headerLabel: '',
            showBackButton: true,
            hasFilterSets: false,
            selectedFilter: {}
        },
        2.5 : {
            headerLabel: '',
            showBackButton: true,
            negativeAction: '',         // Cancel or Delete
            positiveAction: '',         // Create or Save
            field: '',
            operator: '',
            value: ''
        }
    };
    currentWizardStateNumber = 1;                                                       // The current wizard screen page number
    @track currentWizardState = this.wizardStates[this.currentWizardStateNumber];       // The current wizard screen state
    /***********************Initalization****************************/
    //Runs on Page Load
    connectedCallback( ){
        this.toggleSpinner();
        doinit({})
            .then(result => {
                var resultParsed = JSON.parse(result);
                if( resultParsed.hasError ){
                    this.fireToast(resultParsed.messageTitle, resultParsed.message, "info", "sticky");    
                }else{
                    this.initialize(resultParsed);
                    this.setOriginalValues(this.filterList)
                }
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
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Generic method to fire a toast message
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
    // The intializing of the component. Takes in the Datawrapper parsed from apex
    initialize( data ){
        this.filterList = data.allFiltersAndSetsList;
        this.setHasFilter(data.allFiltersAndSetsList);
    }
    // Sets the Original Values that will be used to compare whether we need to reload the table
    setOriginalValues( filterList ){
        filterList.forEach( filter => {
            if( filter.assignmentFilter.Pinned__c ){
                this.originalActiveFilter = JSON.stringify(filter.assignmentFilter);
                this.originalActiveFilterSet = filter.filter.Filter_Items_JSON__c;
                this.activeFilter = filter;
            }
        })
    }
    // Checks whether the filter has changed or the filter set and sends it to the parent LWC
    checkHasChanged( newFilterJson, newFilterSetJson ){
        if( newFilterJson != this.originalActiveFilter ){
            this.hasChanged = true;
        }else if( newFilterJson == this.originalActiveFilter && newFilterSetJson != this.originalActiveFilterSet ){
            this.hasChanged = true;
        }else{
            this.hasChanged = false;
        }
        var filterId = this.activeFilter == null ? '' : this.activeFilter.filter.Id;
        const lwcEvent= new CustomEvent('filterselection', {
            detail : {
                filterId : filterId,
                reloadTable : this.hasChanged
            }
        });
        this.dispatchEvent(lwcEvent);
    }
    // sets the screen variables for when the wizard navigates to a certain page
    setWizardScreen( stateNumber ){
        this.currentWizardStateNumber = stateNumber;
        this.currentWizardState = this.wizardStates[stateNumber];
        switch(stateNumber){
            case 1:
                this.showFilterScreen = true;
                this.showCreateEditFilterScreen = false;
                this.showFilterSetScreen = false;
                this.showCreateEditFilterSetScreen = false;
                break;
            case 1.5:
                this.showFilterScreen = false;
                this.showCreateEditFilterScreen = true;
                this.showFilterSetScreen = false;
                this.showCreateEditFilterSetScreen = false;
                break;
            case 2:
                this.showFilterScreen = false;
                this.showCreateEditFilterScreen = false;
                this.showFilterSetScreen = true;
                this.showCreateEditFilterSetScreen = false;
                break;
            case 2.5:
                this.showFilterScreen = false;
                this.showCreateEditFilterScreen = false;
                this.showFilterSetScreen = false;
                this.showCreateEditFilterSetScreen = true;
                break;
        }
    }
    // Sets whether we have filters created or don't
    setHasFilter( allFilters ){
        if( allFilters.length > 0 ){
            this.wizardStates[1].hasFilters = true;
        }else{
            this.wizardStates[1].hasFilters = false;
        }
    }
    // Sets whether we have filter sets or don't
    setHasFilterSets( filterItemsJSON ){
        var filterItems = JSON.parse(filterItemsJSON);
        if( filterItems.objectFields.length + filterItems.logicFields.length == 0 ){
            this.wizardStates[2].hasFilterSets = false;
        }else{
            var fsList = [];
            filterItems.logicFields.forEach( thisElement => {
                if( typeof thisElement.value == 'string' ){
                    thisElement.valueTextToShow = thisElement.value;
                }else if( Array.isArray(thisElement.value) ){
                    // This is for Lookup
                    let tempValueTextToShow = '';
                    thisElement.value.forEach( innerValue => {
                        tempValueTextToShow = tempValueTextToShow + innerValue.title + ',';
                    });
                    thisElement.valueTextToShow = tempValueTextToShow.slice(0, -1);
                }
            });
            fsList = fsList.concat(filterItems.logicFields);
            filterItems.objectFields.forEach( thisElement => {
                if( typeof thisElement.value == 'string' ){
                    thisElement.valueTextToShow = thisElement.value;
                }else if( Array.isArray(thisElement.value) ){
                    // This is for Lookup
                    let tempValueTextToShow = '';
                    thisElement.value.forEach( innerValue => {
                        tempValueTextToShow = tempValueTextToShow + innerValue.title + ',';
                    });
                    thisElement.valueTextToShow = tempValueTextToShow.slice(0, -1);
                }
            });
            fsList = fsList.concat(filterItems.objectFields);
            this.filterSetList = fsList;
            this.wizardStates[2].hasFilterSets = true;
        }
    }
    // Used to Create or Update a Filter
    updateFilter( actionName, filter, goBack ){
        var filterManager = {};  
        var successMessage = '';      
        if( actionName == 'Create' ){
            filterManager.filter = filter;
            successMessage = 'Created';
        }else if( actionName == 'Save' ){
            successMessage = 'Updated'
            filterManager = this.filterList.filter( filter => {return filter.filter.Name == this.wizardStates[1.5].selectedFilterName;} )[0];
            filterManager.filter.Name = filter.Name != this.wizardStates[1.5].selectedFilterName ? filter.Name : this.wizardStates[1.5].selectedFilterName;
            filterManager.filter.Visibility__c = filter.Visibility__c != this.wizardStates[1.5].selectedFilterVisibility ? filter.Visibility__c : this.wizardStates[1.5].selectedFilterVisibility;
        }
        this.toggleSpinner();
        createUpdateFilterManager({filterCreateUpdate: JSON.stringify(filterManager)})
            .then(result => {
                var resultParsed = JSON.parse(result);
                if( resultParsed.hasError ){
                    this.fireToast(resultParsed.messageTitle, resultParsed.message, "error", "sticky");    
                }else{
                    this.initialize(resultParsed);
                    if( goBack ) this.handleBackButton('');
                    this.fireToast(filterManager.filter.Name + ' was Successfully ' + successMessage + '.', '', "success");
                }
            })
            .catch(error => {
                this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
            })
            .finally(() => {
                this.toggleSpinner();
            })
        ;
    }
    // Handles Updating, Creating, and Deleting of Filter Set
    updateFilterSet( actionName, filterSetAdjusted, index, goBack ){
        var successMessage = '';
        var thisFilterSet = {};
        var activationToggle = false;
        var filterItem = this.wizardStates[2].selectedFilter;
        var filterItemJson = JSON.parse(filterItem.filter.Filter_Items_JSON__c);
        var jsonSectionToAdjust = '';
        var filterOption = this.filterOptions.filter(filter => {return filter.value == filterSetAdjusted.field;})[0];
        if( filterOption.apiField  ){
            jsonSectionToAdjust = 'objectFields';
        }else{
            jsonSectionToAdjust = 'logicFields';
        }
        index = index >= filterItemJson.logicFields.length ? index - filterItemJson.logicFields.length: index;
        if( actionName == 'Create' ){        
            successMessage = 'Created';
            //add to it
            filterSetAdjusted.isActive = true;
            filterSetAdjusted.label = filterOption.label;
            let valueToAppend = typeof filterSetAdjusted.value == 'string' ? filterSetAdjusted.value : JSON.stringify(filterSetAdjusted.value);
            filterSetAdjusted.key = filterSetAdjusted.field + filterSetAdjusted.operator + valueToAppend;
            filterSetAdjusted.canDelete = true;
            filterItemJson[jsonSectionToAdjust].push(filterSetAdjusted);
            thisFilterSet = filterSetAdjusted;
        }else if( actionName == 'Save' ){
            successMessage = 'Updated';
            var existingFilterItem = filterItemJson[jsonSectionToAdjust][index];
            if(filterSetAdjusted.field !== undefined) existingFilterItem.field = filterSetAdjusted.field;
            if(filterSetAdjusted.operator !== undefined) existingFilterItem.operator = filterSetAdjusted.operator;
            if(filterSetAdjusted.value !== undefined) existingFilterItem.value = filterSetAdjusted.value;
            if(filterSetAdjusted.isActive !== undefined){
                existingFilterItem.isActive = filterSetAdjusted.isActive;
                activationToggle = true;
            }
            thisFilterSet = existingFilterItem;
        }else if( actionName == 'Delete' ){
            successMessage = 'Deleted';
            thisFilterSet = filterItemJson[jsonSectionToAdjust][index];
            filterItemJson[jsonSectionToAdjust].splice(index,1);
        }
        filterItem.filter.Filter_Items_JSON__c = JSON.stringify(filterItemJson);
        var filterId = filterItem.filter.Id;
        this.toggleSpinner();
        console.log(JSON.stringify(filterItemJson));
        createUpdateFilterSet({filterIdJson: JSON.stringify(filterId), fitlerItemsJson:JSON.stringify(filterItemJson)})
            .then(result => {
                var resultParsed = JSON.parse(result);
                if( resultParsed.hasError ){
                    this.fireToast(resultParsed.messageTitle, resultParsed.message, "error", "sticky");    
                }else{
                    this.checkHasChanged( JSON.stringify(filterItem.assignmentFilter), JSON.stringify(filterItemJson) );
                    this.initialize(resultParsed);
                    this.setHasFilterSets( JSON.stringify(filterItemJson) );
                    if(goBack) this.handleBackButton( '' );
                    if( !activationToggle) this.fireToast('Filter by ' + thisFilterSet.label + ' was Successfully ' + successMessage + '.', '', "success");
                }
            })
            .catch(error => {
                this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
            })
            .finally(() => {
                this.showDeleteModal = false;
                this.toggleSpinner();
            })
        ;
    }
    // sets what should happen with the Value input in Filter Set edit/creation screen
    setFilterSetValueType( inputType, options ){
        switch(inputType){
            case 'text':
                this.showFilterSetValueInput = true;
                this.showFilterSetValueCombobox = false;
                this.filterSetValueOptions = [];
                this.showFilterSetValueLookup = false;
                break;
            case 'dropdown':
                this.showFilterSetValueInput = false;
                this.showFilterSetValueCombobox = true;
                this.filterSetValueOptions = options;
                this.showFilterSetValueLookup = false;
                break;
            case 'lookup':
                this.showFilterSetValueInput = false;
                this.showFilterSetValueCombobox = false;
                this.filterSetValueOptions = options;
                this.showFilterSetValueLookup = true;
                if( this.currentWizardState.selectedFilterSetValue === '' ) this.currentWizardState.selectedFilterSetValue = [];
                break;
            case 'reset':
                this.showFilterSetValueInput = false;
                this.showFilterSetValueCombobox = false;
                this.filterSetValueOptions = [];
                this.showFilterSetValueLookup = false;
                break;
        }
    }
    /***********************Event Methods****************************/
    // Modification of Visibility in the Filter edit screen
    handlePermissionTypeChange( event ){
        this.permissionTypeValue = event.detail.value;
    }
    // Modification of Name in the Filter Edit Screen
    handleFilterManagerNameChange( event ){
        this.filterManagerNameValue = event.detail.value;
    }
    // Sends close event to the parent LWC to indicate to not display this sidebar
    handleOnClose(event){
        const lwcEvent= new CustomEvent('close', {});
        this.dispatchEvent(lwcEvent);
    }
    // Handles the updating of Active Filter selected
    handleFilterSelection( event ){
        var newAssignmentFilter = {};
        var newFilterSet = {};
        var filtersAdjusted = [];
        this.filterList.forEach( filter => {
            if( filter.assignmentFilter.Pinned__c && filter.filter.Name != event.target.name && event.detail.checked ){
                filter.assignmentFilter.Pinned__c = false;
                filtersAdjusted.push(filter);
            }else if( filter.filter.Name == event.target.name ){
                filter.assignmentFilter.Pinned__c = event.detail.checked;
                if( event.detail.checked ){
                    this.activeFilter = filter;
                    newAssignmentFilter = filter.assignmentFilter;
                    newFilterSet = filter.filter.Filter_Items_JSON__c;
                }else{
                    this.activeFilter = null;
                }
                filtersAdjusted.push(filter);
            }
        });
        this.toggleSpinner();
        this.checkHasChanged( JSON.stringify(newAssignmentFilter), newFilterSet );
        console.log( JSON.stringify(filtersAdjusted) );
        activateDeactivateFilter({ filtersToUpdate : JSON.stringify(filtersAdjusted)})
            .then( result => {
                var resultParsed = JSON.parse(result);
                if( resultParsed.hasError ){
                    this.fireToast(resultParsed.messageTitle, resultParsed.message, "error", "sticky");    
                }else{
                    this.initialize(resultParsed);
                }
            })
            .catch( error => {
                this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
            })
            .finally(() => {
                this.toggleSpinner();
            })
        ;
    }
    // changes the current wizard state back a page
    handleBackButton( event ){
        var stateNumber = this.currentWizardStateNumber % 1 == 0 ? this.currentWizardStateNumber - 1 : this.currentWizardStateNumber - .5;
        this.setWizardScreen( stateNumber );
    }
    // Sets the needed variables for creation or modification screen of a Filter
    handleCreateEditFilter( event ){
        if( event.target.name == 'Create Filter'){
            this.wizardStates[1.5].headerLabel = 'Filters';
            this.wizardStates[1.5].negativeAction = 'Cancel';
            this.wizardStates[1.5].positiveAction = 'Create';
            this.wizardStates[1.5].selectedFilterName = '';
            this.wizardStates[1.5].selectedFilterVisibility = '';
            this.permissionTypeValue = 'Private';
            this.filterManagerNameValue = '';
        }else{
            var selectedFilter = this.filterList.filter(filter => {
                return filter.filter.Name == event.target.name;
            })[0];
            this.wizardStates[1.5].selectedFilterName = selectedFilter.filter.Name;
            this.wizardStates[1.5].selectedFilterVisibility = selectedFilter.filter.Visibility__c;
            this.wizardStates[1.5].headerLabel = 'Edit ' + event.target.name;
            this.wizardStates[1.5].negativeAction = 'Delete';
            this.wizardStates[1.5].positiveAction = 'Save';
            this.wizardStates[1.5].deleteItem = selectedFilter.filter.Id;
            this.wizardStates[1.5].deleteLabel = selectedFilter.filter.Name;
            this.wizardStates[1.5].deleteType = 'Filter';
            this.wizardStates[1.5].deleteIndex = event.target.value;
            this.permissionTypeValue = selectedFilter.filter.Visibility__c;
            this.filterManagerNameValue = selectedFilter.filter.Name;
        }
        this.setWizardScreen(1.5);
    }
    // Sets the wizard screen for creation or modification of a Filter Set
    handleCreateEditFilterSet( event ){
        var selectedFieldOption = {};
        if( event.target.name == 'Create Filter Set'){
            this.wizardStates[2.5].headerLabel = this.wizardStates[2].selectedFilter.filter.Name;
            this.wizardStates[2.5].negativeAction = 'Cancel';
            this.wizardStates[2.5].positiveAction = 'Create';
            this.filterSetField = '';
            this.filterSetOperator = '';
            this.filterSetValue = '';
            this.wizardStates[2.5].selectedFilterSetField = '';
            this.wizardStates[2.5].selectedFilterSetOperator = '';
            this.wizardStates[2.5].selectedFilterSetValue = '';
            selectedFieldOption.filterType = 'reset';
        }else{
            var selectedFilterSet = this.filterSetList[event.target.value];
            this.wizardStates[2.5].selectedFilterSetField = selectedFilterSet.field;
            this.wizardStates[2.5].selectedFilterSetOperator = selectedFilterSet.operator;
            this.wizardStates[2.5].selectedFilterSetValue = selectedFilterSet.value;
            selectedFieldOption = this.filterOptions.filter( filter => {return filter.value == selectedFilterSet.field} )[0];
            this.wizardStates[2.5].headerLabel = 'Edit Filter By ' + selectedFieldOption.label;
            if( selectedFilterSet.canDelete ){
                this.wizardStates[2.5].negativeAction = 'Delete';
            }else{
                this.wizardStates[2.5].negativeAction = 'Cancel';
            }
            this.wizardStates[2.5].positiveAction = 'Save';
            this.filterSetField = selectedFilterSet.field;
            this.filterSetOperator = selectedFilterSet.operator;
            this.filterSetValue = selectedFilterSet.value;
            this.wizardStates[2.5].deleteItem = selectedFilterSet.field;
            this.wizardStates[2.5].deleteLabel = 'Filter By ' + selectedFieldOption.label;
            this.wizardStates[2.5].deleteType = 'FilterSet';
            this.wizardStates[2.5].deleteIndex = event.target.value;
            this.wizardStates[2.5].goBack = true;
        }
        this.setWizardScreen(2.5);
        this.setFilterSetValueType(selectedFieldOption.filterType, selectedFieldOption.options);
    }
    // Handles what to do on delete or cancel of a Fitler during edit/creation screen
    handleNegativeActionFilter( event ){
        if( event.target.name == 'Delete' ){
            this.showDeleteModal = true;
        }else{
            this.handleBackButton(event);
        }
    }
    // Handles what to do on delete or cancel of a Fitler Set during edit/creation screen
    handleNegativeActionFilterSet( event ){
        if( event.target.name == 'Delete' ){
            this.showDeleteModal = true;
        }else{
            this.handleBackButton(event);
        }
    }
    // Handles setting the modal variables for Deletion of a Filter Set
    handleDeleteFilterSet( event ){
        var selectedFieldOption = this.filterOptions.filter( filter => {return filter.value == event.target.name} )[0];
        this.currentWizardState.deleteLabel = 'Filter By ' + selectedFieldOption.label;
        this.currentWizardState.deleteItem = event.target.name;
        this.currentWizardState.deleteType = 'FilterSet';
        this.currentWizardState.deleteIndex = event.target.value;
        this.currentWizardState.goBack = false;
        this.showDeleteModal = true;
    }
    // Handles Deleting either a Filter or a Filter Set
    handleDelete( event ){
        if( this.currentWizardState.deleteType == 'Filter'){
            //Get Id, Send to Delete
            var filterId = this.currentWizardState.deleteItem;
            this.toggleSpinner();
            deleteFilter({filterIdJson: JSON.stringify(filterId)})
                .then(result => {
                    var resultParsed = JSON.parse(result);
                    if( resultParsed.hasError ){
                        this.fireToast(resultParsed.messageTitle, resultParsed.message, "error", "sticky");
                    }else{
                        var deletedFilter = this.filterList.filter( filter => {return filter.filter.Id == filterId})[0];
                        if( deletedFilter.assignmentFilter.Pinned__c ){
                            this.activeFilter = null;
                            this.checkHasChanged('', '');
                        }
                        this.initialize(resultParsed);
                        this.handleBackButton('');
                        this.fireToast(deletedFilter.filter.Name + ' was Successfully Deleted.', '', "success");
                    }
                })
                .catch(error => {
                    this.fireToast('Error - Please contact a Salesforce Admin in ACV', error, "error", "sticky");
                })
                .finally(() => {
                    this.showDeleteModal = false;
                    this.toggleSpinner();
                })
            ;
        }else if( this.currentWizardState.deleteType == 'FilterSet' ){
            //Get JSON, Remove Row, Update Filter
            var fitlerSetToDelete = {
                field : this.currentWizardState.deleteItem
            }
            this.updateFilterSet( 'Delete', fitlerSetToDelete, this.currentWizardState.deleteIndex, this.currentWizardState.goBack );
        }
    }
    // Handles create and save on Filter edit screen, also stops it from saving if all fields aren't populated
    handlePositiveActionFilter( event ){
        if( this.filterManagerNameValue == '' || this.permissionTypeValue == '' ){
            this.fireToast('Please fill out all fields.', '', "error");
            return;
        }
        var filter = {
            attributes : {type:"Filter_Manager__c"},
            Name : this.filterManagerNameValue,
            Visibility__c : this.permissionTypeValue
        }
        this.updateFilter( event.target.name, filter, true);
    }
    // Handles create and save on Filter Sets edit screen, also stops it from saving if all fields aren't populated
    handlePositiveActionFilterSet( event ){
        if( this.filterSetField == '' || this.filterSetOperator == '' || this.filterSetValue == '' ){
            this.fireToast('Please fill out all fields.', '', "error");
            return;
        }
        var filterSet = {
            field    : this.filterSetField,
            operator : this.filterSetOperator,
            value    : this.filterSetValue,
        }
        this.updateFilterSet( event.target.name, filterSet, this.currentWizardState.deleteIndex, true );
    }
    // Handles the chevron arrow to go to fitler set from Filters
    handleNavigateToFilterSet( event ){
        this.wizardStates[2].headerLabel = event.target.name;
        var selectedFilter = this.filterList.filter( filter => {return filter.filter.Name == event.target.name;} )[0];
        this.wizardStates[2].selectedFilter = selectedFilter;
        this.setHasFilterSets(selectedFilter.filter.Filter_Items_JSON__c);
        this.setWizardScreen(2);
    }
    // Updates the needed value with Field changes on Filter Set edit/creation screen
    handleFieldChange( event ){
        this.filterSetField = event.detail.value;
        var selectedFieldOption = this.filterOptions.filter( filter => {return filter.value == event.detail.value} )[0];
        this.setFilterSetValueType(selectedFieldOption.filterType, selectedFieldOption.options);
    }
    // Updates the needed value with Operator changes on Filter Set edit/creation screen
    handleFilterSetOperatorChange( event ){
        this.filterSetOperator = event.detail.value;
    }
     // Updates the needed value with Value changes on Filter Set edit/creation screen
    handleFilterSetValueChange( event ){
        this.filterSetValue = event.detail.value;
    }
     // handles closing of delete modal
    handleCloseModal(){
        this.showDeleteModal = false;
    }
    // Handles updating the Filter Set when its activated or deactivated
    handleFilterSetSelection( event ){
        var filterSetAdjusted = {
            field : event.target.name,
            isActive : event.detail.checked
        }
        this.updateFilterSet( 'Save', filterSetAdjusted, event.target.value, false );
    }
    // runs on lookup Search - so anytime a couple of letters are put in
    handleLookupSearch(event) {
        var key = event.detail.dataitem;
        apexSearch({searchTerm:event.detail.searchTerm, apiName:this.filterOptions.filter( filter => {return filter.value == this.filterSetField} )[0].apiName})
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                    element.errors = [];
                    if(element.key === key){
                        element.setSearchResults(results);
                    }
                });
            })
            .catch(error => {
                // this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.lookupErrors = [error];
            })
        ;
    }
    // Runs on Branding Selection
    handleLookupChange(event){
        this.filterSetValue = event.target.getSelection();
    }
}