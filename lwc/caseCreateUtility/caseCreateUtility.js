import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createUUID } from 'c/acvUtilHelper';
import { fireToast } from 'c/acvUtilHelper';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import logAnInteraction from '@salesforce/apex/CaseCreateUtilityController.logAnInteraction';
import findOwner from '@salesforce/apex/CaseCreateUtilityController.findOwner';
import setOpsCase from '@salesforce/apex/CaseCreateUtilityController.setOpsCase';
import checkTitle from '@salesforce/apex/CaseCreateUtilityController.checkTitle';
import getContacts from '@salesforce/apex/CaseCreateUtilityController.getContacts';
import getAccounts from '@salesforce/apex/CaseCreateUtilityController.getAccounts';
import initialQuery from '@salesforce/apex/CaseCreateUtilityController.initialQuery';
import checkAccess from '@salesforce/apex/CaseCreateUtilityController.checkAffiliationCreateAccess';
import checkPermissions from '@salesforce/apex/CaseCreateUtilityController.checkPermissions';
import currentUserId from '@salesforce/user/Id';
import Case from '@salesforce/schema/Case';
import Auction__c from '@salesforce/schema/Case.Auction_Number__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

export default class CaseCreateUtility extends NavigationMixin(LightningElement) {

    @api recordId;
    @api get closedCheck() {
        return this.hasBeenClosed;
    }
    set closedCheck(value) {
        this.hasBeenClosed = value;
        if(this.clickCounter > 0){
            this.connectedCallback();
        }
        this.clickCounter++;
    }

    @track hasBeenClosed = false;
    @track accountId = '';
    @track errors = [];
    @track rows = [];
    //@track titlesNeeding48HourNotice = {};
    @track cancelCheck = false;
    @track deleteRowCheck = false;
    @track submitCheck = false;
    @track showISTAlert = false;
    @track showSpinner = false;
    @track showReqCheck = false;
    @track accountPop = false;
    @track emptyBucketOrType = false;
    @track missingAuction = false;
    @track emptyNotes = false;
    @track show48HourError = false;
    @track contactInfo;
    @track invalid48HrAuctions = [];

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    noIstRep = false;
    acvUserAccess = false;
    displayLogAnInteraction = true;
    caseAPI = Case;
    inquiryOwner;
    auctionId = Auction__c;
    auction = '';
    contactId = '';
    initBucket = '';
    initOpsCase = '';
    bucketLabel = '';
    minimizeIndex = false;
    clickCounter = 0;
    counter = 0;
    index = 0;
    key = '';
    invalid48HrMapping = new Map();
    duplicateRows = false;

