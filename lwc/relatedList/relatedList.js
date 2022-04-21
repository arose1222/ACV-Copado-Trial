/**
 * @description (1) This LWC is used to display child records on parent's detail page. E.g. if you like to display a list of associated Contacts on the Account page.
 *              (2) This LWC could also be used to display child records on its sibling detail page. In other words, you could display a list of associated Child records on 
 *              another Child (i.e. sibling - both children shares the same parent) page.
 * 
 * @configuration
 * To configure it to display child records on parent:
 * Object Name - Child Object API Name. 
 * Parent Field API Name - API field name on the child object that has parent's record id (i.e parent relation field).
 * 
 * E.g. Case is a parent object of Customer_Inquiry__c object. Customer_Inquiry__c.Ops_Case__c is API field name 
 * that has it's parent (Case) Id. Then, you will configure this LWC on the Case page as:
 * 
 * Object Name -  Customer_Inquiry__c
 * Parent Field API Name - Ops_Case__c
 * 
 * 
 * To configure it to display child records on sibling:
 * Object Name - Child Object API Name. 
 * Parent Field API Name - API field name on the child object that has parent's record id (i.e parent relation field).
 * Sibling Object API Name - Another Child (sibling) Object API Name.
 * Sibling Object Parent Field API Name - API field name on another child (sibling) object that has parent's record id (i.e parent relation field).
 * 
 * E.g. If Case is a parent object of Customer_Inquiry__c & Quality_Control__c objects. And,  Customer_Inquiry__c.Ops_Case__c & Quality_Control__c.Case__c
 * are the API field names that point/relate to parent (Case) Id then you will configure this LWC on the Quality_Control__c page to display Customer_Inquiry__c records as:
 * 
 * Object Name -  Customer_Inquiry__c
 * Parent Field API Name - Ops_Case__c
 * Sibling Object API Name - Quality_Control__c
 * Sibling Object Parent Field API Name - Case__c
 * 
 * 
 * @name   RelatedList
 * @author Aaron Richbart
 * 
 * @History
 * 09/30/2021 - Manmeet Vaseer - Added support for siblings.
 * 
 */
 import { LightningElement, api, wire, track } from 'lwc';  
import fetchRecords from '@salesforce/apex/RelatedListController.fetchRecords';  
import recordSelected from '@salesforce/messageChannel/relatedListChildAdded__c';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
  
export default class RelatedList extends LightningElement {  
  
    subscription = null;
    @track records;

    @api recordId;  
    @api strTitle; 
    @api modeType; 
    @api columnNumber; 
    @api layoutType; 

    @api objectName;  
    @api parentFieldAPIName;  
    @api fieldName1;  
    @api fieldValue1;  
    @api filterType1;  
    @api operator1;  
    @api fieldName2;  
    @api fieldValue2;  
    @api filterType2;  
    @api operator2;
    @api fieldName3;  
    @api fieldValue3;  
    @api filterType3;  
    @api operator3;
    @api orderField;  
    @api orderDirection;  
    @api siblingObjName;
    @api siblingObjParentFieldName;

    get vals(){
        var properties =
            {
                recordId: this.recordId,
                objectName: this.objectName,   
                parentFieldAPIName: this.parentFieldAPIName,
                fieldName1: this.fieldName1,   
                fieldValue1: this.fieldValue1,
                filterType1: this.filterType1, 
                operator1: this.operator1,
                fieldName2: this.fieldName2,   
                fieldValue2: this.fieldValue2,
                filterType2: this.filterType2, 
                operator2: this.operator2,
                fieldName3: this.fieldName3,   
                fieldValue3: this.fieldValue3,
                filterType3: this.filterType3, 
                operator3: this.operator3,
                orderField: this.orderField,
                orderDirection: this.orderDirection,
                siblingObjName: this.siblingObjName,
                siblingObjParentFieldName: this.siblingObjParentFieldName
            }

        return JSON.stringify(properties);
 
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        fetchRecords({ jsonString: this.vals })
            .then(results => {
                this.records = results;
            });
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
  
    // subscribe to relatedListChildAdded messageChannel
    // the logComment LWC publishes to this channel
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

    // When logComment or any other LWC publishes to relatedListChildAdded messageChannel run handleMessage()
    handleMessage(message) {
        if (message.data == 'child_list_modified') {
            this.records = null;
            fetchRecords({ jsonString: this.vals })
                .then(results => {
                    this.records = results;
                    eval("$A.get('e.force:refreshView').fire();");
                });
        }
    }
}