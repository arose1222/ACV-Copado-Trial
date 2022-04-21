import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceAppointments from '@salesforce/apex/UpdateVehicleCountFromAccountController.getEligibleServiceAppointments';
import {createSplunkLog} from 'c/acvUtilHelper';

const columns = [
    { label: 'Sched Start', fieldName: 'SchedStartTime', initialWidth: 100, hideDefaultActions: true, type: 'date', },
    { label: 'Rev Apt', fieldName: 'Work_Order__r.Occurrence__c', initialWidth: 70, hideDefaultActions: true, },
    { label: 'Details', fieldName: 'Details', wrapText: true, hideDefaultActions: true, },
    {type: "button", initialWidth: 100, typeAttributes: {
        label: 'Update',
        name: 'Update',
        title: 'Update',
        disabled: false,
        value: 'Update',
        iconPosition: 'left',
    }},
];

export default class UpdateVehicleCountFromAccount extends LightningElement {
    @api recordId;
    serviceAppointmentId;
    data = [];
    columns = columns;
    showAppointmentList = false;
    showNoAvailAppointments = false;
    showUpdateVehicleCount = false;

    connectedCallback() {
        getServiceAppointments({ accountId: this.recordId })
            .then((result) => {
                if(result.length == 0) {
                    this.showNoAvailAppointments = true;
                    return;
                } else {
                    this.showAppointmentList = true;
                }

                this.data = result.map(
                    record => Object.assign(
                        {
                            "Id": record.Id,
                            "SchedStartTime": record.SchedStartTime,
                            "Work_Order__r.Occurrence__c": record.Work_Order__r.Occurrence__c ? 'Yes' : 'No',
                            "Details": record.Work_Type_Name__c + ', ' + (record.ServiceResources ? record.ServiceResources[0].ServiceResource.Name : 'unassigned'),
                        }
                    )
                )
            })
            .catch((error) => {
                this.generateSplunkLog('Error in getServiceAppointments');
                this.handleClose();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'We were unable to retrieve your appointments',
                        variant: 'error'
                    })
                );
            });
    }

    callRowAction(event){
        this.serviceAppointmentId = event.detail.row.Id;
        this.showAppointmentList = false;
        this.showUpdateVehicleCount = true;
    }

    handleClose(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    generateSplunkLog(message) {
        createSplunkLog('ERROR', message, 'updateVehicleCountFromAccount', ['INSPECTOR_DISPATCH'], this.recordId, 'WorkOrder, ServiceAppointment');
    }

}