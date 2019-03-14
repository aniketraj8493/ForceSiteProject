public class CreateTaskAndEventController {
    
    public List<String> flds{get;set;}
    @testVisible object accessbilityObj;
    public void setaccessbilityobj( object acc){
        if(accessbilityobj==null)
            accessbilityobj = (Accessibility)acc;
        System.debug(accessbilityobj);
    }
    public Accessibility getaccessbilityobj(){
        return (Accessibility)accessbilityobj;
    }
    public RecordWrapper recWrap {get;set;}
    @testVisible List<String> recordsIdList;
    @testVisible String selectedobj;
    @testVisible String recId;
    
    public Map<String, NotificationMessage> needJavaScript {get;set;}
    @testVisible String JavaScriptFunctionCall;
    
    
    public void setrecordsIdList(List<String> ids){
        System.debug('ids: ' + ids);
        if(recordsIdList == null || recordsIdList != ids){
            recordsIdList = ids;
        }
    } public List<String>  getrecordsIdList(){
        return recordsIdList;
    }
    public String getselectedobj(){
        return selectedobj;
    }
    
    public void setselectedobj(String objName){
        System.debug('objName: ' + objName);
        if(selectedobj == null || selectedobj != objName){
            selectedobj = objName;
            initFieldsAndRecordWrapper();
            recId = 'NA';
            initRecord();
        }
    }
    
    public String getrecId(){
        return recId;
    }
    
    public void setrecId(String rId){
        if(recId == null ||  recId != rId){
            recId = rId;
            initFieldsAndRecordWrapper();
            initRecord();
        }
    }

    public List<String> getAccounNames(){
        List<String> accNames = new List<String>();
        for(Account a: [SELECT Id, Name FROM Account]){
            accNames.add('\"' + a.Name + '\"');
        }
        return accNames;
    }
    
    
    public CreateTaskAndEventController(){
        initNotificationMap();
    }
    
    public void initFieldsAndRecordWrapper(){
        flds = new List<String>();
        Map<String, Date> dMap = new Map<String, Date>();
        Map<String, DateTime> dtMap = new Map<String, DateTime>();
        Map<String, LookupHandler> refMap = new Map<String, LookupHandler>();
        Map<String, Schema.SObjectField>fldMap = Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();
        for(String fld: fldMap.keySet()){
            Schema.DescribeFieldResult fieldResult = fldMap.get(fld).getDescribe();
            if(fieldResult.isAccessible() && fieldResult.isCreateable() && fieldResult.getType() != Schema.DisplayType.MultiPicklist && fld != 'ownerid'){
                if(fieldResult.getType() == Schema.DisplayType.DATE){
                    dMap.put(fld, Date.today());
                }else if(fieldResult.getType() == Schema.DisplayType.DATETIME){
                    dtMap.put(fld, DateTime.now());
                }else if(fieldResult.getType() == Schema.DisplayType.REFERENCE){
                    refMap.put(fld, new LookupHandler(fieldResult.getReferenceTo()[0].getDescribe().getName()));
                }
                flds.add(fld);
            }
        }
        recWrap = new RecordWrapper(Schema.getGlobalDescribe().get(selectedObj).newSObject(), dMap, dtMap, refMap);
    }
    
    @testVisible void initRecord(){
        if(recId == 'NA'){
            
        }else{
            String query = 'SELECT ';
            query += String.join(flds, ', ');
            query += ' FROM ';
            query += selectedObj;
            query += ' WHERE Id = \'';
            query += recId;
            query += '\'';
            try{
                recWrap.record = Database.query(query);
                for(String fld: recWrap.dateFields.keySet()){
                    recWrap.dateFields.put(fld, (recWrap.record.get(fld) != null)? (Date)recWrap.record.get(fld) : Date.today());
                }
                for(String fld: recWrap.dateTimeFields.keySet()){
                    recWrap.dateTimeFields.put(fld, (recWrap.record.get(fld) != null)? (DateTime)recWrap.record.get(fld) : DateTime.now());
                }
                recWrap.dummyrecord = recWrap.record.clone();
            }catch(Exception e){
                needJavaScript.put('Success', new NotificationMessage(false, 'NA', 'NA'));
                needJavaScript.put('Failure', new NotificationMessage(true, 'ERROR', e.getMessage()));
                recWrap.record = Schema.getGlobalDescribe().get(selectedObj).newSObject();
                recWrap.dummyrecord = Schema.getGlobalDescribe().get(selectedObj).newSObject();
                recId = 'NA';
            }
        }        
    }
    
    public PageReference save(){
        System.debug('recId: ' + recId);
        if(recId == 'NA'){
            list<task> tlst = new List<Task>();
            for(String s: recordsIdList){
                Task t = new Task();
                t.OwnerId = (id)recWrap.dummyrecord.get('OwnerId__c');
                t.Status = (string)recWrap.dummyrecord.get('Status__c');
                t.Subject = (string)recWrap.dummyrecord.get('Subject__c');
                t.Priority = (string)recWrap.dummyrecord.get('Priority__c');
                t.WhatId = s;
                tlst.add(t);  
            }
            Database.SaveResult[]  srLst = Database.insert(tlst, false);
            recWrap.dummyrecord.put('id', null);
            String error='';
            for(Database.SaveResult sr: srLst){
                if (sr.isSuccess()){
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        error += ( err.getStatusCode() + ': ' + err.getMessage()) + '\n\n';
                        if(err.getFields().size() > 0)
                            error += ('Fields that affected this error: ' + err.getFields() + '\n\n');
                    }
                }
            }
            
            if(error != ''){
                needJavaScript.put('Success', new NotificationMessage(false, 'NA', 'NA'));
                needJavaScript.put('Failure', new NotificationMessage(true, 'ERROR', error));
            }else{
                initFieldsAndRecordWrapper();
                needJavaScript.put('Success', new NotificationMessage(true, 'Tasks Created', 'All tasks were successfully created'));
                needJavaScript.put('Failure', new NotificationMessage(false, 'NA', 'NA'));
            }
        }
        else{
            recWrap.dummyrecord.put('id', recWrap.record.id);
            Database.SaveResult  sr = Database.update(recWrap.dummyrecord, false);
            recWrap.dummyrecord.put('id', null);
            String error='';
            if (sr.isSuccess()){
                needJavaScript.put('Success', new NotificationMessage(true, 'Record Updated', 'The record was successfully updated'));
                needJavaScript.put('Failure', new NotificationMessage(false, 'NA', 'NA'));
            }
            else {
                Database.Error[] errLst = sr.getErrors();
                if(errLst.size() == 1){
                    needJavaScript.put('Success', new NotificationMessage(false, 'NA', 'NA'));
                    needJavaScript.put('Failure', new NotificationMessage(true, String.valueOf(errLst[0].getStatusCode()), errLst[0].getMessage()));
                }else{
                    for(Database.Error err : errLst) {
                        error += ( err.getStatusCode() + ': ' + err.getMessage()) + '\n\n';
                        if(err.getFields().size() > 0)
                            error += ('Fields that affected this error: ' + err.getFields() + '\n\n');
                    }
                }
                
            }
            if(error != ''){
                needJavaScript.put('Success', new NotificationMessage(false, 'NA', 'NA'));
                needJavaScript.put('Failure', new NotificationMessage(true, 'ERROR', error));
            }
        }
        return null;
        
    }
    
    public String getJavaScriptFunctionCall(){
        String toReturn = '';
        if(needJavaScript.get('Success').show){
            toreturn =  SuccessScript(needJavaScript.get('Success'));
        }else if(needJavaScript.get('Failure').show){
            toreturn =  FailureScript(needJavaScript.get('Failure'));
        }
        initNotificationMap();
        return toReturn;
    }
    
    @testVisible String SuccessScript(NotificationMessage nm){
        if(recId == 'NA'){
            return '<script> notify(\'Success\', \'' + nm.statusCode + '\', \'' + nm.message + '\', \'center\', 3000); cancelModal(); </script>';
        }else{
            return '<script> notify(\'Success\', \'' + nm.statusCode + '\', \'' + nm.message + '\', \'center\', 3000); cancelModal(); </script>';
        }   
    }
    
    @testVisible String FailureScript(NotificationMessage nm){
        if(recId == 'NA'){
            return '<script> notify(\'Error\', \'' + nm.statusCode + '\', \'' + nm.message + '\', \'center\', 3000); </script>';
        }else{
            return '<script> notify(\'Error\', \'' + nm.statusCode + '\', \'' + nm.message + '\', \'center\', 3000); </script>';
        }   
        
    }
    
    public void initNotificationMap(){
        needJavaScript = new Map<String, NotificationMessage>();
        needJavaScript.put('Success', new NotificationMessage(false, 'NA', 'NA'));
        needJavaScript.put('Failure', new NotificationMessage(false, 'NA', 'NA'));
    }
    
    public class NotificationMessage{
        public Boolean show;
        public String statusCode;
        public String message;
        
        public NotificationMessage(Boolean show, String statusCode, String message){
            this.show = show;
            this.statusCode = String.escapeSingleQuotes(statusCode);
            this.message = String.escapeSingleQuotes(message);
        }
    }
    
    public class LookupHandler{
        public String refObjName {get;set;}
        public String uniqueField {get;set;}
        public List<String> refObjRecords {get;set;}
        public LookupHandler(String refObjName){
            this.refObjName = refObjName;
            uniqueField = getNameUniqueField(this.refObjName)[0];
            try{
                refObjRecords = new List<String>();
                for(sObject s : Database.query('SELECT ' + uniqueField + ' FROM ' + this.refObjName + ' LIMIT 1000')){
                    refObjRecords.add('\"' + String.valueOf(s.get(uniqueField)) + '\"');
                }
            }catch(Exception e){
                refObjRecords = new List<String>();
            }
        }
        
        public List<String> getNameUniqueField(String objType){   
            System.debug('Function: getNameUniqueField');
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(objType);
            List<String> strResult = new List<String>();
            //Schema.sObjectType objType = obj.getSObjectType();
            Schema.DescribeSObjectResult ObjResult =  LeadSchema.getDescribe();
            Map<String, Schema.SObjectField> mapFields = ObjResult.Fields.getMap();
            schema.describeFieldResult dfield;
            for(String s : mapFields.keySet()){
                dfield = mapFields.get(s).getDescribe();
                //for(Schema.SObjectField objField : mapFields)
                
                if(dfield.isNameField())
                {
                    strResult.add(dfield.getName().toLowerCase());
                    break;
                }
                
                if(dfield.isAutoNumber())
                {
                    strResult.add(dfield.getName().toLowerCase());
                    break;
                }
                
                if(dfield.isUnique())
                {
                    strResult.add(dfield.getName().toLowerCase());
                    break;
                }
            }
            return strResult;  
        }
    }
    
    public class RecordWrapper{
        public sObject record {get;set;}
        public sObject dummyrecord {get;set;}
        public Map<String, Date> dateFields {get;set;}
        public Map<String, DateTime> dateTimeFields {get;set;}
        public Map<String, lookupHandler> lookUpMap {get;set;}
        public RecordWrapper(sObject record, Map<String, Date> dateFields, Map<String, DateTime> dateTimeFields, Map<String, lookupHandler> lookUpMap){
            this.record = record;
            dummyrecord = record.clone();
            this.dateFields = dateFields.Clone();
            this.dateTimeFields = dateTimeFields.Clone();
            this.lookUpMap = lookUpMap.Clone();
        }
    }
    
}