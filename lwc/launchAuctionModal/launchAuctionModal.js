/* LWC for the Launch Auction Modal.
 * It will open itself in a modal container
 * @author James Andre LaCour
*/
import { LightningElement, track, api } from 'lwc';
import launchAuction from '@salesforce/apex/LaunchAuctionCont.launchAuction';
import { fireToast } from 'c/acvUtilHelper';
import doInit from '@salesforce/apex/LaunchAuctionCont.intialize';
/***********************Final Variables**************************/
// Table Columns
const confirmationColumns = [
    { sortable: false, hideDefaultActions: true, label: 'Client', fieldName: 'clientURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'clientName' }
        } 
    },
    { sortable: false, hideDefaultActions: true, label: 'Location', fieldName: 'locationURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'locationName' }
        } 
    },
    { sortable: false, hideDefaultActions: true, label: 'Stock Number', fieldName: 'stockNumber', type: 'text' },
    { sortable: false, hideDefaultActions: true, label: 'VIN', fieldName: 'vinURL', type:'url', 
        typeAttributes:{ 
            label: { fieldName: 'vinName' }
        } 
    },
    { sortable: false, hideDefaultActions: true, label: 'Status', fieldName: 'status', type: 'text' },
    { sortable: false, hideDefaultActions: true, label: 'Year, Make, Model, Trim', fieldName: 'yearMakeModelTrimURL', type: 'url', 
        typeAttributes:{ 
            label: { fieldName: 'yearMakeModelTrim' }
        } 
    },
    { sortable: false, hideDefaultActions: true, label: 'Odometer', fieldName: 'odometer', type: 'number' },
    { sortable: false, hideDefaultActions: true, label: 'Reserve', fieldName: 'reserve', type: 'currency', editable: true },
    { sortable: false, hideDefaultActions: true, label: 'Start Date And Time', fieldName: 'startDateTime', type: 'date',
        typeAttributes:{ year: 'numeric', month: 'long', day:'2-digit', weekday:'long', hour: 'numeric', minute: '2-digit' } 
    },
];
/***********************JS Code**********************************/
export default class LaunchAuctionModal extends LightningElement {
    // Spinner Variable
    @track activeSpinner = false;
    // Success Call Variables
    dataTableColumns = confirmationColumns;      
    // Assigned from Parent LWC
    @api selectedilcrowsjson = '';               // Selected Rows from Parent Screen that we are considering
    @api sendtoconfirmationpage = false;         // If we should return values to the parent for a confirmation screen
    @api editscheduleclicked = false;            // If on Parent Screen we want to redirect to just changing the Launch date and time
    @api launchtype = '';
    // Wizard Variables
    /*
        0 - Starting page
        *.1 - Launching to Standard Flow - Starting screen -> Immediate or DateTie --> DateTime Picker (if picked) -> Confirmation Screen/Launch
        *.4 - Edit Schedule
        998 - Show Ineligible full Screen
        999 - Confirmation Page
    */
    wizardStateVariables = {
        999 : {},
        998 : {
            backOrCancel : 'Back',               // Text to show on the back or cancel button
            showNext : false,                    // Whether to show the Next Button
            goBackStep : null,                   // Gets set when View All on Ineligible gets called   
            showViewAll: false                   // Whether to show the view all button in Ineligible Screen
        },
        0 : {
            backOrCancel : 'Cancel',
            showNext : true,
            showViewAll: true
        },
        0.1 : {
            backOrCancel : 'Back',
            showNext : true,
            showViewAll: true
        },
        0.4 : {
            backOrCancel : 'Cancel',
            showNext : true,
            showViewAll: true
        },
        1 : {
            backOrCancel : 'Back',
            showNext : true,
            showViewAll: true
        }
    }
    currentWizardStateNumber = 0;                //current page the Wizard State is on
    @track currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];   //The current wizard state
    // Starting Screen Variables
    selectedLaunchOption = null;                 // Which option is selected in the first starting screen
    showStartingPage = true;                     // Whether to show the starting screen
    showAsapOrSpecificScreen = false;            // the selection screen
    @track asapChecked = false;                  // Handles raido Button selection for Asap
    @track specificTimeChecked = false;          // Handles raido Button selection for Specific Time
    @track launchOptionsList = [];               // All options to select in starting screen
    // Date Time Picker Variables
    showDateTimeScreen = false;                    // Whether to show the DateTime Picker
    launchDateValue = '';                        // The launch to Date value
    launchTimeValue = '';                        // The launch to Time Value
    launchDateMinValue = '';                     // The launch to Minimum date value
    @track launchTimeMinValue = '';              // The Launch to minimum Time value
    launchTimeMinOriginalValue = '';             // The Launch to Minimum Time Oriiginal value. This is set if they are trying to schedule for the day ot TODAY
    validDate = false;                           // Whether its a valid date to schedule
    validTime = false;                           // Whether its a valid time to schedule
    asapLaunch = false;                          // Whether we will launch immediately or not
    // Ineligible ILC Variables
    @track expandIneligibleSection = false;      // Whether to show or not show the preview of Ineligible ILC's
    @track showIneligibleMessage = false;               // Whether to show the Ineligible message. Depends if there are ineligible cars
    ineligibleValuesView = [];                   // The ineligible values to view. 
    ineligibleValuesSize = null;                 // Size of ineligble values. String concatenated with 'Items'
    ineligiblePreviewAmount = 5                  // Preview size of the ineligible screen
    // Footer Variables
    @track disableNext = true;                   // Whether the Next button is disabled
    /***********************Intialization****************************/
    // Runs on Page Load
    connectedCallback(){
        if( this.editscheduleclicked ){
            this.setDateTimeMinimums();
            this.setCurrentWizardState(.4);
        }else{
            this.toggleSpinner();
            doInit({ilcRowsJson : this.selectedilcrowsjson})
                .then( result => {
                    var data = JSON.parse(result);
                    if( data.statusCode == 400 ){
                        fireToast( 'Error with Launch Auction', 'Please reachout to a Salesforce Admin ', "Error", "dismissable" );
                        this.handleCloseModalEvent('');
                    }else{
                        this.launchOptionsList = data.launchOptionsList;
                        this.setDateTimeMinimums();
                        this.setCurrentWizardState(0);
                        // This bottom part should only be here while LIVE is the only option
                        var liveSelection = data.launchOptionsList.filter( launchOption => {return launchOption.title == 'Live'} )[0];
                        if( liveSelection.className.includes('disableDiv') ){
                            this.ineligibleValuesView = liveSelection.ineligibleList.slice(0,this.ineligiblePreviewAmount);
                            let itemChoice = liveSelection.ineligibleList.length == 1 ? 'item' : 'items';
                            this.ineligibleValuesSize = liveSelection.ineligibleList.length + ' ' + itemChoice;
                            this.showIneligibleMessage = true;
                        }
                    }
                })
                .catch( error => {
                    fireToast( 'Error with Launch Auction', 'Please reachout to a Salesforce Admin ', "Error", "dismissable" );
                    this.handleCloseModalEvent('');
                })
                .finally( () => {
                    this.toggleSpinner();
                })
            ;
        }
    }
    /***********************Helper Methods***************************/
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Sets the Date and time minimum
    // Current Minmum is the datetime you clicked Launch Auction at
    setDateTimeMinimums(){
        var today = new Date();
        this.launchDateMinValue = this.formatDateToIsoLocale(today.toLocaleDateString());
        this.launchTimeMinValue = this.formateTimeToIsoLocale(today);
        this.launchTimeMinOriginalValue = this.formateTimeToIsoLocale(today);
    }
    // Formats the locale time into ISO format for the tags
    formateTimeToIsoLocale(date){
        return date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() + '.' + date.getMilliseconds();
    }
    // Formats the locale date into ISO Format for the tags
    formatDateToIsoLocale(date) {
        var d = new Date(date);
        var month = '' + (d.getMonth() + 1);
        var day = '' + d.getDate();
        var year = d.getFullYear();
        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;
        return [year, month, day].join('-');
    }
    // Validates whether the Date and Time to run is valid
    checkLaunchDateTimeValidation(){
        // Date Validation
        var dateComponent = this.template.querySelector(".LaunchDate");
        if( new Date(dateComponent.value) > new Date(this.launchDateMinValue) || dateComponent.value == this.launchDateMinValue ){
            dateComponent.setCustomValidity('');
            this.validDate = true;
        }else{
            dateComponent.setCustomValidity('This is not a valid date. Please pick a date of ' + this.launchDateMinValue + ' or later.');
            this.validDate = false;
        }
        dateComponent.reportValidity();
        // Time Validation
        var timeComponent = this.template.querySelector(".LaunchTime");
        if( new Date(dateComponent.value + ' ' + timeComponent.value) >= new Date(this.launchDateMinValue + ' ' + this.launchTimeMinValue) && timeComponent.value != '' ){
            timeComponent.setCustomValidity('');
            this.validTime = true;
        }else{
            var message = '';
            if( !this.validDate ){
                message = 'Please fix date value';
            }else if( timeComponent.value == '' ){
                message = 'Please select a time to Launch';
            }else{
                message = 'This is not a valid time. Please pick a time of ' + new Date(this.launchDateMinValue + ' ' + this.launchTimeMinOriginalValue).toLocaleTimeString() + ' or later.';
            }
            timeComponent.setCustomValidity(message);
            this.validTime = false;
        }
        if( this.validTime && this.validDate ){
            this.disableNext = false;
        }else{
            this.disableNext = true;
        }
        timeComponent.reportValidity();
    }
    // Sets the minmum time based on the change of date.
    // Its either the original value from load or no minmum
    setTimeMinimumBasedOnDateChange( dateValue ){
        if( dateValue == this.launchDateMinValue ){
            this.launchTimeMinValue = this.launchTimeMinOriginalValue;
        }else{
            this.launchTimeMinValue = '';
        }
    }
    // Sets the current wizard state based on the the wizard state number passed in
    setCurrentWizardState( wizardStateNumber ){
        if( wizardStateNumber < 0 ){                //for going back, resets to first screen
            this.currentWizardStateNumber = 0;
            this.selectedLaunchOption = null;
        }else{
            this.currentWizardStateNumber = wizardStateNumber;
        }
        switch(this.currentWizardStateNumber){
            case 0:         //Starting Page
                this.showStartingPage = true;
                this.showDateTimeScreen = false;
                this.showIneligibleMessage = false;
                this.expandIneligibleSection = false;
                this.disableNext = true;
                this.showAsapOrSpecificScreen = false;
                this.currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
                break;
            case 998:       //Ineligible Auction Page
                this.showStartingPage = false;
                this.showDateTimeScreen = false;
                this.showIneligibleMessage = true;
                this.expandIneligibleSection = true;
                this.disableNext = true;
                this.showAsapOrSpecificScreen = false;
                this.currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
                break;
            case 0.1:       //Launch Auction Screen
                this.showStartingPage = false;
                this.showDateTimeScreen = true;
                this.disableNext = true;
                this.showAsapOrSpecificScreen = false;
                this.launchDateValue = '';
                this.launchTimeValue = '';
                this.currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
                break;
            case 0.4:       //Edit Schedule
                this.showStartingPage = false;
                this.showDateTimeScreen = true;
                this.disableNext = true;
                this.showAsapOrSpecificScreen = false;
                this.currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
                break;
            case 1:       //Immediate or Date Picker
                this.showStartingPage = false;
                this.showDateTimeScreen = false;
                this.showAsapOrSpecificScreen = true;
                this.disableNext = true;
                this.currentWizardState = this.wizardStateVariables[this.currentWizardStateNumber];
                break;
            case 1.4:       //Edit Schedule Save
                var tableRows = this.updateLaunchDateAndTimeToRows();
                this.sendSuccessCloseEvent( this.launchtype, tableRows );
                break;
            default:
                var tableRows = this.appendLaunchDateAndTimeToRows();
                if( this.sendtoconfirmationpage ){
                    this.sendSuccessCloseEvent( this.launchtype, tableRows );
                }/*else{
                    //If not sending to a confirmation page, need to launch the action from here. This is where you would do it
                    launchLiveAuction({
                            ilcRowsJson : this.selectedilcrowsjson, 
                            dateToLaunchJson : JSON.stringify(this.launchDateValue), 
                            timeToLaunchJson : JSON.stringify(this.launchTimeValue)
                        }).then(result => {

                        })
                        .catch(error => {

                        })
                        .finally( () => {

                        })
                    ;
                }*/
        }
    }
    // Sends an event to the parent on close with data for a confirmation page
    sendSuccessCloseEvent( launchOption, tableRows ){
        var lwcEvent;
        var specificActionData;
        var totalItemsText = '';
        if(tableRows.length == 1){
            totalItemsText = '1 Item';
        }else{
            totalItemsText = tableRows.length + ' Items';
        }
        specificActionData = {};
        lwcEvent = new CustomEvent('close', {
            detail : {
                showConfirmationScreen : true,
                tableColumns : this.dataTableColumns,
                tableRows : tableRows,
                actionExecutedTitle : 'Bulk Launch',
                actionExecutedSubTitle : 'Launch to ' + launchOption,
                totalItemsText : totalItemsText,
                specificActionData : specificActionData,
                launchType : launchOption
            }
        });
        this.dispatchEvent(lwcEvent);
    }
    // Used when the Launch Auction flow is used
    // We append the Start Date time to show up in the confirm table only for rows that can be sent
    appendLaunchDateAndTimeToRows(){
        var rowsToLaunch = [];
        var selectedIlcRows = JSON.parse(this.selectedilcrowsjson);
        selectedIlcRows.forEach(thisRow => {
            if( this.selectedLaunchOption.eligibleList.some( thisEligible => {return thisEligible.ilcId == thisRow.Id;}) ){
                thisRow.startDateTime = this.asapLaunch ? null : this.launchDateValue + ' ' + this.launchTimeValue;
                rowsToLaunch.push( thisRow );
            }
        });
        return rowsToLaunch;
    }
    // Updates Start Date and time of all rows pushed in. Used during the Edit Scheduls screen
    updateLaunchDateAndTimeToRows(){
        var rowsToLaunch = [];
        var selectedIlcRows = JSON.parse(this.selectedilcrowsjson);
        selectedIlcRows.forEach(thisRow => {
            thisRow.startDateTime = this.asapLaunch ? null : this.launchDateValue + ' ' + this.launchTimeValue;
            rowsToLaunch.push( thisRow );
        });
        return rowsToLaunch;
    }
    /***********************Event Methods****************************/
    // When the Launch Date field changes, we update the new minimum for Time and check whether things are valid
    // we also assign the value to this.launchDateValue
    handleLaunchDateChange( event ){
        this.launchDateValue = event.detail.value;
        this.setTimeMinimumBasedOnDateChange( event.detail.value );
        this.checkLaunchDateTimeValidation();
    }
    // When Time field gets changed, we check validation and set the value
    handleLaunchTimeChange( event ){
        this.launchTimeValue = event.detail.value;
        this.checkLaunchDateTimeValidation();
    }
    // Handles what should happen when the Back or Cancel button is clicked
    handleBackCancel( event ){
        if( event.target.name == 'Cancel'){     //Closes Modal
            this.handleCloseModalEvent( event );
        }else if( this.currentWizardStateNumber == 998){        //Goes back to the previous screen from whenever they clicked View All
            this.ineligibleValuesView = this.selectedLaunchOption.ineligibleList.slice(0,this.ineligiblePreviewAmount);
            this.setCurrentWizardState( this.wizardStateVariables[998].goBackStep );
        }else{  // Goes back once in the step
            this.setCurrentWizardState( this.currentWizardStateNumber - 1 );
        }
    }
    // Closes modal
    handleCloseModalEvent( event ){
        const lwcEvent= new CustomEvent('close', {
            detail : {
                showConfirmationScreen : false
            }
        });
        this.dispatchEvent(lwcEvent);
    }
    // Handles what should happen when Next is clicked
    handleNext( event ){
        var nextStep = 0;
        var passValidation = false;     //If it doesn't pass validation, next is disabled
        if( this.currentWizardStateNumber == 0 ){
            nextStep=1;
            passValidation=true;
        }else if( this.currentWizardStateNumber == 1 ){
            if( this.selectedLaunchOption != null ){
                passValidation = true;
                this.currentWizardStateNumber = 0;
                nextStep = this.asapLaunch == true ? 1.1 : .1;
            }
        }else{
            nextStep=1;
            switch( this.currentWizardStateNumber + nextStep ){
                case 1.1:
                    if( this.validDate && this.validTime ) passValidation = true;
                    break;
                case 1.4:
                    if( this.validDate && this.validTime ) passValidation = true;
                    break;
            }
            
        }
        if( passValidation ){
            this.setCurrentWizardState( this.currentWizardStateNumber + nextStep );
        }
    }
    // Handles the selection of which Launch Type we are going to do
    handleLaunchAuctionSelection( event ){
        this.selectedLaunchOption = this.launchOptionsList.filter( launchOption => {
            return launchOption.title == event.target.name;
        })[0];
        this.launchtype = this.selectedLaunchOption.title;
        if( this.selectedLaunchOption.ineligibleList.length > 0 ){
            this.showIneligibleMessage = true;
            this.ineligibleValuesView = this.selectedLaunchOption.ineligibleList.slice(0,this.ineligiblePreviewAmount);
            let itemChoice = this.selectedLaunchOption.ineligibleList.length == 1 ? 'item' : 'items';
            this.ineligibleValuesSize = this.selectedLaunchOption.ineligibleList.length + ' ' + itemChoice;
        }else{
            this.showIneligibleMessage = false;
            this.ineligibleValuesView = [];
            this.ineligibleValuesSize = '';
        }
        this.disableNext = false;
    }
    // Handles the selection of type of Launch timeframe this will be
    handleAsapDateTimeSelection( event ){
        if( event.target.name == 'asap' ){
            this.asapLaunch = true;
            this.asapChecked = true;
            this.specificTimeChecked = false;
        }else{
            this.asapLaunch = false;
            this.asapChecked = false;
            this.specificTimeChecked = true;
        }
        this.disableNext = false;
    }
    // Handles whether the expanded preview form of Ineligible Section should be seen
    handleIneligibleSectionView( event ){
        if( this.expandIneligibleSection ){
            this.expandIneligibleSection = false;
        }else{
            this.expandIneligibleSection = true;
        }
    }
    // Handles when View all is clicked in Ineligible screen
    handleViewAllIneligible( event ){
        this.ineligibleValuesView = this.selectedLaunchOption.ineligibleList;
        this.wizardStateVariables[998].goBackStep = this.currentWizardStateNumber;
        this.setCurrentWizardState(998);
    }
}