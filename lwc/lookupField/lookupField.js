/* eslint-disable no-console */
/**
 * @description : JS for LookupField Component to create a lookup field
 * @author      : Nitin Chandwani, Traction On Demand
 * @date        : 2020/03/12
 */
import { LightningElement, api, track } from 'lwc';
import getFilteredRecords from '@salesforce/apex/LookupFieldCtrl.getFilteredRecords';

export default class LookupField extends LightningElement {
@api sobjectApiName;
@api filterCriteria;
@api fieldName;
@api iconName;
@api label;
@api recordId;
@api fieldsToReturn;
@api defaultValue;
@api componentId;
@api parentRecordId; 
//by default we are considering lookup to be not required
@api requiredFlag = false;

@track lookupResult;
@track filterValue;

@api checkValidity() {
        var inputCmp = this.template.querySelector(".inputCmp");
        return inputCmp.reportValidity();
    }

    /**
     * @description  Connected Callback
     */
    connectedCallback(){
        if( this.defaultValue !== "" ){
            this.filterValue = this.defaultValue;
        }
    }

    /**
     * @description  Handle Change method to filter records and display lookup
     * @param    event
     */
    handleOnChange( event ){
        console.log('::::::  updated 1 more 1 filterCriteria'+ this.filterCriteria);
        let filterValue = event.target.value;                 
        if( filterValue != null && filterValue.length > 2 ){
            getFilteredRecords({
                sobjectApiName : this.sobjectApiName,
                fieldsToReturn : this.fieldsToReturn,
                filterValue : filterValue,
                filterCriteria : this.filterCriteria,
                parentObjectId : this.parentRecordId
            }).then( (result) =>{
                this.lookupResult = JSON.parse(result);
            this.template.querySelector('[data-id="'+ this.lookupListId + '"').classList.remove("slds-hide");
        }).catch((error) => {
                console.log( 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message);
        });
        } if( filterValue == '' ) {
            this.lookupResult = [];
            this.template.querySelector('[data-id="'+ this.lookupListId + '"').classList.add("slds-hide");
            this.recordId = '';
            this.fireEvent();
        } else {
            this.lookupResult = [];
            this.template.querySelector('[data-id="'+ this.lookupListId + '"').classList.add("slds-hide");
            //this.template.querySelector('[data-id="'+ this.inputFieldId + '"').value = "";
        }
    }

    /**
     * @description  Handle Select method to populate lookup and fire an event
     * @param    event
     */
    handleSelect( event ){
        event.preventDefault();
        this.recordId = event.currentTarget.dataset.id;
        this.filterValue = event.currentTarget.dataset.label;
        this.template.querySelector('[data-id="'+ this.lookupListId + '"').classList.add("slds-hide");
        this.template.querySelector('[data-id="'+ this.inputFieldId + '"').value = this.filterValue;
        this.fireEvent();
    }

    fireEvent(){
            const event = new CustomEvent('lookupchange', {
            detail: {
                targetRecord : this.componentId,
                recordId: this.recordId,
                fieldName: this.fieldName,
            }
        });

            this.dispatchEvent(event);
    }

    handleOnBlur( eventDetail ){

        this.blurTimeout = setTimeout( () =>  {
            this.template.querySelector('[data-id="'+ this.lookupListId + '"').classList.add("slds-hide");
            if (
                this.recordId == '' ||
                (
                    typeof this.lookupResult !== 'undefined'
                    && typeof this.lookupResult.length !== 'undefined'
                    && this.lookupResult.length == 0
                )
            ) {
                this.template.querySelector('[data-id="' + this.inputFieldId + '"').value = '';
            }
    }, 300 );
    }

    get lookupListId(){
        return this.componentId + this.fieldName + "_dropdown";
    }

    get inputFieldId(){
        return this.componentId + this.fieldName + "_input";
    }
}