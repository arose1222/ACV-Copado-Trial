/* This is the LWC js controller for PrivateLaneLayout
 * @author James Andre LaCour
*/
import { LightningElement, api, track } from 'lwc';
import { fireToast } from 'c/acvUtilHelper';
import doInit from '@salesforce/apex/AuctionKillController.doInit';
import submitKillAuction from '@salesforce/apex/AuctionKillController.submitKillAuction';
// Table Columns
const dataTableColumns = [    
    { sortable: true, hideDefaultActions: true, label: 'Year, Make, Model, Trim', fieldName: 'yearMakeModelTrim', type: 'text' },
    { sortable: true, hideDefaultActions: true, label: 'VIN', fieldName: 'vin', type:'text' },
    { sortable: true, hideDefaultActions: true, label: 'Status', fieldName: 'status', type: 'text' },
    { sortable: false, hideDefaultActions: true, type: 'button',
        typeAttributes: {
            label:'Remove',
            variant: 'base',
            name: {fieldName : 'Id'},
        }
    }
];
/***********************JS Code**********************************/
export default class TerminateAuctionModal extends LightningElement {
    // Passed in variables
    @api selectedilcrowsjson;
    // Spinner Variables
    activeSpinner = false;
    // Table Variables
    columns = dataTableColumns;
    @track displayedRows;
    // Terminate Reason Variables
    termianteReasonValue = '';
    // Submit Variables
    dataToSubmitWrapper = {};
    terminateConfirmList = [];
    // Return Message Variables
    mixedResultsMessage = {};
    lwcCloseEvent = new CustomEvent('close', {detail : {}});
    // View State Variables
    showConfirmationScreen = false;
    showReviewScreen = true;
    showFailureScreen = false;
    showIneligibleMessage = false;
    @track expandIneligibleSection = false;
    ineligibleValuesSize = '';
    ineligibleValues = [];
    ineligibleValuesView = [];
    ineligiblePreviewAmount = 3;
    viewAllPossible = true;
    wizardStateVariables = {
        0 : {                   // Review Screen
            headerText : 'Terminate Auctions',
            backOrCancel : 'Cancel',
            confirmOrTerminate : 'Terminate Auctions',
            disableConfirmTerminate : true,
            showButtons : true,
            showViewAll : true
        },
        1 : {                   // Confirmation Screen
            headerText : 'Confirm Termination',
            backOrCancel : 'Back',
            confirmOrTerminate : 'Confirm',
            disableConfirmTerminate : false,
            showButtons : true,
            showViewAll : false
        },
        2 : {                   // Failure Screen
            headerText : 'Termination Results',
            backOrCancel : '',
            confirmOrTerminate : '',
            disableConfirmTermianate : false,
            showButtons : false,
            showViewAll : false
        },
        999: {                  // View All Screen
            headerText : '',
            backOrCancel : 'Back',
            confirmOrTerminate  : 'Terminate Auctions',
            disableConfirmTerminate : true,
            showButtons : true,
            showViewAll : false
        }
    }
    currentWizardStateNumber = 0;
    @track currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
    /***********************Intialization****************************/
    // Intialization
    connectedCallback(){
        this.activeSpinner = true;
        doInit({ ilcJsonString: this.selectedilcrowsjson })
            .then(result => {
                var returnVal = JSON.parse( result );
                if( returnVal.errorMessage ){
                    //Error
                    this.submitDisabled = true;
                    this.errorMessage = returnVal.errorMessage;
                }
                //Sets values on init
                if(returnVal.eligibleAuctions) this.displayedRows = returnVal.eligibleAuctions;
                if(returnVal.invalidILCList){
                    this.ineligibleValues = returnVal.invalidILCList;
                    this.ineligibleValuesView = returnVal.invalidILCList.slice(0,this.ineligiblePreviewAmount);
                    if( this.ineligibleValues.length > this.ineligiblePreviewAmount ) this.viewAllPossible = true;
                    let itemText = this.ineligibleValues.length == 1 ? ' item ' : ' items ';
                    this.ineligibleValuesSize = this.ineligibleValues.length  + itemText;
                    this.showIneligibleMessage = true;
                }
                if(returnVal.runningUser) this.dataToSubmitWrapper.currentUser = returnVal.runningUser;
                if( !this.displayedRows || this.displayedRows.length == 0 ){
                    this.currentWizardState.disableConfirmTerminate = true;
                }
            })
            .catch(error => {
                console.log( JSON.stringify(error) );
            })
            .finally( () => {
                this.activeSpinner = false;
            })
        ;
    }
    /***********************Event Methods****************************/
    // Updates the Terminate Reason Variable on change
    handleTerminateReasonChange( event ){
        this.termianteReasonValue = event.detail.value;
        if( this.termianteReasonValue.length == 0 ){
            this.currentWizardState.disableConfirmTerminate = true;
        }else if(this.displayedRows.length > 0){
            this.currentWizardState.disableConfirmTerminate = false;
        }
    }
    // Handles removing a value from the table in the Review Screen
    handleRemoveClick( event ){
        var row = event.detail.row;
        var rowsToUpdate = JSON.parse(JSON.stringify(this.displayedRows));
        var foundRowIndex = rowsToUpdate.findIndex( thisRow => { return row.Id == thisRow.Id } );
        rowsToUpdate.splice(foundRowIndex, 1);
        this.displayedRows = rowsToUpdate;
        if( this.displayedRows.length == 0 ){
            this.currentWizardState.disableConfirmTerminate = true;
        }
    }
    // Handles the Confirm or Terminate Button. Confirm submits to Apex
    handleConfirmOrTerminate( event ){
        if( event.target.name == 'Terminate Auctions'){
            this.setCurrentWizardState( this.currentWizardStateNumber + 1 );
            this.setTerminateConfirmVariables();
        }else if( event.target.name == 'Confirm' ){
            this.activeSpinner = true;
            submitKillAuction({dataSubmitWrapperJSON : JSON.stringify(this.dataToSubmitWrapper)})
                .then(result => {
                    var returnVal = JSON.parse( result );
                    if( returnVal.errorMessage != '' && returnVal.errorMessage !== undefined && returnVal.errorMessage != null ){
                        this.mixedResultsMessage.showErrorMessage = true;
                        this.mixedResultsMessage.errorMessage = returnVal.errorMessage;
                        if( returnVal.successMessage != '' && returnVal.successMessage !== undefined && returnVal.successMessage != null ){
                            this.mixedResultsMessage.showSuccessMessage = true;
                            this.mixedResultsMessage.successMessage = returnVal.successMessage;
                            this.lwcCloseEvent = new CustomEvent('close', {detail : {refreshTable : true}});
                        }
                        this.setCurrentWizardState( this.currentWizardStateNumber + 1 );
                    }else{
                        fireToast('Success', '', 'success', 'dismissable');
                        this.lwcCloseEvent = new CustomEvent('close', {detail : {refreshTable : true}});
                        this.sendCloseEvent();
                    }
                })
                .catch(error => {
                })
                .finally( () => {
                    this.activeSpinner = false;
                })
            ;
        }
    }
    // Closes modal
    handleCloseModalEvent( event ){
        this.sendCloseEvent();
    }
    // Handles whether the expanded preview form of Ineligible Section should be seen
    handleIneligibleSectionView( event ){
        if( this.expandIneligibleSection ){
        this.expandIneligibleSection = false;
        }else{
            this.expandIneligibleSection = true;
        }
    }
    // Handles what should happen when the Back or Cancel button is clicked
    handleBackCancel( event ){
        if( event.target.name == 'Cancel'){     //Closes Modal
            this.sendCloseEvent();
        }else if( this.currentWizardStateNumber == 999){        //Goes back to the previous screen from whenever they clicked View All
            this.ineligibleValuesView = this.ineligibleValues.slice( 0, this.ineligiblePreviewAmount );
            this.setCurrentWizardState( 0 );
        }else{  // Goes back once in the step
            this.setCurrentWizardState( this.currentWizardStateNumber - 1 );
        }
    }
    // Handles when View all is clicked in Ineligible screen
    handleViewAllIneligible( event ){
        this.ineligibleValuesView = this.ineligibleValues;
        this.setCurrentWizardState(999);
    }
    /***********************Helper Methods***************************/
    // Sends close event to parent LWC
    sendCloseEvent(){
        this.dispatchEvent(this.lwcCloseEvent);
    }
    // Sets the DataToSubmitWrapper to pass into Apex
    setTerminateConfirmVariables(){
        var terminatingSummary = {};
        this.displayedRows.forEach( function( thisRow ){
            let status = thisRow.status;
            if( terminatingSummary[status] === undefined ) terminatingSummary[status] = [];
            terminatingSummary[status].push(thisRow);
        });
        let statusNameKeys = Object.keys(terminatingSummary);
        statusNameKeys.forEach( function( statusName ){
            let auctionText = terminatingSummary[statusName].length > 1 ? 'auctions' : 'auction';
            this.terminateConfirmList.push( terminatingSummary[statusName].length + ' ' + auctionText + ' in the ' + statusName + ' status' );
        }, this);
        this.dataToSubmitWrapper.auctions = this.displayedRows;
        this.dataToSubmitWrapper.notes = this.termianteReasonValue;
    }
    // Sets the current wizard state based on the the wizard state number passed in
    setCurrentWizardState( wizardStateNumber ){
        switch(wizardStateNumber){
            case 0:         // Starting Page
                this.showReviewScreen = true;
                this.showConfirmationScreen = false;
                this.showIneligibleMessage = this.ineligibleValues.length > 0 ? true : false;
                this.showFailureScreen = false;
                break;
            case 1:         // Confirmation Screen
                this.showReviewScreen = false;
                this.showConfirmationScreen = true;
                this.showIneligibleMessage = false;
                this.showFailureScreen = false;
                break;
            case 2:
                this.showReviewScreen = false;
                this.showConfirmationScreen = false;
                this.showIneligibleMessage = false;
                this.showFailureScreen = true;
                break;
            case 999:       // View All Screen
                this.showReviewScreen = false;
                this.showConfirmationScreen = false;
                this.showIneligibleMessage = true;
                this.showFailureScreen = false;
                break;
        }
        this.currentWizardState = this.wizardStateVariables[wizardStateNumber];
        this.currentWizardStateNumber = wizardStateNumber;
    }
}