import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import doInit from '@salesforce/apex/RunListSendController.doInit';
import submitSendToRunList from '@salesforce/apex/RunListSendController.submitSendToRunList'

export default class RunListSend extends NavigationMixin(LightningElement) {
    @api ilcRecordsJSON;                //passed in via VF Page
    @track errorMessage;                //Error Message
    @track successMessage;              //Success Message
    @track activeSpinner = false;
    @track submitDisabled = false;
    @track activeOpenSections;
    @track crsToSendList;
    @track invalidCRsList;
    dataToSubmitWrapper = {};

    //Runs on Page Load
    connectedCallback( ){
        this.activeSpinner = true;
        doInit({ ilcJsonString: this.ilcRecordsJSON })
            .then(result => {
                var returnVal = JSON.parse( result );
                if( returnVal.errorMessage ){
                    //Error
                    this.submitDisabled = true;
                    this.errorMessage = returnVal.errorMessage;
                }
                //Sets values on init
                if(returnVal.activeOpenSections) this.activeOpenSections = returnVal.activeOpenSections;
                if(returnVal.eligibleCRs) this.crsToSendList = returnVal.eligibleCRs;
                if(returnVal.eligibleCRs) this.dataToSubmitWrapper.crs = returnVal.eligibleCRs;
                if(returnVal.invalidILCList) this.invalidCRsList = returnVal.invalidILCList;
                if(!this.crsToSendList || this.crsToSendList.length == 0 ){
                    this.submitDisabled = true;
                }
                this.activeSpinner = false;
            })
            .catch(error => {
                //Javascrupt Failed Error
                this.errorMessage = error;
                this.activeSpinner = false;
            })
        ;
    }
    //Runs on Submit button click
    submit(){
        this.activeSpinner = true;
        this.submitDisabled = true;
        submitSendToRunList({dataSubmitWrapperJSON : JSON.stringify(this.dataToSubmitWrapper)})
            .then(result => {
                var returnVal = JSON.parse( result );
                this.errorMessage = returnVal.errorMessage;
                this.successMessage = returnVal.successMessage;
                this.activeSpinner = false;
                this.submitDisabled = false;
            })
            .catch(error => {
                this.errorMessage = error;
                this.activeSpinner = false;
            });
    }
    //When the X is closed on the toast message, this hides the toast message
    hideErrorMessage(){
        this.errorMessage = null;
    }
    //When the X is closed on the toast message, this hides the toast message
    hideSuccessMessage(){
        this.successMessage = null;
    }
    //On button press, this brings you back to your last page
    back(){
        window.history.back();
    }
}