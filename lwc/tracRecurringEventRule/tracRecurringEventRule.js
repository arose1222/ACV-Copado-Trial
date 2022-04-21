/**
 * @description A single rule (or rule collection) that governs the repetition
 * @name tracRecurringEventRule
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-22
 */

import { LightningElement, track, api, wire } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/tracPubSub';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import FIELD_DAY from '@salesforce/schema/Occurrence__c.Day__c';
import FIELD_END_TIME from '@salesforce/schema/Occurrence__c.End_Time__c';
import FIELD_EVERY from '@salesforce/schema/Occurrence__c.Every__c';
import FIELD_FREQUENCY from '@salesforce/schema/Occurrence__c.Frequency__c';
import FIELD_NAME from '@salesforce/schema/Occurrence__c.Name';
import FIELD_START_TIME from '@salesforce/schema/Occurrence__c.Start_Time__c';
import FIELD_WEEK_NUMBER from '@salesforce/schema/Occurrence__c.Week_Number__c';
import FIELD_IS_ACTIVE from '@salesforce/schema/Occurrence__c.Is_Active__c';

const FIELDS = [
    FIELD_DAY,
    FIELD_END_TIME,
    FIELD_EVERY,
    FIELD_FREQUENCY,
    FIELD_NAME,
    FIELD_START_TIME,
    FIELD_WEEK_NUMBER,
    FIELD_IS_ACTIVE,
];

const TIME_EARLIEST = '06:00:00.000Z';
const TIME_LATEST = '21:00:00.000Z';