    initTypeOptions = [{label: 'Please select Call Bucket first', value: 'Please select Call Bucket first'}];
    // auctionRequiredBuckets = ['Buyer Arranged Shipment', 'Sales', 'Title_Information', 'Arbitration_Claim', 'Transportation', 'Unwind'];
    auctionRequiredBuckets = ['Buyer Arranged Shipment', 'Title_Information', 'Arbitration_Claim', 'Transportation', 'Unwind'];
    opsTypeObj = {
        'Title_Information': 'Titles',
        'Arbitration_Claim': 'Arbitration',
        'Unwind': 'Resolutions',
        'Transportation': 'ACV Transport'
    };
    bucketOptions = [
        {label: 'ACV Transport', value: 'Transportation'},
        {label: 'Arbitration', value: 'Arbitration_Claim'},
        {label: 'Buyer Shipment', value: 'Buyer Shipment'},
        {label: 'Helpdesk', value: 'Helpdesk'},
        {label: 'Payments', value: 'Payments'},
        {label: 'Resolutions', value: 'Unwind'},
        {label: 'Sales', value: 'Sales'}
        //{label: 'Retention', value: 'Retention'}
    ];
    callTypeDependencies = {
        'Payments': [
            {label: 'ACV Capital', value: 'ACV Capital'},
            {label: 'Buyer Payment Status', value: 'Buyer Payment Status'},
            {label: 'Default Payment Update', value: 'Default Payment Update'},
            {label: 'Multi-Store Buyer', value: 'Multi-Store Buyer'},
            {label: 'NSF', value: 'NSF'},
            {label: 'Payment Not Selected', value: 'Payment Not Selected'},
            {label: 'Release Slip', value: 'Release Slip'},
            {label: 'Seller Payment Status', value: 'Seller Payment Status'},
            {label: 'Other', value: 'Other'}
        ],
        'Buyer Shipment': [
            {label: 'Abandoned', value: 'Abandoned'},
            {label: 'Cancel Transport', value: 'Cancel Transport'},
            {label: 'Pickup Issue', value: 'Pickup Issue'},
            {label: 'Other', value: 'Other'}
        ],
        'Sales': [
            {label: 'Dealmaker', value: 'Dealmaker'},
            {label: 'False Proxy', value: 'False Proxy'},
            {label: 'Goodwill Request', value: 'Goodwill Request'},
            {label: 'Make an Offer', value: 'Make an Offer'},
            {label: 'Other', value: 'Other'}
        ],
        'Helpdesk': [
            {label: 'Account/Contact Update', value: 'Account/Contact Update'},
            {label: 'Deactivation', value: 'Deactivation'},
            {label: 'Ghost Bid', value: 'Ghost Bid'},
            {label: 'Multi-Store Buyer', value: 'Multi-Store Buyer'},
            {label: 'User Login Support', value: 'User Login Support'},
            {label: 'Other', value: 'Other'}
        ],
        'Title_Information': [ //with case status of 48 hour notice (only way the 48 hour notice update and 48 hour unwind request options will display)
            {label: 'Buyer Reported Problem', value: 'Buyer Reported Problem'},
            {label: 'Buyer Title Status', value: 'Buyer Title Status'},
            {label: 'Seller Title Status', value: 'Seller Title Status'},
            //{label: '48 Hour Notice Request', value: '48 Hour Notice Request'}, //48 Hour Submit
            //{label: '48 Hour Notice Update', value: '48 Hour Notice Update'}, //48 Hour Update
            {label: '48 Hour Unwind Request', value: '48 Hour Unwind Request'},
            {label: 'Other', value: 'Other'}
        ],
        'Title_No_48_Hour_Update': [
            {label: 'Buyer Reported Problem', value: 'Buyer Reported Problem'},
            {label: 'Buyer Title Status', value: 'Buyer Title Status'},
            {label: 'Seller Title Status', value: 'Seller Title Status'},
            {label: '48 Hour Notice Request', value: '48 Hour Notice Request'},
            {label: 'Other', value: 'Other'}
        ],
        'Title_No_48_Hour_Update_No_Buyer_Problem': [
            {label: 'Buyer Title Status', value: 'Buyer Title Status'},
            {label: 'Seller Title Status', value: 'Seller Title Status'},
            {label: '48 Hour Notice Request', value: '48 Hour Notice Request'},
            {label: 'Other', value: 'Other'}
        ],
        'Arbitration_Claim': [
            {label: 'Case Status', value: 'Case Status'},
            {label: 'Payout Dispute', value: 'Payout Dispute'},
            {label: 'Questions on Policy', value: 'Questions on Policy'},
            {label: 'Other', value: 'Other'}
        ],
        'Transportation': [
            {label: 'After-Auction Request', value: 'After-Auction Request'},
            {label: 'Carrier Issue', value: 'Carrier Issue'},
            {label: 'Cost Inquiry', value: 'Cost Inquiry'},
            {label: 'Delivery Status', value: 'Delivery Status'},
            {label: 'Transport Damage', value: 'Transport Damage'},
            {label: 'Other', value: 'Other'}
        ],
        'Unwind': [
            {label: 'Goodwill Status', value: 'Goodwill Status'},
            {label: 'Unwind Delivery Status', value: 'Unwind Delivery Status'},
            {label: 'Unwind Refund Status', value: 'Unwind Refund Status'},
            {label: 'Unwind Request', value: 'Unwind Request'},
            {label: 'Unwind Title Status', value: 'Unwind Title Status'},
            {label: 'Other', value: 'Other'}
        ]
        // 'Retention': [
        //     {label: 'App Education', value: 'App Education'},
        //     {label: 'Arbitration', value: 'Arbitration'},
        //     {label: 'Called No Answer, Try Again', value: 'Called No Answer, Try Again'}, //??
        //     {label: 'Competition', value: 'Competition'},
        //     {label: 'Good Experience', value: 'Good Experience'},
        //     {label: 'Payments', value: 'Payments'},
        //     {label: 'Titles', value: 'Titles'},
        //     {label: 'Transportation', value: 'Transportation'},
        //     {label: 'Unwind', value: 'Unwind'},
        //     {label: 'Valid Business Reason', value: 'Valid Business Reason'}
        // ]
    };

