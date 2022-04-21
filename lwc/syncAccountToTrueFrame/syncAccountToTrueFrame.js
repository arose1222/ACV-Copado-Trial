import { api,wire,track,LightningElement } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import sync from '@salesforce/apex/TrueFrameAccountSync.syncAccount';
import { updateRecord } from 'lightning/uiRecordApi';
import { fireToast } from 'c/acvUtilHelper';

//field imports
import ID_FIELD from '@salesforce/schema/Account.Id';
import ACVID from '@salesforce/schema/Account.Dealership_ID__c';
import name from '@salesforce/schema/Account.Name';
import synced from '@salesforce/schema/Account.Synced_to_TrueFrame__c';
import syncedTime from '@salesforce/schema/Account.Synced_to_TrueFrame_Datetime__c';
import territoryId from '@salesforce/schema/Account.Maps_Territory_ID__c'
import state from '@salesforce/schema/Account.BillingState';
import city from '@salesforce/schema/Account.BillingCity';
import street from '@salesforce/schema/Account.BillingStreet';
import zip from '@salesforce/schema/Account.BillingPostalCode';

const fieldList = [
    ACVID,
    name,
    territoryId,
    synced,
    syncedTime,
    ID_FIELD,
    state,
    city,
    street,
    zip
];

export default class SyncAccountToTrueFrame extends LightningElement {
    @api recordId;
    @track openmodel = false;
    @track activeSpinner = false;
    @wire(getRecord,{recordId:'$recordId', fields:fieldList})Acc;
 
    handleClick(){
        if(this.Acc.error){
            fireToast('TrueFrame Sync Status', 'There was an error getting the record data', 'error');
            return;
        }
        /*Commenting out --> IO-1096
        if(!getFieldValue(this.Acc.data, territoryId) || Number.isNaN(parseInt(getFieldValue(this.Acc.data, territoryId)))){
            fireToast('TrueFrame Sync Status', 'There is an issue with the Territory ID, please create an R&I for this Account', 'error');
            return;
        }*/
        if(!getFieldValue(this.Acc.data, ACVID) || Number.isNaN(parseInt(getFieldValue(this.Acc.data, ACVID)))){
            fireToast('TrueFrame Sync Status', 'There is an issue with the Dealer ID, please create an R&I for this Account', 'error');
            return;
        }
        this.activeSpinner = true;
          
        
        var request = {
            info_id : parseInt(getFieldValue(this.Acc.data, territoryId)),
            name : getFieldValue(this.Acc.data, name),
            acv_id : parseInt(getFieldValue(this.Acc.data, ACVID)),
            state : getFieldValue(this.Acc.data, state),
            city : getFieldValue(this.Acc.data, city),
            street : getFieldValue(this.Acc.data, street),
            zip : getFieldValue(this.Acc.data, zip)
        };
        sync({jsonString: JSON.stringify(request)}).then((result) => {
            if(result){
                const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[synced.fieldApiName] = true;
            fields[syncedTime.fieldApiName] = new Date().toISOString();
            const recordInput = { fields };
            console.log(recordInput);
            updateRecord(recordInput).then(() => {
                fireToast('TrueFrame Sync Status', 'Successfully Synced to TrueFrame', 'success')
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.activeSpinner = false;
            }).catch(error => {
                fireToast('TrueFrame Sync Status', 'An Error Occurred Updating the Account', 'error')
                this.activeSpinner = false;
            });
                
            }
            else{
                fireToast('TrueFrame Sync Status', 'An Error Occurred please try again or contact Support', 'error')
                this.activeSpinner = false;
            }
        });
    }

    openDialog(){
        this.openmodel = true;
    }

    closeDialog(){
        this.openmodel = false;
    }
}