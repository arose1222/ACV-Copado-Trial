/**
 /**
 * @description List view that shows work orders filtered by territory and status
 * @name tracTerritoryFilterListView
 * @author Daniel Labonte, Traction on Demand
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-12
 */

import { LightningElement, track, api, wire } from 'lwc';
import getAllSObjectsApex from '@salesforce/apex/trac_TerritoryFilterListViewController.getAllSObjectsApex';
import getRecordCountApex from '@salesforce/apex/trac_TerritoryFilterListViewController.getRecordCountApex';
import getFilterDataApex from '@salesforce/apex/trac_TerritoryFilterListViewController.getFilterDataApex';
import updateDefaultFiltersOnUsers from '@salesforce/apex/trac_TerritoryFilterListViewController.updateDefaultFiltersOnUsers';
import getDefaultPreferenceVal from '@salesforce/apex/trac_TerritoryFilterListViewController.getDefaultPreferenceVal';

const TIME_OPT = [
    {'label': 'Today', 'value': 'Today'},
    {'label': 'Tomorrow', 'value': 'Tomorrow'},
    {'label': 'This Week', 'value': 'This Week'},
    {'label': 'All dates', 'value': 'All dates'},
    {'label': 'Overdue', 'value': 'Overdue'}];

const DEFAULT_COMBOBOX_VALS =[
    {'label': 'Include', 'value': 'Include'},
    {'label': 'Exclude', 'value': 'Exclude'},
    {'label': 'Filter', 'value': 'Filter'}
]


export default class TerritoryFilterListView extends LightningElement {

@api cardTitle;

@api recordLimit;
@api fields; //CSV string of API field names
@api icon;
@api sobject; //API name

@track openFilters = [];

@track statusFilterLabel = 'Status';
@track territoryFilterLabel = 'Territory';
@track workTypeFilterLabel = 'Work Type';
@track priorityTypeFilterLabel= 'Priorities';
@track dateFilterLabel = 'Date Option';
@track revolvingLabel = 'Revolving Appointments Option';

@track dateFilterComboboxVals = TIME_OPT;
@track revolvingFilterComboboxVals = DEFAULT_COMBOBOX_VALS;

@track dateFilterValues;
@track statusFilterValues;
@track prioritiesFilterValues;
@track territoryFilterValues;
@track workTypeFilterValues;
@track revolvingFilterValues;

@track fieldLabels;
@track fieldList;

@track selectedStatuses = [];
@track selectedTerritories = [];
@track selectedWorkTypes = [];
@track selectedPriorities = [];
@track selectedDate = 'All dates';
@track selectedRevolving = 'Exclude';

@track records;
@track sobjectCount=0;
@track sobjectTotal=0; // number of total records possible within limit

    getSelectedDate(evt){
        this.selectedDate = evt.target.value;
    }
    getSelectedRevolving(evt){
        this.selectedRevolving = evt.target.value;
    }
    /**
     * @description utility to transform a csv string to an array
     */
    getArray(csvString) {
        let arr = [];
        if ((typeof csvString !== 'undefined') && (csvString !== null)) {
            arr = (csvString.split(";"));
        }
        return arr;
    }

    /**
     * @description utility to check for a defined and non-empty variable
     */
    isEmpty(someVariable) {
        return ((typeof someVariable === 'undefined') || (!someVariable));
    }

    /**
     * @description starts of the initialization of the component when it connects
     */
    connectedCallback(){
        this.setDefaultPreferences();
    }


    /**
     * @description initializes configuration data
     */
    getConfigRecords() {
        if (this.isEmpty(this.fieldList)) {
            this.fieldList = this.getArray(this.fields);
            this.getFilterData();
        }
    }

    /**
     * @description transforms the status filter list values to the format required by the tracFilterList component
     */
    formatStatuses(statuses) {
        let statusList = [];
        statuses.forEach(status => {
            let statusItem = {Id: status, Name: status};
        statusList.push(statusItem);
    });
        return statusList;
    }

    /**
     * @description transforms the status filter list values to the format required by the tracFilterList component
     */
    formatPriorities(priorities) {
        let priorityList = [];
        priorities.forEach(priority => {
            let priorityItem = {Id: priority, Name: priority};
        priorityList.push(priorityItem);
    });
        return priorityList;
    }


    /**
     * @description transforms the territory filter list values to the format required by the tracFilterList component
     */
    formatTerritories(territories) {
        let territoryList = [];
        territories.forEach(territory => {  
            let itemLst = [];
            if ( territory.items != null && territory.items.length > 0 ) {                                 
                territory.items.forEach(lvl2 => {
                    let nextLvlLst = [];
                    if ( lvl2.items != null && lvl2.items.length > 0 ) {
                        lvl2.items.forEach(lvl3 => {                  
                            nextLvlLst.push(
                                {
                                    Id: lvl3.id,
                                    Name: lvl3.name
                                }
                            );
                        })
                    }
                    itemLst.push(
                        {
                            Id: lvl2.id,
                            Name: lvl2.name,
                            Items: nextLvlLst
                        }
                    );
                })
            }
            let territoryItem = { Id: territory.id, Name: territory.name, Items: itemLst };
        territoryList.push(territoryItem);
    })
        return territoryList;
    }

    setDefaultPreferences(){
        getDefaultPreferenceVal({})
            .then(result =>{
            if(result['Default_Status_Values__c'] != undefined){
            this.selectedStatuses = result['Default_Status_Values__c'].split(';');
            }
            if(result['Default_Service_Territories__c'] != undefined){
                this.selectedTerritories = result['Default_Service_Territories__c'].split(';');
            }
            if(result['Default_Work_Types__c'] != undefined){
                this.selectedWorkTypes = result['Default_Work_Types__c'].split(';');
            }
            if(result['Default_Priorities__c'] != undefined){
                this.selectedPriorities = result['Default_Priorities__c'].split(';');
            }
            if(result['Default_Revolving__c'] != undefined){
                this.selectedRevolving = result['Default_Revolving__c'];
            }

            this.getConfigRecords();
        });
    }

