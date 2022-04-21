import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ARB_RISK_CATEGORY_JSON from '@salesforce/schema/Condition_Report_Prescreen__c.Arb_Risk_Categories__c';
import ARB_RISK_CATEGORY_CONDITION_REPORT_JSON from '@salesforce/schema/Condition_Report_Prescreen__c.Condition_Report__r.Arb_Risk_Categories__c';

const FIELDS = [ARB_RISK_CATEGORY_JSON,ARB_RISK_CATEGORY_CONDITION_REPORT_JSON];

export default class ArbitrationRiskCategoryTable extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track rows = []
    sortAsc;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    prescreenRecord({error, data}){
        if(data){  

            if(getFieldValue(data, ARB_RISK_CATEGORY_CONDITION_REPORT_JSON) !== null){
                this.rows = JSON.parse( getFieldValue(data, ARB_RISK_CATEGORY_CONDITION_REPORT_JSON) );
            }else if(getFieldValue(data, ARB_RISK_CATEGORY_JSON) !== null){
                this.rows = JSON.parse( getFieldValue(data, ARB_RISK_CATEGORY_JSON) );
            }

        }
        else if(error){ console.log(JSON.stringify(error)); }
        this.hideSpinner();
    }
    
    showSpinner(){
        this.isLoading = true;
    }

    hideSpinner(){
        this.isLoading = false;
    }

    handleSort(event){
        const field = event.target.dataset.field;

        this.rows.sort(
            (a, b) => {
                let columnA;
                let columnB;

                switch (field) {
                    case 'category':
                        columnA = a['category'].toUpperCase();
                        columnB = b['category'].toUpperCase();
                        break;

                    case 'odds':
                        columnA = a['odds'].toUpperCase();
                        columnB = b['odds'].toUpperCase();
                        break;

                    case 'dollarRisk':
                        columnA = a['dollarRisk'];
                        columnB = b['dollarRisk'];
                        break;

                    default:
                        break;
                }
                
                let comparison = 0;

                if(this.sortAsc){
                    if (columnA > columnB) {  comparison = 1; } 
                    else if (columnA < columnB) { comparison = -1; }
                }else{
                    if (columnA < columnB) {  comparison = 1; } 
                    else if (columnA > columnB) { comparison = -1; }
                }
                
                return comparison;
            }
        );

        this.sortAsc = !this.sortAsc;
    }

    get availableRows(){
        return this.rows !== undefined && this.rows !== null && this.rows.length > 0;
    }

    get title(){
        return `Arbitration Risk Categories (${this.rows.length})`;
    }

    get totalDollarRisk(){
        let totalAmount = 0;
        this.rows.forEach( row => {
            totalAmount += row.dollarRisk;
        })
        return totalAmount;
    }
}