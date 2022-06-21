import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//ServiceAppointment Fields
import SA_ID_Field from '@salesforce/schema/ServiceAppointment.Id';
import SA_STATUS from '@salesforce/schema/ServiceAppointment.Status';
import SA_WORKTYPE from '@salesforce/schema/ServiceAppointment.Work_Type_Name__c';
import SA_DUEDATE from '@salesforce/schema/ServiceAppointment.DueDate';
import SA_ORIGDUEDATE from '@salesforce/schema/ServiceAppointment.Original_Due_Date__c';
import SA_SCHEDSTARTTIME from '@salesforce/schema/ServiceAppointment.SchedStartTime';
import CANNOT_COMPLETE_REASON from '@salesforce/schema/ServiceAppointment.Cannot_Complete_Reason__c';
import SA_DURATION from '@salesforce/schema/ServiceAppointment.Duration';
import WORKORDER_ID from '@salesforce/schema/ServiceAppointment.Work_Order__c';
import CURRENT_SERVICE_RESOURCE from '@salesforce/schema/ServiceAppointment.Current_Service_Resource__c';
import WORKTYPE_UNIQUE_ID from '@salesforce/schema/ServiceAppointment.Work_Type_Unique_ID__c';
import WORKTYPE_ID from '@salesforce/schema/ServiceAppointment.WorkTypeId';
import HAS_BEEN_RESCHEDULED from '@salesforce/schema/ServiceAppointment.Has_Been_Rescheduled__c';
import IS_RESCHEDULE from '@salesforce/schema/ServiceAppointment.Is_Reschedule__c';
import IS_DRY_RUN from '@salesforce/schema/ServiceAppointment.Dry_Run__c';
import BUNDLED from '@salesforce/schema/ServiceAppointment.Bundled__c';
import NON_ASI_WORK from '@salesforce/schema/ServiceAppointment.Non_ASI_Work__c';
import RESCHEDULE from '@salesforce/schema/ServiceAppointment.Reschedule__c';
import SANUM from '@salesforce/schema/ServiceAppointment.AppointmentNumber';
import SA_COLOR from '@salesforce/schema/ServiceAppointment.FSL__GanttColor__c';

import getWOLIsForServiceAppointment from '@salesforce/apex/RescheduleServiceAppointmentController.getWOLIsForServiceAppointment';
import rescheduleAppointment from '@salesforce/apex/RescheduleServiceAppointmentController.rescheduleAppointment';

const FIELDS = [
    SA_ID_Field,
    SA_STATUS,
    SA_WORKTYPE,
    SA_DUEDATE,
    SA_ORIGDUEDATE,
    CURRENT_SERVICE_RESOURCE,
    WORKORDER_ID,
    SA_SCHEDSTARTTIME,
    CANNOT_COMPLETE_REASON,
    SA_DURATION,
    WORKTYPE_UNIQUE_ID,
    HAS_BEEN_RESCHEDULED,
    IS_RESCHEDULE,
    WORKTYPE_ID,
    IS_DRY_RUN,
    BUNDLED,
    NON_ASI_WORK,
    RESCHEDULE,
    SANUM,
    SA_COLOR,
];

const columns = [{
    label: 'Number',
    fieldName: 'LineItemNumber',
    type: 'text',
    sortable: true
},
{
    label: 'Status',
    fieldName: 'Status',
    sortable: false
},
{
    label: 'Year, Make, and Model',
    fieldName: 'Year_and_Make_and_Model__c',
    sortable: false
},
{
    label: 'Description',
    fieldName: 'Description',
    sortable: false
}
];

export default class RescheduleServiceAppointment extends NavigationMixin(LightningElement) {
    @api recordId;
    @track serviceApptData = {};
    @track newSA = {};
    @track currentState = 'Comfirm';
    @track error;

    showLoadingSpinner = true;

    workOrderLineItems = [];
    hasWOLIs = false;
    noWOLIs = false;
    hasRanRenderedCallback = false;
    workTypeNotAllowed = ['fbi', 'acvhome'];
    recordPageUrl;
    saAppointmentNum;

    completeButtonText = 'Complete';
    completeButtonVariant = 'brand';
    completeButtonDisabled = false;

    copyButtonText = 'Copy Service Appointment Number';
    copyButtonVariant = 'brand-outline';

    @track value;
    @api sortedDirection = 'asc';
    @api sortedBy = 'LineItemNumber';
    @track allSelectedRows = [];
    @track allSelectedWOLINumbers = [];
    @track page = 1; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    WOLIMap = new Map();

