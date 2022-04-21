import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { fireToast } from 'c/acvUtilHelper';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getContacts from '@salesforce/apex/CaseCreateUtilityController.getContacts';
import getAccounts from '@salesforce/apex/CaseCreateUtilityController.getAccounts';
import initialQuery from '@salesforce/apex/CaseCreateUtilityController.initialQuery';
import checkAffiliationAccess from '@salesforce/apex/CaseCreateUtilityController.checkAffiliationCreateAccess';
import checkRetentionAccess from '@salesforce/apex/DealerOutreachController.checkRetentionCreateAccess';
import checkForLockedAccount from '@salesforce/apex/DealerOutreachController.checkForLockedAccount';
import createRetention from '@salesforce/apex/DealerOutreachController.createRetention';
import getRecordTypeId from '@salesforce/apex/DealerOutreachController.getInsideSalesRecordTypeId';

import retentionIgnition from '@salesforce/schema/Retention_Ignition__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import RETENTION_OBJECT from '@salesforce/schema/Retention_Ignition__c';

export default class CaseCreateUtility extends NavigationMixin(LightningElement) {

    @wire(getObjectInfo, { objectApiName: RETENTION_OBJECT })
    retentionInfo;

    @api recordId;
    @api get closedCheck() {
        return this.hasBeenClosed;
    }
    set closedCheck(value) {
        this.hasBeenClosed = value;
        if(this.clickCounter > 0){
            this.connectedCallback();
        }
        this.clickCounter++;
    }

    @track hasBeenClosed = false;
    @track accountId = '';
    @track errors = [];
    @track cancelCheck = false;
    @track showSpinner = false;
    @track contactInfo;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    retentionAccess = false;
    acvUserAccess = false;
    minimizeIndex = false;
    hasErrors = false;
    clearedByClose = false;
    callAnswered = true;
    answeredErrors = false;
    noAnswerErrors = false;
    lockedAccount = false;
    retentionAPI = retentionIgnition;
    contactId = '';
    clickCounter = 0;

    direction;
    noAnswerSelection;
    dealerComments;
    callType;
    nextSteps;
    latestSelectionsList;

    connectedCallback() {
        checkRetentionAccess()
            .then(results => {
                this.retentionAccess = results;
                if (this.retentionAccess) {
                    checkAffiliationAccess()
                    .then(results => {
                        this.acvUserAccess = results;
                    });

                    initialQuery({recordId: this.recordId})
                        .then(results => {
                            this.determineCurrentObjectType(results);
                        }
                    );
                }
                else {
                    this.minimizePopUp();
                    fireToast('Permissions Needed', 'You do not have access to create Retention & Ignition records through Dealer Outreach.', 'error', 'sticky');
                }
            })
    }

    determineCurrentObjectType(results) {
        if (results.search('sObjectType":"Account') != -1) {
            results = JSON.parse(results);
            this.autoPopulateAccountOnStart(results);
        }
    }

    autoPopulateAccountOnStart(res) {
        if (res) {
            var acctLookup = this.template.querySelector('.accountLookup');
            acctLookup.setSearchResults(res);
        }
        else {
            fireToast('Lookup Error', 'An error occurred while trying to find the account. Please make sure you are on an Account page and try again.', 'error');
        }
    }

    handleLatestChange(event){
        this.latestSelectionsList = event.detail.value;
        if(this.latestSelectionsList != null || this.latestSelectionsList != ''){
            this.hasErrors = false;
        }
        if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }

    handleDirectionChange(event) {
        this.direction = event.detail.value;
        this.hasErrors = false;
        if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }

    handleAnswerChange(event) {
        this.noAnswerSelection = event.detail.value;
        this.hasErrors = false;
        if (this.noAnswerSelection != null && this.noAnswerSelection != '') {
            this.direction = 'Outbound';
            this.callAnswered = false;
        }
        else {
            this.callAnswered = true;
        }

        if (this.clearedByClose) {
            this.clearedByClose = false;
        }
        else if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }

    handleCommentChange(event) {
        this.dealerComments = event.detail.value;
        var dealerCommentsCmp = this.template.querySelector('[data-id="commentsInput"]');
        dealerCommentsCmp.setCustomValidity("");
        dealerCommentsCmp.reportValidity();
        this.hasErrors = false;
        if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }
    
    handleCallTypeChange(event) {
        this.callType = event.detail.value;
        this.hasErrors = false;
        if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }

    handleNextStepsChange(event) {
        this.nextSteps = event.detail.value;
        var nextStepsCmp = this.template.querySelector('[data-id="nextSteps"]');
        nextStepsCmp.setCustomValidity("");
        nextStepsCmp.reportValidity();
        this.hasErrors = false;
        if (this.noAnswerErrors || this.answeredErrors) {
            this.checkRequiredFields();
        }
    }

    handleAccountLookup(evt) {
        const target = evt.target;
        getAccounts(evt.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'An error occurred while trying to find the Account. Please try again or submit an R&I ticket if the error persists.', 'error');
                this.errors = [error];
            }
        );
    }

    handleAccountChange(evt) {
        // add in apex call to see if the selected account is in an approval process SELECT TargetObjectId, ProcessDefinitionId, Status FROM ProcessInstance WHERE Status = 'Pending'
        if (evt.target.getSelection() == '') {
            this.accountId = '';
            this.lockedAccount = false;
        }
        else {
            let account = evt.target.getSelection();
            this.accountId = account[0].id;
            this.template.querySelector('[data-id="accountInput"]').classList.remove('error');
            this.hasErrors = false;
            if (this.noAnswerErrors || this.answeredErrors) {
                this.checkRequiredFields();
            }

            // Adding this with SDP-70
            // provides a toast alert if the selected account is currently locked in an approval process
            checkForLockedAccount({accountId: this.accountId})
                .then(results => {
                    if (results == true) {
                        this.lockedAccount = true;
                        fireToast('Unable to log an outreach on Dealership - ' + account[0].title, 'This Account is locked in an Approval process. Please reach out to reactivations@acvauctions.com for assistance.', 'warning', 'sticky');
                    }
                    else {
                        this.lockedAccount = false;
                    }
                }
            );
        }
    }

    handleContactLookup(evt) {
        const target = evt.target;
        if(this.accountId != ''){
            evt.detail.selectedIds.push(this.accountId);
        }

        getContacts(evt.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'An error occured while trying to find the Contact. Please try again or submit an R&I ticket if the error persists.', 'error');
                this.errors = [error];
            }
        );
    }

    handleContactChange(evt) {
        if (evt.target.getSelection() == '') {
            this.contactId = '';
        }
        else {
            let contact = evt.target.getSelection();
            this.contactId = contact[0].id;
            this.template.querySelector('[data-id="contactInput"]').classList.remove('error');
            this.hasErrors = false;
            if (this.noAnswerErrors || this.answeredErrors) {
                this.checkRequiredFields();
            }
        }
    }

    navigateToNewDealershipContactPage() {
        let rtInfo = this.contactInfo.data.recordTypeInfos;
        let dealerRecordTypeId = Object.keys(rtInfo).find(rti => rtInfo[rti].name === 'Dealership Contact');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                recordTypeId: dealerRecordTypeId
            }
        });
    }

    navigateToAffiliationCreatePage() {
        const defaultValues = encodeDefaultFieldValues({
            Account__c: this.accountId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Affiliation__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    navigateToTaskPage() {

        getRecordTypeId()
            .then(istRecordTypeId => {

                let defaultValues;
                if(this.accountId != ''){
                    defaultValues = encodeDefaultFieldValues({
                        WhatId: this.accountId
                    });
        
                }
 
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Task',
                        actionName: 'new'
                    },
                    state: {
                        defaultFieldValues: defaultValues,
                        recordTypeId: istRecordTypeId
                    }
                });
            });

    }

    handleSubmit(){
        this.checkRequiredFields();

        if(this.hasErrors == false){

            this.showSpinner = true;

            let retention = 
                {
                    account: this.accountId,
                    contact: this.contactId,
                    comments: this.dealerComments,
                    direction: this.direction,
                    noAnswer: this.noAnswerSelection,
                    callType: this.callType,
                    experience: this.latestSelectionsList,
                    nextSteps: this.nextSteps
                };

    
            createRetention({jsonString:JSON.stringify(retention)}) 
                .then(results => {
                    if(results != null) {
                        fireToast('Success', 'Retention & Ignition record created successfully!', 'success');
                    }
                    else {
                        // This error is more likely than the error below as we have a try catch in the apex
                        fireToast('Error Saving', 'There was an error trying to create the Retention & Ignition Record; please try saving again. If the issue persists, submit an R&I ticket with as much information as possible, including a screen shot of the Dealer Outreach form.', 'error', 'sticky');
                    }
                })
                .catch(error => {
                    fireToast('Error Saving', 'There was an error trying to create this Retention & Ignition Record; please try saving again. If the issue persists, submit an R&I ticket with as much information as possible, including a screen shot of the Dealer Outreach form.', 'error', 'sticky');
                    this.errors = [error];
                }
            ).finally(() => {
                this.showSpinner = false;
                this.handleCancel();
            });
        }
    }


    checkRequiredFields() {
        if (this.accountId == null || this.accountId == '') {
            this.template.querySelector('[data-id="accountInput"]').classList.add('error');
            this.hasErrors = true;
        }
        else {
            this.template.querySelector('[data-id="accountInput"]').classList.remove('error');
        }

        if (this.contactId == null || this.contactId == '') {
            this.template.querySelector('[data-id="contactInput"]').classList.add('error');
            this.hasErrors = true;
        }
        else {
            this.template.querySelector('[data-id="contactInput"]').classList.remove('error');
        }

        if (this.direction == null || this.direction == '') {
            this.hasErrors = true;
        }

        if (this.callType == null || this.callType == '') {
            this.hasErrors = true;
        }

        this.checkNoAnswerDependencies();

        if (this.hasErrors && this.callAnswered) {
            this.answeredErrors = true;
            this.noAnswerErrors = false;
        } else if (this.hasErrors && !this.callAnswered) {
            this.noAnswerErrors = true;
            this.answeredErrors = false;
        } else if (!this.hasErrors) {
            this.noAnswerErrors = false;
            this.answeredErrors = false;
        }
        
    }

    checkNoAnswerDependencies() {
        if (this.noAnswerSelection == null || this.noAnswerSelection == '') {

            this.callAnswered = true;
            if (this.dealerComments == null || this.dealerComments == '') {
                var dealerCommentsCmp = this.template.querySelector('[data-id="commentsInput"]');
                dealerCommentsCmp.setCustomValidity("Dealer Comments is required");
                dealerCommentsCmp.reportValidity();
                this.hasErrors = true;
            }
            else {
                this.template.querySelector('[data-id="commentsInput"]').classList.remove('slds-has-error');
            }

            if (this.latestSelectionsList == null || this.latestSelectionsList == '') {
                this.hasErrors = true;
            }

            if (this.nextSteps == null || this.nextSteps == '') {
                var inputCmp = this.template.querySelector('[data-id="nextSteps"]');
                inputCmp.setCustomValidity("Next Steps is required");
                inputCmp.reportValidity();
                this.hasErrors = true;
            }
            else {
                this.template.querySelector('[data-id="nextSteps"]').classList.remove('error');
            }

        }
        else {
            this.removeNoAnswerErrors();
        }
    }

    removeNoAnswerErrors() {
        const textAreas = this.template.querySelectorAll('lightning-textarea');
        if (textAreas) {
            textAreas.forEach(field => {
                field.setCustomValidity("");
                field.reportValidity();
            });
        }
    }

    handleCancel() {
        this.hasErrors = false;
        this.noAnswerErrors = false;
        this.answeredErrors = false;
        this.clearedByClose = true;
        this.cancelCheck = false;
        
        this.template.querySelectorAll("c-lookup").forEach(item => {
            item.selection = [];
        });
        
        this.accountId = '';
        this.contactId = '';
        this.latestSelectionsList = null;
        this.dealerComments = '';
        this.nextSteps = '';
        this.direction = null;
        this.callType = null;
        this.noAnswerSelection = null;

        this.removeAlwaysRequiredErrors();
        const textAreas = this.template.querySelectorAll('lightning-textarea');
        if (textAreas) {
            textAreas.forEach(field => {
                field.value = "Temp";
                field.setCustomValidity("");
                field.reportValidity();
                field.value = '';
            });
        }
        this.minimizePopUp();
    }

    removeAlwaysRequiredErrors() {
        this.template.querySelector('[data-id="accountInput"]').classList.remove('error');
        this.template.querySelector('[data-id="contactInput"]').classList.remove('error');
    }

    checkCancel() {
        this.cancelCheck = true;
    }

    closeCancelModal() {
        this.cancelCheck = false;
    }

    minimizePopUp() {
        let value = this.minimizeIndex;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });

        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        this.minimizeIndex = !this.minimizeIndex;
    }
}