    /**
     * @description calls an apex method to retrieve all the filter data and then queries for records (if all filters have a selection)
     */
    getFilterData() {
        getFilterDataApex()
            .then(result => {
            this.dateFilterValues = result.dateValues;
        this.statusFilterValues = this.formatStatuses(result.statuses);
        this.workTypeFilterValues = result.workTypes;   
        this.territoryFilterValues = this.formatTerritories(result.territories);

        this.prioritiesFilterValues = this.formatPriorities(result.priorityValues);
        //ENDS
        this.setFilterLabels();
        this.getInitialRecords();
    });


    }

    /**
     * @description retrieves the first set of records. Both picklist and territories default selections must be available.
     */
    getInitialRecords() {
        if ((!this.isEmpty(this.selectedTerritories)) &&
            (!this.isEmpty(this.selectedStatuses)) &&
            (!this.isEmpty(this.selectedWorkTypes)) &&
            (this.isEmpty(this.records))) {
            this.getRecords();
        }
    }

    /**
     * @description retrieve the current filter selections and retrieve the records again
     * invoked from the Apply Filters button
     */
    applyFilters() {
        this.getFilterSelections();
        this.openFilters = [];
        this.getRecords();
    }

    /**
     * @description calls an apex method retrieve all the records
     */
    getRecords() {
        let statuses = this.selectedStatuses.join(';');
        let territories = this.selectedTerritories.join(';');
        let workTypes = this.selectedWorkTypes.join(';');
        let priorities = this.selectedPriorities.join(';');

        this.sobjectCount =0;
        this.sobjectTotal = 0;
        this.records = null;

        this.setFilterLabels();

        if ((!this.isEmpty(statuses) && !this.isEmpty(territories) && !this.isEmpty(workTypes))) {
            getAllSObjectsApex({sobjectType: this.sobject,
                                statuses: statuses, includeStatus : true,
                                territories: territories, includeTerritory : true,
                                workTypes: workTypes, includeWorkType: true,
                                origin: this.selectedRevolving,
                                priorities: priorities, includePriorities: true,
                                dates : this.selectedDate,
                                recordLimit: this.recordLimit})
                .then(result => {
                        this.records = result;
                        if(result) {
                            this.sobjectCount = result.length;
                            this.getRecordCount(statuses, territories, workTypes, priorities); //let it go asynchonously
                        }
                })
        }
    }

    /**
     * @description calls an apex method retrieve the total records filtered, without record limits
     */
    getRecordCount(statuses, territories, workTypes, priorities) {
        getRecordCountApex({sobjectType: this.sobject,
            statuses : statuses, includeStatus : true,
            territories : territories, includeTerritory : true,
            priorities: priorities, includePriorities: true,
            workTypes: workTypes, includeWorkType: true,
            origin: 'Include', delinquency: 'Include'})
            .then(result => {
            this.sobjectTotal = result;
    });
    }

    /**
     * @description sets the filter labels to indicate how many statuses and territories have been selected
     */
    setFilterLabels() {
        this.statusFilterLabel= 'Status (0)';
        this.territoryFilterLabel = 'Territory (0)';
        if (!this.isEmpty(this.selectedStatuses)) {
            this.statusFilterLabel = 'Status (' + this.selectedStatuses.length.toString() + ')';
        }
        if (!this.isEmpty(this.selectedTerritories)) {
            this.territoryFilterLabel = 'Territory (' + this.selectedTerritories.length.toString() + ')';
        }
        if (!this.isEmpty(this.selectedWorkTypes)) {
            this.workTypeFilterLabel = 'Work Type (' + this.selectedWorkTypes.length.toString() + ')';
        }

        if (!this.isEmpty(this.selectedDate)) {
            this.dateFilterLabel = 'Date option (' + this.selectedDate.length.toString() + ')';
        }

        if (!this.isEmpty(this.selectedPriorities)) {
            this.priorityTypeFilterLabel = 'Priority (' + this.selectedPriorities.length.toString() + ')';
        }

    }

    /**
     * @description retrieves the tracFilterList controls in order to retrieve the current filter selections
     */
    getFilterListControls () {
        let returnList = [];
        let controlList = this.template.querySelectorAll('c-trac-filter-list');

        if (controlList) {
            controlList.forEach(control => {returnList[control.name] = control;});
        }
        return returnList;
    }

    /**
     * @description retrieve and save the filter selections
     */
    getFilterSelections() {
        let controls = this.getFilterListControls();
        if (controls['statuses']) {
            this.selectedStatuses = (controls['statuses']).getSelectedItems();
        }
        if (controls['territories']) {
            this.selectedTerritories = (controls['territories']).getSelectedItems();
        }
        if (controls['worktypes']) {
            this.selectedWorkTypes = (controls['worktypes']).getSelectedItems();
        }
        if (controls['priorities']) {
            this.selectedPriorities = (controls['priorities']).getSelectedItems();
        }
        //Refactored code:
        updateDefaultFiltersOnUsers({   statusFilter:this.selectedStatuses,
                                        territoryFilter:this.selectedTerritories,
                                        workTypeFilter:this.selectedWorkTypes,
                                        priorityFilter:this.selectedPriorities,
                                        revolvingFilter:this.selectedRevolving});
    }
}