import { LightningElement,api } from 'lwc';
import getCaseStatus from '@salesforce/apex/PreviousAuctionAlertController.getCaseStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PreviousAuctionAlert extends LightningElement {
    @api recordId;

    connectedCallback(){
        getCaseStatus( {'caseId': this.recordId})
        .then(result => {
            console.log('result',JSON.stringify(result));
            if(result==true){

                const event = new ShowToastEvent({
                    title: 'Warning!',
                    message: 'This vehicle was run multiple times on ACV.',
                    variant: 'Warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

            }
        })
        .catch(error => {
            console.log('error',JSON.stringify(error));
        });


    }


}