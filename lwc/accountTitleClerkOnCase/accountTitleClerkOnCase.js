import { LightningElement, track, api, wire } from 'lwc';
import getTitleClerkBuyerInfo from '@salesforce/apex/SearchTitleClerkApexHandler.getTitleClerkBuyerInfo';
import getTitleClerkSellerInfo from '@salesforce/apex/SearchTitleClerkApexHandler.getTitleClerkSellerInfo';
import { getRecord } from 'lightning/uiRecordApi';

// const cols = [
//     // {label:'First Name', fieldName:'FirstName'},
//     // {label:'Last Name', fieldName:'LastName'},
//     {label:'Name', fieldName:'Name'},
//     {label:'Phone', fieldName:'Phone'}
// ];

const fieldList = [
    'Case.Id'
];

export default class AccountTitleClerkOnCase extends LightningElement {
    // @track columns = cols;
    @track buyerContact;
    @track sellerContact;

    @api recordId;

    @wire(getRecord,{recordId:'$recordId', fields:fieldList})case;

    connectedCallback() {
        this.getBuyerContact();
        this.getSellerContact();
        // .then(result=>{
        //     console.log(result);
        // }).catch(err => {
        //     console.log(err);
        // });
        //console.log('connect');
    }

    async getBuyerContact() {
        //let splitClerk = '';
        //let toContact = '';
        if(this.recordId) {
            //const data =  await getTitleClerkInfo({caseId:this.recordId});
            //this.contact = data;
            const namePhoneBuyer =  await getTitleClerkBuyerInfo({caseId:this.recordId});
            //console.log('names ' + namePhone);
            // splitClerk = namePhone.split('^');
            // splitClerk.pop();
            // this.contact = splitClerk;
            //console.log('split ' + splitClerk);
            // for (let i = 0; i < splitClerk.length; i++) {
            //     //console.log('indiv ' + splitClerk[i]);
            //     toContact = (toContact + splitClerk[i] + '\n');
            // }
            // toContact = toContact.slice(0, -2);
            // console.log(toContact);
            this.buyerContact = namePhoneBuyer;
        }
    }

    async getSellerContact() {
        if(this.recordId) {
            const namePhoneSeller = await getTitleClerkSellerInfo({caseId:this.recordId});
            this.sellerContact = namePhoneSeller;
        }
    }
}