    connectedCallback() {
        checkPermissions()
            .then(results => {
                this.displayLogAnInteraction = results;
            })
        checkAccess()
            .then(results => {
                this.acvUserAccess = results;
            });

        initialQuery({recordId: this.recordId})
            .then(results => {
                this.determineCurrentObjectType(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'Incorrect page type. Please refresh and try opening on an Account, Case, or Auction.', 'error');
                this.errors = [error];
            }
        );
    }

    addRow() {
        initialQuery({recordId: this.recordId})
            .then(results => {
                this.determineCurrentObjectType(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'Incorrect page type. Please navigate to an Account, Case, or Auction and try again.', 'error');
                this.errors = [error];
            });
    }

    determineCurrentObjectType(results) {
        if (results.search('sobjects/Case') != -1) {
            results = JSON.parse(results);
            this.addPopulatedRowFromCase(results);
        }
        else if (results.search('Auction__c ') != -1) {
            this.addPopulatedRowFromAuction();
        }
        else if (results.search('sObjectType":"Account') != -1) {
            results = JSON.parse(results);
            this.autoPopulateAccountOnStart(results);
            this.addPopulatedRowFromAccount();
        }
    }

    addPopulatedRowFromCase(record) {
        if (record.RecordType.DeveloperName in this.opsTypeObj) {
            this.initBucket = record.RecordType.DeveloperName;
            this.initOpsCase = this.recordId;
            this.bucketLabel = this.opsTypeObj[record.RecordType.DeveloperName];
        }
        else {
            this.initBucket = null;
            this.initOpsCase = null;
        }

        if(record.RecordType.DeveloperName == 'Title_Information' && !this.bucketOptions.some(e => e.label === 'Titles')){
            this.bucketOptions.push({label: 'Titles', value: 'Title_Information'});
        }
        else if (record.RecordType.DeveloperName != 'Title_Information') {
            this.removeTitleOption();
        }

        var newRow = this.getNewRowData(record.Auction_Number__c, this.initBucket, '', this.initOpsCase, this.bucketLabel);
        this.rows.push(newRow);
    }

    addPopulatedRowFromAuction() {
        this.removeTitleOption();
        var newRow = this.getNewRowData(this.recordId, '', '', null, '');
        this.rows.push(newRow);
    }

    autoPopulateAccountOnStart(res) {
        if (res) {
            var acctLookup = this.template.querySelector('.accountLookup');
            acctLookup.setSearchResults(res);
        }
        else {
            fireToast('Lookup Error', 'An error occurred while trying to find the account. Please make sure you are on an Account page and try again.', 'error');
        }
    }

    addPopulatedRowFromAccount() {
        this.removeTitleOption();
        var newRow = this.getNewRowData('', '', this.recordId, null, '');
        this.rows.push(newRow);
    }

    getNewRowData(aucVal, bucketVal, acctVal, opsVal, labelVal) {
        return {
            uuid: createUUID(),
            auctionId: aucVal,
            callBucket: bucketVal,
            callType:'',
            callNotes:'',
            resolved: false,
            relatedAccount: acctVal,
            relatedOpsCase: opsVal,
            callBucketLabel: labelVal,
            callBucketOptions: this.bucketOptions,
            callTypeOptions: this.initTypeOptions,
            duplicate: false
        }
    }
    
    removeTitleOption() {
        if (this.bucketOptions.some(e => e.label === 'Titles')) {
            this.bucketOptions.pop();
        }
    }

