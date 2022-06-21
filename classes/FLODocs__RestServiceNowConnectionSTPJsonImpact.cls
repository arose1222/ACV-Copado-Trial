/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/ServiceNowConnection/JsonImpactAnalysis/*')
global class RestServiceNowConnectionSTPJsonImpact {
    @HttpGet
    global static List<FLODocs.RestServiceNowConnectionSTPJsonImpact.ImpactAnalysis> callServiceNowMessage() {
        return null;
    }
global class ImpactAnalysis {
    global FLODocs__FLO_Customization__c customization {
        get;
        set;
    }
    global List<FLODocs__FLO_Customization__c> impactedCustomization {
        get;
        set;
    }
    global String safelyMessage {
        get;
        set;
    }
    global String warning_message {
        get;
        set;
    }
    global ImpactAnalysis() {

    }
}
global class ImpactedCusto {
    global String custoId {
        get;
        set;
    }
    global String custoName {
        get;
        set;
    }
    global Boolean isSelected {
        get;
        set;
    }
    global ImpactedCusto() {

    }
}
}
