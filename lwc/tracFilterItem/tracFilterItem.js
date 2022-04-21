/**
 * @description Filter list item
 * Displays value, annotates for selection and raises an event when the selection state changes
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-05
 */
import { LightningElement, api, track } from 'lwc';

export default class Trac_FilterItem extends LightningElement {

    @api name;
    @api value;
    @api label;
    @api selected = false;
    @track selectedclass;

    /**
     * @description sets the initial item selection on load
     */
    connectedCallback () {
        this.refreshSelected(this.selected);
    }

    /**
     * @description method for the parent filter list to refresh the selection of items.
     * This is used when a parent item is [un]selected and the children are automatically [un]selected as a result
     */
    @api refreshSelected (isSelected) {
        this.selected = isSelected;
        this.selectedclass = this.selected ? 'trac-is-selected slds-border_top slds-p-around_x-small' : 'trac-not-selected slds-border_top slds-p-around_x-small';
    }

    /**
     * @description handles the user action of [un]selecting the item
     */
    handleClick(event) {
        let isSelected = !(this.selected);
        this.dispatchEvent(new CustomEvent( 'selectitem', {detail : {value: this.value, name: this.name, selected: isSelected}}));
        this.refreshSelected(!this.selected);
    }
}