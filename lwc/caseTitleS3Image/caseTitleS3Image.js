import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import S3 from "@salesforce/apex/S3.getPreSignedFileUrl";
import IMAGESLOCATION from "@salesforce/schema/Case.Image_Location__c";
import QC_IMAGESLOCATION from "@salesforce/schema/Quality_Control__c.Case__r.Image_Location__c";

import getS3ImageLocationHistory from '@salesforce/apex/CaseTitleS3ImageController.getS3ImageLocationHistory';
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

export default class CaseTitleS3Image extends LightningElement {
  @api fieldList = [IMAGESLOCATION];

  @track showError = false;

  @api recordId;

  @api options = [];
  @api pdfUrl;  

  /* lwc configured parameters  */
  @api isQualityControl = false;

  connectedCallback(){
    if(this.isQualityControl == true) this.fieldList = [QC_IMAGESLOCATION];
  }    

  @wire(getRecord, { recordId: "$recordId", fields: '$fieldList' })
  wireExcpetion({ error, data }) {
    if (data) {
      (async () => {
        this.record = data;

        let link = null;
        if(this.isQualityControl == true)  link = await getFieldValue(this.record, QC_IMAGESLOCATION);
        else  link = await getFieldValue(this.record, IMAGESLOCATION);

        this.pdfUrl = await S3({ url: link });
        this.template.querySelector("c-show-pdf-by-url").setUrl(this.pdfUrl);
      })();
    } else if (error) {
      (async () => {
        this.record = error;

        let link = null;
        if(this.isQualityControl == true)  link = await getFieldValue(this.record, QC_IMAGESLOCATION);
        else  link = await getFieldValue(this.record, IMAGESLOCATION);

        this.template.querySelector("c-show-pdf-by-url").setUrl(link);
      })();
    }
  }

  @wire(getS3ImageLocationHistory, { recordId: '$recordId', isQualityControl: '$isQualityControl'})
  wiredFieldValue({ error, data }) {
    var pdfFiles = [];
    if (data && data.length > 0) {
          pdfFiles = data;
          this.error = undefined;
          // Save the first related PDF's file ID to fileID            
          const fileIDs = Object.keys(data);
          this.fileID =  fileIDs.length ? fileIDs[0] : undefined; 

        const titlesHist = [];
        for(var f = 0; f < pdfFiles.length; f++)  {
          var obj = JSON.parse(pdfFiles[f]);
          titlesHist.push({
            value: obj.s3URL,
            label: obj.lastModifiedDate,
            description: obj.description
          });
        }
        
        this.options = titlesHist;
  
      } else if (error) {
          this.error = error;
          pdfFiles = undefined; 
          this.fileID = undefined; 
      }
  }

  handleChange(event) {
    // Get the string of the "value" attribute on the selected option
    (async () => {
      var titleUrl = await S3({ url: event.detail.value }); 
      this.template.querySelector("c-show-pdf-by-url").setUrl(titleUrl);
    })();        


}  
}