/* eslint-disable eqeqeq */
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable vars-on-top */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import getOpportunities from '@salesforce/apex/DealMakerView2.getOpportunities';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi'
import NOTES_FIELD from '@salesforce/schema/Opportunity.Auction_Notes_2__c';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name'
import search from '@salesforce/apex/DealMakerView2.searchTheTerm';
import filterSave from '@salesforce/apex/DealMakerView2.filterSave';
import loadFilter from '@salesforce/apex/DealMakerView2.loadFilterList';
import getSellerInfo from '@salesforce/apex/DealMakerView2.getSellerInfo';
import getBuyerInfo from '@salesforce/apex/DealMakerView2.getBuyerInfo';
import getVehicleInfo from '@salesforce/apex/DealMakerView2.getVehicleInfo';
//import notesSave from '@salesforce/apex/DealMakerView2.notesSave';

const fieldList = [
    'Opportunity.Id'
];

export default class oppSearch extends LightningElement {
    @track rows = [];
    @track sellRow;
    @track buyRow;
    @track vehRow;
    @track searchTerm = [];
    @track loading = false;
    @track yourSelectedValues;
    @api recordId;
    @track buyDealUrl;
    @track sellDealUrl;
    @track initialSelection = [];
    @track errors = [];
    isMultiEntry = true;
    @track filteredRows = [];
    @track openmodelBuyerInfo = false;
    @track openmodelSellerInfo = false;
    @track openmodelVehicleInfo = false;
    @wire(getRecord,{recordId:'$recordId', fields:fieldList})opportunity; //????????


    async  connectedCallback() {
        this.buildTable();
    }

   async buildTable(){
        const loadResult = await loadFilter();
        if (loadResult.length != 0){
            this.initialSelection = loadResult;
            loadResult.forEach(item => this.searchTerm.push(item.id));
            this.loading = !this.loading;
            await this.buildOppsObj();
            this.loading = !this.loading;
        }
        else{
            this.loading = !this.loading;
            await this.buildOppsObj();
            this.loading = !this.loading;
        }
    }

    async refreshPage(){
        location.reload();  
        //await this.connectedCallback();
    }

