import { api,track,LightningElement } from 'lwc';
import disableVL from '@salesforce/apex/RemoveVLFromPrescreenController.removeVLFromVin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Condition_Report_Prescreen__c.Id';
export default class RemoveVLFromPrescreen extends LightningElement {
    @api recordId;
    @track disableResult = false;
    @track openmodel = false;

    handleClick(){
        disableVL({PerscreenId : this.recordId}).then((result) =>{
            if(result){
                this.notifyUser('Success', 'Virtual Lift Image Removed','success');
                this.closeDialog();
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                const recordInput = { fields };
                updateRecord(recordInput)
            }
            else{
                this.notifyUser('Could Not Remove Virtual Lift Image', 'An Error Occurred please try again or contact Support','error');
                this.closeDialog();
            }
        }).catch(() =>{
            this.notifyUser('Could Not Remove Virtual Lift Image', 'An Error Occurred please try again or contact Support','error');
            this.closeDialog();
        });
    }

    openDialog(){
        this.openmodel = true;
    }

    closeDialog(){
        this.openmodel = false;
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
}