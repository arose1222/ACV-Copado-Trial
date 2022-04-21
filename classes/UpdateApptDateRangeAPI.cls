/*
    This API is designed to be utilized in the OffersAPI only. It should not be utilized by any external services
*/
@RestResource(urlMapping='/UpdateApptDate/*')
global class UpdateApptDateRangeAPI {

    @HTTPPost
    global static void saveOffer( RequestedApptRange requestRec ) {
        OriginalRequest orReturn = new OriginalRequest( requestRec );
        Boolean didUpdate = FALSE;

        if ( !String.isBlank( requestRec.uuid ) && requestRec.startTime != null && requestRec.endTime != null ) {
            WorkOrderLineItem woli = [ SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE External_Record_guid__c = :requestRec.uuid LIMIT 1 ];
            if ( woli != null ) {
                ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE ParentRecordId = :woli.WorkOrderId LIMIT 1 ];

                if ( saRec != null ) {
                    Timezone userZone = UserInfo.getTimeZone();
                    requestRec.startTime = requestRec.startTime.addSeconds( ( ( (-1) * userZone.getOffset( requestRec.startTime ) ) / 1000 ) );
                    requestRec.endTime = requestRec.endTime.addSeconds( ( ( (-1) * userZone.getOffset( requestRec.endTime ) ) / 1000 ) );

                    saRec.Status = 'Offer Attempted';
                    saRec.EarliestStartTime = requestRec.startTime;
                    saRec.DueDate = requestRec.endTime;
                    saRec.ArrivalWindowStartTime = null;
                    saRec.ArrivalWindowEndTime = null;
                    saRec.SchedStartTime = null;
                    saRec.SchedEndTime = null;

                    try {
                        UpdateWorkTypeSATimes.apiOverride = TRUE;
                        update saRec;
                        UpdateWorkTypeSATimes.apiOverride = FALSE;
                        didUpdate = TRUE;
                    } catch ( exception e ) {
                        system.debug( e.getMessage() );
                        system.debug( e.getStackTraceString() );
                    }
                }
            }
        }

        String statusMsg;
        Integer statusCode;    
    
        if ( didUpdate ) {
            statusCode = 200;
            statusMsg = 'Successful Update';
        } else {
            statusCode = 400;
            statusMsg = 'Error processing Update';
        }

        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse( 
            orReturn,
            new PostUpdateApptDateResponse( requestRec.uuid ),
            statusMsg,
            statusCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    global class RequestedApptRange {
        public String uuid;
        public DateTime startTime;
        public DateTime endTime;
    }

    global class OriginalRequest {
        public Object originalRequest;

        global OriginalRequest( Object providedData ) {
            this.originalRequest = providedData;
        }
    }

    global class PostUpdateApptDateResponse {
        public String uuid;

        global PostUpdateApptDateResponse( String uuid ) {
            this.uuid = uuid;
        }
    }
}