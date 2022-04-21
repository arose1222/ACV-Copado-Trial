/**
 * @description Main component for the recurring appointment module
 * @name tracRecurringEvent
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-22
 */

import {LightningElement,track,wire,api} from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/tracPubSub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireToast } from 'c/acvUtilHelper';
/*
import FIELD_TIMELINE_ACCOUNT from '@salesforce/schema/Timeline__c.Account__c';
import FIELD_TIMELINE_ENDDATE from '@salesforce/schema/Timeline__c.End_Date__c';
import FIELD_TIMELINE_ACTIVE from '@salesforce/schema/Timeline__c.Is_Active__c';
// import FIELD_TIMELINE_TERRITORY from '@salesforce/schema/Timeline__c.Service_Territory__c';
import FIELD_TIMELINE_RESOURCE from '@salesforce/schema/Timeline__c.Service_Resource__c';
import FIELD_TIMELINE_RESOURCENAME from '@salesforce/schema/Timeline__c.Service_Resource_Name__c';
// import FIELD_TIMELINE_TERRITORYNAME from '@salesforce/schema/Timeline__c.Service_Territory_Name__c';
import FIELD_TIMELINE_AVERAGECARS from '@salesforce/schema/Timeline__c.Average_Number_Cars__c';
import FIELD_TIMELINE_STARTDATE from '@salesforce/schema/Timeline__c.Start_Date__c';
import FIELD_TIMELINE_NAME from '@salesforce/schema/Timeline__c.Name';
import FIELD_TIMELINE_USER from '@salesforce/schema/Timeline__c.User__c';
*/

import userId from '@salesforce/user/Id';
import getOccurrences from '@salesforce/apex/tracRecurringEventController.getOccurrences';
import getAccountAddress from '@salesforce/apex/tracRecurringEventController.getAccountAddress';
import getTrue360 from '@salesforce/apex/HaltTrue360Appointments.getTrue360Id';
import deleteTimeline from '@salesforce/apex/tracRecurringEventController.deleteTimeline';
import getOperatingHours from '@salesforce/apex/tracRecurringEventController.getOperatingHours';
import getUpdatedOperatingHours from '@salesforce/apex/tracRecurringEventController.getUpdatedOperatingHours';
import createRevolvingInspectionRequest from '@salesforce/apex/InspectionRequest.createRevolvingInspectionRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/*
import FIELD_ACCOUNT_CITY from '@salesforce/schema/Account.BillingCity';
import FIELD_ACCOUNT_STATE from '@salesforce/schema/Account.BillingState';
import FIELD_ACCOUNT_ZIP from '@salesforce/schema/Account.BillingPostalCode';
import FIELD_ACCOUNT_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import FIELD_ACCOUNT_STREET from '@salesforce/schema/Account.BillingStreet';
import BillingCity from '@salesforce/schema/Account.BillingCity';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
*/

/*const FIELDS = [
    FIELD_TIMELINE_ACCOUNT,
    FIELD_TIMELINE_ENDDATE,
    FIELD_TIMELINE_ACTIVE,
    FIELD_TIMELINE_RESOURCE,
    FIELD_TIMELINE_RESOURCENAME,
    FIELD_TIMELINE_AVERAGECARS,
    FIELD_TIMELINE_STARTDATE,
    FIELD_TIMELINE_NAME,
    FIELD_TIMELINE_USER,
];

const ACCOUNT_FIELDS = [
    FIELD_ACCOUNT_CITY,
    FIELD_ACCOUNT_STATE,
    FIELD_ACCOUNT_ZIP,
    FIELD_ACCOUNT_COUNTRY,
    FIELD_ACCOUNT_STREET,
];*/

export default class RecurringEvent extends NavigationMixin(LightningElement) {
@wire(CurrentPageReference) pageRef;  // for pubsub events

@api recordId; // record id of the parent container (can be timeline or account record)
    timelineId;    // id of the timeline record
    accountId;     // id of the account record
    isEditMode;    // if page is quick action (create new) or timeline edit override (update existing)
    today;         // today's date properly formatted
    true360Id;

@track timeline = {};   // object to track timeline sobject
@track account = {};

@track occurrenceIds = [];  // list of child occurrence record ids
@track acctStartTime;
@track acctEndTime;

@api accountBillingStreet;
@api accountBillingCity;
@api accountBillingCountry;
@api accountBillingState;
@api accountBillingPostalCode;
@api accountHaltTrue360Appointments;

