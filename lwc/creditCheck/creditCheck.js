/* eslint-disable vars-on-top */
/* eslint-disable no-alert */
/* eslint-disable no-console */

import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getObjectInfo from '@salesforce/apex/CreditCheckController.getObjectInfo';
import createCreditRecord from '@salesforce/apex/CreditCheckController.createCreditRecord';

export default class creditCheck extends LightningElement {

    @api recordId;
    @track dealerOptions = [];
    @track budgetOptions = [];
    @track showAucComp = false;
    @track showCredComp = false;
    @track showActComp = false;
    @track showForAuction = false;    
    @track showForCredit = false;
    @track showForAccount = false;
    @track showExpirationDate = false;
    @track sfObject = [];
    @track rootCauseOptions = [];
    @track paymentOptionsList = [];
    @track expirationDefault = '';
    @track showNoBudgetMessage = false;
    @track showSellerInfoBudgetMessage = false;
    @track showBuyerInfoBudgetMessage = false;
    @track amountLimit = 999999;
    @track showSlamDunk = false;
    @track activeSpinner = false;
    @track disableSubmit = false;
    createCred;
    enteredAmount;
    enteredExplanation;
    desObjectInfo;
    dealerBuy;
    dealerSell;
    defaultDealer;

    sfObject = {
        currentObjectType:'',
        selectedDealer:'',
        otherDealer:'',
        resolution:'',
        enteredAmount:'',
        selectedBudget:'',
        selectedRecord:'',
        secondaryRecord:'',
        creditReason:'',
        selectedRootCause:'',
        enteredExplanation:'',
        caseId:'',
        currentId:'',
        goodwill:'',
        budget:'',
        expirationDate:'',
        slamDunk:false
    }
    // Turns on and off the Main Loading Spinner
    toggleSpinner(){
        this.activeSpinner = !this.activeSpinner;
    }
    //Get object info: OjectType & Dealers
    async connectedCallback(){
        var objectInfo = await getObjectInfo({objectRecordId:this.recordId});
        this.desObjectInfo = JSON.parse(objectInfo);
        console.log(this.desObjectInfo);
        this.sfObject.currentObjectType = this.desObjectInfo.objectName;
        this.sfObject.currentId = this.recordId;        
        
        if(this.desObjectInfo.objectName==='Auction__c' && this.desObjectInfo.auctionInfo.sellerDealer !==null && this.desObjectInfo.budgetList !==null){
            this.showAucComp = true;
            this.dealerSell = {value:this.desObjectInfo.auctionInfo.sellerDealer.key, label:'Seller: ' + this.desObjectInfo.auctionInfo.sellerDealer.name};
            this.dealerOptions.push(this.dealerSell);
            this.showSellerInfoBudgetMessage = true;
            this.desObjectInfo.budgetList.forEach(x=>{
                var budId = {value:x.budgetId,label:x.budgetName};
                this.budgetOptions.push(budId);                
            });
            
            if(this.desObjectInfo.auctionInfo.buyerDealer !== null){
                this.dealerBuy = {value:this.desObjectInfo.auctionInfo.buyerDealer.key, label:'Buyer: ' + this.desObjectInfo.auctionInfo.buyerDealer.name};
                this.dealerOptions.push(this.dealerBuy);
                this.showBuyerInfoBudgetMessage = true;
            }
            this.showSlamDunk = this.desObjectInfo.showSlamDunkCheckbox;
        }
        else if(this.desObjectInfo.objectName==='Credits_Checks__c'){
            this.showCredComp = true;
        }else if( this.desObjectInfo.objectName === 'Account' ){
            this.showActComp = true;
            this.sfObject.selectedDealer = this.desObjectInfo.auctionInfo.buyerDealer.key;
            this.dealerOptions.push( {value:this.desObjectInfo.auctionInfo.buyerDealer.key, label:this.desObjectInfo.auctionInfo.buyerDealer.name} );
            this.defaultDealer = this.desObjectInfo.auctionInfo.buyerDealer.key;
            this.desObjectInfo.budgetList.forEach(x=>{
                var budId = {value:x.budgetId,label:x.budgetName};
                this.budgetOptions.push(budId);                
            });
        }
        if( this.desObjectInfo.expirationDate != '' ){
            this.sfObject.expirationDate = this.desObjectInfo.expirationDate;
            this.expirationDefault = this.desObjectInfo.expirationDate;
        }
    }
    
