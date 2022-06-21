import { api, wire, LightningElement, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import getVehicles from '@salesforce/apex/BundleOfferController.getVehicles';
import getRelatedVehicles from '@salesforce/apex/BundleOfferController.getRelatedVehicles';
import addVehiclesToBundle from '@salesforce/apex/BundleOfferController.addVehiclesToBundle';
import deleteVehiclesFromBundle from '@salesforce/apex/BundleOfferController.deleteVehiclesFromBundle';
import updateBundleVehicleAssociations from '@salesforce/apex/BundleOfferController.updateBundleVehicleAssociations';
import BUNDLEVEHICLE_OBJECT from '@salesforce/schema/BundleOfferVehicleAssociation__c';

import ID_FIELD from '@salesforce/schema/BundleOfferVehicleAssociation__c.Id';


const COLS = [
	{ label: 'VIN', fieldName: 'VIN__c'},
	{ label: 'Year/Make/Model', fieldName: 'Year_Make_Model_Trim__c'},
	{ label: 'ACV Estimated Price', fieldName: 'ACV_Estimated_Price__c', editable: true, type: 'currency'},
	{ label: 'Auction Sale Amount', fieldName: 'Auction_Sale_Amount__c', type: 'currency'},
	{ label: 'Previous Run Floor Bid', fieldName: 'Previous_Run_Floor_Bid__c', type: 'currency'},
	{ label: 'Is Auctioned', fieldName: 'Is_Auctioned__c', type: 'boolean' },
];
const VEHICLECOLS = [
	{ label: 'VIN', fieldName: 'VIN__c'},
	{ label: 'Name', fieldName: 'Name'},
	{ label: 'Year/Make/Model', fieldName: 'Year_Make_Model_Trim__c'},
];

export default class BundleOfferLWC extends LightningElement {
    bundleVehicleObject = BUNDLEVEHICLE_OBJECT;
    @api recordId;
    columns = COLS;
    vehicleCols = VEHICLECOLS;
    draftValues = [];

    @track error;
		@track recordsCount = 0;
		@track vehicleRecordsCount = 0;
		@track isDisabled = true;
		@track isVDisabled = true;
		
		
		selectedRecords = [];
		selectedVehiclesRecords = [];
		refreshTable;
	
	
	@wire(getRelatedVehicles, { bundleId: '$recordId' })
    bundleOffer;

    @wire(getVehicles, { bundleId: '$recordId' })
    avaliableVehicles;
    

    // handleSave(event) {

    //     const fields = {}; 
    //     fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
    //     fields["ACV_Estimated_Price__c"] = event.detail.draftValues[0].ACV_Estimated_Price__c;

    //     const recordInput = {fields};

    //     updateRecord(recordInput)
    //     .then(() => {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Bundle Offer Updated',
    //                 variant: 'success'
    //             })
    //         );
    //         // Display fresh data in the datatable
    //         return refreshApex(this.bundleOffer).then(() => {

    //             // Clear all draft values in the datatable
    //             this.draftValues = [];

    //         });
    //     }).catch(error => {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error updating or reloading record',
    //                 message: error,
    //                 variant: 'error'
    //             })
    //         );
    //     });
    // }
		
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = await updateBundleVehicleAssociations({data: updatedFields});
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Vehicles updated',
                    variant: 'success'
                })
            );

            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);

            // Display fresh data in the datatable
            refreshApex(this.bundleOffer).then(() => {
                // Clear all draft values in the datatable
                this.draftValues = [];
            });
            getRecordNotifyChange([{recordId: this.recordId}]);
        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        };
    }
		
		// Getting selected rows 
    getSelectedRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;
        
        this.recordsCount = event.detail.selectedRows.length;

        // this set elements the duplicates if any
        let vehicleIds = new Set();

        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
            vehicleIds.add(selectedRows[i].Id);
        }

        // coverting to array
        this.selectedRecords = Array.from(vehicleIds);
				console.log(this.selectedRecords);
				this.isDisabled = this.recordsCount > 0 ? false : true;

				console.log('selectedRecords ====> ' +this.selectedRecords);
    }
		
		
		
		// delete records process function
    deleteVehicles(event) {
				console.log('selectedrows ===' + this.selectedRecords);
        if (this.selectedRecords) {
            // setting values to reactive variables
            this.buttonLabel = 'Processing....';
            this.isDisabled = true;

            // calling apex class to delete selected records.
            this.deleteBundleVehicles();
        }
    }


    deleteBundleVehicles() {
        deleteVehiclesFromBundle({
						bundleId: this.recordId,
						vehicleIds: this.selectedRecords
				})
        .then(result => {
						console.log('result ====> ' + result);

            this.buttonLabel = 'Delete Selected Vehicles';
            this.isDisabled = true;

            // showing success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!', 
                    message: this.recordsCount + ' Vehicles are deleted.', 
                    variant: 'success'
                }),
            );
            
            // Clearing selected row indexs 
						this.template.querySelector('lightning-datatable').selectedRows = [];
						this.template.querySelector('[data-id="vehicleDatatable"]').selectedRows = [];


            this.recordsCount = 0;
						

            // refreshing table data using refresh apex
						console.log(this.bundleOffer);
						
            refreshApex(this.bundleOffer).then(() => {
                // Clear all draft values in the datatable
                this.isDisabled = true;
								
            });
						this.vehicleRecordsCount = 0;
						this.isVDisabled = true;
						refreshApex(this.avaliableVehicles);

        })
        .catch(error => {
            console.log(error);
						this.isDisabled = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Vehicles', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
        });
    }
		
		// Getting selected rows 
    getSelectedVehicleRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;
        
        this.vehicleRecordsCount = event.detail.selectedRows.length;

        // this set elements the duplicates if any
        let vehicleIds = new Set();

        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
            vehicleIds.add(selectedRows[i].Id);
        }

        // coverting to array
        this.selectedVehiclesRecords = Array.from(vehicleIds);
				console.log(this.selectedVehiclesRecords);
				this.isVDisabled = this.vehicleRecordsCount > 0 ? false : true;

				console.log('selectedRecords ====> ' +this.selectedVehiclesRecords);
    }
		
		addVehicles(event) {
				console.log('selectedrows ===' + this.selectedVehiclesRecords);
        if (this.selectedVehiclesRecords) {
            // setting values to reactive variables
            this.buttonLabel = 'Processing....';
            this.isVDisabled = true;

            // calling apex class to delete selected records.
            this.addBundleVehicles();
        }
    }
		
		addBundleVehicles() {
        addVehiclesToBundle({
						bundleId: this.recordId,
						vehicleIds: this.selectedVehiclesRecords
				})
        .then(result => {
						console.log('result ====> ' + result);

            this.buttonLabel = 'Delete Selected Vehicles';
            this.isVDisabled = true;

            // showing success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!', 
                    message: this.vehicleRecordsCount + ' Vehicles are Added.', 
                    variant: 'success'
                }),
            );
            
            // Clearing selected row indexs 
						this.template.querySelector('[data-id="vehicleDatatable"]').selectedRows = [];
						this.template.querySelector('lightning-datatable').selectedRows = [];


            this.vehicleRecordsCount = 0;

            // refreshing table data using refresh apex
						console.log(this.avaliableVehicles);
            refreshApex(this.avaliableVehicles).then(() => {
                // Clear all draft values in the datatable
                this.isVDisabled = true;
								
            });
						this.recordsCount = 0;
						this.isDisabled = true;
						refreshApex(this.bundleOffer);

        })
        .catch(error => {
            console.log('Error while adding Vehicles - ',JSON.stringify(error));
						this.isVDisabled = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while adding Vehicles', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
        });
    }
}