    /**
     * @description on component load
     */
    connectedCallback() {
        this.isEditMode = false;
        this.accountId = this.recordId;
        this.timeline.Is_Active__c = true; // new record, default to active for creation

        if(this.accountBillingStreet == null && this.accountBillingCity == null && this.accountBillingCountry == null && this.accountBillingState == null && this.accountBillingPostalCode == null) {
            //query for account fields
            getAccountAddress({recordId: this.recordId}).then(
                result => {
                    if(result) {
                        this.account.BillingStreet = result.BillingStreet;
                        this.account.BillingCity = result.BillingCity;
                        this.account.BillingCountry = result.BillingCountry;
                        this.account.BillingState = result.BillingState;
                        this.account.BillingPostalCode = result.BillingPostalCode;
                        this.account.Halt_True360_Appointments__c = result.Halt_True360_Appointments__c;
                    } else if(result.error) {
                        alert('error loading fields for account.');
                    }
                }
            )
            
        }
        else {
            this.account.BillingStreet = this.accountBillingStreet;
            this.account.BillingCity = this.accountBillingCity;
            this.account.BillingCountry = this.accountBillingCountry;
            this.account.BillingState = this.accountBillingState;
            this.account.BillingPostalCode = this.accountBillingPostalCode;
            this.account.Halt_True360_Appointments__c = this.accountHaltTrue360Appointments;
        }
        
        this.timeline.City__c = this.account.BillingCity;
        this.timeline.State__c = this.account.BillingState;
        this.timeline.Postal_Code__c = this.account.BillingPostalCode;
        this.timeline.Country__c = this.account.BillingCountry;
        this.timeline.Street__c = this.account.BillingStreet;

        getOperatingHours({acctId: this.accountId}).then(
            result => {
                var returnVar = JSON.parse( result );
                this.acctStartTime = returnVar.startingHour;
                this.acctEndTime = returnVar.closingHour;
            }
        );

        // get child occurrence ids
        getOccurrences({recordId: this.recordId}).then(result => {
            result.forEach(occ => {
                this.occurrenceIds.push(occ.Id);
             });
            !this.occurrenceIds.length && this.occurrenceIds.push(''); // add new record on create
        });

        let today = new Date();
        let dd = today.getDate(),
            mm = today.getMonth()+1,
            yyyy = today.getFullYear();

        this.today = yyyy + '-' + (mm < 10?'0'+mm:mm) + '-' + (dd < 10?'0'+dd:dd);
        this.timeline.Start_Date__c = this.today;
    }

    @wire(getTrue360, { })
    handleTrue360Result(result) {
        if(result.data) {
            this.true360Id = result.data;
        } else if(result.error) {
            alert('error loading True 360 Id');
        }
    };

/*
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredRecord(result) {
        if(result.data) {
            this.account['Id'] = this.recordId;
            for(let prop in result.data.fields) {
                this.account[prop] = result.data.fields[prop].value;
            }
        } else if(result.error) {
            alert('error loading fields for account.');
        }

        this.timeline.City__c = this.account.BillingCity;
        this.timeline.State__c = this.account.BillingState;
        this.timeline.Postal_Code__c = this.account.BillingPostalCode;
        this.timeline.Country__c = this.account.BillingCountry;
        this.timeline.Street__c = this.account.BillingStreet;
    };

    
    // retrieve timeline record if timeline id exists
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredTimeline(result) {
        if(result.data) {
            this.timeline['Id'] = this.timelineId;
            for(let prop in result.data.fields) {
                this.timeline[prop] = result.data.fields[prop].value;
            }
            if(this.timeline.Average_Number_Cars__c) {
                this.setCars(this.timeline.Average_Number_Cars__c);
            }
        } else if(result.error) {
            alert('Aw snap! There was an unexpected error loading this record! Please try again and report it to your admin if it persists.');
            console.log('error',result.error);
        }
    };
*/

    // /**
    //  * @description handle when the territory lookup is changed
    //  * @param e
    //  */
    // handleTerritoryChange(e) {
    //     if(e.detail)
    //         this.timeline.Service_Territory__c = e.detail.id;
    //     else
    //         this.timeline.Service_Territory__c = undefined;
    // }


    /**
     * @description handle when the resource lookup is changed
     * @param e
     */
    handleResourceChange(e) {
        if(e.detail)
            this.timeline.Service_Resource__c = e.detail.id;
        else
            this.timeline.Service_Resource__c = undefined;
    }

    handleAddress(event){
        this.timeline.City__c = event.detail.city;
        this.timeline.State__c = event.detail.province;
        this.timeline.Postal_Code__c = event.detail.postalCode;
        this.timeline.Country__c = event.detail.country;
        this.timeline.Street__c = event.detail.street;
    }

    /**
     *
     * @returns {{label: string, value: string, selected: boolean}[]}
     */
    get optionsCars() {
        let cars = [{label: '-- Select the average number of cars --', value:'', selected: false}];
        for (let i = 1; i < 16; i++) {
            cars.push({label: i, value:i, selected: this.timeline.Average_Number_Cars__c === i});
        }
        return cars;
    }

    /**
     * @description handles the picklist value changed
     * @param e
     */
    handleCarsSelect(e) {
        console.log('event captured');
        this.setCars(e.detail.value);
    }

    setCars(value) {
        this.timeline.Average_Number_Cars__c = value;
    }


    /**
     * @description when the start date is selected, only allow future dates to be entered
     * @param e
     */
    handleStartDateChange(e) {
        let date = this.template.querySelector('.startDate').value;
        if(date != '' && date >= this.today) {
            this.timeline.Start_Date__c = date;
        } else {
            this.template.querySelector('.startDate').value = this.timeline.Start_Date__c;
            alert('Start date must be a date in the future');
        }
    }


