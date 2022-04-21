import LightningDatatable from 'lightning/datatable';
import auctionLights from './auctionLights.html'

export default class CustomDataTable extends LightningDatatable {    
    static customTypes = {
        auctionLights: {
            template: auctionLights,
            standardCellLayout: true,
            typeAttributes: [ 'lights' ]
        }
    };
}