    //***********************************************************************************
    openModal() {
        if(this.desObjectInfo.objectName==='Auction__c'){
            if(this.desObjectInfo.budgetList.length > 0){
                this.showForAuction=true;
                this.amountLimit = 999999;
                this.slamDunk = false;
            }else{
                this.showNoBudgetMessage=true;
            }
            
        }
        else if(this.desObjectInfo.objectName==='Credits_Checks__c'){
            this.showForCredit=true;
        }else if( this.desObjectInfo.objectName === 'Account' ){
            this.showForAccount = true;
        }
    }

    closeModal() {
        if(this.desObjectInfo.objectName==='Auction__c'){
            this.showForAuction=false;
            this.showNoBudgetMessage=false;
        }
        else if(this.desObjectInfo.objectName==='Credits_Checks__c'){
            this.showForCredit=false;
        }else if( this.desObjectInfo.objectName === 'Account' ){
            this.showForAccount = false;
        }
        this.showExpirationDate=false;
    }
    
    //***********************************************************************************
    handleDealerChange(event){
        this.sfObject.selectedDealer = event.detail.value;
        if( this.desObjectInfo.objectName != 'Account' ){
            if(this.sfObject.selectedDealer === this.dealerBuy){
                this.sfObject.otherDealer = this.dealerSell.value;
            }
            else if(this.dealerBuy !== null){
                this.sfObject.otherDealer = this.dealerBuy.value;
            }
        }
    }
    //***********************************************************************************
    handleExpirationDateChange(event){
        this.sfObject.expirationDate = event.detail.value;
    }
    //***********************************************************************************
    handleSlamDunkChange(event){
        this.sfObject.slamDunk = event.detail.checked;
        if( this.sfObject.slamDunk ){
            this.amountLimit = 500;
        }else{
            this.amountLimit = 99999999;
        }
    }
    //***********************************************************************************
    handleAmountChange(event){
        this.sfObject.enteredAmount = event.detail.value;
    }

    //***********************************************************************************
    handleBudgetChange(event){
        this.sfObject.selectedBudget = event.detail.value;
    }
    //***********************************************************************************
    get reasonOptions() {
        let reasonOptions = [];
        if( this.desObjectInfo.objectName === 'Account' ){
            reasonOptions = [{ label: 'Promotion', value: 'Promotion' }];
        }else{
            reasonOptions = [
                //{ label: 'Arbitration', value: 'Arbitration' },
                { label: 'Goodwill', value: 'Goodwill' }
                // { label: 'Promotion', value: 'Promotion' }
                //{ label: 'Bad Debt Expense', value: 'Bad Debt Expense' },
                //{ label: 'No direct expense to ACV', value: 'No direct expense to ACV' }
            ];
        }
        return reasonOptions;
    }
    handleReasonChange(event){
        this.sfObject.creditReason = event.detail.value;

        if(this.sfObject.creditReason === 'Arbitration'){
            this.rootCauseOptions = [
                { label: 'Arbitration unavoidable', value: 'Arbitration unavoidable' },
                { label: 'Arbitration avoidable', value: 'Arbitration avoidable' },
                { label: 'Zero downside', value: 'Zero downside' }
            ];
        }
        else if(this.sfObject.creditReason === 'Goodwill'){
            this.rootCauseOptions = [
                { label: 'Past Arbitration Time Frame – 48-hour ACV Transport', value: 'Past Arbitration Time Frame – 48-hour ACV Transport' },
                { label: 'Past Arbitration Time Frame – 10-day Arbitration', value: 'Past Arbitration Time Frame – 10-day Arbitration' },
                { label: 'Component Not Covered', value: 'Component Not Covered' },
                { label: 'Disclosure Dispute', value: 'Disclosure Dispute' },
                { label: 'Double Sale', value: 'Double Sale' },
                { label: '48-hour Title Notice', value: '48-hour Title Notice' },
                { label: 'Transportation Issue', value: 'Transportation Issue' },
                { label: 'Other Goodwill Issue', value: 'Other Goodwill Issue' },
            ];
        }
        else if(this.sfObject.creditReason === 'Promotion'){
            this.rootCauseOptions = [
                // { label: 'First time buyer', value: 'First time buyer' },
                // { label: '14-day guarantee', value: '14-day guarantee' },
                // { label: 'Other Promotion', value: 'Other Promotion' },
                // { label: 'Buyer Fee Refund / Correction', value: 'Buyer Fee Refund / Correction' },
                // { label: 'Seller Fee Refund / Correction', value: 'Seller Fee Refund / Correction' },
                // { label: 'Transport Fee Refund / Correction', value: 'Transport Fee Refund / Correction' },
                // { label: 'Capital Fee Refund / Correction', value: 'Capital Fee Refund / Correction' }
                { label: 'Promotion', value: 'Promotion' }
            ];
        }
        else if(this.sfObject.creditReason === 'Bad Debt Expense'){
            this.rootCauseOptions = [
                { label: 'Non-payment', value: 'Non-payment'}
            ]
        }
        else if(this.sfObject.creditReason === 'No direct expense to ACV'){
            this.rootCauseOptions =[
                {label: 'Auction Error', value:'Auction Error'}
            ]
        }
    }

