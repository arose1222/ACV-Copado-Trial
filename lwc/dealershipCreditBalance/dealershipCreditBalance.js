import { LightningElement, api, track } from 'lwc';
import getAccountBalance from '@salesforce/apex/DealershipCreditBalanceCont.getAccountBalance';

export default class DealershipCreditBalance extends LightningElement {
    @api recordId;
    @track amount  = 0;
    @track noError = false;
    
    connectedCallback(){
        // Get Balance
        getAccountBalance( {recordId : this.recordId} )
            .then(result => {
                // If the balance returned == null, we don't want to display the component so we leave noError = false
                if( result != null && result !== undefined ){
                    this.amount = result;
                    this.noError = true;
                }
            })
            .catch( error => {
                // This catches Javascript errors, can just debug these if they happen, no need to display an error
                console.log( JSON.stringify(error) );
            })
            .finally( () => {
                // No Actions Needed
            })
        ;
    }
    
}