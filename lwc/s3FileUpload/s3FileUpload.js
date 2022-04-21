import { api, LightningElement, track } from 'lwc';
import getAWSUploadPresignedS3Url from '@salesforce/apex/S3.generateUploadPresignedURL';
import insertObjects from '@salesforce/apex/S3.insertS3Objects';
import {createUUID, createSplunkLog, fireToast} from 'c/acvUtilHelper';
export default class S3FileUpload extends LightningElement {

    
    @api junctionObjectType;
    @api junctionObjectId;
    @api s3ReferenceType;
    @api s3Bucket;
    @api s3FilePath = '';

    @api allowMultiple = false;
    @api disableSObjectInsertion = false;
		@api acceptedExtensions = 'image/*';
		@api uploadButtonText = 'Upload Files';
		@api cdnUrl = '';


    uploadResults = [];
    insertionResults = [];
    
    @api fileResults(){
        console.log("File results called");
        console.log(this.uploadResults);
        return this.uploadResults;
    }
    
    @api insertResults(){
        console.log("insert results called");
        console.log(this.insertionResults);
        return this.insertionResults;
    }


    //All private varibles
    fileList = [];

    //elements of the finishedFileList have these variables: fileName, fileURL, file, guid
    @track finishedFileList = [];

    handleUpload(e){
        if(this.allowMultiple){
            this.fileList = e.target.files;
        }
        else{
            this.fileList = e.target.files;
        }
        this.generateURLLinks();
        
    }

    async generateURLLinks(){
        if(this.allowMultiple){
            for(var file of this.fileList){
                var uploadPath = this.s3FilePath+file.name;
                const url = await getAWSUploadPresignedS3Url({bucketName:this.s3Bucket, filePath:uploadPath});
                this.finishedFileList.push(this.createFileObject(file.name, url, file));
            }
        }
        else{
            const theFile = this.fileList[0];
            var uploadPath = this.s3FilePath+theFile.name;
            await getAWSUploadPresignedS3Url({bucketName:this.s3Bucket, filePath:uploadPath}, result => {
                this.finishedFileList.push(this.createFileObject(theFile.name, result, theFile));
            });
        }
    }



    uploadFiles(){

        for(var file of this.finishedFileList){
            //set files to uploading
            file.icon = 'utility:threedots';
            this.uploadFile(file);
        }

    }

    async uploadFile(finishedFile){

        await fetch(finishedFile.fileURL, {
            method: 'PUT',
            body: finishedFile.file
        })
        .then(response => {

            
            
            console.log('upload results');
            this.uploadResults.push(response);
            console.log(this.uploadResults);

            if(response.status === 200){
                
                createSplunkLog('INFO', 'successfully uploaded ' + finishedFile.fileName + ' to s3 bucket ' + this.s3Bucket, 's3FileUpload', ['ENTERPRISE_APPS']);
                finishedFile.icon = 'utility:success';
                //var insertReturn = insertObjects({s3Name:finishedFile.fileName, s3Type:this.s3ReferenceType, s3Url:this.cdnUrl + finishedFile.fileName, junctionObjectType:this.junctionObjectType, junctionObjectId: this.junctionObjectId});
                //console.log('insert results');
                //this.insertionResults.push(insertReturn);
								//console.log(this.insertionResults);
								
								insertObjects({s3Name:finishedFile.fileName, s3Type:this.s3ReferenceType, s3Url:this.cdnUrl + finishedFile.fileName, junctionObjectType:this.junctionObjectType, junctionObjectId: this.junctionObjectId}).then(message => {
                    message = JSON.parse(message);
                    console.log(message);
										var messageData = {
                        icon: "standard:brand",
                        id:  message.referenceId,
                        sObjectType: "S3_Reference__c",
                        subtitle: message.url,
                        title: message.name 
                		};
                    const selectEvent = new CustomEvent('supload', {
                    detail: messageData
												
                });
                    this.dispatchEvent(selectEvent);
                });
            }
            else{
                createSplunkLog('ERROR', 'failed to upload' + finishedFile.fileName + ' to s3 bucket ' + this.s3Bucket + '. Status: ' + response.status, 's3FileUpload', ['ENTERPRISE_APPS']);
                finishedFile.icon = 'utility:error';
            }

        })
        .catch(err =>{
            console.log(err);
            fireToast('Error', 'An unexpected error occurred with the S3 file upload component.', 'error', 'sticky');
            createSplunkLog('FATAL', 'An error occurred during file upload process: ' + err , 's3FileUpload', ['ENTERPRISE_APPS']);
            finishedFile.icon = 'utility:error';
        });
    }

    


    handleRemove(e){
        var removalGuid = e.currentTarget.dataset.key;
        var removalPosition;

        for(var i = 0; i < this.finishedFileList.length; i++){
            if(this.finishedFileList[i].guid === removalGuid){
                removalPosition = i;
                break;
            }
        }
        
        if(typeof removalPosition !== 'undefined'){
            this.finishedFileList.splice(removalPosition, 1);
        }
        
    }

    createFileObject(fileNameParameter, fileURLParameter, fileParameter){
        return {
            fileName : fileNameParameter,
            fileURL : fileURLParameter,
            file : fileParameter,
            guid: createUUID(),
            icon: 'utility:shift_pattern_entry'
        }
    }
}