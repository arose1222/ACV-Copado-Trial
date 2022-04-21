import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import generateExistingGroups from '@salesforce/apex/groupingController.generateExistingGroups';
import createNewGroup from '@salesforce/apex/groupingController.generateNewGroup';

export default class GroupingHelper extends NavigationMixin(LightningElement) {
    @track options = [];
    _selected = [];

    async connectedCallback(){
        this.options = JSON.parse(await generateExistingGroups());
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    navigateToRecordViewPage(newRecordID) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: newRecordID,
                objectApiName: 'Group__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    async handleSuccess(event) {

        var groupWrapper = this.createGroupWrapper(event.detail.id);
        var wrapperString = JSON.stringify(groupWrapper);
        await createNewGroup({inputString:wrapperString}).then(result=>{
            this.navigateToRecordViewPage(event.detail.id);
        });
        this.generateCloseEvent();
    }

     handleChange(e) {
        this._selected = e.detail.value;
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this._selected = [];
     }

     createGroupWrapper(newGroupId){
        return {
            groupId : newGroupId,
            groupList : this._selected
        };
     }

    generateCloseEvent(){
        var close = true;
        const closeEvent = new CustomEvent('closeEvent',{ detail : close});
        this.dispatchEvent(closeEvent);
      }
}