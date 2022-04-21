import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {createSplunkLog} from 'c/acvUtilHelper';

//ServiceAppointment Fields
import SA_ID_Field from '@salesforce/schema/ServiceAppointment.Id';
import SA_STATUS from '@salesforce/schema/ServiceAppointment.Status';
import SA_WORKTYPE from '@salesforce/schema/ServiceAppointment.Work_Type_Name__c';
import SA_DUEDATE from '@salesforce/schema/ServiceAppointment.DueDate';
import SA_SCHEDSTARTTIME from '@salesforce/schema/ServiceAppointment.SchedStartTime';
import SA_SCHEDENDTIME from '@salesforce/schema/ServiceAppointment.SchedEndTime';
import SA_DURATION from '@salesforce/schema/ServiceAppointment.Duration';
import WORKORDER_ID from '@salesforce/schema/ServiceAppointment.Work_Order__c';
import NUMBER_OF_VEHICLES from '@salesforce/schema/ServiceAppointment.Work_Order__r.Inspection_Number_of_Vehicles__c';

//Work Type Fields
import WORKTYPE_DURATION from '@salesforce/schema/ServiceAppointment.WorkType.EstimatedDuration';
import WORKTYPE_UNIQUE_ID from '@salesforce/schema/ServiceAppointment.WorkType.Work_Type_Unique_ID__c';

//WorkOrder Fields
import WORKORDER_ID_FIELD from '@salesforce/schema/WorkOrder.Id';
import WORKORDER_NUMVEHICLES_FIELD from '@salesforce/schema/WorkOrder.Inspection_Number_of_Vehicles__c';

const FIELDS = [
    SA_STATUS,
    SA_WORKTYPE,
    SA_DUEDATE,
    NUMBER_OF_VEHICLES,
    WORKORDER_ID,
    SA_SCHEDSTARTTIME,
    SA_SCHEDENDTIME,
    SA_DURATION,
    WORKTYPE_DURATION,
    WORKTYPE_UNIQUE_ID,
];

export default class updateVehicleCount extends LightningElement {
    @api recordId;
    @api fromGantt = false;
    @track appointmentData = {};

    @track error;

    showLoadingSpinner = false;
    showUpdateVehicleCount = false;
    showWorkTypeNotAllowed = false;
    showStatusNotAllowed = false;
    showPastDueDateNotAllowed = false;
    showFutureDueDateNotAllowed = false;
    showSuccessForGantt = false;

    statusAllowed = ['New', 'Scheduled', 'Dispatched', 'Acknowledged'];
    workTypeAllowed = ['inspection', 'true360', 'siriusxm'];

    saveDisabled = true;
    decrementDisabled;
    incrementDisabled;
    onload = true;
    isWorkOrderUpdated = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({error, data}) {
        if (error) {
            let errorMessage = 'Unknown error';
            if (Array.isArray(error.body)) {
                errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                errorMessage = error.body.message;
            }
            this.showLoadingSpinner = false;
            this.closeModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        } else if (data) {
            this.appointmentData.saStatus = getFieldValue(data, SA_STATUS);
            this.appointmentData.saWorkTypeUniqueId = getFieldValue(data, WORKTYPE_UNIQUE_ID);
            this.appointmentData.saDueDate = new Date(getFieldValue(data, SA_DUEDATE));
            this.appointmentData.numberOfVehicles = getFieldValue(data, NUMBER_OF_VEHICLES);
            this.appointmentData.workOrderId = getFieldValue(data, WORKORDER_ID);
            this.appointmentData.saSchedStartTime = getFieldValue(data, SA_SCHEDSTARTTIME);
            this.appointmentData.saSchedEndTime = getFieldValue(data, SA_SCHEDENDTIME);
            this.appointmentData.workTypeDuration = getFieldValue(data, WORKTYPE_DURATION);
            this.appointmentData.saWorkType = getFieldValue(data, SA_WORKTYPE);

            if(this.onload == true) {
                this.appointmentData.originalNumberOfVehicles = getFieldValue(data, NUMBER_OF_VEHICLES);

                let today = new Date();
                today.setDate(today.getDate() + 5);
                var endDate = new Date(today.toDateString());

                if(!this.workTypeAllowed.includes(this.appointmentData.saWorkTypeUniqueId)) {
                    this.showWorkTypeNotAllowed = true;
                } else if(!this.statusAllowed.includes(this.appointmentData.saStatus)) {
                    this.showStatusNotAllowed = true;
                } else if(this.appointmentData.saDueDate < Date.now()) {
                    this.showPastDueDateNotAllowed = true;
                } else if(this.appointmentData.saDueDate >= endDate) {
                    this.showFutureDueDateNotAllowed = true;
                } else {
                    this.showUpdateVehicleCount = true;
                }
                this.onload = false;
            }

            this.handleVehicleNumberChange(this.appointmentData.numberOfVehicles);
        }
    }

