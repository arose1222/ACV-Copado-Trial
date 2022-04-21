import { LightningElement, api,track, wire } from 'lwc';
import getArbitrationrecords from '@salesforce/apex/ArbitrationFormController.getArbitrationrecords';

export default class ArbitrationForm extends LightningElement {
  @api recordId;
  @track formOptions =[];
  @track error;
  @track wiredgetarbitrations;
  @track claimNotes = 'Please provide details relevant to your desire to file a claim on the items(s) indicated above.';
  @track uploadFileHdr = 'Please provide relevant relevant photos to support.';
  @track getChildData = [];
  @track textValue = '';
  @track errormssg=false;
  @track Errormessage;
  @track errormssg1=false;
  @track Errormessage1;
  @track readingMaxLength = '7';
  @track numValue = '';
  
  @wire(getArbitrationrecords) arbitrations({data, error}){
    if(data) {
      for(let key in data) {
          if (data.hasOwnProperty(key)) { // Filtering the data in the loop
              this.formOptions.push({key: key, value: data[key]});
          }
      }
    }
    else if(error) {
        window.console.log(error);
    }
   
  }
  handleChildMethod(e){
    this.getChildData = e.detail;
  }
  textFieldChange(e){
    if(e.target.type == 'textarea'){
      this.textValue = e.target.value;
    }
  }
  handleReadingFormat(e){
    if(e.target.type == 'number' && e.target.value.length == this.readingMaxLength){
        this.numValue = e.target.value.slice(0,6) + '.' + e.target.value.slice(this.readingMaxLength-1);
      }
  }
  submitform(){
    var callmethod = true;
    var callmethod1 = true;
    if(this.getChildData.length === 0){
      this.errormssg = true;
      this.Errormessage = "You must indicate your reason(s) for claim submission via the above checkboxes. If you are unable to locate the issue you're looking for, please review the list of items not covered under policy here.";
      callmethod=false;
    }
    if(callmethod){
      this.errormssg = false;
    }
    if(this.textValue === ''){
      this.errormssg1 = true;
      this.Errormessage1 = "Please provide details regarding your issue(s) in the text box so that our team can best support you.";
      callmethod1=false;
    }
    
    if(callmethod1){
      this.errormssg1 = false;
    }
    }

}