    //method that builds the rows for the deal maker page
    async buildOppsObj(){
        let rows_tmp = [];
        this.rows = [];
        this.createData();
        this.createData2();
        this.createData3();
        const data = await getOpportunities({searchTerm:JSON.stringify(this.searchTerm)});
        //this.loading = !this.loading;
        for (let i = 0; i < data.length; i++) {
            let an2 = null;
            //manually gets the buyer dealership url that users can click on in the component to take them directly to the account
            // if (data[i].Buyer_Dealership__c != null && data[i].Buyer_Dealership__r.Id != null) {
            //     var buyDealUrl = 'https://acvauctions.lightning.force.com/lightning/r/Account/'+data[i].Buyer_Dealership__r.Id+'/view';
            // }
            //manually gets the seller dealership url that users can click on in the component to take them directly to the account
            //if (data[i].Seller_Dealership__c) {
            //   var sellDealUrl = 'https://acvauctions.lightning.force.com/lightning/r/Account/'+data[i].Seller_Dealership__c+'/view';
            //}
            //manually gets the seller ist url that users can click on in the component to take them directly to the user
            if (data[i].Seller_IST__c) {
                var sellIstUrl = 'https://acvauctions.lightning.force.com/lightning/r/User/'+data[i].Seller_IST__c+'/view';
            }
            if (data[i].Buyer_IST__c) {
                var buyISTUrl = 'https://acvauctions.lightning.force.com/lightning/r/User/'+data[i].Buyer_IST__c+'/view';
            }
            //high bid reformatted with $
            //var highBidSo = data[i].High_Bid__c;
            var highBidCur = '$'+data[i].High_Bid__c;
            var varIn$ = '$'+data[i].Price_Variance__c;
            //formula to get the price variance % and reformatted
            var priVarPercentage = ((data[i].Floor_Value__c-data[i].High_Bid__c)/data[i].Floor_Value__c);
            var priVarPercentageRound = (priVarPercentage*100).toFixed(2)+'%';
            //floor price reformatted with $
            //var floorPriceSort = data[i].Floor_Value__c;
            var floor = '$'+data[i].Floor_Value__c;
            //reformatting the datetime object to make it more visually appealing
            var adjustedTime = new Date(data[i].Auction_End_Date_Time__c).toLocaleString();
            var adjustTimeSub = adjustedTime.substring(10);
            //manually gets the auction manager url that users can click on in the component to take them directly to the auction manager
            if (data[i].Auction__c && data[i].Auction__r.id__c){
                var amUrlString = 'https://tools.acvauctions.com/auctions/dashboard?auction_id='+data[i].Auction__r.id__c;
            }
            //manually gets the deal maker url that users can click on in the component to take them directly to deal maker
            if (data[i].Buyer_Primary_Contact__c != null && data[i].Buyer_Primary_Contact__r.ID__c != null && data[i].Auction__r.id__c != null){
                var dmUrlString = 'https://tools.acvauctions.com/deal-maker?auction_id='+data[i].Auction__r.id__c+'&buyer_id='+data[i].Buyer_Primary_Contact__r.ID__c;
            }
            //manually gets the buyer primary contact ID that the component uses
            if(data[i].Buyer_Primary_Contact__c && data[i].Buyer_Primary_Contact__r.ID__c){
                var buyerID = data[i].Buyer_Primary_Contact__r.ID__c;
            }
            //manually gets the opportunity url that users can click on in the component to take them dierectly to the opportunity
            if(data[i].Id){
                var oppUrlString = 'https://acvauctions.lightning.force.com/lightning/r/Opportunity/'+data[i].Id+'/view';
                var keyID = data[i].Id;
            }
            // manually gets the buyer contact url that users can click on in the component to take them directly to the contact
            // if (data[i].Buyer_Primary_Contact__c){
            //     var buyerPrimaryContactUrl = 'https://acvauctions.lightning.force.com/lightning/r/Contact/'+data[i].Buyer_Primary_Contact__c+'/view';
            // }
            // if(data[i].Buyer_Primary_Contact__c != null && data[i].Buyer_Primary_Contact__r.Id__c != null){
            //     var buyerIdInt = parseInt(data[i].Buyer_Primary_Contact__r.ID__c, 10);
            // }
            //manually gets the auctionID
            if (data[i].Auction__c && data[i].Auction__r.id__c){
                var auctionID = data[i].Auction__r.id__c;
            //     var auctionLights = data[i].Auction__r.Auction_Lights__c;
            }
            //manually gets the Buyer IST name
            if (data[i].Buyer_IST__c != null && data[i].Buyer_IST__r.Name != null){
                var buyerIST = data[i].Buyer_IST__r.Name;
            }
            //manually gets the Seller IST name
            if (data[i].Seller_IST__c != null && data[i].Seller_IST__r.Name != null){
                var sellerIST = data[i].Seller_IST__r.Name;
            }
            //gets the buyer dealership name and makes it fit onto the page without it being wierd
            if (data[i].Buyer_Dealership__c && data[i].Buyer_Dealership__r.Name){
                var buyerDealership = data[i].Buyer_Dealership__r.Name;
                var buyerDealershipSub = buyerDealership.substring(0,15);
            }
            //gets the buyer primary contact name and makes it fit onto the page
            // if (data[i].Buyer_Primary_Contact__c && data[i].Buyer_Primary_Contact__r.Name){
            //     var buyerPrimaryContact = data[i].Buyer_Primary_Contact__r.Name;
            //     var buyerPrimaryContactSub = buyerPrimaryContact.substring(0,15);
            // }
            //gets the seller dealership name and makes it fit onto the page
            if (data[i].Seller_Dealership__c && data[i].Seller_Dealership__r.Name){
                var sellerDealership = data[i].Seller_Dealership__r.Name;
                var sellerDealershipSub = sellerDealership.substring(0,15);
            }
            //brings in the auction notes that they can use to make deals
            if (data[i].Auction_Notes_2__c){
                an2 = data[i].Auction_Notes_2__c;
            }
            //gets the serller IST ID
            // if (data[i].seller_IST__c){
            //     var sellISTid = data[i].seller_IST__c;
            // }
            //gets the opportunity name of the deal maker opp
            if(data[i].Name != null){
                var opportunityName = data[i].Name;
                var opportunityNameSub = opportunityName.substring(0,15);
            }
            if(data[i].Seller_Region__c != null){
                var sellerRegion = data[i].Seller_Region__c;
                var sellRegSub = sellerRegion.substring(0,15);
            }
            //These rows re the fields you see on each title
            var newRow = {
                //gets name of buyer dealership
                buyDeal: buyerDealershipSub,
                vinNum: data[i].VIN_Last_Six__c,
                //gets buyer dealership Url
                // REMOVED FOR NOW bDealUrl: buyDealUrl,
                //gets name of buyer primary contact
                //buyPriCont: buyerPrimaryContactSub,
                // REMOVED FOR NOW gets buyer contact Url
                // REMOVED FOR NOW bPriContUrl: buyerPrimaryContactUrl,
                //gets name of the seller dealership
                sellDeal: sellerDealershipSub,
                //gets seller dealership Url
                // REMOVED FOR NOW sDealUrl: sellDealUrl,
                //sets auction manager url to a variable for html to use
                linkToAucMan: amUrlString,
                //gets the price variance number
                priVariance: varIn$,
                //stores price variance percentage as number for sorting in the object
                // REMOVED FOR NOW priVarSo: priVarPercentage,
                //gets the price variance percentage number
                priVarPerc: priVarPercentageRound,
                //gets the current stage
                // REMOVED FOR NOW staName: data[i].StageName,
                //gets the end date/time
                endTime: adjustTimeSub,
                //gets the highest bid number
                //highBidSort: highBidSo,
                highBid: highBidCur,
                //gets the floor price number
                //floPriceSo: floorPriceSort,
                floPrice: floor, 
                //sets the deal maker url to a variable for html to use
                linkToDealMake: dmUrlString,
                //gets the auction notes
                aucNotes2: an2,
                //gets the seller  and buyer ist
                buyIST: buyerIST,
                buyId: buyerID,
                // REMOVED FOR NOW buyISTc: data[i].Buyer_IST__c,
                bIstUrl: buyISTUrl,
                sellIST: sellerIST,
                // REMOVED FOR NOW sellISTc: sellISTid,
                //gets the seller Ist Url puts to variable
                sIstUrl: sellIstUrl, 
                //gets the opportunity name
                oppName: opportunityNameSub,
                //gets the record Id
                key: keyID,
                //gets the auction Id number of the opportunity
                aucId: auctionID,
                //REMOVED FOR NOW aucLights: auctionLights,
                //gets the opportunity url to a variable for html to use
                oppUrl: oppUrlString,
                //gets seller region
                sellReg: sellRegSub
            }
            rows_tmp.push(newRow);
        }
        this.rows = rows_tmp;
    }

