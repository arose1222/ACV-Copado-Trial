import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import deactivateAddressList from '@salesforce/apex/AddAddressToAccountController.deactivateAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeleteAddressPopUp extends NavigationMixin(LightningElement) {
    @track cancel;
    @api addressid;
    activeSpinner = false;

    handleCloseModal() {
        console.log('in cancel');
        this.cancel = false;
        let event = new CustomEvent('cancelled', { detail: this.cancel });
        this.dispatchEvent(event);
    }

    handleDeleteAddress(){
        this.activeSpinner = true;
        deactivateAddressList({
            'addressId': this.addressid
        })
        .then(result => {
            if(result){

                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'Success! Address deleted Successfully.',
                    variant: 'success'
                }));
                this.cancel = false;
                let event = new CustomEvent('cancelled', { detail: this.cancel,action:'delete' });
                this.dispatchEvent(event);
            }else{
                
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'Something went wrong!',
                    variant: 'error'
                }));
                this.handleCloseModal();
            }
            console.log('result', JSON.stringify(result));
            this.activeSpinner = false;
           
        })
        .catch(error => {
            console.log('Error--' + JSON.stringify(error));
            this.activeSpinner = false;
        });

    }


}