public class CreateRecordComponentController {
    
    public List<String> flds{get;set;}
    public RecordWrapper recWrap {get;set;}
    
    @testVisible String selectedobj;
    @testVisible String recId;
    
    public Map<String, NotificationMessage> needJavaScript {get;set;}
    @testVisible String JavaScriptFunctionCall;
    
    public String getselectedobj(){
        return selectedobj;
    }
    
    public void setselectedobj(String objName){
        
     
        if(selectedobj == null || selectedobj != objName ){
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

      

    
    public CreateRecordComponentController(){
        initNotificationMap();
    }
    
    public void initFieldsAndRecordWrapper(){
        flds = new List<String>();
        
        Map<String, String> dMap = new Map<String, String>();
        Map<String, String> dtMap = new Map<String, String>();
        Map<String, LookupHandler> refMap = new Map<String, LookupHandler>();
        Map<String, Schema.SObjectField> fldMap;
        try{
           
            fldMap= Schema.getGlobalDescribe().get(selectedObj.toLowerCase()).getDescribe().fields.getMap();
            
          for(String fld: fldMap.keySet()){
            Schema.DescribeFieldResult fieldResult = fldMap.get(fld).getDescribe();
            if(fieldResult.isAccessible() && fieldResult.isCreateable()  && fld != 'ownerid'){
                if(fieldResult.getType() == Schema.DisplayType.DATE){
                    dMap.put(fld, String.valueOf(Date.today()));
                }else if(fieldResult.getType() == Schema.DisplayType.DATETIME){
                    dtMap.put(fld, String.valueOf(DateTime.now()));
                }else if(fieldResult.getType() == Schema.DisplayType.REFERENCE){
                    refMap.put(fld, new LookupHandler(fieldResult.getReferenceTo()[0].getDescribe().getName()));
                }
                flds.add(fld);
            }
        }
        recWrap = new RecordWrapper(Schema.getGlobalDescribe().get(selectedObj).newSObject(), dMap, dtMap, refMap);
        }catch(Exception e){
            apexpages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
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
               system.debug(tempRecord);
               recWrap.record = Database.query(query);
                tempRecord = recWrap.record.clone();
                for(String fld: recWrap.dateFields.keySet()){
                    recWrap.dateFields.put(fld, (recWrap.record.get(fld) != null)? String.valueOf((Date)recWrap.record.get(fld)) : String.valueOf(Date.today()));
                }
                for(String fld: recWrap.dateTimeFields.keySet()){
                    recWrap.dateTimeFields.put(fld, (recWrap.record.get(fld) != null)? String.valueOf((DateTime)recWrap.record.get(fld)) : String.valueOf(DateTime.now()));
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
    
    
    @testVisible void setDate(){
        for(String dFld: recWrap.DateFields.keySet()){
            String dateValue = recWrap.DateFields.get(dFld);
            if(dateValue != null || dateValue != ''){
                List<String> dList = dateValue.split('-');
                recWrap.dummyrecord.put(dFld, Date.newInstance(Integer.valueOf(dList[0]), Integer.valueOf(dList[1]), Integer.valueOf(dList[2])));
            }else{
                
            }            
        }
    }
    
    @testVisible void setDateTime(){
        for(String dtFld: recWrap.DateTimeFields.keySet()){
            String dateTimeValue = recWrap.DateTimeFields.get(dtFld);
            if((dateTimeValue != null || dateTimeValue != '') && dateTimeValue.containsIgnoreCase('T')){
                List<String> dtList = dateTimeValue.split('T');
                List<String> dtList_d = dtList[0].split('-');
                List<String> dtList_t = dtList[1].split(':');
                recWrap.dummyrecord.put(dtFld, DateTime.newInstance(Integer.valueOf(dtList_d[0]), Integer.valueOf(dtList_d[1]), Integer.valueOf(dtList_d[2]), Integer.valueOf(dtList_t[0]), Integer.valueOf(dtList_d[1]), 0));
            }else if(dateTimeValue != null || dateTimeValue != ' '){
                List<String> dtList = dateTimeValue.split(' ');
                List<String> dtList_d = dtList[0].split('-');
                List<String> dtList_t = dtList[1].split(':');
                recWrap.dummyrecord.put(dtFld, DateTime.newInstance(Integer.valueOf(dtList_d[0]), Integer.valueOf(dtList_d[1]), Integer.valueOf(dtList_d[2]), Integer.valueOf(dtList_t[0]), Integer.valueOf(dtList_d[1]), Integer.valueOf(dtList_d[2])));
            }else{
                
            }            
        }
    }
    
    MyUser__C user;
    Map<id, sobject> objHistoryMap;
    Sobject tempRecord ;
    public PageReference save(){
        
        userInfo__C customUser;
       
        id uId = apexpages.currentPage().getParameters().get('userId');
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');
            
            customUser= UserInfo__c.getInstance(user.Name);
            
            
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
        }
        if(recId == 'NA'){
            setDate(); setDateTime();
           initObjHistory((id)recWrap.dummyrecord.get('id'));
            Database.SaveResult  sr = Database.insert(recWrap.dummyrecord, false);
            id objid =  (id)recWrap.dummyrecord.get('id');
            sobject sendObj = recWrap.dummyrecord;
            recWrap.dummyrecord.put('id', null);
            String error='';
            if (sr.isSuccess()){
                initFieldsAndRecordWrapper();
                
                createHistory(sendObj, true, objId);
                //recWrap.record = Schema.getGlobalDescribe().get(selectedObj).newSObject();
                //recWrap.dummyrecord = Schema.getGlobalDescribe().get(selectedObj).newSObject();
                needJavaScript.put('Success', new NotificationMessage(true, 'Record Created', 'The record was successfully created'));
                needJavaScript.put('Failure', new NotificationMessage(false, 'NA', 'NA'));
                customUser.isCreate__c= false;
                update customUSer;
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
        else{
           
            setDate(); setDateTime();
            recWrap.dummyrecord.put('id', recWrap.record.id);
            //initObjHistory((id)recWrap.dummyrecord.get('id'));
            Database.SaveResult  sr = Database.update(recWrap.dummyrecord, false);
            id objid =  (id)recWrap.dummyrecord.get('id');
            Sobject sendObj = recWrap.dummyrecord;
           
            recWrap.dummyrecord.put('id', null);
            String error='';
            if (sr.isSuccess()){
                createHistory(sendObj, false, '');
                //recWrap.record.put('id', sendObj.id);
                //createHistory(objid, false);
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
                for(sObject s : Database.query('SELECT ' + uniqueField + ' FROM ' + this.refObjName + ' LIMIT 50')){
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
    
    
    public Pagereference cancel(){
        userInfo__C customUser;
        MyUser__C user;
        id uId = apexpages.currentPage().getParameters().get('userId');
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');
            
            customUser= UserInfo__c.getInstance(user.Name);
            customUser.isCreate__c= false;
            update customUser;
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
        }
        return null;
    }
    
    
    
   ///####Create History #### ///////////////
    
    
    public void initObjHistory(id accId){
         
        switch on selectedobj.toLowerCase() {
            when 'account' {
               objHistoryMap = new Map<id, sObject>([select id from  AccountHistory where accountId = :accId]);
            }
            when 'opportunity' {
               
            }
            when 'contact' {
               
            }
        }
        
    }
    public void createHistory(sobject sobj, boolean iscreated, String objId){
        
        
        SiteHistory__C histryobj;
        switch on selectedobj.toLowerCase() {
            when 'account' {
                histryobj = new SiteHistory__C();
                if(user != null){
                    histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                    histryobj.Email__c = user.Name;
                   
                    String msg ='Changed ';
                    
                    if(!iscreated){
                         histryobj.Account__c =recId;
                        Map<String ,object> fldMap = sobj.getPopulatedFieldsAsMap();
                        for(String fld : fldMap.keySet()){
                            
                            if(Schema.getGlobalDescribe().get('account').getDescribe().fields.getMap().get(fld).getDescribe().isUpdateable()){
                                if(tempRecord.get(fld)!=null && sobj.get(fld) !=null){
                                    if(!tempRecord.get(fld).equals(sobj.get(fld))){
                                        
                                        if(tempRecord.get(fld) != null){
                                            msg += 'Changed ' + fld + ' from ' +  tempRecord.get(fld) + ' to ' + sobj.get(fld) + '\n';  
                                        }
                                    }else if(sobj.get(fld) == null){
                                        
                                        msg += 'Deleted ' + sobj.get(fld) + ' in ' + fld + '\n';
                                    }
                                }else if(sobj.get(fld) !=null){
                                    msg += 'Changed ' + fld + ' to ' + sobj.get(fld) + '\n';
                                }else if(tempRecord.get(fld) !=null){ 
                                    msg += ' Deleted '+ tempRecord.get(fld) + ' in ' + fld + '\n';
                                    
                                }
                                
                            }
                        }
                        
                        
                        histryobj.action__C= msg;
                    }else{
                         histryobj.Account__c =objId;
                        histryobj.action__C = 'Created';
                    }
                    
                }
            }
            when 'opportunity' {
                System.debug('Opportunity' + recId);
                histryobj = new SiteHistory__C();
                if(user != null){
                    histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                    histryobj.Email__c = user.Name;
                    
                    String msg ='Changed ';
                    
                    if(!iscreated){
                         histryobj.opportunity__c =recId;
                        Map<String ,object> fldMap = sobj.getPopulatedFieldsAsMap();
                        for(String fld : fldMap.keySet()){
                           // if(Schema.getGlobalDescribe().get('opportunity').getDescribe().fields.getMap().get(fld).getDescribe().isNillable()){
                                if(tempRecord.get(fld)!=null && sobj.get(fld) !=null){
                                    if(!tempRecord.get(fld).equals(sobj.get(fld))){
                                        if(tempRecord.get(fld) != null){
                                            msg += 'Changed ' + fld + ' from ' +  tempRecord.get(fld) + ' to ' + sobj.get(fld) + '\n';  
                                        }
                                    }else if(sobj.get(fld) == null){
                                        msg += 'Deleted ' + sobj.get(fld) + ' in ' + fld + '\n';
                                    }
                                }else if(sobj.get(fld) !=null){
                                    msg += 'Changed ' + fld + ' to ' + sobj.get(fld) + '\n';
                                }else if(tempRecord.get(fld) !=null){ 
                                    msg += ' Deleted '+ tempRecord.get(fld) + ' in ' + fld + '\n';
                                    
                                }
                                
                            //}
                        }
                        histryobj.action__C= msg;
                        System.debug(msg);
                    }else{
                        histryobj.opportunity__C =objId;
                        histryobj.action__C = 'Created';
                    }
                }
            }
            when 'contact' {
                histryobj = new SiteHistory__C();
                if(user != null){
                    histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                    histryobj.Email__c = user.Name;
                   
                    String msg ='Changed ';
                    
                    if(!iscreated){
                         histryobj.contact__c =recId;
                        Map<String ,object> fldMap = sobj.getPopulatedFieldsAsMap();
                        for(String fld : fldMap.keySet()){
                            
                            if(Schema.getGlobalDescribe().get('contact').getDescribe().fields.getMap().get(fld).getDescribe().isUpdateable()){
                                if(tempRecord.get(fld)!=null && sobj.get(fld) !=null){
                                    if(!tempRecord.get(fld).equals(sobj.get(fld))){
                                        
                                        if(tempRecord.get(fld) != null){
                                            msg += 'Changed ' + fld + ' from ' +  tempRecord.get(fld) + ' to ' + sobj.get(fld) + '\n';  
                                        }
                                    }else if(sobj.get(fld) == null){
                                        
                                        msg += 'Deleted ' + sobj.get(fld) + ' in ' + fld + '\n';
                                    }
                                }else if(sobj.get(fld) !=null){
                                    msg += 'Changed ' + fld + ' to ' + sobj.get(fld) + '\n';
                                }else if(tempRecord.get(fld) !=null){ 
                                    msg += ' Deleted '+ tempRecord.get(fld) + ' in ' + fld + '\n';
                                    
                                }
                                
                            }
                        }
                        histryobj.action__C= msg;
                    }else{
                         histryobj.contact__C =objId;
                        histryobj.action__C = 'Created';
                    }
                }
            }
        }
        
        Database.SaveResult  sr;
        System.debug('history  '+histryobj);
        if(histryobj != null){
            sr = Database.insert(histryobj);
        }
        String error='';
        
        if (sr.isSuccess()){
             tempRecord = recWrap.dummyrecord.clone();
            
            //recWrap.Record.put('id', recId);
        }
        else {
            for(Database.Error err : sr.getErrors()) {
                error += ('<b>' + err.getStatusCode() + '</b>: ' + err.getMessage()) + '<br/><br/>';
                if(err.getFields().size() > 0)
                    error += ('Fields that affected this error: ' + err.getFields() + '<br/><br/>');
            }
            
        }
        
        if(error != ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
        }else{
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All selected records have been updated successfully'));
        } 
    }

    public class RecordWrapper{
        public sObject record {get;set;}
        public sObject dummyrecord {get;set;}
        public Map<String, String> dateFields {get;set;}
        public Map<String, String> dateTimeFields {get;set;}
        public Map<String, lookupHandler> lookUpMap {get;set;}
        public RecordWrapper(sObject record, Map<String, String> dateFields, Map<String, String> dateTimeFields, Map<String, lookupHandler> lookUpMap){
            this.record = record;
            dummyrecord = record.clone();
            this.dateFields = dateFields.Clone();
            this.dateTimeFields = dateTimeFields.Clone();
            this.lookUpMap = lookUpMap.Clone();
        }
    }
    
}