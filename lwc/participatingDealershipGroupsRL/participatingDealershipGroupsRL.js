/* This is the LWC for Participating Dealership Groups Related List
 * @author James Andre LaCour
*/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPLAs from '@salesforce/apex/ParticipatingDealershipGroupsRLCont.getPrivateLaneAccess';
import deleteAccess from '@salesforce/apex/ParticipatingDealershipGroupsRLCont.deletePLA';
import { NavigationMixin } from 'lightning/navigation';
/***********************JS Code**********************************/
export default class ParticipatingDealershipGroupsRL extends NavigationMixin(LightningElement) {
    // Spinner Variable
    @track activeSpinner = false;                           // Controls whether the Spinner is showing
    // Variables set via  Page or Component
    @api recordId;                                          // Record Id set by the page
    // Modal Variables
    @track showModal = false;
    newDealershipModal = false;
    deleteDealershipModal = false;
    // Private Lane Access Variables
    @track plaList = [];
    emptyMessage = 'No dealership groups added...';
    @track showEmptyMessage = false;
    /***********************Intialization****************************/
    //Runs on Page Load
    connectedCallback(){
        this.intialize( this.recordId );
    }
    /***********************Helper Methods***************************/
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Fires the Toast message for notifications to the user
    fireToast( title, message, variant="info", mode="dismissable", messageData=[]){
        // title = Title of the Toast, displayed as a Heading (Required)
        // message = String message (Required), can contain {0}...{N} indicating an index a messageData will replace
        // messageData = list of string or object{url,label} to replace the index in message. Default = []
        // variant = info (default) (gray), success (green), warning (yellow), error (red)
        // mode = dismissable (default) (remains 3 seconds or can be closed), pester (remains 3 seconds), sticky (has to be closed)
        const event = new ShowToastEvent({
            "title" : title,
            "message" : message,
            "messageData" : messageData,
            "mode" : mode,
            "variant" : variant
        });
        this.dispatchEvent( event );
    }
    // Intializes the list on load or after a delete happens
    intialize( privateLaneId ){
        getPLAs({recordId: privateLaneId})
            .then(result =>{
                var data = JSON.parse(result);
                if( !data.hasError ){
                    this.plaList = data.plaList;
                }else{
                    this.fireToast( 'There was an issue loading the Particpating Dealerships', data.message, "error", "dismissable" );
                }
                if( this.plaList.length == 0 ){
                    this.showEmptyMessage = true;
                }else{
                    this.showEmptyMessage = false;
                }
            })
            .catch(error => {
                this.fireToast( 'There was an issue loading the Particpating Dealerships', 'Please refresh the page', "error", "dismissable" );
            })
            .finally(() =>{
            })
        ;
    }
    /***********************Event Methods****************************/
    // Navigates to the Organization group that was clicked
    handleNavigateToOrgGroup( event ){
        let orgGroupId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orgGroupId,
                actionName: 'view'
            }
        });
    }
    // Ran when the modal is closed. 
    handlePrivateLaneAccessClose( event ){
        this.handleCloseModal('');
        // If new record was created, we will refresh list to show new one
        if( event.detail.createNewRecord ){
            this.intialize( this.recordId );
        }
    }
    // When create is clicked, we set the modal variables
    handleAddDealershipGroup( event ){
        this.showModal = true;
        this.newDealershipModal = true;
    }
    // On close of modal, resets the modal variables
    handleCloseModal( event ){
        this.showModal = false;
        this.newDealershipModal = false;
        this.deleteDealershipModal = false;
    }
    // ran on menu select for a specific Participating Dealership
    handleButtonMenuSelect( event ){
        // Navigates to the Private Lane Access page
        if( event.detail.value == 'View Information' ){
            var privateLaneAccessPageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.name,
                    actionName: 'view'
                }
            };
            this[NavigationMixin.GenerateUrl](privateLaneAccessPageRef)
            .then(url => this.url = url);
            this[NavigationMixin.Navigate](privateLaneAccessPageRef);
        // Deletes the Private Lane Access
        }else if( event.detail.value == 'Delete' ){
            if( window.confirm('Are you sure you wish to delete this permission?') ){
                this.toggleSpinner();
                deleteAccess( { privateAccessId: event.target.name } )
                    .then( result => {
                        var data = JSON.parse(result);
                        if( !data.hasError ){
                            this.intialize( this.recordId );
                            this.fireToast('Success', 'This permission has successfully been removed' , 'success', 'pester');
                        }else{
                            this.fireToast('There was an issue deleting the Private Lane Access', data.message , 'success', 'pester');
                        }
                    })
                    .catch( error => {
                        this.fireToast( 'There was an issue deleting the Private Lane Access', JSON.stringify(error), "error", "dismissable" );
                    })
                    .finally( () => {
                        this.toggleSpinner();
                    })
                ;
            }
        }
    }
    
}