    /**
     * @description when the end date is selected, disallow past dates from being entered
     * @param e
     */
    handleEndDateChange(e) {
        let date = this.template.querySelector('.endDate').value;
        if(date === '' || date >= this.today) {
            this.timeline.End_Date__c = date;
        } else {
            this.template.querySelector('.endDate').value = this.timeline.End_Date__c;
            alert('End date must be a date in the future');
        }
    }


    /**
     * @description add new related occurrence (empty string since id doesn't exist yet)
     */
    handleRepeatClick() {
        this.occurrenceIds.push('');
    }


    /**
     * @description saves the timeline record when the save button is clicked
     */
    handleSaveClick() {
        if(this.true360Id == this.timeline.Work_Type__c && this.account.Halt_True360_Appointments__c) {
            fireToast('True 360', 'This dealership is not approved for any True 360 inspections at this time. Please direct the dealer to call (716) 954-9515 or email ar@true360.com with questions.', 'error', 'sticky');
        }
        else {
            createRevolvingInspectionRequest({ accountId : this.accountId, numberOfVehicles : this.timeline.Average_Number_Cars__c, workTypeId : this.timeline.Work_Type__c }).then(result => {
                if(!this.isEditMode) {
                    this.timeline.Account__c = this.accountId;
                    this.timeline.User__c = userId;
                }
    
                this.timeline.Inspection_Request__c = result;
    
                this.template.querySelector('lightning-record-edit-form').submit(this.timeline);
            }).catch(error =>{
                const toastEvent = new ShowToastEvent({
                    title: 'Error - If the issue is unclear, Please open an R&I with the following details:',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky',
                });
                this.dispatchEvent(toastEvent);
                this.closeModal();
            })
        }
    }


    /**
     * @description update existing record with Is_Active__c to false (batch deletes record)
     */
    deactivate() {
        if (confirm('Are you sure you want to delete this revolving appointment?') === true) {
            if(this.isEditMode) {
                deleteTimeline({recordId: this.timelineId});
                // this.template.querySelector('lightning-record-edit-form').submit({Id:this.timelineId,Is_Active__c:false});
            }
            this.closeModal();
        }
    }


    /**
     * @description save child occurrence records once timeline is inserted
     * @param e timeline (id)
     */
    handleFormSuccess(e) {
        //console.log('e'+ JSON.stringify(e.detail));
        let proceedWithRecordSave = true;
        this.template
            .querySelectorAll("c-lookup-field")
            .forEach(element => {
           if(!element.checkValidity()){
               proceedWithRecordSave = false;
           }
        });
        console.log('proceedWithRecordSave'+proceedWithRecordSave);
        if(proceedWithRecordSave) {
             fireEvent(this.pageRef,'timelinesave',{detail: {timelineId: e.detail.id}});
              const toastEvent = new ShowToastEvent({
                  title: 'Success',
                  message: 'Your revolving appointment was created successfully',
                  variant: 'success',
              });
              this.dispatchEvent(toastEvent);
              this.closeModal();
        }
    }


    /**
     * @description alert error message to user on save error (shoudln't get here)
     * @param e error
     */
    handleFormError(e) {
        console.log('handleFormError',e.detail);
        //alert('Aw Snap! There was an unexpected error. Try reloading the page and try again.');
    }


    /**
     * @description handle the click of the cancel button
     */
    handleCancelClick() {
        this.closeModal();
    }


    /**
     * @description exit the timeline editor based on component contextt
     */
    closeModal(){
        //this.accountId means we are on an account page quick action
        //this.isEditMode
        if(this.accountId) {
            this.dispatchEvent(new CustomEvent('close'));
        } else {
            window.history.go(-1);
        }
    }

    handleLookupChange( evt ){
        let recordId = evt.detail.recordId;
        let fieldName = evt.detail.fieldName;
        
        this.timeline.Work_Type__c = recordId;
        if(this.true360Id == this.timeline.Work_Type__c && this.account.Halt_True360_Appointments__c) {
            fireToast('True 360', 'This dealership is not approved for any True 360 inspections at this time. Please direct the dealer to call (716) 954-9515 or email ar@true360.com with questions.', 'error', 'sticky');
        }
        //TODO: Perform related action
    }

    handleServiceResourceLookUpChange( evt ){
        let recordId = evt.detail.recordId;
        let fieldName = evt.detail.fieldName;
        this.timeline.Service_Resource__c = recordId;
        console.log('target Record Id'+ recordId);
        //TODO: Perform related action -- Old Traction Remark?

        let optHourRange = {
            startingHour: this.acctStartTime,
            closingHour: this.acctEndTime
        };

        getUpdatedOperatingHours({ optHourRange: JSON.stringify(optHourRange), serviceResourceId: recordId, providedAcctId: this.accountId}).then(
            result => {
                var returnVar = JSON.parse( result );
                this.acctStartTime = returnVar.startingHour;
                this.acctEndTime = returnVar.closingHour;
            }
        );
    }
}