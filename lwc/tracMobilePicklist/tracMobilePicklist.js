/**
 * @description Piclist that uses the native html select option so that mobile devices use their native selection tool
 * @name tracMobilePicklist
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-06
 */

import { LightningElement, api } from 'lwc';

export default class MobilePicklist extends LightningElement {
    @api options;
    @api includeFirstNull = false;
    @api firstOptionPlaceholder = 'Select an option';

    connectedCallback() {

    }

    handleSelect(e) {
        // let asdf = e.path;
    }

    handleChange(e) {
        this.dispatchEvent(new CustomEvent('valuechange',{detail: this.template.querySelector('select')}));
    }

}