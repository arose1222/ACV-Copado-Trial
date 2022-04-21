/* This is the LWC js controller for the BadgeBanner LWC
 * @author James Andre LaCour
*/
import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import ACVColors from '@salesforce/resourceUrl/acvColors';
import getBadges from '@salesforce/apex/BadgeBannerCont.getBadges';
/***********************JS Code**********************************/
export default class BadgeBanner extends LightningElement {
    // Variables set via Page
    @api recordId;
    // Screen Conditional Variables
    @track noBadges = false;
    // Badge Data
    badgeList = [];
    /***********************Intialization****************************/
    // Loads in the ACV Colors maintained in a static resource
    renderedCallback(){
        loadStyle(this, ACVColors);
    }
    // Gets badges and determines what it should/shouldn't show
    connectedCallback(){
        getBadges({recordId : this.recordId})
        .then( result => {
            var data = JSON.parse(result);
            var badgeSize = 'BadgeLarge';
            if( data.badgeList.length == 0 ){
                this.noBadges = true;
            }else if( data.badgeList.length > 1 ){
                badgeSize = 'slds-badge';
            }
            data.badgeList.forEach(badge => {
                badge.className = badgeSize + ' ' + badge.ACV_Preset_Colors__c;
                badge.styleName = 'background-color:' + badge.Background_Color__c + ';color:' + badge.Text_Color__c + ';';
            });
            this.badgeList = data.badgeList;
        })
        .catch( error => {
            console.log( JSON.stringify(error) );
        })
        .finally( () => {
        });
    }
}