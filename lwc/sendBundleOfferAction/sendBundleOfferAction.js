import {
    LightningElement,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CloseActionScreenEvent
} from 'lightning/actions';
import {
    NavigationMixin
} from "lightning/navigation";
import getRelatedVehicles from '@salesforce/apex/BundleOfferController.getRelatedVehicles';
import sendBundledOfferEmail from '@salesforce/apex/BundleOfferController.sendBundledOfferEmail';
import Bundle_Offer_Vehicle_List_Size_Zero_Error from '@salesforce/label/c.Bundle_Offer_Vehicle_List_Size_Zero_Error';

const COLS = [{
        label: 'Year/Make/Model',
        fieldName: 'Year_Make_Model_Trim__c'
    },
    {
        label: 'VIN',
        fieldName: 'VIN__c'
    }
];

export default class SendBundleOfferAction extends NavigationMixin(LightningElement) {
    showSpinner = false;
    _recordId;

    showErrorMessage = false;
    vehicleListSizeZeroError = Bundle_Offer_Vehicle_List_Size_Zero_Error;

    @api set recordId(value) {
        this._recordId = value;
        this._getRelatedVehicles();
    }

    get recordId() {
        return this._recordId;
    }

    columns = COLS;
    relatedVehicles = [];
    adjustedBundlePrice = 0;

    _getRelatedVehicles() {
        this.showSpinner = true;
        // console.log('this.recordId - ', this.recordId)
        getRelatedVehicles({
                bundleId: this.recordId
            })
            .then(res => {
                this.relatedVehicles = res;
                if (this.relatedVehicles.length == 0) {
                    this.showErrorMessage = true;
                } else {
                    this.showErrorMessage = false;

                    this.relatedVehicles.forEach(elem => {
                        this.adjustedBundlePrice += (elem.ACV_Estimated_Price__c ? elem.ACV_Estimated_Price__c : 0)
                    })
                }
            })
            .catch(error => {
                this.showToast('', JSON.stringify(error), 'error')
            })
            .finally(() => {
                this.showSpinner = false;
            })
    }

    sendMail() {
        this.showSpinner = true;
        // console.log('this.recordId - ', this.recordId)
        sendBundledOfferEmail({
                recordId: this.recordId
            })
            .then(() => {
                this.showToast('Success', 'Email sent !', 'success');
                this.closeModal();
            })
            .catch(error => {
                let errorMsg = error.message || ( error.body && error.body.message);
                this.showToast("", errorMsg, "error");
                console.error(error);
            })
            .finally(() => {
                this.showSpinner = false;
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