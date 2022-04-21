/**
 * @description A component to display links of internal/external websites. It is available on Utility Bar and App.
 * It is configurable through Site_Links__c Custom Settings.
 *
 * @name SiteLinks
 * @author Manmeet Vaseer
 * @date 07/02/2021
 * 
 */
import { LightningElement, api, wire, track } from 'lwc';

import getSiteLinks from '@salesforce/apex/SiteLinksController.getSiteLinks';

export default class SiteLinks extends LightningElement {
    @api namespace;
    @api error;

    @track siteLinks = [];
    @track showError = false;

    @wire(getSiteLinks, {namespace: '$namespace'})
    wiredFieldValue({ error, data }) {
        var siteLinksPayload = [];
        if (data) {
            siteLinksPayload = data;
            this.error = undefined;
            for (var f = 0; f < siteLinksPayload.length; f++) {
                var obj = JSON.parse(siteLinksPayload[f]);
                this.siteLinks.push({
                    id: obj.Id,
                    url: obj.siteURL,
                    label: obj.siteName
                });
            }
        } else if (error) {
            this.showError = true;
            this.error = JSON.stringify(error);
            siteLinksPayload = undefined;
        }
    }

}