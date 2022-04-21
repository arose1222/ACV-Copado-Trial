/**
 * Javascript for RateCardApprovalButtons
 */
import { LightningElement, api } from 'lwc';
import { fireToast } from 'c/acvUtilHelper';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import approve from '@salesforce/apex/RateCardApprovalButtonsCont.approve';
import reject from '@salesforce/apex/RateCardApprovalButtonsCont.reject';
import checkPermission from '@salesforce/apex/RateCardApprovalButtonsCont.checkApprovalPermissions';
export default class RateCardApprovalButtons extends LightningElement {
    @api recordId;              // gets populated on load. record Id of the page you're on
    showModal = false;          // Controls whether the modal is displayed
    showButtons = false;        // Controls whether the LWC displays. This is based on if you are an approver in the Queue
    optionSelected = '';        // Approval or Rejection
    commentsLabel = ''          // Label to the field in Comments 
    comments = '';              // comments
    activeSpinner = false;      // Whether the spinner appears
    /*************************Intialization***************************/
    // Runs on Load. Checks Permission
    connectedCallback(){
        checkPermission( {recordId: this.recordId} )
        .then(result => {
            this.showButtons = result;
        })
        .catch(error => {
            console.log( JSON.stringify(error) );
        })
        .finally(() => {
        })
    }
    /*************************Event Methods***************************/
    // Runs on Approval Click
    handleApprove( event ){
        this.openModal('Approval');
    }
     // Runs on Rejection Click
     handleRejection( event ){
        this.openModal('Rejection');
    }
    // Runs on Modal Save
    handleSave(){
        if( this.comments != '' && this.comments !== undefined && this.comments != null ){
            this.toggleSpinner();
            if( this.optionSelected == 'Approval' ){
                approve( {comments: this.comments, recordId: this.recordId} )
                    .then( result =>{
                        var data = JSON.parse(result);
                        if( data.hasError ){
                            fireToast('There was an issue with Approving', data.message, 'error');
                        }else{
                            fireToast('Success', 'The Rate Card has been Successfully Approved', 'Success');
                            getRecordNotifyChange([{recordId: this.recordId}]);
                        }
                    })
                    .catch( error => {
                        console.log( JSON.stringify(error) );
                        fireToast('Something Went Wrong', 'There was an issue approving. Before trying again, please contact a Salesforce Admin', 'error');
                    })
                    .finally( () => {
                        this.toggleSpinner();
                        this.closeModal();
                    })
                ;
            }else{
                reject( {comments: this.comments, recordId: this.recordId} )
                    .then( result =>{
                        var data = JSON.parse(result);
                        if( data.hasError ){
                            fireToast('There was an issue with Rejecting', data.message, 'error');
                        }else{
                            fireToast('Success', 'The Rate Card has been Successfully Rejected', 'Success');
                            getRecordNotifyChange([{recordId: this.recordId}]);
                        }
                    })
                    .catch( error => {
                        console.log( JSON.stringify(error) );
                        fireToast('Something Went Wrong', 'There was an issue rejecting. Before trying again, please contact a Salesforce Admin', 'error');
                    })
                    .finally( () => {
                        this.toggleSpinner();
                        this.closeModal();
                    })
                ;
            }
        }else{
            this.template.querySelector('[data-name="commentTextArea"]').reportValidity();
        }
    }
    // Runs on Modal Cancel
    handleCancel(){
        this.closeModal();
    }
    // Runs on Comment change. Sets the value to the global variable
    handleCommentsOnChange( event ){
        this.comments = event.detail.value;
    }
    /*************************Helper Methods***************************/
    // Turns on and off the Main Loading Spinner 
     toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Opens modal and sets the view variables on Approval or Rejection
    openModal( headerTitle ){
        this.showModal = true;
        this.optionSelected = headerTitle;
        this.commentsLabel = headerTitle + ' Comments';
    }
    // Closes Modal and resets the comment variable
    closeModal(){
        this.showModal = false;
        this.comments = '';
    }
}