    //method that handels the lookup filter lookups
    async handleOppLookup(event) {
        var searchWord = event.detail.dataitem;
        await search(event.detail)
            .then(results => {
                var allLookups = this.template.querySelectorAll("c-lookup");
                allLookups.forEach(element => {
                    if(element.searchWord === searchWord){
                        element.setSearchResults(results);
                    }
                });
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    //method the notes uses to notify the user if the notes saved successfully or errored
    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts){
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

    //Gets the search term from the user input event
    termChange(event) {
        var selectedUsers = this.template.querySelector('c-lookup').getSelection();
        var searchNames = [];
        selectedUsers.forEach(item => {
            this.searchTerm.push(item.id);
            searchNames.push(item.title);
        });
        filterSave({searchWords:searchNames});
        this.buildOppsObj();
    }

    //Row handler function for HTML handling of the note input
    handleRowAction(evt) {
        this.loading = !this.loading;
        const fields = {};
        let recordInput = {};
        this.rows.forEach(item => {
            if (item.key === evt.currentTarget.dataset.key) {
                item.aucNotes2 = evt.target.value;
                fields[ID_FIELD.fieldApiName] = item.key;
                console.log(item.key);
                fields[NOTES_FIELD.fieldApiName] = item.aucNotes2;
                recordInput = {fields};
                //notesSave({noteInput:item.aucNotes2, idField:item.key});
            }
        })
        //reverts input field back to 1 row when they are updated to the system.
        evt.currentTarget.setAttribute("rows", "1");
        //Another function used in the HTML portion that updates records
        updateRecord(recordInput).then(() => {
            this.loading = !this.loading;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Notes Successfully Updated',
                    message: 'Notes updated',
                    varient: 'success'
                })
            );
        })
    }

    // When clicked into, opens up 10 rows of notes, and can still make changes. When clicked out of, applies changes to notes field.
    bigTextWindow(evt){
        evt.currentTarget.setAttribute("rows", "10");
    }

