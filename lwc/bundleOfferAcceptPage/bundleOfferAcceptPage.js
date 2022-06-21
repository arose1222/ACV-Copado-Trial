import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateBundleOfferStatus from '@salesforce/apex/ACVAuctionsSiteController.updateBundleOfferStatus';
import ACVLogo from '@salesforce/resourceUrl/ACVLogo';

export default class BundleOfferAcceptPage extends LightningElement {
    showSpinner = true;
    bundleOfferId;
    ACVLogo = ACVLogo;
    displayMessage = 'Thank you for confirming your bundle. All auctions will be launched shortly into our No Reserve sale.';
    alreadyActivated = false;
    
    _updateBundleOfferStatus() {
        updateBundleOfferStatus({
            bundleOfferId: this.bundleOfferId
        })
        .then(result => {
            if(result == false) {
                this.displayMessage = 'Your bundle has already been activated!';
                this.alreadyActivated = true;
            }
            this.showSpinner = false;
            //this.showToast('Success', 'Success !', 'success')
        })
        .catch(error => {
            let errorMsg = this.getErrorMessage(error);
			this.showToast("", errorMsg, "error");
        })
    }

    connectedCallback() {
        const param = 'Id';
        this.bundleOfferId = this.getUrlParamValue(window.location.href, param);
        if(this.bundleOfferId) {
            this._updateBundleOfferStatus();
        }
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

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    getErrorMessage(error) {
        if(error) {
            let erroMsg = error.message || (error.body && error.body.message) ||
            (error.body && error.body.pageErrors && error.body.pageErrors[0].message) ||
            (error.body && error.body.fieldErrors && error.body.fieldErrors[0].message);
            if (erroMsg && erroMsg.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                let erroMsgArray = erroMsg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                if (erroMsgArray && erroMsgArray.length > 1) {
                    erroMsg = erroMsgArray[1];
                    erroMsg = erroMsg.replace(": []", "");
                }
            } else if (erroMsg && erroMsg.includes('UNABLE_TO_LOCK_ROW')) {
                erroMsg = 'Please try again.'
            }
    
            return erroMsg;
        }
    }
}