    handleAccountLookup(evt) {
        const target = evt.target;
        getAccounts(evt.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'An error occurred while trying to find the Account. Please try again or submit an R&I ticket if the error persists.', 'error');
                this.errors = [error];
            }
        );
    }

    handleAccountChange(evt) {
        if (evt.target.getSelection() == '') {
            this.accountId = '';
        }
        else {
            let account = evt.target.getSelection();
            this.accountId = account[0].id;
            findOwner({accountId:this.accountId})
                .then(results => {
                    if(results == 'NO IST'){
                        this.inquiryOwner = currentUserId;
                        this.noIstRep = true;
                    } 
                    else {
                        this.inquiryOwner = results;
                        this.noIstRep = false;
                    }
                }
            );
        }
    }

    handleContactLookup(evt) {
        const target = evt.target;
        if(this.accountId != ''){
            evt.detail.selectedIds.push(this.accountId);
        }

        getContacts(evt.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                fireToast('Lookup Error', 'An error occured while trying to find the Contact. Please try again or submit an R&I ticket if the error persists.', 'error');
                this.errors = [error];
            }
        );
    }

    handleContactChange(evt) {
        if (evt.target.getSelection() == '') {
            this.contactId = '';
        }
        else {
            let contact = evt.target.getSelection();
            this.contactId = contact[0].id;
        }
    }

    navigateToNewDealershipContactPage() {
        let rtInfo = this.contactInfo.data.recordTypeInfos;
        let dealerRecordTypeId = Object.keys(rtInfo).find(rti => rtInfo[rti].name === 'Dealership Contact');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                recordTypeId: dealerRecordTypeId
            }
        });
    }

    navigateToAffiliationCreatePage() {
        const defaultValues = encodeDefaultFieldValues({
            Account__c: this.accountId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Affiliation__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleAuctionChange(evt) {
        this.rows.forEach(item=> {
            if (evt.currentTarget.dataset.key === item.uuid) {
                item.auctionId = evt.target.value;
            
                if (evt.target.value != '' && item.callBucket != '') {

                    this.checkForDuplicateRows();
                    
                    if (item.callBucket in this.opsTypeObj) {
                        setOpsCase({currentBucket:item.callBucket, currentAuction: evt.target.value})
                        .then(results => {
                            item.relatedOpsCase = results;
                        })
                    }
                }
            }
        });
    }

    // this was old version before checkForDuplicateRows was created
    // handleAuctionChange(evt) {

    //     this.rows.forEach(item=> {
    //         if (evt.currentTarget.dataset.key === item.uuid) {
    //             item.auctionId = evt.target.value;
    //             if (item.auctionId != '' && item.callBucket != '' && item.callBucket in this.opsTypeObj) {
    //                 setOpsCase({currentBucket:item.callBucket, currentAuction: evt.target.value})
    //                 .then(results => {
    //                     item.relatedOpsCase = results;
    //                 })
    //             }
    //         }
    //     });
    // }

    handleBucketChange(evt) {

        this.counter = 0;
        var isOpsCase = false;
        this.rows.forEach(item=> {
            if (evt.currentTarget.dataset.key === item.uuid) {

                item.callBucket = evt.target.value;
                item.callBucketLabel = evt.target.options.find(opt => opt.value === evt.detail.value).label;
                item.callTypeOptions = this.callTypeDependencies[evt.target.value];
                this.template.querySelector('[data-id="'+item.uuid+'"]').disabled = false;

                if (item.auctionId != '') {

                    this.checkForDuplicateRows();

                    if (evt.target.value in this.opsTypeObj) {
                        this.index = this.counter;
                        this.auction = item.auctionId;
                        isOpsCase = true;
                    }
                }
            }
            this.counter += 1;
        });

        if(isOpsCase) {
            setOpsCase({currentBucket:evt.target.value, currentAuction: this.auction})
                .then(results => {
                    this.rows[this.index].relatedOpsCase = results;
                }
            )
        }
    }

    // this was old version before checkForDuplicateRows was created
    // handleBucketChange(evt) {
    //     this.counter = 0;
    //     var isOpsCase = false;
    //     this.rows.forEach(item=> {
    //         if (evt.currentTarget.dataset.key === item.uuid) {
    //             if (evt.target.value in this.opsTypeObj && item.auctionId != '') {
    //                 this.index = this.counter;
    //                 this.auction = item.auctionId;
    //                 isOpsCase = true;
    //             }
    //             item.callBucket = evt.target.value;
    //             item.callBucketLabel = evt.target.options.find(opt => opt.value === evt.detail.value).label;
    //             item.callTypeOptions = this.callTypeDependencies[evt.target.value];
    //             this.template.querySelector('[data-id="'+item.uuid+'"]').disabled = false;
    //         }
    //         this.counter += 1;
    //     });
    //     if(isOpsCase) {
    //         setOpsCase({currentBucket:evt.target.value, currentAuction: this.auction})
    //             .then(results => {
    //                 this.rows[this.index].relatedOpsCase = results;
    //             }
    //         )
    //     }
    // }

    checkForDuplicateRows() {
        // first set all row duplicates to false behind the scenes
        // then cycle through all rows and mark any remaining duplicates
        this.rows.forEach(row=> {
            row.duplicate = false;
        });
        var redColor = "background:#c70438";
        var foundDuplicates = false;
        this.rows.forEach(rowA=> {
            this.rows.forEach(rowB=> {
                if (rowA.auctionId != '' && rowA.auctionId == rowB.auctionId && rowA.callBucket != '' && rowA.callBucket == rowB.callBucket && rowA.callType != '' && rowA.callType == rowB.callType && rowA.uuid != rowB.uuid) {  // don't need to check for null on rowB since we are comparing A and B
                    // these are duplicates
                    rowA.duplicate = true;
                    rowB.duplicate = true;
                    this.duplicateRows = true;
                    foundDuplicates = true;
                }
            });
        });

        // loop over all rows and either mark them red or clear error
        let counter = 0;
        this.rows.forEach(item=> {
            this.key = '[data-tr-id="'+item.uuid+'"]';
            if (item.duplicate) {
                this.template.querySelector(this.key).style=redColor;
            } 
            else if (counter%2 == 1) { //reset the odd rows to white
                this.template.querySelector(this.key).style="background:#F5F5F5";
            }
            else { //reset the even rows to grey
                this.template.querySelector(this.key).style="background:#ffffff";
            }
            counter++;
        });

        if (!foundDuplicates) {
            this.duplicateRows = false;
        }
        
    }

    onTypeOpen(evt) {
        this.rows.forEach(item=> { 
            if (evt.currentTarget.dataset.key === item.uuid) {
                if(item.callBucket != '') {
                    if (item.relatedOpsCase != null && item.callBucket == 'Title_Information') {
                        checkTitle({opsCaseId:item.relatedOpsCase}) //call type would be empty... , callType:item.callType
                            .then(results => {
                                if(results.Status != '48 Hour Notice') {
                                    if (results.Status == 'Sent') {
                                        // has Buyer Reported Problem but NO 48 Hour Unwind Request
                                        item.callTypeOptions = this.callTypeDependencies['Title_No_48_Hour_Update'];
                                    }
                                    else {
                                        // no Buyer Reported Problem or 48 Hour Unwind Request
                                        item.callTypeOptions = this.callTypeDependencies['Title_No_48_Hour_Update_No_Buyer_Problem'];
                                    }
                                }
                                else { //has 48 Hour Unwind Request, but NO 48 Hour Notice Request
                                    item.callTypeOptions = this.callTypeDependencies[item.callBucket]; //shouldn't this not show the 48 hr request option? it it's already set to 48 hour notice you don't need to request it again (need to comment it out above)
                                }
                            }
                        );
                    } 
                    else {
                        item.callTypeOptions = this.callTypeDependencies[item.callBucket];
                    }
                }
                else {
                    item.callTypeOptions = this.initTypeOptions;
                }
            }
        });
    }

    handleTypeChange(evt) {
        this.counter = 0;
        this.rows.forEach(item=> {
            if (evt.currentTarget.dataset.key === item.uuid) {
                item.callType = evt.target.value;
                this.checkForDuplicateRows();
                
                this.key = '[data-id="'+item.uuid+'"]';
                // set resolved to false at first so we can re-evaluate
                item.resolved = false;
                this.template.querySelector(this.key).checked = false;
                this.template.querySelector(this.key).disabled = false;
                
                if (item.callBucket != 'Title_Information' ) { 
                    item.resolved = true;
                    this.template.querySelector(this.key).checked = true;
                    this.template.querySelector(this.key).disabled = true;
                    //delete this.titlesNeeding48HourNotice[item.uuid];
                }
                else if (item.relatedOpsCase != null) {
                    this.index = this.counter;
                    if (evt.target.value == '48 Hour Notice Request') {
                        checkTitle({opsCaseId:item.relatedOpsCase})
                            .then(results => {
                                if (results.FortyEightHrEligible == false) {
                                    //add to array
                                    if (!this.invalid48HrAuctions.includes(results.AuctionNumber)) { //if the auction isn't already listed
                                        this.invalid48HrAuctions.push(results.AuctionNumber);
                                        this.invalid48HrMapping.set(this.rows[this.index].auctionId, results.AuctionNumber);
                                    }
                                }
                                // if (results.includes('allowedCaseNumber:')) {
                                //     this.rows[this.index].resolved = true;
                                //     this.template.querySelector(this.key).checked = true;
                                //     // This adds a key value pair where key is the row uuid and value is the caseNumber__title case Id 
                                //     this.titlesNeeding48HourNotice[this.rows[this.index].uuid] = results.split(':')[1] + '__' + item.relatedOpsCase;
                                // }
                                // else if(results != '48 Hour Notice') {
                                //     fireToast('Title Update Required', 'You are required to update the Title Case Status to 48 Hour Notice in order to select 48 Hour Notice Request as the Call Type.', 'error');
                                //     this.rows[this.index].callType = null;
                                //     this.rows[this.index].resolved = false;
                                //     this.template.querySelector(this.key).checked = false;
                                // }
                                // else {
                                //     this.rows[this.index].resolved = true;
                                //     this.template.querySelector(this.key).checked = true;
                                // }
                            }
                        );
                    }
                    //else {
                        //delete this.titlesNeeding48HourNotice[item.uuid];
                    item.resolved = false;
                    this.template.querySelector(this.key).checked = false;
                    //}
                }
            }
            this.counter += 1;
        });
    }

    handleNotesChange(evt) {
        this.rows.forEach(item=> {
            if (evt.currentTarget.dataset.key === item.uuid) {
                item.callNotes = evt.target.value;
            }
        });
    }

    handleResolvedChange(evt) {
        this.rows.forEach(item=> {
            if (evt.currentTarget.dataset.key === item.uuid) {
                item.resolved = evt.target.checked;
            }
        });
    }

    checkRequiredFields() {
        var redColor = "background:#c70438";
        this.counter = 0;
        this.showReqCheck = true;
        this.submitCheck = false;
        if (this.accountId == '') {
            this.accountPop = true;
        }
        else {
            this.rows.forEach(item=> {
                this.key = '[data-tr-id="'+item.uuid+'"]';
                if (this.counter%2 == 1) { //reset the odd rows to grey
                    this.template.querySelector(this.key).style="background:#F5F5F5";
                }
                else { //reset the even rows to white
                    this.template.querySelector(this.key).style="background:#ffffff";
                }

                if (item.callBucket == '' || item.callType == '') {
                    this.template.querySelector(this.key).style=redColor;
                    this.emptyBucketOrType = true;
                }

                if ((item.auctionId == '' && item.callBucket == 'Helpdesk' && item.callType == 'Ghost Bid') 
                || (item.auctionId == '' && item.callBucket == 'Payments' && item.callType != 'Default Payment Update' && item.callType != 'ACV Capital')
                || (item.auctionId == '' && item.callBucket == 'Sales' && item.callType != 'Other')
                || (item.auctionId == '' && this.auctionRequiredBuckets.includes(item.callBucket))) {
                    this.template.querySelector(this.key).style=redColor;
                    this.missingAuction = true;
                }

                if (item.callNotes == '' && item.callBucket == 'Title_Information') {
                    this.template.querySelector(this.key).style=redColor;
                    this.emptyNotes = true;
                }
                this.counter += 1;
            });
        }

        if (this.invalid48HrAuctions.length > 0) {
            this.show48HourError = true;
            //if they remove the row, i will need to remove the entry from the array...
        }
        else if (this.noIstRep == true && this.accountPop == false && this.emptyBucketOrType == false && this.missingAuction == false && this.emptyNotes == false) {
            this.showISTAlert = true;
        }
        else if (this.noIstRep == false && this.accountPop == false && this.emptyBucketOrType == false && this.missingAuction == false && this.emptyNotes == false) {
            this.handleSubmit();
        }
    }

    checkOK() {
        if (this.showISTAlert == true) {
            this.handleSubmit();
        }
        else {
            this.showReqCheck = false;
            this.accountPop = false;
            this.emptyBucketOrType = false;
            this.missingAuction = false;
            this.emptyNotes = false;
            this.show48HourError = false;
        }
    }

    handleSubmit() {
        this.showISTAlert = false;
        this.showReqCheck = false;
        this.rows.forEach(item=> {
            item.relatedAccount = this.accountId;
        });
        this.showSpinner = true;

        logAnInteraction({accountId:this.accountId, inquiryOwner:this.inquiryOwner, contactId:this.contactId, jsonString:JSON.stringify(this.rows)}) //initComments:this.initComments,
            .then(results => {
                if(results != null) {
                    fireToast('Success', 'Support Case created successfully!', 'success');
                    // Below we handle firing a toast that reminds user they need to still make a 48 Hour Notice request
                    // let numberOf48HourNotice = Object.keys(this.titlesNeeding48HourNotice).length;
                    // if (numberOf48HourNotice > 0) {
                    //     let message = 'For case';
                    //     if (numberOf48HourNotice > 1) {
                    //         message += 's';
                    //     }
                    //     let messageData = [];
                    //     let counter = 0;
                    //     for (var key in this.titlesNeeding48HourNotice) {
                    //         message += ' {' + counter + '} ';
                    //         let data = {
                    //             // url gets case Id
                    //             url: '/' + this.titlesNeeding48HourNotice[key].split('__')[1],
                    //             // label gets caseNumber
                    //             label: this.titlesNeeding48HourNotice[key].split('__')[0]
                    //         }
                    //         messageData.push(data);
                    //         counter++;
                    //     }
                        //no need to display, we do not want them creating duplicate work
                        //fireToast('IMPORTANT', message + 'you are still responsible for entering a 48 Hour Notice submit request via the 48 Hour Notice tab from the Title Case.', 'warning', 'sticky', messageData);
                    //}
                    this.submitCheck = false;
                    this.handleCancel();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: results,
                            objectApiName: 'Case',
                            actionName: 'view',
                        },
                    });
                }
                else {
                    // This error is more likely than the error below as we have a try catch in the apex
                    fireToast('Error Saving Table', 'There was an error trying to create the Support Case and Customer Inquiries; please try saving again. If the issue persists, submit an R&I ticket with as much information as possible, including a screen shot of the Log an Interaction form.', 'error', 'sticky');
                }
            })
            .catch(error => {
                fireToast('Error Saving', 'There was an error trying to create the Support Case and Customer Inquiries; please try saving again. If the issue persists, submit an R&I ticket with as much information as possible, including a screen shot of the Log an Interaction form.', 'error', 'sticky');
                this.errors = [error];
            }
        ).finally(() => {
            this.showSpinner = false;
        });
    }

    handleCancel() {
        this.cancelCheck = false;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName !== 'AccountId'){
                    field.reset();
                }
            });
        }
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = undefined;
        });

        this.template.querySelectorAll('lightning-input').forEach(box => {
            box.checked = false;
        });

        this.template.querySelectorAll('lightning-textarea').forEach(text => {
            text.value = '';
        });
        
        this.template.querySelectorAll("c-lookup").forEach(item => {
            item.selection = [];
        });
        
        let value = this.minimizeIndex;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });

        this.rows = [];
        //this.titlesNeeding48HourNotice = {};
        this.accountId = '';
        this.contactId = '';
        this.invalid48HrAuctions = [];
        this.invalid48HrMapping.clear();
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        this.minimizeIndex = !this.minimizeIndex;
    }

    checkDeleteRow(evt) {
        this.index = evt.target.value;
        //need to remove here before the auctionId is cleared
        let aucToRemove = this.invalid48HrMapping.get(this.rows[this.index].auctionId);
        let removeIndex = this.invalid48HrAuctions.indexOf(aucToRemove);
        //don't have the Auction.Name stored anywhere. i could either:
        // 1 - add "name" which is the number to the row data but i don't know how much existing stuff this would mess with
        //or
        // 2 - create a dictionary type thing where in addition to populating the array with the displayable numbers (Name), i also populate a map of Ids to Name
        //then i coukd use that with the this.rows[this.index].auctionId above and get the Name and then use that to get the remove index
        //i like that better
        if (removeIndex != -1) {
            this.invalid48HrAuctions.splice(removeIndex, 1); //what the balogna?
        }
        if (this.rows[this.index].auctionId == '' && this.rows[this.index].callBucket == '' && this.rows[this.index].callType == '' && this.rows[this.index].callNotes == '') {
            this.removeRow();
        }
        else {
            this.deleteRowCheck = true;
        }
    }

    removeRow() {
        this.rows.splice(this.index, 1);
        this.deleteRowCheck = false;
        this.checkForDuplicateRows();
    }

    checkSubmit() {
        this.submitCheck = true;
    }

    closeSubmitModal() {
        this.submitCheck = false;
    }

    checkCancel() {
        this.cancelCheck = true;
    }

    closeCancelModal() {
        this.cancelCheck = false;
    }

    closeDelRowModal() {
        this.deleteRowCheck = false;
    }
}