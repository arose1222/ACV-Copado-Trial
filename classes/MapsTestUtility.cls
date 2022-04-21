public class MapsTestUtility {
    public static void makeData() {
        MapsTestUtility.createGeoLayer();
        maps__ShapeLayer__c shapeLayerRec = [ SELECT Id FROM maps__ShapeLayer__c LIMIT 1 ];
        MapsTestUtility.createAssignmentPlan( shapeLayerRec );
    }

    public static void createGeoLayer() {
        maps__Folder__c newFolder = new maps__Folder__c(
            Name = 'Great Lakes Region'
        );
        insert newFolder;

        maps__ShapeLayer__c newShapeLayer = new maps__ShapeLayer__c(
            ACV_Territory_Id__c = '3',
            maps__Description__c = '\"Buffalo" Territory, \"Great Lakes\" Region',
            maps__CustomGeometry__c = FALSE,
            maps__Folder__c = newFolder.Id,
            Name = 'Buffalo',
            maps__Options__c = '{"country":"shapesV2","advancedOptions":{"calculateTerritoryAggregates":false,"dissolveGeometry":true,"affectVisibility":false},"colorOptions":{"fillColor":"#37D341","borderColor":"#16325C","fillOpacity":"0.2","labelEnabled":true,"labelOverride":"Buffalo","labelJustification":"center","labelFontSize":"10px","labelFontColor":"#FFFFFF","labelBGColor":"#000000","labelBGOpacity":"0.3"}}'
        );
        insert newShapeLayer;

        maps__ShapeLayerGeometry__c newShapeLayerGeo = new maps__ShapeLayerGeometry__c(
            maps__Geometry__c = '{\"1\":[\"USA-14009\",\"USA-14010\",\"USA-14011\",\"USA-14012\",\"USA-14013\",\"USA-14020\",\"USA-14021\",\"USA-14024\",\"USA-14025\",\"USA-14026\",\"USA-14027\",\"USA-14028\",\"USA-14029\",\"USA-14030\",\"USA-14031\",\"USA-14032\",\"USA-14033\",\"USA-14034\",\"USA-14035\",\"USA-14036\",\"USA-14037\",\"USA-14038\",\"USA-14039\",\"USA-14040\",\"USA-14042\",\"USA-14043\",\"USA-14047\",\"USA-14051\",\"USA-14052\",\"USA-14054\",\"USA-14055\",\"USA-14056\",\"USA-14057\",\"USA-14059\",\"USA-14060\",\"USA-14061\",\"USA-14065\",\"USA-14066\",\"USA-14067\",\"USA-14068\",\"USA-14069\",\"USA-14083\",\"USA-14091\",\"USA-14095\",\"USA-14102\",\"USA-14107\",\"USA-14109\",\"USA-14110\",\"USA-14111\",\"USA-14112\",\"USA-14130\",\"USA-14133\",\"USA-14134\",\"USA-14140\",\"USA-14143\",\"USA-14173\",\"USA-14174\",\"USA-14205\",\"USA-14215\",\"USA-14220\",\"USA-14223\",\"USA-14231\",\"USA-14233\",\"USA-14240\",\"USA-14241\",\"USA-14263\",\"USA-14264\",\"USA-14265\",\"USA-14267\",\"USA-14269\",\"USA-14270\",\"USA-14272\",\"USA-14273\",\"USA-14276\",\"USA-14280\",\"USA-14301\",\"USA-14302\",\"USA-14305\",\"USA-14427\",\"USA-14536\",\"USA-14549\",\"USA-14550\",\"USA-14591\",\"USA-14706\",\"USA-14721\",\"USA-14730\",\"USA-14745\",\"USA-14751\",\"USA-14756\",\"USA-14758\",\"USA-14774\",\"USA-14783\",\"USA-14786\",\"USA-14802\",\"USA-14884\",\"USA-14001\",\"USA-14004\",\"USA-14005\",\"USA-14006\",\"USA-14008\",\"USA-14070\",\"USA-14072\",\"USA-14075\",\"USA-14080\",\"USA-14082\",\"USA-14085\",\"USA-14086\",\"USA-14092\",\"USA-14094\",\"USA-14101\",\"USA-14105\",\"USA-14108\",\"USA-14113\",\"USA-14120\",\"USA-14126\",\"USA-14127\",\"USA-14131\",\"USA-14132\",\"USA-14139\",\"USA-14141\",\"USA-14144\",\"USA-14145\",\"USA-14150\",\"USA-14151\",\"USA-14167\",\"USA-14168\",\"USA-14169\",\"USA-14170\",\"USA-14171\",\"USA-14172\",\"USA-14201\",\"USA-14202\",\"USA-14203\",\"USA-14204\",\"USA-14206\",\"USA-14207\",\"USA-14208\",\"USA-14209\",\"USA-14210\",\"USA-14211\",\"USA-14212\",\"USA-14213\",\"USA-14214\",\"USA-14216\",\"USA-14217\",\"USA-14218\",\"USA-14219\",\"USA-14221\",\"USA-14222\",\"USA-14224\",\"USA-14225\",\"USA-14226\",\"USA-14227\",\"USA-14228\",\"USA-14260\",\"USA-14261\",\"USA-14303\",\"USA-14304\",\"USA-14429\",\"USA-14508\",\"USA-14707\",\"USA-14708\",\"USA-14709\",\"USA-14711\",\"USA-14714\",\"USA-14715\",\"USA-14717\",\"USA-14727\",\"USA-14729\",\"USA-14731\",\"USA-14735\",\"USA-14737\",\"USA-14738\",\"USA-14739\",\"USA-14741\",\"USA-14743\",\"USA-14744\",\"USA-14748\",\"USA-14753\",\"USA-14754\",\"USA-14760\",\"USA-14766\",\"USA-14770\",\"USA-14777\",\"USA-14778\",\"USA-14779\",\"USA-14788\",\"USA-14803\",\"USA-14804\",\"USA-14806\",\"USA-14813\",\"USA-14822\",\"USA-14880\",\"USA-14895\",\"USA-14897\"]}',
            Name = 'Buffalo-geometry',
            maps__ShapeLayer__c = newShapeLayer.Id
        );
        insert newShapeLayerGeo;
    }

    public static void createAssignmentPlan( maps__ShapeLayer__c providedShapeLayerRec ) {
        maps__AssignmentPlan__c newAssignmentPlanRec = new maps__AssignmentPlan__c(
            maps__Active__c = TRUE,
            maps__RuleLookupField__c = 'maps__assignmentrule__c',
            maps__CustomAssignmentField__c = 'rsd__c',
            maps__LatField__c = 'billinglatitude',
            maps__LngField__c = 'billinglongitude',
            Name = 'ACV Auctions USA Sales RSD Plan',
            maps__ReassignOwner__c = FALSE,
            maps__SObject__c = 'Account',
            maps__SObject_Name__c = 'Account (Maps Assignment Rule)',
            maps__SOQLFilter__c = 'recordtypeid = \'012j0000000ugG8AAI\''
        );
        insert newAssignmentPlanRec;

        maps__AssignmentRule__c newAssignmentRuleRec = new maps__AssignmentRule__c(
            maps__Active__c = TRUE,
            maps__AssignmentPlan__c = newAssignmentPlanRec.Id,
            Name = 'Buffalo',
            maps__ShapeLayer__c = providedShapeLayerRec.Id,
            maps__User__c = UserInfo.getUserId()
        );
        insert newAssignmentRuleRec;
    }
}