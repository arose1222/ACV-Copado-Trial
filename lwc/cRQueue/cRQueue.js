/* eslint-disable vars-on-top */
import { LightningElement, track } from 'lwc';
import getPrescreens from '@salesforce/apex/CRQueueController.getPrescreens';
import getRules from '@salesforce/apex/CRQueueController.getCRReasons';
import {createUUID} from 'c/acvUtilHelper';

export default class CRQueue extends LightningElement {
    @track queueList = [];
    @track filteredQueue = [];
    @track ruleList = [];
    @track containerClasses = 'container';
    @track selectedRules = [];
    @track yearList = [{value: "0", label: "--None--"}];
    @track selectedYear;

    connectedCallback(){
        this.getRuleList();
        this.makeYearList();
        this.getPrescreenList();
    }


    filterResults(){
        this.filteredQueue = [];
        this.queueList.forEach(item => {
            var alreadyFiltered = false;
            if(item.reasons.some(v=>this.selectedRules.indexOf(v) !== -1)){
                this.filteredQueue.push(item);
                //alreadyFiltered = true;
            }
            if(typeof item.Year !== 'undefined' && !alreadyFiltered && !item.Year && this.selectedYear != '0' && item.Year.toString() >= this.selectedYear){
                this.filteredQueue.push(item);
            }
        });
        if(this.selectedRules.length < 1 && (this.selectedYear === '0' || !this.selectedYear)){
            this.filteredQueue = this.queueList;
        }
    }

    handleYearChange(event){
        this.selectedYear = event.detail.value;
        this.filterResults();
    }

     makeYearList(){
        const now = new Date().getUTCFullYear();
        const years = Array(now - (now - 100)).fill('').map((v, idx) => now - idx);
        years.forEach(y =>{
            this.yearList.push({value: y.toString(), label: y.toString()});
        });
    }

    handleRuleChange(event) {
        this.selectedRules = event.detail.value;
        this.filterResults();
    }

    toggleDrawer(){
        var selected = this.template.querySelector('[data-id="container"]');
        if(selected){
            if(this.containerClasses === 'container' || this.containerClasses === 'slideOutUp'){
                this.containerClasses = 'slideInDown';
            }
            else{
                this.containerClasses = 'slideOutUp';
            }
        }
    }

     async getRuleList(){
        const data = JSON.parse(await getRules());
        if(data.length > 0){
            this.ruleList = data;
        }
    }

    async getPrescreenList(){
        this.queueList = [];
        const data = await getPrescreens();
        if(data.length > 0){
            for(var i = 0; i < data.length; i++){
                this.queueList.push(this.createLine(data[i]));    
            }
        }
        this.filterResults();
    }

    createLine(item){
        console.log(item);
        var reasonList = [];
        item.Prescreen_Reasons__r.forEach(element => {
            reasonList.push(element.Name);
        });
        var lineItem = {
            key: createUUID(),
            id : item.Id,
            vci : item.VCI__r ? item.VCI__r.Name : '',
            reasons : reasonList,
            VIN : item.Vehicle__r ? item.Vehicle__r.vin__c : '',
            Name : item.Name,
            Age: item.Age_in_Minutes__c,
            Link: item.Link_To_CR__c,
            Year: item.Vehicle__r ? item.Vehicle__r.Year__c : '',
            linkToRecord: '/'+item.Id
        }
        return lineItem;
    }
}