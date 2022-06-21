import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import launchOfferAction from '@salesforce/apex/BundleOfferController.launchOfferAction';

export default class LaunchBundleOfferAction extends LightningElement {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this._launchOfferAction();
    }

    get recordId() {
        return this._recordId;
    }

    _launchOfferAction() {
        launchOfferAction({
            bundleId: this.recordId
        })
        .then(() => {
            this.showToast('Success', 'Launched !', 'success')
        })
        .catch(error => {
            this.showToast('', JSON.stringify(error), 'error')
        })
        .finally(() => {
            this.closeModal();
        })
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}