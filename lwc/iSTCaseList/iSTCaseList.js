import { LightningElement, api, track } from 'lwc';
import {createUUID} from 'c/acvUtilHelper';
import { NavigationMixin } from 'lightning/navigation';
import getCases from '@salesforce/apex/ISTCaseListController.getAllCases';
import getRTList from '@salesforce/apex/ISTCaseListController.getRecordTypeSelectList';

export default class ISTCaseList extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @api isSeller = false;
    @track selectedRT;
    @track showClosed = false;
    @track visibleCaseList = [];
    @track picklistOptions = [];
    @track filterTerm;
    caseList = [];

    connectedCallback(){
        this.createOptions();
    }

    navigateToRecordViewPage(event) {
        event.preventDefault();
        if(event.target.getAttribute("data-aid")){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.getAttribute("data-aid"),
                    objectApiName: 'Auction__c', // objectApiName is optional
                    actionName: 'view'
                }
            });
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.getAttribute("data-value"),
                objectApiName: 'Case', // objectApiName is optional
                actionName: 'view'
            }
        });

        
    }

    filterUpdate(event){
        var matches = [];
        this.filterTerm = event.target.value;
        this.filterRows();
        if(this.filterTerm){
            var substrRegex = new RegExp(this.filterTerm, 'i');
            this.visibleCaseList.forEach(item =>{
                if(substrRegex.test(item.auctionNumber) || substrRegex.test(item.vin) || substrRegex.test(item.yearMake)){
                    matches.push(item);
                }
            });
            if(matches.length > 0){
                this.visibleCaseList = matches;
            }
            else{
                this.visibleCaseList = [];
            }
        }
    }

    async createOptions(){
        const data = JSON.parse(await getRTList());
        if(data.length > 0){
            this.picklistOptions = data;
        }
    }

    async getData(){
        this.caseList = []; 
        // added asSeller
        const data = await getCases({accountId:this.recordId, asSeller:this.isSeller});
        if(data.length > 0){
            for(var i = 0; i < data.length; i++){
                var myCase = this.generateRow(data[i]);
                this.caseList.push(myCase);
            }
            this.filterRows();
        }
    }

    generateRow(caseInput){
        var ym = '';
        if(caseInput.Vehicle__r){
            ym = caseInput.Vehicle__r.Year_Make_Model_Trim__c
        }
        return {
            case:caseInput,
            selected: false,
            key: createUUID(),
            linkToRecord: '/' + caseInput.Id,
            auctionNumber: caseInput.Auction_Number__r ? caseInput.Auction_Number__r.Name : '',
            auctionLink: caseInput.Auction_Number__c ? '/' + caseInput.Auction_Number__c : '',
            vin: caseInput.Vehicle_VIN__c ? caseInput.Vehicle_VIN__c : '',
            vinLink: caseInput.Vehicle__c ? '/' + caseInput.Vehicle__c : '',
            yearMake: ym
        };
    }

    recordTypeChange(event){
        this.selectedRT = event.detail.value;
        this.getData();
    }

    toggleCloseCase(){
        this.showClosed = !this.showClosed;
        this.getData();
    }

    filterRows(){
        this.visibleCaseList = [];
        this.caseList.forEach(myCase =>{
            if(myCase.case.RecordTypeId === this.selectedRT){
                if(!this.showClosed){
                    if(!myCase.case.IsClosed){
                        this.visibleCaseList.push(myCase);
                    }
                }
                else{
                    this.visibleCaseList.push(myCase);
                }
            }
            else if(!this.selectedRT || this.selectedRT === 'none'){
                if(!this.showClosed){
                    if(!myCase.case.IsClosed){
                        this.visibleCaseList.push(myCase);
                    }
                }
                else{
                    this.visibleCaseList.push(myCase);
                }
            }
        });
    }
}