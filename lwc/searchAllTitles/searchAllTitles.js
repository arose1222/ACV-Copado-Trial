/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import getTitles from '@salesforce/apex/SearchAllTitlesApexHandler.getTitles';
import { updateRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

const fieldList = [
    'Case.Id'
];

export default class SearchFunction extends LightningElement {
    @track rows = [];
    @track searchTerm = '';
    @track loading = false;
    @api recordId;
    @wire(getRecord,{recordId:'$recordId', fields:fieldList})case;

    connectedCallback() {
        this.getCases();
    }
    //Function that gets the Titles through a search term in the Apex Class
    async getCases() {
        var newRow = '';
        let rows_tmp = [];
        this.rows = [];
        const data = await getTitles({searchTerm:this.searchTerm});
        for (let i = 0; i < data.length; i++) {
            let caseURL = 'https://acvauctions.lightning.force.com/lightning/r/Case/' + data[i].Id + '/view';
            let auctionURL = 'https://acvauctions.lightning.force.com/lightning/r/Auction__c/' + data[i].Auction_Number__c + '/view';
            let vinURL = 'https://acvauctions.lightning.force.com/lightning/r/Vehicle__c/' + data[i].Vehicle__c + '/view';
            let titleData = '';
            let auctionNum = '';
            let vehicleNum = '';
            if (data[i].Title_Attached__c === true) {
                titleData = 'TA';
            }
            else {
                titleData = 'TWD';
            }

            if (data[i].Auction_Number__c === undefined) {
                auctionNum = '';
            }
            else {
                auctionNum = data[i].Auction_Number__r.Name;
            }

            if (data[i].Vehicle__c === undefined) {
                vehicleNum = '';
            }
            else {
                vehicleNum = data[i].Vehicle__r.Name;
            }
            //These rows re the fields you see on each title
            newRow = {
                //can NOT search by any text field still
                key: data[i].Id,
                title: titleData,
                days: data[i].Age_in_Days__c,
                status: data[i].Status,
                //caseNumber: data[i].CaseNumber,
                caseNumber: caseURL,
                //can search by case num
                //auctionNumber: data[i].Auction_Number_Case__c,
                auctionNumber: auctionURL,
                //can NOT search by auction num
                //vin: data[i].Vehicle_VIN__c,
                vin: vinURL,
                //can search by vin
                make: data[i].Vehicle_Make__c,
                model: data[i].Vehicle_Model__c,
                year: data[i].Vehicle_Year__c,
                //can NOT search by year
                sellerName: data[i].Seller_Name__c,
                buyerName: data[i].Buyer_Name__c,
                paymentMethod: data[i].Payment_Method__c,
                paymentStatus: data[i].Payment_Status__c,
                caseNum: data[i].CaseNumber,
                aucNum: auctionNum,
                vinNum: vehicleNum
            }
            //pushes rows to a temporty placeholder so they don't flash on refresh and show wrong results
            rows_tmp.push(newRow);
        }
        //pushes the rows that correspond to the search term to the 
        this.rows = rows_tmp;
    }
    
    //Function that fires the given function after a specified number of milliseconds. If immediate is true it will ignore and fire instantly. 
    debounce(func, wait, immediate, context) {
        var timeout;
        return function executedFunction(){
            //var context = this;
            var args = arguments;
            let exec = () => func.apply(context, args);
            var later = function() {
                timeout = null;
                if (!immediate) exec();
           };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) exec();
        };
    }
    
    //Gets the search term from the user input event
    termChange(evt) {
        this.searchTerm = evt.target.value;
        //fires get cases after the user stops typing for 2 full seconds and uses the search term to get the corret results
        let xdog = this.debounce(this.getCases, 1000, false, this);
        //calls the returned debounce function
        xdog();   
    } 

    //Row handler function for HTML handling of the rows
    handleRowAction(evt) {
        this.loading = !this.loading;
        const fields = {};
        let recordInput = {};
        this.rows.forEach(item => {
            if (item.key === evt.currentTarget.dataset.key) {
                item.status = 'Received';
                evt.target.disabled = true;
                fields[ID_FIELD.fieldApiName] = item.key;
                fields[STATUS_FIELD.fieldApiName] = item.status;
                recordInput = {fields};
            }
        })

        //Another function used in the HTML portion that updates records
        updateRecord(recordInput).then(() => {
            this.loading = !this.loading;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Status updated',
                    varient: 'success'
                })
            );
            //this.connectedCallback();
        })
    }
}