export default class RecurringEventRule extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @api recordId;  // occurrence id
    @api parentId;  // timeline id
    @api acctStartTime; // timeline's Account's Operating Hours, latest start time
    @api acctEndTime; // timeline's Account's Operating Hours, earliest end time

    // save chosen day in array
    @track days = [
        { label: 'Sunday',    selected: false },
        { label: 'Monday',    selected: true  },
        { label: 'Tuesday',   selected: false },
        { label: 'Wednesday', selected: false },
        { label: 'Thursday',  selected: false },
        { label: 'Friday',    selected: false },
        { label: 'Saturday',  selected: false },
    ];

    // save chosen description (Week_Number__c) in array
    @track descriptions = [
        { label: 'first',  value: 'first',  selected: true  },
        { label: 'second', value: 'second', selected: false },
        { label: 'third',  value: 'third',  selected: false },
        { label: 'fourth', value: 'fourth', selected: false },
        { label: 'fifth',  value: 'fifth',  selected: false },
        { label: 'last',   value: 'last',   selected: false },
    ];

    // save day in an array (monthly option)
    @track allDayOptions = [
        { label: 'Sunday',      value: 'Sunday',      selected: false },
        { label: 'Monday',      value: 'Monday',      selected: false },
        { label: 'Tuesday',     value: 'Tuesday',     selected: false },
        { label: 'Wednesday',   value: 'Wednesday',   selected: false },
        { label: 'Thursday',    value: 'Thursday',    selected: false },
        { label: 'Friday',      value: 'Friday',      selected: false },
        { label: 'Saturday',    value: 'Saturday',    selected: false },
        { label: 'day',         value: 'day',         selected: false },
        { label: 'weekday',     value: 'weekday',     selected: true  },
        { label: 'weekend day', value: 'weekend day', selected: false },
        ];

    // save day in an array (monthly calendar view)
    @track dates = [
        { label: '1',  selected: true  },
        { label: '2',  selected: false },
        { label: '3',  selected: false },
        { label: '4',  selected: false },
        { label: '5',  selected: false },
        { label: '6',  selected: false },
        { label: '7',  selected: false },
        { label: '8',  selected: false },
        { label: '9',  selected: false },
        { label: '10', selected: false },
        { label: '11', selected: false },
        { label: '12', selected: false },
        { label: '13', selected: false },
        { label: '14', selected: false },
        { label: '15', selected: false },
        { label: '16', selected: false },
        { label: '17', selected: false },
        { label: '18', selected: false },
        { label: '19', selected: false },
        { label: '20', selected: false },
        { label: '21', selected: false },
        { label: '22', selected: false },
        { label: '23', selected: false },
        { label: '24', selected: false },
        { label: '25', selected: false },
        { label: '26', selected: false },
        { label: '27', selected: false },
        { label: '28', selected: false },
        { label: '29', selected: false },
        { label: '30', selected: false },
        { label: '31', selected: false },
    ];

    // save frequencies in an array
    @track frequencyOptions = [
        { label: 'Daily',   value: 'daily',   selected: true  },
        { label: 'Weekly',  value: 'weekly',  selected: false },
        { label: 'Monthly', value: 'monthly', selected: false },
    ];

    @track every;  // save value of the "every" input
    @track isDaily = false;  // flag for if frequency is daily
    @track isWeekly = false;  // flag for if frequency is weekly
    @track isMonthly = false;  // flag for if frequency is monthly
    @track isCalendar = false;  // flag for month option toggle
    @track monthlyDayOptions;  // save the selected day description (for monthly)
    @track monthlyWeekNumber;  // save the selected week number (for monthly)

    // set default values if its creating a new record
    @track occurrence = {
        Timeline__c: this.parentId,
        Frequency__c: 'Daily',
        Day__c: 'Monday',
        Is_Active__c: true,
        Every__c: '1',
    };

    @track timeOption = false;  // flag for specifying time
    @track startTime = TIME_EARLIEST;  // save value of the selected start time
    @track endTime = TIME_LATEST;  // save value of the selected end time


    /**
     * @description method on component load
     */
    connectedCallback() {
        console.log('registering listener: ' + this.saveOccurrence + ' on ' + this);
        registerListener('timelinesave',this.saveOccurrence,this);
        this.buildOccurrence();
    }

    disconnectedCallback(){
        unregisterAllListeners();
    }


    //
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOccurrence(result) {
        if(result.data) {
            this.occurrence['Id'] = this.recordId;
            for (let prop in result.data.fields) {
                this.occurrence[prop] = result.data.fields[prop].value;
            }
            this.buildArrays();
            this.buildOccurrence();
        } else if(result.error) {
            alert('There was an error retrieving the occurrences, please refresh the page and try again.')
            console.log(result.error);
        }
    };

    buildArrays() {
        // build frequency array
        this.frequencyOptions.forEach(opt => {
            opt.selected = opt.label === this.occurrence.Frequency__c;
        });

        // build weekly days array
        if(this.occurrence.Frequency__c === "Weekly") {
            this.days.forEach(opt => {
                opt.selected = this.occurrence.Day__c.includes(opt.label);
            });
        }

        // build month arrays
        if(this.occurrence.Frequency__c === "Wonthly") {
            // build day and description array
            if(isNaN(this.occurrence.Day__c[0])) {
                this.allDayOptions.forEach(opt => {
                    opt.selected = this.occurrence.Day__c.includes(opt.label);
                });
                this.isCalendar = false;
                this.descriptions.forEach(opt => {
                    opt.selected = this.occurrence.Week_Number__c.includes(opt.label);
                });
            } else {  // build dates array
                this.isCalendar = true;
                this.dates.forEach(opt => {
                    opt.selected = (this.occurrence.Day__c===opt.label
                        || this.occurrence.Day__c.startsWith(opt.label + ';')
                        || this.occurrence.Day__c.endsWith(';'+opt.label)
                        || this.occurrence.Day__c.includes(';'+opt.label+';'));
                });
            }
        }

        if(this.occurrence.Start_Time__c) {
            this.timeOption = true;
            this.startTime = this.occurrence.Start_Time__c;
            this.endTime = this.occurrence.End_Time__c;
        }
    }


    get isActive() {
        return this.occurrence.Is_Active__c;
    }



    buildOccurrence() {
        this.isDaily   = this.occurrence.Frequency__c.toLowerCase() === "daily";
        this.isWeekly  = this.occurrence.Frequency__c.toLowerCase() === "weekly";
        this.isMonthly = this.occurrence.Frequency__c.toLowerCase() === "monthly";

        this.setEvery(this.occurrence.Every__c);
        this.setFrequency(this.occurrence.Frequency__c);

        this.isDaily   && this.buildDaily();
        this.isWeekly  && this.buildWeekly();
        this.isMonthly && this.buildMonthly();

        this.initiateMessage();
    }


    buildDaily() {
        this.resetFields();  // reset fields
        this.setEvery(this.occurrence.Every__c);
    }


    buildWeekly() {
        this.resetFields();  // reset fields
        this.occurrence.Day__c = this.arrayToCommaSeparated(this.days);  // set Day__c field based on days array
    }

    arrayToCommaSeparated(array) {
        let selectedDays = [];
        array.forEach(opt => {
            if(opt.selected) selectedDays.push(opt.label);
        });
        return selectedDays.join(';');
    }


    buildMonthly() {
        console.log('isCalendar',this.isCalendar);
        this.resetFields();

        // this.isCalendar !== undefined
        // && this.occurrence.Day__c !== undefined
        // && (this.isCalendar = !isNaN(this.occurrence.Day__c[0]));


        !this.isCalendar && (this.occurrence.Week_Number__c = this.findSelected(this.descriptions).label,
            this.occurrence.Day__c = this.findSelected(this.allDayOptions).label);

        this.monthlyDayOptions = this.occurrence.Day__c;
        this.monthlyWeekNumber = this.occurrence.Week_Number__c;

        this.isCalendar && (this.occurrence.Day__c = this.loadDaysFromArray(this.dates));
        console.log('DANIEL array:' + this.dates)
    }

    resetFields() {
        this.occurrence.Day__c = null;
        this.occurrence.Week_Number__c = null;
    }



    get optionsFrequency() {
        return this.frequencyOptions;
    }


    handleFrequencyChange(e) {
        this.occurrence.Frequency__c = e.detail.value;
        this.setFrequency(this.occurrence.Frequency__c);
        this.buildOccurrence();
        this.initiateMessage();
    }


    /**
     * @description sets the frequency and related boolean variables
     * @param value frequency
     */
    setFrequency(value) {
        this.frequencyOptions.forEach(opt => {
            opt.selected = opt.value.toString().toLowerCase() === value.toString().toLowerCase();
        });
    }


    /**
     * @description creates an array of select options from 1 to 99
     * @returns {Array}
     */
    get optionsEvery() {
        let every = [];
        for (let i = 1; i < 100; i++) {
            every.push({label: i, value:i, selected: this.every === i});
        }
        return every;
    }



    handleEverySelect(e) {
        this.setEvery(e.detail.value);
        this.initiateMessage();
    }



    setEvery(value) {
        this.every = value;
        this.occurrence.Every__c = value;
    }


    handleDayClick(e) {
        let index = this.jsonIndex(this.days,'label',e.detail.id);
        this.days[index].selected = !this.days[index].selected;

        this.addRemoveDay(this.days[index].label,this.days);
        this.initiateMessage();
    }


    loadDaysFromArray(inArray) {
        let dayValues = this.occurrence.Day__c.split(';');
        inArray.forEach(opt => {
            opt.selected = false;
            dayValues.forEach(day => {
                if(opt.label.toLowerCase() === day.toLowerCase()) {
                    opt.selected = true;
                }
            });
        });

        return inArray;
    }


    setDaysFromField(scsv, array) {
        let dayValues = scsv.split(';');
        for(let i in dayValues) {
            array.forEach(opt => {
                if(opt.label.toLowerCase() === dayValues[i].toLowerCase()) {
                    opt.selected = true;
                }
            });
        }
        this.occurrence.Day__c = dayValues[0] !== '' ? dayValues.join(';') : [];
    }


    /**
     * @description add or remove value from string that of semi-colon separated values
     * @param array
     * @param value string of semi-colon separated values
     */
    addRemoveDay(value,array) {
        let contains = false;
        let dayValues;

        if(this.occurrence.Day__c !== undefined) {
            dayValues = this.occurrence.Day__c.length > 0 ? this.occurrence.Day__c.split(';') : [];
            for (let i in dayValues) {
                if (dayValues[i] === value) {
                    if(dayValues.length > 1) {
                        dayValues.splice(i, 1);
                    }
                    contains = true;
                }
            }
        }

        if(!contains && value) dayValues.push(value);
        this.setDaysFromField(dayValues.join(';'),array);
    }




    get getMonthOccurOptions(){
        return this.descriptions;
    }

    handleOccurSelect(e) {
        this.monthlyWeekNumber = e.detail.value;
        this.occurrence.Week_Number__c = e.detail.value;
        this.selectInArray(this.descriptions,e.detail.value);
        this.initiateMessage();
    }


    get getMonthlyDayOptions(){
        return this.allDayOptions;
    }

    handleDayOptSelect(e) {
        this.monthlyDayOptions = e.detail.value;
        this.occurrence.Day__c = e.detail.value;
        this.selectInArray(this.allDayOptions,e.detail.value);
        this.initiateMessage();
    }


    selectInArray(array,value) {
        array.forEach(opt => {
            opt.selected = false, opt.value === value && (opt.selected = true);
        });
    }





    handleMonthOptionClick(e) {
        this.isCalendar = e.detail.selected;
        if(this.isCalendar) {  // each date "1, 2, and 3"
            this.occurrence.Week_Number__c = null;
            this.occurrence.Day__c = this.arrayToCommaSeparated(this.dates)
        } else {  // on the "first monday"
            this.occurrence.Week_Number__c = this.findSelected(this.descriptions).label;
            this.occurrence.Day__c = this.findSelected(this.allDayOptions).label;
        }
        this.initiateMessage();
    }


    /**
     * @description handle the click of the month option toggle
     * @param e
     */
    handleDateClick(e) {
        let index = this.jsonIndex(this.dates,'label',e.detail.id);
        this.dates[index].selected = !this.dates[index].selected;

        this.addRemoveDay(this.dates[index].label,this.dates);
        this.initiateMessage();
    }


    /**
     * @description handle the click of the start time option
     */
    handleTimeOptionClick() {
        if ( typeof this.acctStartTime != 'undefined' && this.acctStartTime != null && this.acctStartTime.length != 0 ) {
            this.startTime = this.acctStartTime;
        }
        if ( typeof this.acctEndTime != 'undefined' && this.acctEndTime != null && this.acctEndTime.length != 0 ) {
            this.endTime = this.acctEndTime;
        }
        this.timeOption = !this.timeOption;
    }


    /**
     * @description handle and validate change to the start time input
     * @param e
     */
    handleStartTimeChange(e) {
        if(e.detail.value >= this.endTime) {
            alert('Start time has to be before end time');
            this.template.querySelector('.startTime').value = this.startTime;
        } else if(e.detail.value === '') {
            alert('Start time must be populated when times are specified');
            this.template.querySelector('.startTime').value = this.startTime;
        } else if ( e.detail.value < this.acctStartTime ) {
            alert('Start time must be within then the Account\'s specified Operating Hours');
            this.template.querySelector('.startTime').value = this.startTime;
        } else {
            this.startTime = e.detail.value;
        }
    }


    /**
     * @description handle and validate change to the end time input
     * @param e
     */
    handleEndTimeChange(e) {
        if(this.startTime >= e.detail.value) {
            alert('End time has to be after start time');
            this.template.querySelector('.endTime').value = this.endTime;
        } else if(e.detail.value === '') {
            alert('End time must be populated when times are specified');
            this.template.querySelector('.endTime').value = this.endTime;
        } else if ( e.detail.value > this.acctEndTime ) {
            alert('End time must be within then the Account\'s specified Operating Hours');
            this.template.querySelector('.endTime').value = this.endTime;
        } else {
            this.endTime = e.detail.value;
        }
    }


    /**
     * @description method to save the occurrence record when the parent timeline sends save event
     * @param e timeline id
     */
    saveOccurrence(e) {
        if(this.occurrence.Timeline__c === undefined && e !== undefined) {
            this.occurrence.Timeline__c = e.detail.timelineId;
        }

        // set start and end time based on what has been captured in the UI
        if(this.timeOption) {
            this.occurrence.Start_Time__c = this.startTime;
            this.occurrence.End_Time__c   = this.endTime;
        } else {
            this.occurrence.Start_Time__c = null;
            this.occurrence.End_Time__c   = null;
        }

        // save occurrence unless brand new but deleted from screen
        if(this.occurrence.Is_Active__c || !this.occurrence.Is_Active__c && this.occurrence.Id && this.occurrence.Id.length >= 15) {
            this.template.querySelector('lightning-record-edit-form').submit(this.occurrence);
        }
    }


    /**
     * @description handle click of the delete button to delete an occurrence
     * @param e
     */
    handleDeleteClick(e) {
        console.log('occurrence',this.occurrence);
        if (confirm('Are you sure you want to delete this repetition that occurs' + this.buildMessageString()+'?') === true) {
            // console.log('lets get rid of this puppy');
            this.occurrence.Is_Active__c = false;
            this.saveOccurrence(undefined);
        }
    }


    get timeLabel() {
        return this.timeOption ? 'Remove times' : 'Specify times';
    }


    get getMessage() {
        return this.message;
    }


    /************ COLLOQUIAL MESSAGE ************/
    @track message = 'Event';
    initiateMessage() {
        this.message = 'This event will occur ' + this.buildMessageString();
    }


    buildMessageString() {
        let message = '';

        if(this.isMonthly) {
            if(this.monthlyWeekNumber !== undefined && this.monthlyDayOptions !== undefined && this.every !== undefined) {
                message += ' on the ' + this.monthlyWeekNumber + ' ' + this.monthlyDayOptions + ' of ';
                if (this.occurrence.Every__c == 1) message += 'every month';
                else if (this.occurrence.Every__c == 2) message += 'every 2nd month';
                else if (this.occurrence.Every__c == 3) message += 'every 3rd month';
                else if (this.occurrence.Every__c > 3) message += 'every ' + this.occurrence.Every__c + 'th month';
            }
        } else {
            let selectedDays = [];
            for (let i = 0; i < this.days.length; i++) if (this.days[i].selected) selectedDays.push(this.days[i].label);
            let numWeekendDays = 0;
            let numWeekDays = 0;
            for (let i = 0; i < selectedDays.length; i++) {
                if (selectedDays[i] === 'Saturday' || selectedDays[i] === 'Sunday') numWeekendDays++;
                else numWeekDays++;
            }
            if (selectedDays.length === 7 && !this.isDaily) {
                message += ' daily';
                if (this.occurrence.Every__c == 1) message += ' - you could have just selected daily frequency...';
            } else if (numWeekDays === 5 && numWeekendDays === 0) {
                message += ' on week days';
            } else if (numWeekDays === 0 && numWeekendDays === 2) {
                message += ' on weekend days - boo';
            } else if (this.isWeekly) {
                let one = false;
                if (selectedDays.length > 0) message += ' on ';
                for (let i = 0; i < selectedDays.length; i++) {
                    if (selectedDays.length > 2 && i > 0) message += ', ';
                    if (i === selectedDays.length - 1 && one) message += ' and ' + selectedDays[i] + 's';
                    else message += selectedDays[i] + 's';
                    one = true;
                }
            }
            let frequency = '';
            if (this.isDaily) frequency = 'day';
            else if (this.isWeekly) frequency = 'week';
            else if (this.isMonthly) frequency = 'month';
            if (this.occurrence.Every__c == 0)
                message = '';
            else if (this.occurrence.Every__c == 1 && frequency !== 'week') message += ' every ' + frequency;
            else if (this.occurrence.Every__c >= 2) message += ' every ' + this.occurrence.Every__c + ' ' + frequency + 's';
        }

        return message;
    }





    /************ IO HELPER METHODS ************/

    /**
     * @description checks if a array of json objects has a matching property and value
     * @param json array of json objects
     * @param prop property to find in each object
     * @param value value to compare for the propery
     * @returns {boolean} whether a match was found
     */
    jsonIndex(json,prop,value) {
        return json.findIndex(obj => obj[prop] === value);
    }


    /**
     * @description finds and returns object with attribute "selected:true" in array oj objects
     * @param array of objects
     * @returns {object}
     */
    findSelected(array) {
        return (array.filter(opt => {
            return opt.selected;
        }))[0];
    }

}