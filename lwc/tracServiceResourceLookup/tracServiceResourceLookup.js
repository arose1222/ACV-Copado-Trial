/**
 * @description Lookup for service resource
 * @name tracServiceResourceLookup
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-10-17
 */

import {LightningElement,track,api} from 'lwc';
import getResources from '@salesforce/apex/tracRecurringEventController.getResources'

export default class ServiceResourceLookup extends LightningElement {
    @api timeline;
    @track initialSelection = [];
    @track errors = [];

    connectedCallback() {
        if(this.timeline.Service_Resource__c) {
            console.log('Service_Resource__c',this.timeline.Service_Resource__c);
            this.initialSelection = [
                {
                    id: this.timeline.Service_Resource__c,
                    sObjectType: 'ServiceResource',
                    icon: 'standard:service_resource',
                    title: this.timeline.Service_Resource_Name__c,
                    subtitle: 'Subtitle'
                }
            ];
        }
    }

    handleResourceLookup(e){
        getResources(e.detail)
            .then(results => {
                this.template.querySelector("c-lookup").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occurred while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                this.errors = [error];
            });
    }

    handleResourceChange() {
        let selectedValue = this.template.querySelector('c-lookup').getSelection();
        this.dispatchEvent(new CustomEvent('change', {detail: selectedValue[0]}));
    }
}