    async openmodalBuyerInfo(evt){
        var idVar;
        this.createData2();
        const fields = {};
        this.rows.forEach(item => {
            if (item.key === evt.currentTarget.dataset.key) {
                fields[ID_FIELD.fieldApiName] = item.key;
                idVar = item.key;
            }
        })
        var buyData = await getBuyerInfo({buyOpp:idVar});
        var street = buyData[0].Buyer_Dealership__r.BillingAddress.street;
        var city = buyData[0].Buyer_Dealership__r.BillingAddress.city;
        var state = buyData[0].Buyer_Dealership__r.BillingAddress.state;
        var postCode = buyData[0].Buyer_Dealership__r.BillingAddress.postalCode;
        var country = buyData[0].Buyer_Dealership__r.BillingAddress.country;
        var address = street+', '+city+' '+state+', '+postCode+', '+country;
        this.buyDealUrl = 'https://acvauctions.lightning.force.com/lightning/r/Account/'+buyData[0].Buyer_Dealership__r.Id+'/view';
                    var newBuyRow = {
                        bDealName: buyData[0].Buyer_Dealership__r.Name,
                        bContName: buyData[0].Buyer_Primary_Contact__r.Name,
                        bContPhone: buyData[0].Buyer_Primary_Contact__r.Phone,
                        bContEmail: buyData[0].Buyer_Primary_Contact__r.Email,
                        bDealLoc: address
                    };    
        this.buyRow = newBuyRow;
        this.openmodelBuyerInfo = true;
    }

    closemodelBuyerInfo(){
        //clear out variable 
        this.openmodelBuyerInfo = false;
    }
    buyLinkMethod(){
        window.open(this.buyDealUrl, '_blank');
    }

    createData(){
        this.sellRow = {
            sDealName: '',
            sContName: '',
            sContPhone: '',
            sDealLoc: ''
        };
    }
    createData2(){
        this.buyRow = {
            bDealName: '',
            bContName: '',
            bContPhone: '',
            bDealLoc: ''
        };
    }
    createData3(){
        this.vehRow ={
            vVIN: '',
            vYear: '',
            vMake: '',
            vModel: '',
            vTrim: '',
            vMile: '',
            vAutoSell: '',
            vLights: ''
        };
    }
    
    
    async openmodalSellerInfo(evt){
        var idVar;
        this.createData();
        const fields = {};
        this.rows.forEach(item => {
            if (item.key === evt.currentTarget.dataset.key) {
                fields[ID_FIELD.fieldApiName] = item.key;
                idVar = item.key;
            }
        })
        var sellData = await getSellerInfo({sellOpp:idVar});
        var street = sellData[0].Seller_Dealership__r.BillingAddress.street;
        var city = sellData[0].Seller_Dealership__r.BillingAddress.city;
        var state = sellData[0].Seller_Dealership__r.BillingAddress.state;
        var postCode = sellData[0].Seller_Dealership__r.BillingAddress.postalCode;
        var country = sellData[0].Seller_Dealership__r.BillingAddress.country;
        var address = street+', '+city+' '+state+', '+postCode+', '+country;
        this.sellDealUrl = 'https://acvauctions.lightning.force.com/lightning/r/Account/'+sellData[0].Seller_Dealership__r.Id+'/view';
                    var newSellRow = {
                        sDealName: sellData[0].Seller_Dealership__r.Name,
                        sContName: sellData[0].Seller_Primary_Contact__r.Name,
                        sContPhone: sellData[0].Seller_Primary_Contact__r.Phone,
                        sContEmail: sellData[0].Seller_Primary_Contact__r.Email,
                        sDealLoc: address
                    };    
        this.sellRow = newSellRow;
        this.openmodelSellerInfo = true;
    }

    closemodelSellerInfo(){
        this.openmodelSellerInfo = false;
    }
    sellerLinkMethod(){
        window.open(this.sellDealUrl, '_blank');
    }

    async openmodalVehicleInfo(evt){
        var idVar;
        this.createData3();
        const fields = {};
        this.rows.forEach(item => {
            if (item.key === evt.currentTarget.dataset.key) {
                fields[ID_FIELD.fieldApiName] = item.key;
                idVar = item.key;
            }
        })
        var vehData = await getVehicleInfo({vehOpp:idVar});
                    var newVehRow = {
                        //working
                        vVIN: vehData[0].VIN__c,
                        //year make model trim blank fields? 
                        vYear: vehData[0].Auction__r.vehicle_id__r.Year__c,
                        vMake: vehData[0].Auction__r.vehicle_id__r.make__c,
                        vModel: vehData[0].Auction__r.vehicle_id__r.model__c,
                        vTrim: vehData[0].Auction__r.vehicle_id__r.trim__c,
                        //working
                        vMile: vehData[0].Auction__r.odometer__c,
                        //populated but wont show?
                        vAutoSell: vehData[0].Auction__r.Auto_sell__c ? 'No' : 'Yes',
                        vLights: vehData[0].Auction__r.Auction_Lights__c
                    };    
        this.vehRow = newVehRow;
        this.openmodelVehicleInfo = true;
    }

