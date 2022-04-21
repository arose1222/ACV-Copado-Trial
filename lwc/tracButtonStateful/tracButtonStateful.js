/**
 * @description Button Stateful
 * @name tracButtonStateful
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-22
 */

import {LightningElement,api,track} from 'lwc';

export default class ButtonStateful extends LightningElement {
    @api identifier;
    @api labelWhenOff;
    @api labelWhenOn;
    @api selected;
    @api buttonClass;
    @api isDynamic;

    baseClasses;
    buttonStyleOff = ' slds-button_neutral ';
    buttonStyleOn;

    connectedCallback() {
        this.buttonStyleOn = this.isDynamic ? ' slds-button_brand ' : this.buttonStyleOff;
        this.baseClasses = ' slds-button slds-button_stretch custom-button ' + this.buttonClass + ' ';
    }

    get classes() {
        return this.selected ? this.baseClasses + this.buttonStyleOn : this.baseClasses + this.buttonStyleOff;
    }

    get label() {
        return this.selected ? this.labelWhenOn : this.labelWhenOff;
    }

    handleClick(e) {
        this.dispatchEvent(
            new CustomEvent('toggle', {
                detail: {
                    id: this.identifier, selected: !this.selected
                }
            }));

    }

}