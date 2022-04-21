import { LightningElement, api, wire, track } from 'lwc';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import getProgramAndContactDetails from '@salesforce/apex/DealerProgramApplicationController.getProgramAndContactDetails';
import getContentDetails from '@salesforce/apex/DealerProgramApplicationController.getContentDetails';
import submitApplication from '@salesforce/apex/DealerProgramApplicationController.submitApplication';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import group12Resource from '@salesforce/resourceUrl/Group_12'; 
import group11Resource from '@salesforce/resourceUrl/Group_11';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

const columns = [
    { label: 'Title',       fieldName: 'Title', wrapText : true,
        cellAttributes: { 
            iconName: { fieldName: 'icon' }, iconPosition: 'left' 
        }
    },
    { label: 'Created Date',  fieldName: 'CreatedDate',
        cellAttributes: { 
            iconName: 'standard:date', iconPosition: 'left' 
        }
    } 
];
/*
const columns = [
    { label: 'Title',       fieldName: 'Title', wrapText : true,
        cellAttributes: { 
            iconName: { fieldName: 'icon' }, iconPosition: 'left' 
        }
    },
    { label: 'Created By',  fieldName: 'CREATED_BY',
        cellAttributes: { 
            iconName: 'standard:user', iconPosition: 'left' 
        }
    },
    { label: 'File Size',   fieldName: 'Size' },
    { label: 'Preview', type:  'button', typeAttributes: { 
            label: 'Preview',  name: 'Preview',  variant: 'brand-outline',
            iconName: 'utility:preview', iconPosition: 'right'
        } 
    },
    { label: 'Download', type:  'button', typeAttributes: { 
            label: 'Download', name: 'Download', variant: 'brand', iconName: 'action:download', 
            iconPosition: 'right' 
        } 
    },
    { label: 'Delete', type:  'button', typeAttributes: { 
            label: 'Delete',   name: 'Delete',   variant: 'destructive',iconName: 'standard:record_delete', 
            iconPosition: 'right' 
        } 
    } 
];
*/

export default class DealerProgramApplication extends NavigationMixin(LightningElement) {
    @api listGroup;
    @api recordId;
    @api objectApiName
    @api contactRecord;
    @api programEnrollmentRecord;
    @api programRecord;
    @api isLinkExpired;
    @api isApplicationSuccess;
    @track programRuleAssignments;
    @api conditionAcceptanceCount;
    @api accntId;
    @api prgId;
    @api primaryContactId;
    @api programEnrollmentId;
    @api error;   
    @api isError;
    @track isRecordLoaded;
    @track isRecordLoading; 
    isLoading = false;
    isSubmitting = false;
    @track dataList;
    @track columnsList = columns;
    @track isModalVisible;
    @track isApplicationSubmitted;
    @track group12Resourceurl;
    @track group11Resourceurl;
    @track selectedRuleId;
    @track divOffset;
    @track isRuleSelected;
    @api submitButtonClass;
    @track selectedRuleName;

    strName;
    strAccountNumber;
    strPhone;
    idAccount;
    
