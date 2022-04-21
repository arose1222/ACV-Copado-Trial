/* This is the LWC js controller for PrivateLaneLayout
 * @author James Andre LaCour
*/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { fireToast } from 'c/acvUtilHelper';
import apexSearch from '@salesforce/apex/PrivateLaneLayoutCont.getBrandingReferences';
import getRecord from '@salesforce/apex/PrivateLaneLayoutCont.getRecord';
import submit from '@salesforce/apex/PrivateLaneLayoutCont.submit';
// Custom Labels
import auctionDurationSubtext from '@salesforce/label/c.Auction_Duration_Static_Subtext';
import customStartPriceSubtext from '@salesforce/label/c.Custom_Start_Price_Static_Subtext';
import customStartPriceHelptext from '@salesforce/label/c.Custom_Start_Price_Static_Helptext';
import makeOfferDurationSubtext from '@salesforce/label/c.Make_Offer_Duration_Static_Subtext';
import previewDurationSubtext from '@salesforce/label/c.Preview_Duration_Static_Subtext';
import s3CdnUrl from '@salesforce/label/c.PRIVATE_LANE_LOGO_S3_CDN_URL';
import s3BucketName from '@salesforce/label/c.PRIVATE_LANE_LOGO_S3_BUCKET_NAME';
const frequencyOptions = [{label:'Recurring', value:'Recurring'},{label:'One-Time', value:'One-Time'},{label:'Perpetual',value:'Perpetual'}];
const frequencyTypeOptions = [{label:'Daily', value:'Daily'},{label:'Weekly', value:'Weekly'}/*,{label:'Bi-Weekly',value:'BiWeekly'},{label:'Monthly',value:'Monthly'}*/];
const frequencyScheduleVariables = { 
    'RecurringDaily': {showDates:false, showTimes:true, showAuctionDuration:true, showDaysOfTheWeek:false, startTimeLabel:'Start Time Each Day', endTimeLabel:'End Time Each Day'},
    'RecurringWeekly': {showDates:false, showTimes:true, showAuctionDuration:true, showDaysOfTheWeek:true, startTimeLabel:'Start Time Each Day', endTimeLabel:'End Time Each Day'},
    'RecurringBiWeekly': {showDates:true, showTimes:true, showAuctionDuration:true, showDaysOfTheWeek:true, startTimeLabel:'Start Time Each Day', endTimeLabel:'End Time Each Day'},
    'RecurringMonthly': {showDates:false, showTimes:false, showAuctionDuration:false, showDaysOfTheWeek:false, startTimeLabel:'Monthly?', endTimeLabel:'Monthly?'},
    'One-Time': {showDates:true, showTimes:true, showAuctionDuration:true, showDaysOfTheWeek:false, startTimeLabel:'Start Time on Start Date', endTimeLabel:'End Time on End Date'},
    'Perpetual': {showDates:false, showTimes:false, showAuctionDuration:true, showDaysOfTheWeek:false, startTimeLabel:'', endTimeLabel:''},
    'Recurring': {showDates:false, showTimes:false, showAuctionDuration:false, showDaysOfTheWeek:false, startTimeLabel:'', endTimeLabel:''}  
};
const timeOptions = [{label:'Minutes', value:'Minutes'},{label:'Hours', value:'Hours'},{label:'Days', value:'Days'}];
const statusOptions = [{label:'Open', value:'Open'},{label:'Closed', value:'Closed'}];
/***********************JS Code**********************************/
export default class PrivateLaneLayout extends NavigationMixin(LightningElement) {
    // Custom Labels
    label = { auctionDurationSubtext, customStartPriceSubtext, customStartPriceHelptext, makeOfferDurationSubtext, previewDurationSubtext }
    // Set from Javascript Constants
    freqOptions = frequencyOptions;
    freqTypeOptions = frequencyTypeOptions;
    timePicklistOptions = timeOptions;
    statusPicklistOptions = statusOptions;
    freqScheduleVariables = frequencyScheduleVariables; 
    // The record page provides recordId and objectApiName - These are auto populated
    @api recordId;
    @api objectApiName;
    // Spinner
    @track activeSpinner = false;
    // View state mode Variables and View Variables with custom logic
    currentFreqScheduleVariable = {};
    @track errors = { branding:[], daysOfTheWeek:'' };
    @track showSchedulingOptions = false;
    showFrequencyType = false;
    @track isReadOnly = true;
    @track isEditOnly = false;
    @track readOnlyTextFields = {};
    // packFee = '';
    // vciFeeText = '';
    // goGreenFeeText = ''; 
    // buyFeeText = '';                    // Will either be 'Default' or a currency value
    // sellFeeText = '';                   // Will either be 'Default' or a currency value
    daysOfTheWeekText = '';             // String Concat's the Days selected
    customStartPriceText = '';          // Turns the two fields (value and type) into one field of text
    customStartPriceFieldFormatter = 'currency';   //Switches from `currency` to `percent-fixed` based on type selected
    // Private Lane Values
    brandSelection = [];
    daysOfTheWeekSelected = [];
    @track thisPrivateLane = {};
    originalPrivateLane = {};
    // Dynamic Options
    @track daysOfTheWeekOptions = [
        {day:'Sun', value:'Sunday', isSelected:false, variant:'neutral'},
        {day:'Mon', value:'Monday', isSelected:false, variant:'neutral'},
        {day:'Tues', value:'Tuesday', isSelected:false, variant:'neutral'},
        {day:'Weds', value:'Wednesday', isSelected:false, variant:'neutral'},
        {day:'Thurs', value:'Thursday', isSelected:false, variant:'neutral'},
        {day:'Fri', value:'Friday', isSelected:false, variant:'neutral'},
        {day:'Sat', value:'Saturday', isSelected:false, variant:'neutral'}
    ];
    customStartPriceDisabled = false;     // on default, this is disabled
    // Static Options
    @track picklistOptions = {};
    @track paymentOptionPicklistOptions = [];
    @track customPricePicklistOptions = [];
    @track timezonePicklistOptions = [];
    @track saleFormatPicklistOptions = [];
    @track makeOfferTypePicklistOptions = [];
    @track toPicklistOptions = [];
		@track showS3Component = true;
		@api junctionObjectType;
    @api junctionObjectId;
    @api s3ReferenceType;
    @api s3Bucket = s3BucketName;
		@api uploadButtonText = 'Select Files';
		@api cdnUrl = s3CdnUrl;
		@track s3Urlpreview;
		
