/* eslint-disable vars-on-top */
/* eslint-disable no-alert */
/* eslint-disable no-console */

import { LightningElement, wire, api, track} from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import Salesforce_Request__cId from '@salesforce/schema/Salesforce_Request__c.Id';
import getBoards from '@salesforce/apex/TransferTicketController.getBoards';
import postToBoard from '@salesforce/apex/TransferTicketController.postToBoard';
import jiraLink from '@salesforce/schema/Salesforce_Request__c.Jira_Link__c';
import getStatus from '@salesforce/apex/TransferTicketController.getStatus';
import postComment from '@salesforce/apex/TransferTicketController.postComment';
import description from '@salesforce/schema/Salesforce_Request__c.Additional_Details_Regarding_My_Request__c';



const fieldList = [
    Salesforce_Request__cId, 
    jiraLink,
    description
];


export default class TransferTicket extends LightningElement {

    @track openmodel = false;
    @track showSendButton = false;
    @track showBox = false;
    @api recordId;
    @wire(getRecord,{recordId:'$recordId', fields:fieldList})Salesforce_Request__c;
    selectedOption;
    selectedIssue;
    commentToSend;
    @track optionsList = [];
    @track issueList = [];
    @track shownIssueList = [];
    @track fullCommentList = [];
    @track status = [];
    @track updatedJiraAssignee;
    urlKey;
    updatedJiraSummary;
    updatedJiraDescription;

    async connectedCallback(){

        const jsonData = await getBoards();
        if(jsonData !== 'Jira endpoint not reached'){
            var jsonDataObject = JSON.parse(jsonData);       
            var jiraURL = getFieldValue(this.Salesforce_Request__c.data, jiraLink);

            if(jiraURL){

                this.showBox = true;
                var splitUrl = jiraURL.split('/');
                this.urlKey = splitUrl[splitUrl.length-1];
                const jiraStatus = await getStatus({inputId:this.recordId, inputKey:this.urlKey});

                var jiraStatusObject = JSON.parse(jiraStatus);
                this.status = 'Status: ' + jiraStatusObject[0].name;
                this.updatedJiraAssignee = 'Jira Assignee: ' + jiraStatusObject[0].jiraAssignee;
                this.updatedJiraSummary = jiraStatusObject[0].summary;
                this.updatedJiraDescription = jiraStatusObject[0].description;
                jiraStatusObject[0].jiraCommentProjectLst.forEach(x=>{
                    var tempVar = {value:x.author, label:x.comment};
                    this.fullCommentList.push(tempVar);
                });
            }
            else{
                this.showSendButton = true;
            }
            
            jsonDataObject.forEach(x=>{
                var tempVar = {value:x.key,label:x.name};
                this.optionsList.push(tempVar);
                this.issueList.push({key: x.key, issues: x.issueTypeKeyLst});
            });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failure',
                    message: 'Jira endpoint not reached.',
                    variant: 'error'
                })
    
            );
        }
    }

    handleSendClick(){
        this.openmodel = true;
    }

    handleUpdateClick(){
        //Updates description field in SF
        const fields = {};
        fields[Salesforce_Request__cId.fieldApiName] = getFieldValue(this.Salesforce_Request__c.data, Salesforce_Request__cId);
        fields[description.fieldApiName] = this.updatedJiraDescription;
        const recordUpdate = {fields};
        updateRecord(recordUpdate).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Fields Updated',
                    variant: 'success'
                })
    
            );
            this.loaded = true;
            this.showscreen1 = false;
            this.error = false;
                            
            // Display fresh data in the form
            return refreshApex(this.Salesforce_Request__c);
        })
        

    }

    //**************************************************************
    handleCommentChange(event){
        this.commentToSend = event.target.value;
    }

    async handleCommentSendClick(){
        const postResponse = await postComment({inputKey:this.urlKey, commentText:this.commentToSend});
        
        if(postResponse==='Comment Posted'){
            location.reload();
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: 'Failed to post comment',
                    variant: 'error'
                })
            );
        }

    }
    //**************************************************************

    

    handleChange(event) {
        this.selectedOption = event.detail.value;
        
        this.issueList.forEach(x=>{
         
            if(x !== undefined && x.key===event.detail.value){             
                var tempIssVar = [];
                x.issues.forEach(y=>{                 
                    tempIssVar.push({value:y, label:y});
                })                
                this.shownIssueList=tempIssVar;
                
            }

        })
    }

    handleIssueChange(event){
        this.selectedIssue = event.detail.value;
    } 

    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    }
    
    async sendTicketToJira(){
        if(this.recordId && this.selectedIssue && this.selectedOption) {
            this.openmodel = false;
            var posted = await postToBoard({inputId:this.recordId, inputOption:this.selectedOption, inputIssue:this.selectedIssue});
            if(posted===201){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Jira Ticket Created',
                        variant: 'success'
                    })
                );
               
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed',
                        message: 'Please try to send again',
                        variant: 'error'
                    })
                );
            }


        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: 'Must select Board and Issuetype',
                    variant: 'error'
                })
            );
        }
    }
    
}