import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { LightningElement,api, wire } from 'lwc';
import getPreSignedUrl  from '@salesforce/apex/S3.getPreSignedFileUrl'
export default class S3FileView extends LightningElement {
    @api recordId
    @api objectApiName
    @api s3LinkFieldApiName
    @api title = 'S3 Doc'
    record
    fields
    errorMessage
    connectedCallback(){
        this.fields = [this.objectApiName+'.'+this.s3LinkFieldApiName]
    }
    @wire(getRecord,{recordId:'$recordId', fields:'$fields'})
    getRecordInfo({data,error}){
        // console.log(this.recordId)
        // console.log(this.objectApiName)
        // console.log(this.s3LinkFieldApiName)
        // console.log(error);
        if(data){
            (async() => {
                console.log(data)
                let s3Link = getFieldValue(data,this.objectApiName+'.'+this.s3LinkFieldApiName)
                console.log(s3Link)
                //let preSignedUrl = await getPreSignedUrl({url: s3Link})
                try{
                    let preSignedUrl =  await getPreSignedUrl({url: s3Link})
                    console.log(preSignedUrl)
                    this.template.querySelector('c-show-pdf-by-url').setUrl(preSignedUrl)
                }
                catch(ex){
                    console.error(ex)
                    this.errorMessage = ex.body.message
                }
            })()

            // (async () => {
            //     this.record = data;
            //     let link = await getFieldValue(this.record, IMAGESLOCATION);
            //     this.pdfUrl = await S3({url: link});
            //     this.template.querySelector('c-show-pdf-by-url').setUrl(this.pdfUrl);
            // })();
        }
        if(error){
            this.errorMessage = 'Failed to get the S3 Link. Please Contact you Admin'
        }
    }
}