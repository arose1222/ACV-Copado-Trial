import { LightningElement, track, wire, api } from 'lwc';
import getArbitrationrecords from '@salesforce/apex/ArbitrationFormController.getArbitrationrecords';
import getSequenceNumbers from '@salesforce/apex/ArbitrationFormController.getSequenceNumbers';

export default class ArbitrationForm extends LightningElement {
  @track formOptionsCol1 =[];
  @track formOptionsCol2 =[];
  @track error;
  @track selectedRecords = [];
  @track allData =[];

  @wire(getSequenceNumbers) arbitrations1(data){
    if(data){
      getSequenceNumbers()
      .then((result) => {
        this.allData = result;
      })
      console.log('sequence resulits11', JSON.stringify(data));
      console.log('sequence resulits11', JSON.stringify(this.allData));
    }
  } 
  @wire(getArbitrationrecords) arbitrations({data, error}){
    if(data) {
      getSequenceNumbers()
        .then((result) => {
          this.allData = result;
        })
        console.log('sequence resulits', JSON.stringify(this.allData));
      var i=1;
      var seq;
      for(let key in data) {
          // Preventing unexcepted data
          if (data.hasOwnProperty(key)) { // Filtering the data in the loop
            console.log('sequence number', data[key][0].Sequence__c);
              var mod1 = i%2;
              if(mod1 == 1)
                this.formOptionsCol1.push({key: key, value: data[key]});
              else
                this.formOptionsCol2.push({key: key, value: data[key]});
              i++;
          }
      }
    }
    else if(error) {
        window.console.log(error);
    }
  }
  
  @api handleChanges(e){
    console.log('CheckedORunchecked',e.target.checked);
    if(e.target.type == 'checkbox'){
      if(e.target.checked){
        this.selectedRecords.push(e.target.checked);
        console.log('sizewhen cheked',this.selectedRecords.length);
      }
      else {
        this.selectedRecords.splice(e.target.checked);
        console.log('sizewhen unchecked',this.selectedRecords.length);
      }
        }
        const custEvent = new CustomEvent(
          'callpasstoparent', {
              detail: this.selectedRecords
          });
          console.log('custEvent',custEvent);
      this.dispatchEvent(custEvent);
        
  }
}