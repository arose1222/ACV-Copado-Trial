/**
 * @description Tile for the details of a list item
 * @name tracTerritoryFilterItem
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-02
 */

import {LightningElement,api, track} from 'lwc';
import { NavigationMixin} from 'lightning/navigation';

export default class TerritoryFilterItem extends NavigationMixin(LightningElement) {
    @api item; // record
    @api fields; // fields to display
    @api sobject; //type of object to display
    @track alarmClock = '\u23F0';

    get fieldList() {
        return this.fields !== undefined ? this.fields.split(",") : [];
    }

    

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.item.Work_Order__r.Id,
                objectApiName: this.sobject,
                actionName: 'view',
            },
        });
    }
}