({
    MAX_FILE_SIZE: 2900000, //Max file size 2.9 MB 
     
    uploadHelper: function(component, event) {
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileuploader").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileMessage", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
         
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
             
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
         
        objFileReader.readAsDataURL(file);
    },
     
    uploadProcess: function(component, file, fileContents) {
        var action = component.get("c.saveFile");
        var folderName = component.get("v.recordId") + '/' + component.find("documentType").get("v.value");
        const now = new Date();
        const offsetMs = now.getTimezoneOffset() * 60 * 1000;
        const dateLocal = new Date(now.getTime() - offsetMs);
        const str = dateLocal.toISOString().slice(0, 19).replace(/-/g, "-").replace("T", "_");
        action.setParams({
            fileName: file.name + "_" + str,
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type,
            recordId: component.get("v.recordId"),
            documentType: component.find("documentType").get("v.value")
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id  
            component.set("v.fileMessage", "") 
            component.set("v.enableFileUploader", false)
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('File has been uploaded successfully');
                var action1 = component.get('c.getDealerApplicationDoc');
                action1.setParams({
                    recordId: component.get("v.recordId"),
                    documentType: component.find("documentType").get("v.value")
                });
                action1.setCallback(this, function(response){
                    var fileList = JSON.parse(response.getReturnValue());
                    var formattedList = [];
                    for (const file in fileList) {
                        formattedList.push({
                            key: file.split('/')[file.split('/').length-1], 
                            value: fileList[file]});
                    }
                    component.set("v.fileList", formattedList);
                })
                $A.enqueueAction(action1);
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    showFile : function(row) {
        window.open(row.value, '_blank').focus();
    },
    
    deleteFile: function(component, row) {
        var isExecuted = confirm("Are you sure to deleting " + row.key + "? This cannot be undo!");
        
        var action = component.get('c.deleteDealerApplicationDoc');
        if (isExecuted) {
            action.setParams({
                fileName: row.key,
                url: row.value.split("?")[0]
            });
            action.setCallback(this, function(response){
                var action1 = component.get('c.getDealerApplicationDoc');
                action1.setParams({
                    recordId: component.get("v.recordId"),
                    documentType: component.find("documentType").get("v.value")
                });
                action1.setCallback(this, function(response){
                    var fileList = JSON.parse(response.getReturnValue());
                    var formattedList = [];
                    for (const file in fileList) {
                        formattedList.push({
                            key: file.split('/')[file.split('/').length-1], 
                            value: fileList[file]});
                    }
                    component.set("v.fileList", formattedList);
                })
                $A.enqueueAction(action1);
            })
            $A.enqueueAction(action);
        }

    },
})