    closemodelVehicleInfo(){
        this.openmodelVehicleInfo = false;
    }
    vehicleLinkMethod(){

    }

    //All these next functions sort the specific column in the function name based on data type in asc or des order
    sortTableBuyDeal() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.buyDeal.toLowerCase() > y.buyDeal.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.buyDeal.toLowerCase() < y.buyDeal.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableBuyContact() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.buyPriCont.toLowerCase() > y.buyPriCont.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.buyPriCont.toLowerCase() < y.buyPriCont.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableSellDeal() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.sellDeal.toLowerCase() > y.sellDeal.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.sellDeal.toLowerCase() < y.sellDeal.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableLinkAM() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.aucId.toLowerCase() > y.aucId.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.aucId.toLowerCase() < y.aucId.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableVariance() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.priVariance > y.priVariance){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.priVariance < y.priVariance){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableVariancePercentage() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.priVarSo > y.priVarSo){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.priVarSo < y.priVarSo){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableStage() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.staName.toLowerCase() > y.staName.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.staName.toLowerCase() < y.staName.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableEndTime() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.endTime.toLowerCase() > y.endTime.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.endTime.toLowerCase() < y.endTime.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableHighBid() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.highBidSort > y.highBidSort){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.highBidSort < y.highBidSort){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableFloorPrice() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.floPriceSo > y.floPriceSo){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.floPriceSo < y.floPriceSo){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableLinkDM() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.buyIdInt > y.buyIdInt){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.buyIdInt < y.buyIdInt){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    // sortTableNotes() {
    //     var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
    //     switching=true;
    //     // eslint-disable-next-line @lwc/lwc/no-document-query
    //     table = document.getElementById("dealMakerTable");
    //     dir = "asc"
    //     while (switching){
    //         switching = false;
    //         for (i=0; i<(this.rows.length-1); i++){               
    //             shouldSwitch = false;
    //             x = this.rows[i];
    //             y = this.rows[i+1];
    //             if(dir === "asc"){
    //                 if(x.aucNotes2.toLowerCase() > y.aucNotes2.toLowerCase()){
    //                     shouldSwitch = true;
    //                     break;
    //                 }
    //             } else if (dir === "desc"){
    //                 if(x.aucNotes2.toLowerCase() < y.aucNotes2.toLowerCase()){
    //                     shouldSwitch = true;
    //                     break;
    //                 }
    //             }
    //         }
    //         if(shouldSwitch){
    //             var tmp = this.rows[i+1];
    //             var tmp2 = this.rows[i];
    //             this.rows[i] = this.rows[i+1];
    //             this.rows[i+1] = tmp2;
    //             switching = true;
    //             switchcount ++;
    //         }else{
    //             if(switchcount === 0 && dir === "asc"){
    //                 dir = "desc";
    //                 switching = true;
    //             }
    //         }
    //     }
    // }

    sortTableSellIST() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.sellIST.toLowerCase() > y.sellIST.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.sellIST.toLowerCase() < y.sellIST.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableBuyIST() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.buyIST.toLowerCase() > y.buyIST.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.buyIST.toLowerCase() < y.buyIST.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }

    sortTableOppName() {
        var switching, table, i, x, y, shouldSwitch, dir, switchcount = 0;
        switching=true;
        // eslint-disable-next-line @lwc/lwc/no-document-query
        table = document.getElementById("dealMakerTable");
        dir = "asc"
        while (switching){
            switching = false;
            for (i=0; i<(this.rows.length-1); i++){               
                shouldSwitch = false;
                x = this.rows[i];
                y = this.rows[i+1];
                if(dir === "asc"){
                    if(x.oppName.toLowerCase() > y.oppName.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                } else if (dir === "desc"){
                    if(x.oppName.toLowerCase() < y.oppName.toLowerCase()){
                        shouldSwitch = true;
                        break;
                    }
                }
            }
            if(shouldSwitch){
                var tmp = this.rows[i+1];
                var tmp2 = this.rows[i];
                this.rows[i] = this.rows[i+1];
                this.rows[i+1] = tmp2;
                switching = true;
                switchcount ++;
            }else{
                if(switchcount === 0 && dir === "asc"){
                    dir = "desc";
                    switching = true;
                }
            }
        }
    }
}