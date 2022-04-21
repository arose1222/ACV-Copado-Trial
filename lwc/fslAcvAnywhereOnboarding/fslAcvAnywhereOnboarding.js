import { LightningElement, api, wire } from 'lwc';

import { fireToast } from 'c/acvUtilHelper';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import acvAnywhereRegistrationRequest from '@salesforce/apex/FslAcvAnywhereOnboardingController.acvAnywhereRegistrationRequest';
import checkEligibility from '@salesforce/apex/FslAcvAnywhereOnboardingController.checkEligibility';

export default class FslAcvAnywhereOnboarding extends LightningElement {
    recordId;
    showLoadingSpinner;
    isModalOpen;

    isActiveDealer;
    isNotEligible;
    isShowRegistration;
    isRegistrationDisabled;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;

            if(this.recordId != null){

                checkEligibility({ accountId: this.recordId })
                .then(result => {

                    this.isActiveDealer = result.isActiveDealer;
                    this.isShowRegistration = (!result.isAlreadyRegistered && result.isActiveDealer);
                    this.isAlreadyRegistered = !this.isActiveDealer ? false : result.isAlreadyRegistered;
                    this.isRegistrationDisabled = !this.isShowRegistration;
                    this.isModalOpen = true;
                    this.showLoadingSpinner = false;

                })
                .catch(error => {
                    fireToast('Error', 'This was an issue processing your request.', 'error', 'sticky');
                });
            } else {
                fireToast('Error', 'This was an issue processing your request.', 'error', 'sticky');
            }
        }
    }


    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    submitRegister() {
        this.showLoadingSpinner = true;
        this.isModalOpen = false;

        acvAnywhereRegistrationRequest({ accountId: this.recordId })
        .then(result => {

            if(result.errorId == 200 || result.errorId == 400){
                fireToast('Success', 'This account was successfully registered.', 'success');
            } else {
                fireToast('Error', 'This was an issue processing your request.', 'error', 'sticky');
            }

            this.closeModal();

        })
        .catch(error => {
            fireToast('Error', 'This was an issue processing your request.', 'error', 'sticky');
        });
    }
}