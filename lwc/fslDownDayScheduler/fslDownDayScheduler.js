import { LightningElement, wire, track } from 'lwc';
import recordSelected from '@salesforce/messageChannel/calendarDateSelection__c';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import { fireToast } from 'c/acvUtilHelper';
import apexSearch from '@salesforce/apex/FSLDownDaySchedulerController.getWorkTypes';
import saveDay from '@salesforce/apex/FSLDownDaySchedulerController.saveDownDay';

export default class FslDownDayScheduler extends LightningElement {

    subscription = null;

    @track selectedDate;
    @track isAllDay;
    @track showEventCreationScreen;
    @track showLoadingSpinner;
    @track workTypeSelection;
    @track errors = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.isAllDay = false; // Set to False by Default
        this.showEventCreationScreen = false;
        this.showLoadingSpinner = false;
        this.workTypeSelection = '';
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        this.isAllDay = message.isAllDay;
        this.selectedDate = message.dateStr;
        this.showEventCreationScreen = true;
    }

    handleDate(event){
        this.selectedDate = event.detail.value;
    }

    handleUploaderSelectionChangeforWorkType(event) {
        var selectedValue = event.target.getSelection();
        if ( selectedValue.length > 0 ) {
            this.workTypeSelection = selectedValue[0].id;
        } else {
            this.workTypeSelection = '';
        }
    }

    handleWorkTypeLookup(event) {
        const target = event.target;
        apexSearch(event.detail)
        .then(results => {
            target.setSearchResults(results);
        })
        .catch(error => {
            fireToast('Lookup Error', 'There was an issue trying to look up the selected Work Type', 'error');
            this.errors = [error];
        });
    }

    saveEvent() {
        this.showLoadingSpinner = true;
        saveDay({ downDate: this.selectedDate, workTypeId: this.workTypeSelection })
        .then(results => {
            if ( results != null && results == true ) {
                fireToast('Success', 'The Down Day has been created!', 'success');
            } else {
                fireToast('Save Error', 'There was an issue trying to create your down day!', 'error');
            }
        })
        .catch(error => {
            fireToast('Save Error', 'There was an issue trying to create your down day!', 'error');
            this.errors = [error];
        }).finally( () => {
            this.closeModal();
            eval("$A.get('e.force:refreshView').fire();");
        });
    }

    closeModal() {
        this.showEventCreationScreen = false;
        this.showLoadingSpinner = false;
    }
}