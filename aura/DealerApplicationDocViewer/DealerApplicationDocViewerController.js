({
    doInit: function(component) {
        component.set("v.enableFileUploader", true)
        component.set('v.columns', [
            {label: 'File Name', fieldName: 'key', type: 'text'},
            {label: 'View', type: 'button', initialWidth: 90, typeAttributes: { label: 'View', name: 'view', title: 'Click to View the file'}},
            {label: 'Delete', type: 'button', initialWidth: 90, typeAttributes: { label: 'Delete', name: 'delete', title: 'Click to Delete the file'}}
        ]);
        var action = component.get('c.getDealerApplicationDoc');
        action.setParams({
            recordId: component.get("v.recordId"),
            documentType: 'driver_license'
        });
		action.setCallback(this, function(response){
            var fileList = JSON.parse(response.getReturnValue());
            var formattedList = [];
			for (const file in fileList) {
              	formattedList.push({
                    key: file.split('/')[file.split('/').length-1], 
                    value: fileList[file]});
            }
            component.set("v.fileList", formattedList);
        })
        $A.enqueueAction(action);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view':
                helper.showFile(row);
                break;
            case 'delete':
                helper.deleteFile(component, row);
                break;
        }
    },
    
    documentTypeonChange: function (component, event) {
        var action = component.get('c.getDealerApplicationDoc');
        action.setParams({
            recordId: component.get("v.recordId"),
            documentType: component.find("documentType").get("v.value")
        });
		action.setCallback(this, function(response){
            var fileList = JSON.parse(response.getReturnValue());
            var formattedList = [];
			for (const file in fileList) {
              	formattedList.push({
                    key: file.split('/')[file.split('/').length-1], 
                    value: fileList[file]
                });
            }
            component.set("v.fileList", formattedList);
        })
        $A.enqueueAction(action);
    },
    
    handleSave: function(component, event, helper) {
        if (component.find("fileuploader").get("v.files") 
            && component.find("fileuploader").get("v.files").length == 1
            && component.get("v.enableFileUploader") == true) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select only one Valid File');
        }
    },
     
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileMessage", "File Selected: "+fileName)
            component.set("v.enableFileUploader", true)
            alert(fileName + " has been selected for " + component.find("documentType").get("v.value"));
        }
    },
     
    handleCancel: function(component, event, helper) {
        component.set("v.enableFileUploader", false)
        component.set("v.fileMessage", "")
        $A.get("e.force:closeQuickAction").fire();
    }
})