    //***********************************************************************************
    get paymentOptions(){
        if(this.desObjectInfo.objectName==='Auction__c'){
            this.paymentOptionsList = [
                { label: 'ACV Credit Assigned', value: 'ACV Credit Assigned' },
                { label: 'ACV Issue Check', value: 'ACV Issue Check' },
                { label: 'Debt Forgiveness', value: 'Debt Forgiveness' }
            ];
        }
        else if(this.desObjectInfo.objectName==='Credits_Checks__c'){
            this.paymentOptionsList = [
                { label: 'ACV Credit Assigned', value: 'ACV Credit Assigned' },
                { label: 'ACV Credit Deduction', value: 'ACV Credit Deduction' }
            ];
        }else if( this.desObjectInfo.objectName === 'Account' ){
            this.paymentOptionsList = [
                { label: 'ACV Credit Assigned', value: 'ACV Credit Assigned' },
                { label: 'ACV Issue Check', value: 'ACV Issue Check' },
                { label: 'Debt Forgiveness', value: 'Debt Forgiveness' }
            ];
        }
        return this.paymentOptionsList;
    }

    handlepaymentChange(event){
        this.sfObject.resolution = event.detail.value;

        if(this.sfObject.resolution === 'ACV Credit Assigned' || this.sfObject.resolution === 'ACV Credit Deduction'){
            this.sfObject.selectedRecord = 'Credit';
            this.showExpirationDate = true;
        }
        else if(this.sfObject.resolution === 'ACV Issue Check' || this.sfObject.resolution == 'Debt Forgiveness'){
            this.sfObject.selectedRecord = 'Check';
            this.showExpirationDate = false;
        }
    }

    //***********************************************************************************
    handleRootCauseChange(event){
        this.sfObject.selectedRootCause = event.detail.value;
    }

    //***********************************************************************************
    handleExplanationChange(event){
        this.sfObject.enteredExplanation = event.detail.value;
    }

    //***********************************************************************************
    handleSubmitClick(){

        var inputObject = JSON.stringify(this.sfObject);
        if(this.desObjectInfo.objectName==='Credits_Checks__c'){
            if(this.sfObject.enteredAmount==='' || this.sfObject.resolution===''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Missing fields',
                        variant: 'error'
                    })
                );
            }
            else{
                this.disableSubmit = true;
                this.toggleSpinner();
                createCreditRecord({inputObject:inputObject})
                    .then( result => {
                        this.createCred = result;
                        this.closeModal();
                        if(this.createCred === 'Success'){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Record Created',
                                    variant: 'success'
                                })
                            );
                        }
                        else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Failure to create record',
                                    variant: 'error'
                                })
                            );
                        }
                    })
                    .catch( error => {
                        console.log( JSON.stringify(error) );
                    })
                    .finally( () => {
                        this.toggleSpinner();
                    })
                ;
                
            }
        }

        else if(this.desObjectInfo.objectName==='Auction__c' || this.desObjectInfo.objectName === 'Account' ){
            if(this.sfObject.selectedDealer==='' || this.sfObject.enteredAmount==='' || this.sfObject.enteredAmount < 0 || this.sfObject.selectedBudget=== '' || this.sfObject.selectedRecord==='' || this.sfObject.creditReason==='' || this.sfObject.selectedRootCause===''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Missing fields',
                        variant: 'error'
                    })
                );
            }else if( this.sfObject.slamDunk && this.sfObject.enteredAmount > this.amountLimit ){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Slam Dunk has a limit of $500',
                        variant: 'error'
                    })
                );
            }
            else{
                this.disableSubmit = true;
                this.toggleSpinner();
                createCreditRecord({inputObject:inputObject})
                    .then( result => {
                        this.createCred = result;
                        console.log('createCred: ' + this.createCred);
                        this.closeModal();

                        if(this.createCred === 'Success'){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Record Created',
                                    variant: 'success'
                                })
                            );
                        }
                        else{
                            if(this.createCred === 'falseBudget'){
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Failure to create record: No Budget Assigned',
                                        variant: 'error'
                                    })
                                );
                            }
                            else{
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Failure to create record',
                                        variant: 'error'
                                    })
                                );
                            }
                        }
                    })
                    .catch( error => {
                        console.log( JSON.stringify(error) );
                    })
                    .finally( () => {
                        this.toggleSpinner();
                    })
                ;
            }
        }
    }
}