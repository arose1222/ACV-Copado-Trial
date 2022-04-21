/**
 * The DownloadTableButton Javascript logic
 */
import { LightningElement, api } from 'lwc';
import { fireToast } from 'c/acvUtilHelper';

export default class DownloadTableButton extends LightningElement {
    // Required Properties
    @api fileType = '';     // Accepted Values: CSV
    @api fileName = '';     // Will be used as the name of the File
    @api tableData = {};    // Data from your table. Look in later comments for how to properly set data type requirements
    // CSV Required Fields
    // tableData = [[]]     // Expects an Array in an Array of the data. Examile [ [Test Name 1,7-1-2021,testId1], [Test Name 2,7-1-2021,testId2] ]
    @api columns = [];      // Expects an Array of Column Names: Example  [Name,Created Date,Id]
    // Optional Properties
    // Button Variables - For valid Options, check https://developer.salesforce.com/docs/component-library/bundle/lightning-button/specification
    @api buttonVariant = 'brand'
    @api buttonLabel = 'Download Table';
    @api buttonName = 'Download Table';
    @api buttonTitle = 'Download Table';
    @api buttonType = 'button';
    @api buttonIconName = 'utility:download';
    @api buttonIconPosition = 'left';
    @api buttonClass = '';
    @api buttonDisabled = false;
    @api buttoneHide = false;       // Hides the button if you don't want it on the page but want to use the downloadTable functino
    // Public function to downlaod the table based on the required fields
    @api
    downloadTable(){
        this.fireLoadingEvent(true);
        setTimeout( () => {
            let fileTypeLowerCase = this.fileType.toLowerCase();
            switch(fileTypeLowerCase) {
                case 'csv':
                    if( this.tableData == null || this.tableData === undefined ){
                        fireToast('There is an issue with the Table\'s Data', ' Please Contact your Salesforce Administrator', 'error' );
                        break;
                    }
                    let csvData = "data:text/csv;charset=utf-8,";
                    csvData += this.columns.join(",") + "\r\n";
                    this.tableData.forEach(function(rowArray) {
                        let row = rowArray.join(",");
                        csvData += row + "\r\n";
                    });
                    var docElement = document.createElement('a');
                    docElement.href = encodeURI(csvData);
                    docElement.target = '_blank';
                    docElement.download = this.fileName + '.' + this.fileType;
                    docElement.click();
                    break;
                default:    //Error on file type
                    fireToast('File Type ' + fileTypeLowerCase + ' is not supported.', ' Please Contact your Salesforce Administrator', 'error' );
            }
            this.fireLoadingEvent(false);
        }, 0);        
    }
    // On click of Download Table, runs the logic
    handleDownloadTableClick(){
        this.downloadTable();
    }
    // Firest a loading event indicatign whether its processing or not
    fireLoadingEvent( isLoading ){
        const loadingEvent = new CustomEvent('loading', { detail: isLoading });
        this.dispatchEvent(loadingEvent);
    }
}