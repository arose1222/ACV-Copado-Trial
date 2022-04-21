/**
 * @description A panel to display record fields (like Highlight panel). Highligh panel could only display upto 7 fields. 
 * This component could be used if you like to display additional record fields.
 *
 * @name DisplayRecInfoPanel
 * @author Manmeet Vaseer
 * @date 05/25/2021
 * 
 */
import { LightningElement, api } from 'lwc';

export default class DisplayRecInfoPanel extends LightningElement {
    @api recordId;
    @api panelTitle;
    @api objectName;    
    @api fieldAPIName1;
    @api fieldAPIName2;
    @api fieldAPIName3;
    @api fieldAPIName4;
}