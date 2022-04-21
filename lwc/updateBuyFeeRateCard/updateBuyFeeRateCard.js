import { LightningElement, api, track } from 'lwc';
import getRateCards from '@salesforce/apex/UpdateBuyFeeRateCardController.GetRateCards';
import updateRateCard from '@salesforce/apex/UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard';
import { fireToast,  createSplunkLog} from 'c/acvUtilHelper';
import {CloseActionScreenEvent} from 'lightning/actions';

export default class UpdateBuyFeeRateCard extends LightningElement {

    @api recordId;
    @track rateCardOptions=[];
    @track disableSave= true;
    @track isProcessing= false;
    @track selectedRateCard;


    connectedCallback(){
        getRateCards()
        .then( result => {
            if(result != null && result != undefined){
                const cards = [];
                result.forEach(x => {
                    var tempVar = {value:x.Id, label:x.Display_Name__c};
                    cards.push(tempVar);  
                });
            this.rateCardOptions= cards;
            }
        })
        .catch(error =>{
            this.dispatchEvent(new CloseActionScreenEvent());
            createSplunkLog('ERROR', error.body.message, 'updateBuyFeeRateCard', ['MARKETPLACE'], this.recordId, 'Account');
            fireToast( 'Error Occured', 'You do not have permissions to change rate card assignment for dealers.', 'error', "sticky" );
        })
        .finally(()=>{

        });
   }


   updateBuyFeeRateCard() {
        this.disableSave= true;
        this.isProcessing= true;
        updateRateCard({
            'recordId': this.recordId,
            'rateCard':this.selectedRateCard
        })
        .then(result => {
            var data = JSON.parse(result);
            if(data.hasError)
            {
                fireToast('There was an issue with updating', data.message, 'error');
            }
            else{
                fireToast( 'Success', 'Rate Card updation successful', 'Success');
                eval("$A.get('e.force:refreshView').fire();");

            }
        })
        .catch(error => {
            fireToast( 'Error Occured', error.body.message, 'error');
        })
        .finally(()=>{
            this.isProcessing= false;
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }

    changeRateCard(event)
    {
        this.disableSave= false;
        this.selectedRateCard=  event.target.value;
    }
}