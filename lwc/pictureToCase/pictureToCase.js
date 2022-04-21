/* eslint-disable no-console */
import {LightningElement, api, track} from 'lwc';
import getSAPUrl from '@salesforce/apex/AuctionAPI.getSAPUrl';

export default class pictureToCase extends LightningElement {
    @api hover = false;
    @api singleLink = '';
    @api imgList = [];
    @track displayList = [];
    @track selectedImage;
    @api recordId
    @track result;
    @track openmodel = false;
    imageZoomEnabled = false;
    @track showError = false;
    imageSet = ['odometer', 'vin_plate', 'vin_sticker'];
    vehicleInfo = [];


    async renderedCallback(){
        this.vehicleInfo = await getSAPUrl({recordId: this.recordId, imageSet: this.imageSet});    
        if(this.vehicleInfo.length>0){
            this.template.querySelector('c-image-display').populateImageList(this.vehicleInfo);
        }
    }  

}