    group12Resourceurl = group12Resource;
    group11Resourceurl = group11Resource;
    connectedCallback() {
        //isLoading = true;
        this.submitButtonClass = 'unclickedSubmitButton slds-float_right';
        this.isSubmitClicked = false;
        this.isRuleSelected = false;
        this.isRecordLoaded = false;
        this.isRecordLoading = true;
        this.isError = false;
        var url = window.location.href;
        var urlSplit = url.split('?');
        var parametersSplitOnAND = urlSplit[1].split('&');
        this.accntId = parametersSplitOnAND[0].split('=')[1];
        this.prgId = parametersSplitOnAND[1].split('=')[1];
        this.primaryContactId = parametersSplitOnAND[2].split('=')[1];
        this.programEnrollmentId = parametersSplitOnAND[3].split('=')[1];
        console.log('@@@@CallBack Over----');
        console.log('@@@@this.accntId----',this.accntId);
        console.log('@@@@this.prgId----',this.prgId);
        console.log('@@@@this.primaryContactId----',this.primaryContactId);
        console.log('@@@@this.programEnrollmentId----',this.programEnrollmentId);
        getProgramAndContactDetails({ programId: this.prgId, accountId: this.accntId, primaryContactId: this.primaryContactId, recordId: this.programEnrollmentId})
        .then(result => {
            if (result) {
				console.log('@@@@result----',{...result});
                console.log('@@@@result.programRecord Outside If----',result.programRecord);
                this.isLinkExpired = false;
                this.isRecordLoaded = true;
                this.isRecordLoading = false;
                if(result.isLinkExpired == true){
                    console.log('@@@@Link Expired----');
                    this.isLinkExpired = true;
                    this.programEnrollmentRecord = result.programEnrollmentRecord;        
                } else {
                    console.log('@@@@ Mi else madhe alo ');
                    this.programRecord = result.programRecord;
                    console.log('@@@@result.programRecord----',result.programRecord);
                    //console.log('@@@@this.programRecord----',this.programRecord);
                    if(this.programRecord.Active__c == false){
                        this.error = "The Program You are applying for is no more a active program....";
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'The Program You are applying for is no more a active program....',
                                message: error.body.message,
                                variant: 'error',
                            }),
                        );
                    }
                    this.contactRecord = result.contactRecord;
                    this.programEnrollmentRecord = result.programEnrollmentRecord;   
                    /*if(this.programEnrollmentRecord.No_Of_Days_Since_Invitation_Sent__c  > 7){
                        this.error = "The Program You are applying for is no more a active program....";
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'The Program You are applying for is no more a active program....',
                                message: error.body.message,
                                variant: 'error',
                            }),
                        );
                    }*/
                    console.log('@@@@programEnrollmentRecord----',this.programEnrollmentRecord);
                    //this.programRuleAssignments = data.programRuleAssignments;
                    this.programRuleAssignments = result.programRuleAssignmentAndAcceptanceList;       
                    this.dataList = result.contentVersionList;  
                    this.isRecordLoaded = true;
                    this.isRecordLoading = false;
                    //this.error = undefined;
                }
			} else if (error) {
				console.log('@@@@error----',error);
				this.error = error;
				this.programRecord = undefined;
				this.contactRecord = undefined;
				this.programRuleAssignments = undefined;
			}
        })
        .catch(error => {
            this.error = error;
            this.programRecord = undefined;
        });
    }       

    get backgroundStyle() {
        return "height:50rem;background:url(${submitButtonResource})";
    }

    handleRuleSelection(event) {
        this.isRuleSelected = true;
      // this.selectedRuleId = event.target.dataset.name;
      this.selectedRuleId = event.currentTarget.id;

     
     console.log('@@@@selectedRuleId----'+this.selectedRuleId);  
   
      this.divOffset=this.template.querySelector('.scrollDiv').offsetTop;
       // alert(this.divOffset);
        var selectedruledesc=this.selectedRuleId.split('-');
        
        var ruleOffset=this.template.querySelector('.'+selectedruledesc[0]).offsetTop;
       // alert(ruleOffset- this.divOffset);
        this.template.querySelector('.scrollDiv').scrollTop=(ruleOffset- this.divOffset);
      


    }
    
    handleSubmitClick(event) {
        //isLoading = true;
        this.isSubmitClicked = true;
        event.preventDefault();
        this.isError = false;
        this.isModalVisible = false;
        var isTermsSelected = this.template.querySelectorAll('[data-id="checkbox"]')[0].checked;
        this.submitButtonClickedCSS();
        if(isTermsSelected){
            this.isSubmitting = true;

            this.handleSaveClick();
            this.isSubmitting = false;
            let message = {
                "message" : 'Success'
            }
        } else {
            this.isSubmitClicked = false;
            this.isSubmitting = false;
            this.isError = true;
            this.error = "This Field is Required";
        }
    }
    
    submitButtonClickedCSS() {
        this.submitButtonClass = 'clickedSubmitButton slds-float_right';           
    }
    /*
    submitButtonHoverCSS() {
        this.submitButtonClass = 'hoveredSubmitButton slds-float_right';         
    }
    */
    checkAllSelected() {
        var conditionCheckedCount = 0;
        let i;
        //COde could be changed as per class instead of data-id
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');

        for(i=0; i<checkboxes.length; i++) {
            if(checkboxes[i].checked){
                conditionCheckedCount += 1;
            }
        }
        return (conditionCheckedCount == this.programRuleAssignments.length) ? true : false;           
    }
    
    /*handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles---',{...uploadedFiles});
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'File Uploaded Successfully!!!',
                variant: 'success',
            }),
        );
    }*/
    handleUploadFinished(event){    
        //this.isRecordLoaded = false;
        console.log('@@@@inside handleUploadFinished----');
        console.log('@@@@programEnrollmentId----',this.programEnrollmentId);
        getContentDetails({recordId: this.programEnrollmentId})
            .then(result => {                
                this.dataList = result;
                //show success message                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File Uploaded Successfully!!!',
                        variant: 'success',
                    }),
                );
                this.isRecordLoaded = true;
                console.log('@@@@ before isRecordLoading set to false');
                this.isRecordLoading = false;
                console.log('@@@@ after isRecordLoading set to false');
            })
            .catch(error => {
                //show error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'There is a problem in uploading a File!!!',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });            
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Get Help',
            message: 'Salesforce documentation is available in the app. Click ? in the upper-right corner.',
        });
        this.dispatchEvent(event);
    }
    handlePrimaryButtonClick() {
        /*eslint-disable no-console */
        console.log('Inside ModalContainer.handlePrimaryButtonClick()');
        this.isModalVisible = false;
    }

    handleNavigate() {
        var compDefinition = {
            componentDef: "c:applicationSuccess",
            attributes: {
                propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:  encodedCompDef
            }
        });
    }

    /*
        handler to perform save operation.
        save signature as attachment.
        after saving shows success or failure message as toast
    */
   @api handleSaveClick(){    
        console.log('@@@@inside handleSaveClick----');       
        
        //call Apex method imperatively and use promise for handling sucess & failure
        console.log('@@@@parentId----',this.programEnrollmentId);
        //if(!this.isSignatureBlank){
            submitApplication({parentId: this.programEnrollmentId})
                .then(result => {
                    this.isApplicationSubmitted = result;
                    this.isSubmitting = false;
                    this.isRecordLoaded = false;
                    this.isRecordLoading = false;
                    //show success message
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Application for the program submitted successfully!!!!',
                            variant: 'success',
                        }),
                    );*/
                })
                .catch(error => {
                    //show error message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'There is a problem while submittin the application',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        /*} else {
            console.log('Signature is not defined');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Signature is required in order to submitt the application....',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }  */ 
    }

    /*@wire(getRecord, {recordId:'$accntId', fields: arrFields})
    accountRecordNew;   

    @wire(getContactCustom, { accountId: '$accntId', programId: '$prgId'})
    wiredFlows({ error, data }) {
        if (data) {
            this.contactRecord = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactRecord = undefined;
        }
    }*/

    
    /*
    @wire(getContentDetails, { recordId: '$parentId'})
    wiredFlows({ error, data }) {
        //isLoading = true;
        if (data) {
            console.log('@@@@data----',{...data});
            this.dataList = data;
        } else if (error) {
            console.log('@@@@error----',error);
            this.error = error;
        }
    }
    */
    /*
    handleAcceptanceCheck(event) {
        let rowId = event.currentTarget.getAttribute('data-id');
        this.programRuleAssignments.forEach(programRuleAssignment => {
            if(rowId === programRuleAssignment.programRuleAssignment.Id){
                try{
                    programRuleAssignment.ruleAcceptance = true;
                } catch(e) {
                    console.log('Exception',e);
                }
            }
        });
    }
    */

    /*renderedCallback(){
        loadScript(this, JQuery)
        .then(() => {
            console.log('JQuery loaded.');
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }*/
}