const createUUID = () => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
}

const verifyUUID = ( uuidString ) => {
  const regexUUID = /[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/;
  try {
      if ( uuidString.length == 36 ) { return regexUUID.test( uuidString ); }
  } catch ( error ) {}
  return false;
}

const getCountryOptions = () =>{
  return [
    { label: 'United States', value: 'US' },
    { label: 'Canada', value: 'CA' }
    ];
}

const getAddressTypes = () =>{
  return [
    { label: 'Billing', value: 'billing' },
    { label: 'Legal', value: 'legal' },
    { label: 'Title Mailing', value: 'title_mailing' },
    { label: 'Payment', value: 'payment' },
    { label: 'Delivery', value: 'delivery' },
    { label: 'Pickup', value: 'pickup' },
    ];
}

const getCountryProvinceMap = () =>{
  return {
      US: [{"label": "Alabama","value": "AL"},{"label": "Alaska","value": "AK"},{"label": "American Samoa","value": "AS"},{"label": "Arizona","value": "AZ"},{"label": "Arkansas","value": "AR"},{"label": "California","value": "CA"},{"label": "Colorado","value": "CO"},{"label": "Connecticut","value": "CT"},{"label": "Delaware","value": "DE"},{"label": "District Of Columbia","value": "DC"},{"label": "Federated States Of Micronesia","value": "FM"},{"label": "Florida","value": "FL"},{"label": "Georgia","value": "GA"},{"label": "Guam","value": "GU"},{"label": "Hawaii","value": "HI"},{"label": "Idaho","value": "ID"},{"label": "Illinois","value": "IL"},{"label": "Indiana","value": "IN"},{"label": "Iowa","value": "IA"},{"label": "Kansas","value": "KS"},{"label": "Kentucky","value": "KY"},{"label": "Louisiana","value": "LA"},{"label": "Maine","value": "ME"},{"label": "Marshall Islands","value": "MH"},{"label": "Maryland","value": "MD"},{"label": "Massachusetts","value": "MA"},{"label": "Michigan","value": "MI"},{"label": "Minnesota","value": "MN"},{"label": "Mississippi","value": "MS"},{"label": "Missouri","value": "MO"},{"label": "Montana","value": "MT"},{"label": "Nebraska","value": "NE"},{"label": "Nevada","value": "NV"},{"label": "New Hampshire","value": "NH"},{"label": "New Jersey","value": "NJ"},{"label": "New Mexico","value": "NM"},{"label": "New York","value": "NY"},{"label": "North Carolina","value": "NC"},{"label": "North Dakota","value": "ND"},{"label": "Northern Mariana Islands","value": "MP"},{"label": "Ohio","value": "OH"},{"label": "Oklahoma","value": "OK"},{"label": "Oregon","value": "OR"},{"label": "Palau","value": "PW"},{"label": "Pennsylvania","value": "PA"},{"label": "Puerto Rico","value": "PR"},{"label": "Rhode Island","value": "RI"},{"label": "South Carolina","value": "SC"},{"label": "South Dakota","value": "SD"},{"label": "Tennessee","value": "TN"},{"label": "Texas","value": "TX"},{"label": "Utah","value": "UT"},{"label": "Vermont","value": "VT"},{"label": "Virgin Islands","value": "VI"},{"label": "Virginia","value": "VA"},{"label": "Washington","value": "WA"},{"label": "West Virginia","value": "WV"},{"label": "Wisconsin","value": "WI"},{"label": "Wyoming","value": "WY"}],
      CA: [{"label": "Alberta", "value": "AB"}, {"label": "British Columbia", "value": "BC"}, {"label": "Manitoba", "value": "MB"}, {"label": "New Brunswick", "value": "NB"}, {"label": "Newfoundland and Labrador", "value": "NL"}, {"label": "Nova Scotia", "value": "NS"}, {"label": "Ontario", "value": "ON"}, {"label": "Prince Edward Island", "value": "PE"}, {"label": "Quebec", "value": "QC"}, {"label": "Saskatchewan", "value": "SK"}]
  };
}

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/**
 * Fires the Toast message for notifications to the user. Must add the following line to your lwc
 * import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 */
const fireToast = ( title, message, variant="info", mode="dismissable", messageData=[] ) => {
  // title = Title of the Toast, displayed as a Heading (Required)
  // message = String message (Required), can contain {0}...{N} indicating an index a messageData will replace
  // messageData = list of string or object{url,label} to replace the index in message. Default = []
  // variant = info (default) (gray), success (green), warning (yellow), error (red)
  // mode = dismissable (default) (remains 3 seconds or can be closed), pester (remains 3 seconds), sticky (has to be closed)
  const event = new ShowToastEvent({
      "title" : title,
      "message" : message,
      "messageData" : messageData,
      "mode" : mode,
      "variant" : variant
  });
  dispatchEvent( event );
}

import processJSON from '@salesforce/apex/SplunkHelper.processJSON';
/**
 * Creates a splunk log from JS. Must add the following line to your lwc
 */
const createSplunkLog = ( logLevel, message, componentName, domainSet, recordId="", sfObject="", stackTrace="" ) => {
  // logLevel = Must be one of the following: PERFORMANCE, DEBUG, INFO, WARN, ERROR, FATAL (Required)
  // message = String message (Required)
  // componentName = String componentName (Required)
  // domainSet = Set of domains (Required) must be one of the following:
    //ENTERPRISE_APPS, SALES, POST_TRANSACTION, CONDITION_REPORT, SUPPLY, DEMAND, MARKETPLACE, CAPITAL, MYACV, EMPLOYEE_BUSINESS_SYSTEMS, CUSTOMER_CHURN_PREVENTION, SECURITY, INSPECTION_PLATFORM, OFF_LEASE_PLATFORM, SCHEDULING_PLATFORM, INSPECTOR_DISPATCH, PRIVATE_AUCTIONS
  // recordId = (optional)
  // sfObject = (optional)
  // stackTrace = (optional)

  //example:
    // createSplunkLog('ERROR', 'message', 'updateVehicleCount', ['INSPECTOR_DISPATCH'], 'recordId', 'WorkOrder, ServiceAppointment');

  const log = {};
  log.logLevel = logLevel;
  log.message = message;
  log.location = componentName;
  log.componentName = componentName;
  log.domainSet = domainSet;
  log.sfRecordId = recordId;
  log.sfObject = sfObject;
  log.stackTrace = stackTrace;
  log.contextType = 'LWC';

  processJSON({ logInfoJSON: JSON.stringify(log) });
}



export {createUUID, getCountryOptions, getCountryProvinceMap, getAddressTypes, fireToast, createSplunkLog, verifyUUID};