    @api s3FilePath = '';
    /***********************Intialization****************************/
    connectedCallback(){
        this.toggleSpinner();
        getRecord( {recordId: JSON.stringify(this.recordId)} )
            .then( result => {
                let data = JSON.parse(result);
                if( !data.hasError ){
                    this.setPicklistOption( 'paymentOptionPicklistOptions', data.paymentOptionPicklistOptionsList);
                    this.setPicklistOption( 'customPricePicklistOptions', data.customStartPricePicklistOptionsList);
                    this.setPicklistOption( 'timezonePicklistOptions', data.timezonePicklistOptionsMap);
                    this.setPicklistOption( 'saleFormatPicklistOptions', data.saleFormatPicklistOptionsList);
                    this.setPicklistOption( 'makeOfferTypePicklistOptions', data.makeOfferTypePicklistOptionsMap);
                    this.setPicklistOption( 'toPicklistOptions', data.toPicklistOptionsList);
                    this.originalPrivateLane = data.plw;
                    this.intializePage();                
                }else{
                    fireToast( data.messageTitle, data.message, "error", "sticky" );
                }
            })
            .catch( error => {
                console.log(JSON.stringify(error));
                fireToast('There was an issue loading the Private Lane', 'Please contact a Salesforce Admin to continue', "error", "sticky");
            })
            .finally( () => {
                this.toggleSpinner();
            })
        ;
        if( this.recordId == 'New' ){
            this.toggleViewStateMode();
						this.showS3Component = false;
        }
    }
    // Sets pages variables on Initialize, Save, Cancel
    intializePage(){
        Object.assign( this.thisPrivateLane, this.originalPrivateLane );
				console.log(this.thisPrivateLane);
        this.brandSelection = this.thisPrivateLane.brandReference;
				this.s3Urlpreview = this.brandSelection.length > 0 ? this.brandSelection[0].subtitle : '';
        this.setFreqAndTypeVariables( this.thisPrivateLane.frequency, this.thisPrivateLane.frequencyType );
        this.setDaysOfWeek();
        this.setReadOnlyTextField( 'auctionDuration', {auctionDuration: this.thisPrivateLane.auctionDuration, auctionDurationType:this.thisPrivateLane.auctionDurationType} );
        this.setReadOnlyTextField( 'timezone', {timezoneApiName: this.thisPrivateLane.timezone} );
        this.setReadOnlyTextField( 'makeOfferType', {makeOfferApiName: this.thisPrivateLane.makeOfferType} );
        this.updateDaysOfTheWeekText();
        this.setReadOnlyTextField( 'makeOfferDuration', {makeOfferDuration:this.thisPrivateLane.makeOfferDuration, makeOfferDurationType:this.thisPrivateLane.makeOfferDurationType} );
        this.setReadOnlyTextField( 'previewDuration', {previewDuration:this.thisPrivateLane.previewDuration, previewDurationType:this.thisPrivateLane.previewDurationType} );
        this.updateCustomStartPriceText( this.thisPrivateLane.customStartPriceValue, this.thisPrivateLane.customStartPriceType );
        this.checkCustomStartPrice( this.thisPrivateLane.customStartPriceType, this.thisPrivateLane.customStartPriceValue, true );
        this.setReadOnlyTextField( 'buyFee', {amount:this.thisPrivateLane.buyFee} );
        this.setReadOnlyTextField( 'sellFee', {amount:this.thisPrivateLane.sellFee} );
        this.setReadOnlyTextField( 'vciFee', {amount:this.thisPrivateLane.vciFee} );
        this.setReadOnlyTextField( 'goGreenFee', {amount:this.thisPrivateLane.goGreenFee} );
        this.setReadOnlyTextField( 'packFee', {amount:this.thisPrivateLane.packFee} );
    }
    /***********************Event Methods****************************/
    // Runs on Submit of form
    handleSave( event ){
        var passedValidation = this.inputValidation();
        if( passedValidation ){
            this.toggleSpinner();
            submit({plwToUpdateJson: JSON.stringify(this.thisPrivateLane)})
                .then( result =>{
                    let data = JSON.parse(result);
                    if( !data.hasError ){
                        fireToast('Success', 'This Private Lane has been Successfully Saved', "success", 'dismissable');
                        if( this.recordId == 'New' ){
                            // If newly created, Navigate to saved record page
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: data.pl.Id,
                                    objectApiName: 'Private_Lane__c',
                                    actionName: 'view'
                                }
                            });
                            this.sendCloseTab();
                        }else{
                            this.originalPrivateLane = data.plw;
														console.log(this.originalPrivateLane);
                            this.intializePage();
                            // If updating, toggle view state
                            this.toggleViewStateMode();
                        }
                    }else{
                        fireToast(data.messageTitle, data.message, "error", "sticky");
                    }
                })
                .catch( error => {
                    fireToast('There was an issue saving this Private Lane', 'Please contact a Salesforce Admin to continue', "error", "sticky");
                })
                .finally( () => {
                    this.toggleSpinner();
                })
            ;
        }
    }
    // runs on Branding Search - so anytime a couple of letters are put in
    handleBrandingLookup(event) {
        var key = event.detail.dataitem;
        apexSearch(event.detail)
            .then(results => {
								console.log(results);
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                    element.errors = [];
                    if(element.key === key){
                        element.setSearchResults(results);
                    }
                });
            })
            .catch(error => {
                // this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors.branding = [error];
            })
        ;
    }
    // Runs on Branding Selection
    handleBrandingSelectionChange(event){
        let brandingName = event.target.getSelection().length > 0 ? event.target.getSelection()[0].title : 'No Branding';
        let brandReference = event.target.getSelection().length > 0 ? event.target.getSelection() : [];
        this.updateThisPrivateLane( event.target.name, brandReference );
        this.updateThisPrivateLane( 'brandingName', brandingName );
        this.brandSelection = event.target.getSelection();
				console.log(this.brandSelection);
				console.log(brandingName);
				this.s3Urlpreview = this.brandSelection.length > 0 ? this.brandSelection[0].subtitle : '';
    }
		
		handleS3Upload(event){
				// updating brandselect after upload from s3 component
				const data = [JSON.parse(JSON.stringify(event.detail))];
				this.updateThisPrivateLane( 'brandReference', data );
        this.updateThisPrivateLane( 'brandingName', data[0].title );
        this.brandSelection = data;
				this.s3Urlpreview = data[0].subtitle;
		}
		
    // Runs on Custom Start Price Change - needs to update Custom Start Price Text for Read Only Mode
    handleCustomStartPriceChange( event ){
        this.updateThisPrivateLane( event.target.name, event.detail.value );
        this.checkCustomStartPrice( this.thisPrivateLane.customStartPriceType, event.detail.value, false );
        this.updateCustomStartPriceText( event.detail.value, this.thisPrivateLane.customStartPriceType );
    }
    // Runs on Custom Start Price Type Change - needs to update Custom Start Price Text for Read Only Mode
    handleCustomStartPriceTypeChange( event ){
        this.checkCustomStartPrice( event.detail.value, this.thisPrivateLane.customStartPriceValue, false );
        this.updateThisPrivateLane( event.target.name, event.detail.value );
        this.updateCustomStartPriceText( this.thisPrivateLane.customStartPriceValue, event.detail.value );
    }
    // Runs on the selection of Days of the Week in Edit Mode
    handleDaysOfTheWeekSelection( event ){
        let daySelected = this.daysOfTheWeekOptions.find(thisDay => {return thisDay.day == event.target.name});
        // Handles turning the selection on and off. Brand = Selected, Neutral = Unselected
        let daySelectedIndex = this.daysOfTheWeekOptions.findIndex(thisDay => {return thisDay.day == event.target.name});
        this.daysOfTheWeekOptions[daySelectedIndex].isSelected = !this.daysOfTheWeekOptions[daySelectedIndex].isSelected;
        if( this.daysOfTheWeekOptions[daySelectedIndex].variant == 'neutral' ){
            this.daysOfTheWeekOptions[daySelectedIndex].variant = 'brand';
            this.daysOfTheWeekSelected.push(daySelected.value);
        }else{
            this.daysOfTheWeekOptions[daySelectedIndex].variant = 'neutral';
            let dayIndex = this.daysOfTheWeekSelected.findIndex( thisDay => {return thisDay == daySelected.value} );
            this.daysOfTheWeekSelected.splice(dayIndex,1);
        }
        // Handles setting this field value on the thisPrivateLane object
        this.updateThisPrivateLane( 'daysOfTheWeek', this.daysOfTheWeekSelected.join(';') );
        this.updateDaysOfTheWeekText();
    }
    // Updates the thisPrivateLane with the field changed value - runs on most field changes
    handleFieldChangeUpdate( event ){
        switch( event.target.name ){
            case 'timezone':
                this.setReadOnlyTextField( 'timezone', {timezoneApiName:event.target.value})
                break;
            case 'makeOfferType':
                this.setReadOnlyTextField( 'makeOfferType', {makeOfferApiName:event.target.value})
                break;
            case 'frequency':
                this.setFreqAndTypeVariables( event.detail.value, this.thisPrivateLane.frequencyType );
                break;
            case 'frequencyType':
                this.setFreqAndTypeVariables( this.thisPrivateLane.frequency, event.detail.value );
                break;
            case 'buyFee': case 'sellFee': case 'vciFee': case 'packFee': case 'goGreenFee':
                event.detail.value = event.detail.value == '' ? null : event.detail.value;
                this.setReadOnlyTextField( event.target.name, {amount: event.detail.value});
                break;
            case 'auctionDuration':
                this.setReadOnlyTextField( 'auctionDuration', {auctionDuration: event.detail.value, auctionDurationType:this.thisPrivateLane.auctionDurationType} );
                break;
            case 'auctionDurationType':
                this.setReadOnlyTextField( 'auctionDuration', {auctionDuration: this.thisPrivateLane.auctionDuration, auctionDurationType: event.detail.value} );
                break;
            case 'makeOfferDuration':
                this.setReadOnlyTextField( 'makeOfferDuration', {makeOfferDuration: event.detail.value, makeOfferDurationType: this.thisPrivateLane.makeOfferDurationType} );
                break;
            case 'makeOfferDurationType':
                this.setReadOnlyTextField( 'makeOfferDuration', {makeOfferDuration: this.thisPrivateLane.makeOfferDuration, makeOfferDurationType:event.detail.value} );
                break;
            case 'previewDuration':
                this.setReadOnlyTextField( 'previewDuration', {previewDuration: event.detail.value, previewDurationType: this.thisPrivateLane.previewDurationType} );
                break;
            case 'previewDurationType':
                this.setReadOnlyTextField( 'previewDuration', {previewDuration: this.thisPrivateLane.previewDuration, previewDurationType:event.detail.value} );
                break;
            case 'previewStartPrice': case 'previewProxyBidding':
                event.detail.value = event.detail.checked;
                break;
        }
        this.updateThisPrivateLane( event.target.name, event.detail.value );
    }
    setReadOnlyTextField( fieldName, fieldValueObj ){
        let fieldValueProcessed = '';
        switch( fieldName ){
            case 'timezone':
                fieldValueProcessed = this.picklistOptions.timezonePicklistOptions.find(tz => tz.value === fieldValueObj.timezoneApiName)?.label;
                break;
            case 'auctionDuration':
                fieldValueProcessed = fieldValueObj.auctionDuration == null || fieldValueObj.auctionDuration === undefined ? '' : fieldValueObj.auctionDuration + ' ' + fieldValueObj.auctionDurationType;
                break;
            case 'makeOfferType':
                fieldValueProcessed = this.picklistOptions.makeOfferTypePicklistOptions.find(makeOfferType => makeOfferType.value === fieldValueObj.makeOfferApiName)?.label;
                break;
            case 'makeOfferDuration':
                fieldValueProcessed = fieldValueObj.makeOfferDuration == null || fieldValueObj.makeOfferDuration === undefined ? '' : fieldValueObj.makeOfferDuration + ' ' + fieldValueObj.makeOfferDurationType;
                break;
            case 'previewDuration':
                fieldValueProcessed = fieldValueObj.previewDuration == null || fieldValueObj.previewDuration === undefined ? '' : fieldValueObj.previewDuration + ' ' + fieldValueObj.previewDurationType;
                break;
            case 'buyFee': case 'sellFee': case 'vciFee': case 'packFee': case 'goGreenFee':
                if( fieldValueObj.amount == null || fieldValueObj.amount === undefined ){
                    fieldValueProcessed = 'Default'
                }else{
                    fieldValueProcessed = '$' +  eval(fieldValueObj.amount).toFixed(2).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
                }
        }
        this.readOnlyTextFields[fieldName] = fieldValueProcessed;
    }
    // Handles the Cancel Button. Whether it resets the form or navigates back to the Private Lane home page
    handleCancel( event ){
        if( this.recordId != 'New' ){
            // Cancel for Existing Record
            this.toggleViewStateMode();
            this.intializePage();
        }else{
            // Cancel for New Record - Navigate back to Private Lane List View
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Private_Lane__c',
                    actionName: 'home'
                }
            });
        }
    }
    /***********************Helper Methods***************************/
    // Needed when creating a new Private Lane. Closes the tab after successful creation
    sendCloseTab(){
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        // Fire the custom event
        this.dispatchEvent(closeclickedevt); 
    }
    // Updates the Days of the Week Text for Read Only Mode
    updateDaysOfTheWeekText(){
        this.daysOfTheWeekText = this.thisPrivateLane.daysOfTheWeek.replaceAll(';', ', ');
    }
    // Updates Custom Start Price Text
    updateCustomStartPriceText( customStartPriceValue, customStartPriceType ){
        if( customStartPriceValue === undefined ){
            this.customStartPriceText = '';
        }else{
            if( customStartPriceType == 'Percent' ){
                this.customStartPriceText = customStartPriceValue + '%';
            }else if( customStartPriceType == 'Dollars' && customStartPriceValue != null && customStartPriceValue !== undefined && customStartPriceValue != '' ){
                this.customStartPriceText = '$' +  eval(customStartPriceValue).toFixed(2).replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
            }else{
                this.customStartPriceText = customStartPriceType;
            }
        }
    }
    // Sets the Days of the Week buttons to the correct state
    setDaysOfWeek(){
        let alreadySelectedDays = this.thisPrivateLane.daysOfTheWeek.split(';');
        this.daysOfTheWeekSelected = alreadySelectedDays;
        for(var i=0; i<this.daysOfTheWeekOptions.length; i++ ){
            if( alreadySelectedDays.includes( this.daysOfTheWeekOptions[i].value ) ){
                this.daysOfTheWeekOptions[i].isSelected = true;
                this.daysOfTheWeekOptions[i].variant = 'brand';
            }else{
                this.daysOfTheWeekOptions[i].isSelected = false;
                this.daysOfTheWeekOptions[i].variant = 'neutral';
            }
        }
    }
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    // Changes the viewstate from Edit mode to Read Only mode and vice-versa
    toggleViewStateMode(){
        this.isReadOnly = !this.isReadOnly;
        this.isEditOnly = !this.isEditOnly;
    }
    // Updates the Conditional Variables needed in the Scheduling System
    setFreqAndTypeVariables( freqSelected, freqTypeSelected ){
        // On change, reset background values
        if( freqSelected != this.thisPrivateLane.frequency || freqTypeSelected != this.thisPrivateLane.frequencyType ){
            this.thisPrivateLane.startDate = null;
            this.thisPrivateLane.startTime = null;
            this.thisPrivateLane.auctionDuration = 4;
            this.thisPrivateLane.auctionDurationType = 'Hours';
            this.auctionDurationText = '';
            this.daysOfTheWeekSelected = [];
            if( freqSelected != this.thisPrivateLane.frequency ){
                freqTypeSelected = null;
                this.thisPrivateLane.frequencyType = null;
            }
            for( var i=0; i<this.daysOfTheWeekOptions.length; i++ ){
                this.daysOfTheWeekOptions[i].variant = 'neutral';
            }
        }
        // Whether to show the Scheduling Option Fields
        if( freqSelected == null ) freqSelected = '';
        if( freqTypeSelected == null ) freqTypeSelected = ''; 
        if( freqSelected != '' && freqSelected !== undefined && freqSelected != null ){
            if( !this.showSchedulingOptions ) this.showSchedulingOptions = true;
        }else{
            if( this.showSchedulingOptions ) this.showSchedulingOptions = false;
        }
        // Whether to Show Recurring Options
        if( freqSelected == 'Recurring' ){
            if( !this.showFrequencyType ) this.showFrequencyType = true;
        }else{
            if( this.showFrequencyType ) this.showFrequencyType = false;
            if( this.thisPrivateLane != '' ) this.thisPrivateLane.frequencyType = '';
        }
        this.currentFreqScheduleVariable = this.freqScheduleVariables[ ''+ freqSelected + freqTypeSelected ];
    }
    // Updates the Private Lane field with the value
    updateThisPrivateLane( field, value ){
        this.thisPrivateLane[field] = value;
    }
    // Handles Validation and Conditional Disabling for Custom Start Price
    checkCustomStartPrice( customStartPriceType, customStartPriceValue, isInitProcess ){
        var inputCmp = this.template.querySelector('[data-name="customStartPriceValue"]');
        let validMsg = '';
        switch(customStartPriceType){
            case 'Default':
                this.thisPrivateLane.customStartPriceValue = null;
                this.customStartPriceDisabled = true;
                validMsg = '';
                break;
            case 'Percent':
                this.customStartPriceDisabled = false;
                if( customStartPriceValue > 100 ){
                    validMsg = 'There can only be a max value of 100%';
                }else{
                    validMsg = '';
                }
                this.customStartPriceFieldFormatter = 'percent-fixed';
                break;
            case 'Dollars':
                this.customStartPriceDisabled = false;
                this.customStartPriceFieldFormatter = 'currency';
                validMsg = '';
                break;
        }
        if( !isInitProcess ){
            inputCmp.setCustomValidity(validMsg);
            inputCmp.reportValidity();
        }
    }
    /***********************Page Validation**************************/
    // On Save, does validation
    inputValidation(){
        var passedValidation = true;
        var inputCmp;   //Will be used for all of them
        // Name - Required for All
        inputCmp = this.template.querySelector('[data-name="nameOfLane"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Name is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Brand Reference - Not Required but if brandSelection 
        // if( this.thisPrivateLane.brandReference.length == 0 ){
        //     this.errors.branding = ['A brand logo is required'];
        //     passedValidation = false;
        // }else{
        //     this.errors.branding = [];
        // }
        // Status - Required for All
        inputCmp = this.template.querySelector('[data-name="status"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Status is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Frequency - Required for All
        inputCmp = this.template.querySelector('[data-name="frequency"]');
        if( inputCmp != null ){
            if( inputCmp == null || inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Frequency is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Frequency Type - Required for Frequency = Recurring
        if( this.thisPrivateLane.frequency == 'Recurring' ){
            inputCmp = this.template.querySelector('[data-name="frequencyType"]');
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Frequency Type is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Days of the Week - Required for Weekly and Biweekly
        if( this.thisPrivateLane.frequencyType == 'Weekly' ){
            if( this.daysOfTheWeekSelected.length == 0 ){
                this.errors.daysOfTheWeek = 'A day must be selected';
                passedValidation = false;
            }
            else{
                this.errors.daysOfTheWeek = '';
            }
        }
        // Start Date - Required by One-time
        inputCmp = this.template.querySelector('[data-name="startDate"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Start Date is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            inputCmp.reportValidity();
        }
        // Start Time - Required by All Recurring and One Time
        if( this.thisPrivateLane.frequency == 'Recurring' || this.thisPrivateLane.frequency == 'One-Time' ){
            inputCmp = this.template.querySelector('[data-name="startTime"]');
            if( inputCmp != null ){ // If =='s null, this could be because a Recurring Type hasn't been picked yet so this isn't rendered on the page yet
                if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Start Time is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        // Timezone - Required if Start Time is populated
        if( this.thisPrivateLane.startTime != '' && this.thisPrivateLane.startTime != null && this.thisPrivateLane.startTime !== undefined ){
            inputCmp = this.template.querySelector('[data-name="timezone"]');
            if( inputCmp != null ){
                if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Timezone is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        // Auction Duration - Required by All
        inputCmp = this.template.querySelector('[data-name="auctionDuration"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Auction duration is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Auction Duration Type - Required if Auction Duration is populated
        if( this.thisPrivateLane.auctionDuration != '' && this.thisPrivateLane.auctionDuration != null && this.thisPrivateLane.auctionDuration !== undefined ){
            inputCmp = this.template.querySelector('[data-name="auctionDurationType"]');
            if( inputCmp != null ){
                if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Auction Duration Type is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        // Buy Fee - Technically Required but can be blank as that would be Default
        // inputCmp = this.template.querySelector('[data-name="buyFee"]');
        // if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
        //     inputCmp.setCustomValidity('Buy Fee is required');
        //     passedValidation = false;
        // }else{
        //     inputCmp.setCustomValidity('');
        // }
        // inputCmp.reportValidity();
        // Sell Fee - Technically Required but can be blank as that would be Default
        // inputCmp = this.template.querySelector('[data-name="sellFee"]');
        // if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
        //     inputCmp.setCustomValidity('Sell Fee is required');
        //     passedValidation = false;
        // }else{
        //     inputCmp.setCustomValidity('');
        // }
        // inputCmp.reportValidity();
        // Make Offer Duration - Required By All
        inputCmp = this.template.querySelector('[data-name="makeOfferDuration"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Make Offer Duration is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Make Offer Duration Type - Required if Make Offer Duration is populated
        if( this.thisPrivateLane.makeOfferDurationType != '' && this.thisPrivateLane.makeOfferDurationType != null && this.thisPrivateLane.makeOfferDurationType !== undefined ){
            inputCmp = this.template.querySelector('[data-name="makeOfferDurationType"]');
            if( inputCmp != null ){
                if( inputCmp == null || inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Make Offer Duration Type is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        inputCmp = this.template.querySelector('[data-name="previewDuration"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Preview Duration is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Make Offer Duration Type - Required if Make Offer Duration is populated
        if( this.thisPrivateLane.previewDurationType != '' && this.thisPrivateLane.previewDurationType != null && this.thisPrivateLane.previewDurationType !== undefined ){
            inputCmp = this.template.querySelector('[data-name="previewDurationType"]');
            if( inputCmp != null ){
                if( inputCmp == null || inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Preview Duration Type is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        // Payment Options - Required for All
        inputCmp = this.template.querySelector('[data-name="paymentOption"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Payment Option is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Custom Start Price Type - Required if Custom Start Price is populated
        if( this.thisPrivateLane.customStartPriceType != '' && this.thisPrivateLane.customStartPriceType != null && this.thisPrivateLane.customStartPriceType !== undefined ){
            inputCmp = this.template.querySelector('[data-name="customStartPriceType"]');
            if( inputCmp != null ){
                if( inputCmp == null || inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                    inputCmp.setCustomValidity('Custom Start Price Type is required');
                    passedValidation = false;
                }else{
                    inputCmp.setCustomValidity('');
                }
                if( !inputCmp.checkValidity() ){
                    passedValidation = false;
                }
                inputCmp.reportValidity();
            }
        }
        // Custom Start Price - Required By All but can be null if type is Default
        inputCmp = this.template.querySelector('[data-name="customStartPriceValue"]');
        if( inputCmp != null ){
            if( (inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined) && this.thisPrivateLane.customStartPriceType != 'Default' ){
                inputCmp.setCustomValidity('Custom Start Price is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Sale Format Options - Required for All
        inputCmp = this.template.querySelector('[data-name="saleFormat"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Sale Format is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        // Title Options - Required for All
        inputCmp = this.template.querySelector('[data-name="titleOption"]');
        if( inputCmp != null ){
            if( inputCmp.value == '' || inputCmp.value == null || inputCmp.value === undefined ){
                inputCmp.setCustomValidity('Title is required');
                passedValidation = false;
            }else{
                inputCmp.setCustomValidity('');
            }
            if( !inputCmp.checkValidity() ){
                passedValidation = false;
            }
            inputCmp.reportValidity();
        }
        return passedValidation;
    }
    // Sets the Picklist option 
    setPicklistOption( name , optionsMap ){
        let optionsList = [];
        Object.entries(optionsMap).forEach( function( value ){
            optionsList.push( { label:value[1], value:value[0] } );
        });
        this.picklistOptions[name] = optionsList;
    }
}