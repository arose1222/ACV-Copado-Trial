import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import doInit from '@salesforce/apex/AuctionKillController.doInit';
import submitKillAuction from '@salesforce/apex/AuctionKillController.submitKillAuction'

export default class AuctionKill extends NavigationMixin(LightningElement) {
    @api ilcRecordsJSON;                //passed in via VF Page
    @track errorMessage;                //Error Message
    @track successMessage;              //Success Message
    @track auctionsToKillList;    
    @track invalidAuctionsList;      
    @track submitDisabled = false;
    @track activeSpinner = false;
    @track activeOpenSections;
    dataToSubmitWrapper = {};
    notes = '';
    defaultNotesMessage = 'Auciton has been killed from counter sent status to ended killed status.';
    inventoryLifeCycleHomePageRef;

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
                if(returnVal.eligibleAuctions) this.auctionsToKillList = returnVal.eligibleAuctions;
                if(returnVal.eligibleAuctions) this.dataToSubmitWrapper.auctions = returnVal.eligibleAuctions;
                if(returnVal.invalidILCList) this.invalidAuctionsList = returnVal.invalidILCList;
                if(returnVal.runningUser) this.dataToSubmitWrapper.currentUser = returnVal.runningUser;
                if(!this.auctionsToKillList || this.auctionsToKillList.length == 0 ){
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
        // Web browser confirmation will pop up. Depending on your selection depends if any actions run
        var confirmation = confirm("Are you sure you want to End these Auctions?");
        if( confirmation == true ){
            this.activeSpinner = true;
            this.submitDisabled = true;
            //If no note was set, we use the placeholder text
            if(this.notes == ''){
                this.dataToSubmitWrapper.notes = this.defaultNotesMessage;
            }else{
                this.dataToSubmitWrapper.notes = this.notes;
            }
            submitKillAuction({dataSubmitWrapperJSON : JSON.stringify(this.dataToSubmitWrapper)})
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
                })
            ;
        }else{
            //Did not decided to confirm 
        }
    }
    //Sets value of the notes variable
    setNotesValue(event){
        this.notes = event.detail.value;
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