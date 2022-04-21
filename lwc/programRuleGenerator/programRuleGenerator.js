import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import getFieldTypeAndOperatorListWire from '@salesforce/apex/ProgramRuleGeneratorController.getFieldTypeAndOperatorList';
import getObjectFieldsByTypeMapWire from '@salesforce/apex/ProgramRuleGeneratorController.getObjectFieldsByTypeMap';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import ExternalId from '@salesforce/schema/Product2.ExternalId';


export default class ProgramRuleGeneratorClass extends NavigationMixin(LightningElement) {
    showSpinner = false;
    lhsObjectVal = '';
    rhsObjectVal = '';
    lhsFieldVal = '';
    operatorVal = '';
    rhsFieldVal = '';
    lhsFieldType = '';
    operatorsList = [];
    monitorVal=false;
    EligibilityVal=false;
    rhsDisplayCombo = false;
    rhsDisplayDate = false;
    rhsDisplayInput = false;
    @wire(getFieldTypeAndOperatorListWire, { objectAPIName: 'Program_Rule__c', fieldAPIName: 'Operator__c'}) wiredOperatorsByType;
    @wire(getObjectFieldsByTypeMapWire) wiredFieldsByType;
    get lhsObjectOptions() {
        console.log('inside lhsObjectOptions');
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Program', value: 'Program__c' },
        ];
    }
    get rhsObjectOptions() {
        console.log('inside rhsObjectOptions');
        return [
            { label: 'Static value', value: 'Static_value' },
            { label: 'Account', value: 'Account' },
            { label: 'Program', value: 'Program__c' },
        ];
    }
    lhsObjectChange(event) {
        console.log('inside lhsObjectChange');
        this.lhsObjectVal = event.detail.value;
        switch (this.lhsObjectVal) {
            case 'Account':
                this.lhsFieldsMap = this.wiredFieldsByType.data['AccountALL'];
                console.log('LHS filed map : ');
                console.log(this.lhsFieldsMap);
                break;
            case 'Program__c':
                this.lhsFieldsMap = this.wiredFieldsByType.data['Program__cALL'];
                break;
            default:
                break;
        }
    }

    rhsObjectChange(event) {
        console.log('inside rhsObjectChange');
        this.rhsObjectVal = event.detail.value;
        switch (this.rhsObjectVal) {
            case 'Account':
                this.rhsFieldsMap = this.wiredFieldsByType.data[this.rhsObjectVal+this.lhsFieldType];
                this.rhsDisplayCombo = true;
                this.rhsDisplayInput = false;
                this.rhsDisplayDate = false;
                break;
            case 'Program__c':
                this.rhsFieldsMap = this.wiredFieldsByType.data[this.rhsObjectVal+this.lhsFieldType];
                this.rhsDisplayCombo = true;
                this.rhsDisplayInput = false;
                this.rhsDisplayDate = false;
                break;
            case 'Static_value':
                switch (this.lhsFieldType) {
                    case 'BOOLEAN':
                        this.rhsFieldsMap = this.wiredFieldsByType.data[this.lhsFieldType];
                        this.rhsDisplayCombo = true;
                        this.rhsDisplayInput = false;
                        this.rhsDisplayDate = false;
                        break;
                    case 'DATETIME':
                        this.rhsDisplayCombo = false;
                        this.rhsDisplayInput = false;
                        this.rhsDisplayDate = true;
                        break;
                    default:
                        this.rhsDisplayCombo = false;
                        this.rhsDisplayInput = true;
                        this.rhsDisplayDate = false;
                        break;
                }
                break;
            default:
                this.rhsDisplayCombo = false;
                this.rhsDisplayInput = false;
                this.rhsDisplayDate = false;
                break;
        }
    }

    lhsFieldChange(event) {
        console.log('inside lhsFieldChange');
        this.lhsFieldVal = event.detail.value;
        let fieldData = this.lhsFieldVal.split('-');
        this.lhsFieldType = fieldData[1];
        this.operatorsList = this.wiredOperatorsByType.data[this.lhsFieldType];
        console.log('oplist '+JSON.stringify(this.operatorsList));
        console.log('lhsFieldVal '+this.lhsFieldVal);
        console.log('LHS filed Type'+this.lhsFieldType);
        console.log('LHS filed Type error'+JSON.stringify(this.wiredOperatorsByType.data));
    }

    rhsFieldChange(event) {
        console.log('inside rhsFieldChange');
        this.rhsFieldVal = event.detail.value;
    }
    operatorChange(event) {
        console.log('inside operatorChange');
        this.operatorVal = event.detail.value;
    }

 


    handleEligibilityChange(event) {
        console.log('inside Eligibility FieldChange'+event.detail.value);
        let i;
        let checkboxes = this.template.querySelector('[data-id="checkbox-eligblity"]')
        this.EligibilityVal = event.target.checked;
    
    }
    handleMonitorChange(event) {
        console.log('inside Monitor FieldChange'+ event.target.checked);
        let i;
        let checkboxes = this.template.querySelector('[data-id="checkbox-monitoring"]')
        this.monitorVal = event.target.checked;
    }
       
    //     this.monitorVal = event.detail.value;
    // }
    // monitorChange(event) {
    //     console.log('inside Monitor FieldChange'+event.detail.value);
    //     this.EligibilityVal = event.detail.value;
    // }
    programRuleCreateSubmit(event) {
        console.log('inside programRuleCreateSubmit');
       
        this.showSpinner = true;
        event.preventDefault();       // stop the form from submitting
        const programRuleData = event.detail.fields;
        let lhsFieldData = this.lhsFieldVal.split('-');
        let rhsFieldData = this.rhsFieldVal;
        if(this.rhsObjectVal != 'Static_value'){
            rhsFieldData = this.rhsFieldVal.split('-')[0];
            console.log('inside not : '+rhsFieldData);
        }
        else{
            programRuleData.Is_RHS_Static_Value__c = true;
            rhsFieldData=this.rhsFieldVal.trim().replaceAll(' ','_');
        }
        console.log('rhsFieldData out : '+rhsFieldData);
        programRuleData.Field_To_Compare_1__c = lhsFieldData[0];
        programRuleData.Field_Type__c = this.lhsFieldType;
        programRuleData.Operator__c = this.operatorVal;
        programRuleData.Field_To_Compare_2__c = rhsFieldData.toLowerCase();
        programRuleData.monitor__c =this.monitorVal;
        programRuleData.Eligibility__c =this.EligibilityVal;

        this.template.querySelector('lightning-record-edit-form').submit(programRuleData);
    }

    programRuleCreateSuccess(event) {
        console.log('inside programRuleCreateSuccess');
        this.showSpinner = false;
        this.handleReset(event);
        var msgData = [{url: "/"+event.detail.id, label: 'Click here'}];
        this.showToast('Success', 'Program rule created. {0}', msgData, 'success');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Program_Rule__c',
                actionName: 'view'
            },
        });
    }
    programRuleCreateError(event) {
        console.log('inside programRuleCreateError');
        this.showSpinner = false;
        //this.showToast('Error', event.detail.detail, null, 'error');
    }
    showToast(titleVar, messageVar, messageDataVar, variantVar) {
        console.log('inside showToast');
        this.dispatchEvent(new ShowToastEvent({
            title: titleVar,
            message: messageVar,
            messageData: messageDataVar,
            variant: variantVar
        }));
    }
    handleReset(event){
        console.log('inside handleReset');
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.lhsObjectVal = '';
        this.rhsObjectVal = '';
        this.lhsFieldVal = '';
        this.operatorVal = '';
        this.rhsFieldVal = '';
        this.lhsFieldType = '';
        this.operatorsList = [];
        this.rhsDisplayCombo = false;
        this.rhsDisplayDate = false;
        this.rhsDisplayInput = false;
        this.showSpinner = false;
    }
    handleCancel(event){
        console.log('inside handleReset');
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close }
        });
        this.dispatchEvent(closeclickedevt); 
    }
}