    updateNumberOfVehicles(){
        this.showUpdateVehicleCount = false;
        this.showLoadingSpinner = true;
        const fields = {};
        this.appointmentData.numberOfVehicles = this.template.querySelector("lightning-input").value;
        fields[WORKORDER_ID_FIELD.fieldApiName] = this.appointmentData.workOrderId;
        fields[WORKORDER_NUMVEHICLES_FIELD.fieldApiName] = this.appointmentData.numberOfVehicles;

        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.isWorkOrderUpdated = true;
            this.updateServiceAppointment();
        })
        .catch(error => {
            this.rollbackWorkOrderUpdate();
            this.generateSplunkLog('Error when updating the workorder');
        });
    }

    updateServiceAppointment(){
        const fields = {};
        fields[SA_ID_Field.fieldApiName] = this.recordId;
        fields[SA_DURATION.fieldApiName] = this.appointmentData.duration;

        if(this.appointmentData.saSchedStartTime) {
            let schedEnd = new Date(this.appointmentData.saSchedStartTime);
            schedEnd.setMinutes(schedEnd.getMinutes() + this.appointmentData.duration);
            fields[SA_SCHEDENDTIME.fieldApiName] = schedEnd.toISOString();
        }

        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.showLoadingSpinner = false;

            if(this.fromGantt) {
                this.showSuccessForGantt = true;
            } else {
                eval("$A.get('e.force:refreshView').fire();"); 
            }
            
            this.closeModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The appointment has been updated.',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.rollbackWorkOrderUpdate();
            this.generateSplunkLog('Error when updating the service appointment');
        });
    }

    rollbackWorkOrderUpdate() {
        if(this.isWorkOrderUpdated) {
            const fields = {};
            fields[WORKORDER_ID_FIELD.fieldApiName] = this.appointmentData.workOrderId;
            fields[WORKORDER_NUMVEHICLES_FIELD.fieldApiName] = this.appointmentData.originalNumberOfVehicles;

            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.showLoadingSpinner = false;
                this.closeModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'We were unable to update your appointment',
                        variant: 'error'
                    })
                );
            })
            .catch(error => {
                this.generateSplunkLog('Error when attempting to rollback the workorder update');
                this.showLoadingSpinner = false;
                this.closeModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'We were unable to update your appointment',
                        variant: 'error'
                    })
                );
            });
        } else {
            this.showLoadingSpinner = false;
            this.closeModal();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'We were unable to update your appointment',
                    variant: 'error'
                })
            );
        }
    }

    toggleSpinner() {
        this.showLoadingSpinner = !this.showLoadingSpinner;
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleCount(event){
        if(event.target.name == 'increment') {
            this.appointmentData.numberOfVehicles += 1;
        } else if(event.target.name == 'decrement') {
            this.appointmentData.numberOfVehicles -= 1;
        }

        this.handleVehicleNumberChange(this.appointmentData.numberOfVehicles);
    }

    handleInputChange(){
        this.appointmentData.numberOfVehicles = parseInt(this.template.querySelector("lightning-input").value);
        this.handleVehicleNumberChange(this.appointmentData.numberOfVehicles ? this.appointmentData.numberOfVehicles : 0);
    }

    handleVehicleNumberChange(numberOfVehicles){
        if(numberOfVehicles == this.appointmentData.originalNumberOfVehicles || numberOfVehicles < 1 || numberOfVehicles * this.appointmentData.workTypeDuration > 450){
            this.saveDisabled = true;
        } else {
            this.saveDisabled = false;
        }

        if(numberOfVehicles <= 1 && numberOfVehicles != ''){
            this.decrementDisabled = true;
        } else {
            this.decrementDisabled = false;
        }

        if((numberOfVehicles + 1) * this.appointmentData.workTypeDuration > 450){
            this.incrementDisabled = true;
        } else {
            this.incrementDisabled = false;
        }

        this.appointmentData.duration = numberOfVehicles * this.appointmentData.workTypeDuration;
    }

    generateSplunkLog(message) {
        if(!this.fromGantt) {
            createSplunkLog('ERROR', message, 'updateVehicleCount', ['INSPECTOR_DISPATCH'], this.recordId, 'WorkOrder, ServiceAppointment');
        }
    }

}