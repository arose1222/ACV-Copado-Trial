/* This is the LWC for Private Lane Access layout
 * @author James Andre LaCour
*/
import { LightningElement, track , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submit from '@salesforce/apex/PrivateLaneAccessCont.submit';
import { NavigationMixin } from 'lightning/navigation';
import Fields from '@salesforce/schema/AsyncOperationStatus.Fields';
/***********************JS Code**********************************/
export default class PrivateLaneAccessLayout extends NavigationMixin(LightningElement){
    // Background Variables
    @api recordId;                                      // Record Id of this Private Lane Access if its editing an existing one
    @api objectApiName= "Private_Lane_Access__c";       // Object API name of this layout
    @api mode = 'view';                                 // Used to set the Lightning-record-form from view to edit and vic-versa
    @api privatelane;                                   // passed in from the ParticpatingDealershipGroupRL with the Private Lanes Id for defaulting 
    @api isfromrl = false;                              // Set to true if we are navigated to this page from the ParticpatingDealershipGroupRL LWC
    // Spinner Variable
    @track activeSpinner = false;                       // Variable to turn off and on the spinner
    // Title Bar variables
    @track showTitleBar;                                // On create, we show a title bar called New Private Lane Access. This controls that
    /***********************Intialization****************************/
    // Runs on Page Load
    connectedCallback() {
        if( this.mode == 'edit' ){
            this.showTitleBar = true;
        }else{
            this.showTitleBar = false;
        }
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
    // Fires an event to close the current tab if this page is opened from a tab
    sendCloseTab(){
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close }
        });
        // Fire the custom event
        this.dispatchEvent(closeclickedevt); 
    }
    // Fires an event to close the modal if this page is opened from a modal
    sendCloseModalEvent( detailObj ){
        const closeclickedevt = new CustomEvent('close', {
            detail: detailObj
        });
        // Fire the custom event
        this.dispatchEvent(closeclickedevt); 
    }
    /***********************Event Methods****************************/
    // Handles the Cancel event on the screen.
    handleCancel( event ){
        if(this.mode == 'edit'){
            this.sendCloseTab()
            this.sendCloseModalEvent( { createNewRecord : false } );
        }else{
            this.mode = 'view';
        }
    }
    // Handles the submission of the form(s)
    handleSubmit( event ){
        event.preventDefault(); // Stops the form from submitting so we can do custom logic
        this.toggleSpinner();
        const fields = event.detail.fields;
        if( this.recordId !== undefined ) fields.Id = this.recordId;
        submit({ fieldsJson : JSON.stringify(fields) })
            .then( result => {
                let data = JSON.parse(result);
                if( data.statusCode == 200 ){
                    let updatedOrCreated = fields.Id !== undefined && fields.Id != null && Fields.Id != '' ? 'updated' : 'created';
                    this.fireToast('Success', 'This has been successffuly ' + updatedOrCreated, 'success', 'pester');
                    if( this.isfromrl ){
                        this.sendCloseModalEvent( { createNewRecord : true } );
                    }else{
                        this.template.querySelector('lightning-record-form').submit(fields);    //lightning-record-form runs when its run form a new tab 
                    }
                }else if( data.statusCode >= 400 ){
                    this.fireToast('Please contact a Salesforce Admin', data.statusMessage, 'error', 'sticky');
                }
            })
            .catch( error => {
                this.fireToast('Please contact a Salesforce Admin', JSON.stringify(error), 'error', 'sticky');
            })
            .finally( () => {
                this.toggleSpinner();
            })
        ;
    }
}