    renderedCallback() {
        if(this.allSelectedRows.length > 0 && !this.hasRanRenderedCallback && this.isStateSelectWOLIs) {
            var selectedIds = [];
            for(var i=0; i<this.allSelectedRows.length;i++){
                if(this.data.includes(this.allSelectedRows[i])) {
                    selectedIds.push(this.allSelectedRows[i].Id);
                }
            }
            this.template.querySelector(
                '[data-id="table"]'
            ).selectedRows = selectedIds;

            this.hasRanRenderedCallback = true;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredSARecord(result) {
        if(result.data) {
            this.serviceApptData['Id'] = this.recordId;
            for(let prop in result.data.fields) {
                this.serviceApptData[prop] = result.data.fields[prop].value;
            }
            if(this.workTypeNotAllowed.includes(this.serviceApptData.Work_Type_Unique_ID__c) || this.serviceApptData.Work_Type_Unique_ID__c.includes('cpo')) {
                this.error = 'ACV Anywhere, FBI and CPO Appointments must be rescheduled in GLASS.';
                this.currentState = 'Error';
                this.toggleSpinner();
            }
            else if(this.serviceApptData.Work_Type_Unique_ID__c == 'verification') {
                this.error = 'You cannot reschedule Asset Verification appointments.';
                this.currentState = 'Error';
                this.toggleSpinner();
            }
            else if(this.serviceApptData.Status != 'Cannot Complete' && !this.serviceApptData.Dry_Run__c) {
                this.error = 'You can only reschedule Service Appointments that are Dry Run or have a status of "Cannot Complete".';
                this.currentState = 'Error';
                this.toggleSpinner();
            }
            else if(this.serviceApptData.Has_Been_Rescheduled__c == true) {
                this.error = 'This Service Appointment has already been rescheduled.';
                this.currentState = 'Error';
                this.toggleSpinner();
            }
            else if(this.serviceApptData.Bundled__c == true) {
                this.error = 'You cannot reschedule bundled appointments.';
                this.currentState = 'Error';
                this.toggleSpinner();
            }
            else {
                getWOLIsForServiceAppointment({ searchId: this.serviceApptData.Work_Order__c })
                .then(result=> {
                    this.workOrderLineItems = result;
                    this.toggleSpinner();
                    if(result != null) {
                        this.setupTableInfo();
                    }
                })
                .catch(error=> {
                    this.error = 'Error - If the issue is unclear, Please open an R&I with the following details: ' + error.body.message;
                    this.currentState = 'Error';
                    if(this.showLoadingSpinner) {
                        this.toggleSpinner();
                    }
                });
            }
        } else if(result.error) {
            this.error = 'Error - If the issue is unclear, Please open an R&I with the following details: ' + result.error.body.message;
            this.currentState = 'Error'
            this.toggleSpinner();
        }
    }

    confirmReschedule() {
        if(this.workOrderLineItems == null || this.workOrderLineItems == 'undefined' || this.workOrderLineItems.length == 0 || !this.serviceApptData.Non_ASI_Work__c) {
            this.handleReschedule();
        }
        else if(this.workOrderLineItems.length > 0) {
            this.currentState = 'Select WOLIs';
        }
    }

    handleReschedule() {
            this.toggleSpinner();
            this.currentState = 'Submitting';
            rescheduleAppointment({serApptJSON: JSON.stringify(this.serviceApptData), woliList: this.allSelectedRows})
            .then(result => {
            
                if(result.status == 'Success') {
                    this.saAppointmentNum = result.newSANumber;
                    this.recordPageUrl = result.recordURL;
                    this.currentState = 'Success';
                    this.toggleSpinner();
                }
                else {
                    this.error = 'Error - If the issue is unclear, Please open an R&I with the following details: ' + result.message;
                    this.currentState = 'Error'
                    this.toggleSpinner();
                }
            })
            .catch(error => {
                this.error = 'Error - If the issue is unclear, Please open an R&I with the following details: ' + error.body.message;
                this.currentState = 'Error';
                this.toggleSpinner();
            });
    }


    copySANum() {
        let msg = this.saAppointmentNum;

        if (navigator.clipboard && window.isSecureContext) {
            this.copyButtonText = 'Copied!';
            this.copyButtonVariant = 'success';
            return navigator.clipboard.writeText(msg);
        } else {
            let textArea = document.createElement("textarea");
            textArea.value = msg;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            return new Promise((res, rej) => {
                document.execCommand("copy") ? res() : rej();
                textArea.remove();
                this.copyButtonText = 'Copied!';
                this.copyButtonVariant = 'success';
            });
        }
    }

    redirectToSA() {
        window.open(this.recordPageUrl, "_top");  
    }

    setupTableInfo() {
        this.totalRecountCount = this.workOrderLineItems.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.endingRecord = this.pageSize;
        this.data = this.workOrderLineItems.slice(0,this.pageSize); 
        this.columns = columns;
        for(var i=0; i<this.workOrderLineItems.length;i++){
            if(!(this.workOrderLineItems[i].Status == 'Complete' || this.workOrderLineItems[i].Status == 'Inspected')) {
                this.allSelectedRows.push(this.workOrderLineItems[i]);
                this.allSelectedWOLINumbers.push(this.workOrderLineItems[i].LineItemNumber);
                this.WOLIMap.set(this.workOrderLineItems[i].LineItemNumber, this.workOrderLineItems[i]);
            }
        }    
    }

    //clicking on previous button this method will be called
    previousHandler() {
        //this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
              if(this.data.includes(this.allSelectedRows[i])) {
                selectedIds.push(this.allSelectedRows[i].Id);
              }
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;

          //if(selectedIds.length > 0) {
            //this.isPageChanged = true;
          //}
    }

    //clicking on next button this method will be called
    nextHandler() {
        //this.isPageChanged = true;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            if(this.data.includes(this.allSelectedRows[i])) {
                selectedIds.push(this.allSelectedRows[i].Id);
            }
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;

          //if(selectedIds.length > 0) {
            //console.log('MGF nextHandler this.isPageChanged = true');
            //this.isPageChanged = true;
          //}
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.workOrderLineItems.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }   

    sortColumns( event ) {
        //this.sortedBy = event.detail.fieldName;
        //this.sortedDirection = event.detail.sortDirection;
        //return refreshApex(this.result);
    }

    onRowSelection(event){
        //if(!this.isPageChanged){
            this.processSelectedRows(event.detail.selectedRows);
        //}else{
        //    this.isPageChanged = false;
        //}
        
    }

    processSelectedRows(selectedWOLIs){
        var newMap = new Map();
        for(var i=0; i<selectedWOLIs.length;i++){
            if(!this.allSelectedWOLINumbers.includes(selectedWOLIs[i].LineItemNumber)){
                this.allSelectedRows.push(selectedWOLIs[i]);
                this.allSelectedWOLINumbers.push(selectedWOLIs[i].LineItemNumber);
            }
            this.WOLIMap.set(selectedWOLIs[i].LineItemNumber, selectedWOLIs[i]);
            newMap.set(selectedWOLIs[i].LineItemNumber, selectedWOLIs[i]);
        }

        for(let [key,value] of this.WOLIMap.entries()){
            if(newMap.size<=0 || (!newMap.has(key))){
                const index = this.allSelectedWOLINumbers.indexOf(key);
                if (index > -1) {
                    if(this.data.includes(this.allSelectedRows[index])) {
                        this.allSelectedRows.splice(index, 1); 
                        this.allSelectedWOLINumbers.splice(index, 1);
                    }
                }
            }
        }
        if(this.allSelectedRows.length == 0) {
            if(this.completeButtonText == 'Complete') {
                this.completeButtonText = 'You must select at least one Work Order Line Item.';
                this.completeButtonDisabled = true;
            }
        }
        else {
            if(this.completeButtonText != 'Complete') {
                this.completeButtonText = 'Complete';
                this.completeButtonDisabled = false;
            }
        }
    }

    get isStateConfirm(){
        return (this.currentState == 'Comfirm');
    }
    get isStateSelectWOLIs(){
        return (this.currentState == 'Select WOLIs');
    }
    get isStateBadWorkType(){
        return (this.currentState == 'Invalid Work Type');
    }
    get isStateInvalidSA(){
        return (this.currentState == 'Invalid SA');
    }
    get isStateAlreadyRescheduled(){
        return (this.currentState == 'Already Rescheduled');
    }
    get isStateSuccess(){
        return (this.currentState == 'Success');
    }
    get isStateError(){
        return (this.currentState == 'Error');
    }
    get isStateSubmitting(){
        return (this.currentState == 'Submitting');
    }
    
    
    toggleSpinner() {
        this.showLoadingSpinner = !this.showLoadingSpinner;
    }
}