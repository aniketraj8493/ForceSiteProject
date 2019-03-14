public class RelatedListComponentController {
    
    @testVisible String objName;
    @testVisible String recId;
    @testVisible String profileName;
    public String uniqfield {get; set;}
    public List<RelatedRecordWrapper> relatedRecords {get;set;}
    
    public String activeTab {get;set;}
    public sObject record {get; set;}
    public String getobjName(){
        return objName;
    }
    
    public void setProfilename(String pr){
        
        if(ProfileName == null){
            profileName = pr;
        }
    }
    public String getProfilename(){
        return profileName;
    }
    public void setobjName(String obNm){
        
        if(objName == null || objName != obNm){
            objName = obNm;
            
        }
    }
    
    public String getrecId(){
        return recId;
    }
    
    public void setrecId(String recordId){
        if(recId == null){
            recId = recordId;
            initrelatedRecords();
            initRecord();
        }
    }
    public void initRecord(){
        System.debug(objName + '  ' + recId);
        try{
            
            record = database.query('Select ' + getNameUniqueField(objName)[0] + ' From ' + objName + ' Where id = \'' + recId + '\'');
            System.debug('Select ' + uniqfield + ' From ' + objName + ' Where id = \'' + recId + '\'');
        }catch(Exception e){
            System.debug('Select ' + uniqfield + ' From ' + objName + ' Where id = \'' + recId + '\'');
        }
        
    }
    
    
    
    public RelatedListComponentController(){
        
        activeTab = 'MainRecord';
    }
    
    public void initrelatedRecords(){
        relatedRecords = new List<RelatedRecordWrapper>();
        Map<String, String> relObjMap = getRelatedObjects();
        Integer count = 1;
        for(String relObj: relObjMap.keySet()){
            RelatedRecordWrapper relRec= new RelatedRecordWrapper(relObjMap.get(relObj), relObj, getRelatedQuery(relObjMap.get(relObj), getRelatedFieldList(relObjMap.get(relObj))), getRelatedFieldList(relObjMap.get(relObj)), count++);
            relatedRecords.add(relRec);
        }
        
    }
    
    public List<String> filterObjectList(List<String> objLst){
        
        List<String> mainLst = new List<String>{'Account', 'Asset', 'Campaign', 'Case', 'Contact',
            'Contract', 'Opportunity', 'Order',
            'Product', 'Solution', 'Task', 'Event'};
                mainLst.addAll(getAllCustomSObjects());
        //List<String> mainLst = new List<String>{'Account', 'Contact', 'Opportunity', 'Task', 'Event',
        //                                      'Lead', 'Case'};
        Set<String> setObjLst = new Set<String>(objLst);
        setObjLst.retainAll(mainLst);
        List<String> l = new List<String>(setObjLst);
        List<String> toReturn = new List<String>();
        for(String o: l){
            if(isObjectPresent(o)){
                toReturn.add(o);
            }
        }
        return toReturn;
    }
    public static List<String> getAllCustomSObjects()
    {
        
        List<String> sObjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
            Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
            if(describeSObjectResultObj.isCustom())
            {
                String name = objTyp.getDescribe().getName();
                // Exclude all the unwanted Sobjects e.g. History, Share etc..
                if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
                   !name.containsignorecase('share') && !name.containsignorecase('feed'))
                {
                    SobjectList.add(name);
                }
            }
        }
        return sObjectList;
    }
    public Boolean isObjectPresent(String obj){
        Boolean result = false;
        for(String o: Schema.getGlobalDescribe().keyset()){
            if(o == obj){
                result = true;
                break;
            }
        }
        return result;
    }
    public Map<String, String> getRelatedObjects(){
        Map<String, String> relObjMap = new Map<String, String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.DescribeSObjectResult R = gd.get(objName).getDescribe();
        Map<String, String> objList = new Map<String, String>();
        for (Schema.ChildRelationship cr: R.getChildRelationships()) 
        {
            objList.put(cr.getChildSObject().getDescribe().getName(), cr.getChildSObject().getDescribe().getlabelPlural() );
            // relObjMap.put(cr.getChildSObject().getDescribe().getlabelPlural(), cr.getChildSObject().getDescribe().getName());
        }
        List<String> o = new List<String>(objList.keySet());
        List<String> finalObjLst = filterObjectList(o);
        for(String s : finalObjLst)
            relObjMap.put(objList.get(s),s);
        // relObjMap.put('Opportunities', 'Opportunity');
        return relObjMap;
    }
    
    public String getRelatedQuery(String relObj, List<String> relfieldLst){
        
        String query = '';
        query += 'SELECT ';
        query += String.join(relfieldLst, ', ');
        query += ' FROM ';
        query += relObj;
        query += ' WHERE '+ getReferenceField(relObj)  + ' = \'' + recId + '\'';
        return query;
    }
    public String getReferenceField(String ob){
        String fld='';
        
        map<string, Schema.SObjectType> mp = schema.getGlobalDescribe();
        Schema.DescribeSObjectResult f1 = mp.get(objName).getDescribe();
        list<schema.ChildRelationship> f= f1.getChildRelationships();  
        
        for(Schema.ChildRelationship reference : f) {
            if(ob.toLowerCase() == reference.getChildSObject().getDescribe().getName().tolowerCase())
                fld= reference.getfield().getdescribe().getName();
        }
        return fld;
        
    }
    
    public List<String> getRelatedFieldList(String obj){
        List<String> fldLst = new List<String>();
        fldLst.addAll(getDefaultFields(obj));
        return fldLst;
    }
    
    public Boolean isFieldPresent(String obj, String fld){
        Boolean result = false;
        for(String f: Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().keySet()){
            if(fld == f){
                result = true;
                break;
            }
        }
        return result;
    }
    
    public List<String> getDefaultFields(String obj){
        System.debug('Function: getDefaultFields');
        List<String> defld = new List<String>();
        if(obj == 'Account'){
            defld = new List<String>{'Name', 'AccountNumber', 'Phone', 'Rating', 'Type', 'Industry'};
        }else if(obj == 'Asset'){
            defld = new List<String>{'Name', 'Product2Id', 'Price', 'Quantity', 'AccountId', 'ContactId'};
        }else if(obj == 'Campaign'){
            defld = new List<String>{'Name', 'isActive', 'Type', 'Status', 'StartDate', 'EndDate'};
        }else if(obj == 'Case'){
            defld = new List<String>{'CaseNumber', 'OwnerId', 'AccountId', 'ContactId', 'Status', 'Priority', 'Origin'};
        }else if(obj == 'Contact'){
            defld = new List<String>{'Name', 'AccountId', 'Phone', 'Email'};
        }else if(obj == 'Contract'){
            defld = new List<String>{'AccountId', 'Status', 'StartDate', 'ContractTerm'};
        }else if(obj == 'Lead'){
            defld = new List<String>{'FirstName', 'LastName', 'Company', 'LeadSource'};
        }else if(obj == 'Opportunity'){
            defld = new List<String>{'Name', 'Amount', 'Probability', 'StageName', 'CloseDate', 'ForecastCategoryName'};
        }else if(obj == 'Order'){
            defld = new List<String>{'AccountId', 'ContractId', 'Status', 'EffectiveDate', 'Type'};
        }else if(obj == 'Product'){
            defld = new List<String>{'Name', 'isActive', 'Family'};
        }else if(obj == 'Solution'){
            defld = new List<String>{'SolutionName', 'isPublished', 'SolutionNumber', 'Status'};
        }else if(obj == 'User'){
            defld = new List<String>{'FirstName', 'LastName', 'Alias', 'Email', 'UserName', 'CommunityNickname'};
        }else if(obj == 'Task'){
            defld = new List<String>{'Subject', 'WhoId', 'WhatId', 'Status', 'ActivityDate', 'Type'};
        }else if(obj == 'Event'){
            defld = new List<String>{'Subject', 'StartDateTime', 'EndDateTime', 'ActivityDate', 'whoId', 'whatId'};
        }
        else{
            defld = getNameUniqueField(obj);
        }
        List<String> toReturn = new List<String>();
        for(String f: defld){
            if(isFieldPresent(obj, f)){
                toReturn.add(f);
            }
        }
        return toReturn;
    }
    
    public List<String> getNameUniqueField(String objType){   
        
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
    public Pagereference back(){
        MyUSer__C user;
        userInfo__C customUser ;
        id uId = apexpages.currentPage().getParameters().get('userId');
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');//isCreate, isTable, isGlobalTable, isTaskEvent, isHome
            customUser= UserInfo__c.getInstance(user.Name);
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
        }
        //customUser.isHome__c  =true;
        //customUser.isTable__c = false;
       // update customUser;
        Pagereference pgr = new Pagereference('/apex/headerMainPage');
        
        pgr.getParameters().put('UserId', apexpages.currentPage().getparameters().get('UserId'));
       // pgr.setRedirect(true);
        return pgr;
    }
    public class RelatedRecordWrapper{
        public String relatedObjPluralName {get; set;}
        public String relatedObjName {get;set;}
        public String relQuery {get;set;}
        public List<String> relFieldLst {get;set;}
        public Integer index {get;set;}
        public RelatedRecordWrapper(String relatedObjName, String relatedObjPluralName, String relQuery, List<String> relFieldLst, Integer i){
            this.relatedObjName = relatedObjName;
            this.relatedObjPluralName = relatedObjPluralName;
            this.relQuery = relQuery;
            this.relFieldLst = relFieldLst;
            this.index = i;
        }
    }
    
    
    
    
     
    public  Accessibility objAccessibiblity {get; set;}
    public Accessibility accessibility1 {get;set;}
    public Accessibility accessibility2 {get;set;}
    //public List<Account> permittedrecordList{get;set;}
    public List<FieldName> permittedfieldList {get;set;}
    public String objectName {get;set;}
    @testVisible String objectNameWithNamespace;
    @testVisible String namespacePrefix;
    
    public void CheckPermission(){
        objAccessibiblity =  new Accessibility();
        // profileName='installer';
        Boolean namespaceExists = initObjectAndNameSpacePrefix();
        if(namespaceExists){
           // initFields();
            //initRecords();
            initaccessibility1();
            initaccessibility2();
        }else{
            initFieldsWithoutNameSpace();
            initaccessibility1WithoutNameSpace();
            //initaccessibility2WithoutNameSpace();
            
        }
        objAccessibiblity= accessibility1;
    }
    
    @testVisible void initaccessibility1(){
        accessibility1 = new Accessibility();
        accessibility1.Email = '';
        accessibility1.Profile = profileName;
        initObjectAccessibility(accessibility1);
        initFieldAccessibility(accessibility1, objectNameWithNamespace);
    }
    
    
    @testVisible void initaccessibility2(){
        accessibility2 = new Accessibility();
        accessibility2.Email = '';
        accessibility2.Profile = profileName;
        initObjectAccessibility(accessibility2);
        initFieldAccessibility(accessibility2, objectNameWithNamespace);
    }
    
    @testVisible void initObjectAccessibility(Accessibility accessibility){
        list<ObjectPermissions> objper = [SELECT Id,SObjectType, PermissionsRead, PermissionsEdit, PermissionsCreate, permissionsDelete 
                                          FROM ObjectPermissions 
                                          WHERE parentId IN ( SELECT id 
                                                             FROM permissionset 
                                                             WHERE PermissionSet.Profile.Name = :accessibility.Profile)]; 
        for(ObjectPermissions op : objper){
            Accessibility.ObjectAccess objaccess = new Accessibility.ObjectAccess();
            objaccess.hasReadAccess = op.PermissionsRead;
            objaccess.hasEditAccess = op.PermissionsEdit;
            objaccess.hasCreateAccess = op.PermissionsCreate;
            objaccess.hasdeleteAccess = op.permissionsDelete;
            accessibility.objectAccessibility.put((string)op.SObjectType.toLowerCase(), objaccess);
        }
    }
    
    @testVisible void initFieldAccessibility(Accessibility accessibility, String objectNameWithNamespace){
        list<FieldPermissions> fldper =  [SELECT Id,Field, PermissionsRead, PermissionsEdit 
                                          FROM FieldPermissions 
                                          WHERE parentId IN (SELECT id 
                                                             FROM permissionset 
                                                             WHERE PermissionSet.Profile.Name = :accessibility.Profile)
                                          AND sObjectType = :objectNameWithNamespace]; 
        for(FieldPermissions fp:fldper){
            Accessibility.FieldAccess fldaccess=new Accessibility.FieldAccess();
            fldaccess.hasReadAccess = fp.PermissionsRead;
            fldaccess.hasEditAccess = fp.PermissionsEdit;
            accessibility.Fieldaccessibility.put(fp.Field, fldaccess);
        }
        adjustFieldAccessibilityMap(accessibility.Fieldaccessibility);
    }
    
    
    @testVisible void initRecordAccessibility(Accessibility accessibility){
        
    }
      
    
    
    
    
    @testVisible void adjustFieldAccessibilityMap(Map<String, Accessibility.FieldAccess> fieldAccessMap){
        for(FieldName fld: permittedfieldList){
            Accessibility.FieldAccess fldaccess=new Accessibility.FieldAccess();
            
            if(!fieldAccessMap.containsKey(fld.fieldNameWithNamespace) && !getRequiredFields().contains(fld.fieldNameWithoutNamespace)){
                fldaccess.hasReadAccess = false;
                fldaccess.hasEditAccess = false;
                fieldAccessMap.put(fld.fieldNameWithNamespace, fldaccess);
                
            }else{
                
                fldaccess.hasReadAccess = true; // Undefined???????????????
                fldaccess.hasEditAccess = true; // Undefined???????????????
                fieldAccessMap.put(fld.fieldNameWithNamespace, fldaccess);
            }
        }
    }
    
    public Boolean initObjectAndNameSpacePrefix(){
        ApexClass cs = [select NamespacePrefix from ApexClass where Name =:getClassName()];
        namespacePrefix = cs.NamespacePrefix;
        objectName = objName;
        if(namespacePrefix != null){
            objectNameWithNamespace = namespacePrefix + '__' + objectName;
            return true;
        }else{
            return false;
        }
    }
    
    @testVisible String getClassName(){
        return String.valueOf(this).split(':')[0];
    }
    
    @testVisible List<String> getRequiredFields(){
        List<String> reqfields = new List<String>();
        for(String fld: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getmap().keyset()){
            if(isRequired(objectName, fld)){
                reqfields.add(fld);
            }
        }
        return reqfields;
    }
    
    public Boolean isRequired(String obj, String fld){
        return !Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(fld).getDescribe().isNillable();
    }    
    public class FieldName{
        public String fieldNameWithoutNamespace {get;set;}
        public String fieldNameWithNamespace {get;set;}
        public FieldName(String fieldNameWithoutNamespace, String fieldNameWithNamespace){
            this.fieldNameWithoutNamespace = fieldNameWithoutNamespace; 
            this.fieldNameWithNamespace = fieldNameWithNamespace;
        }
    }
    @testVisible void initaccessibility1WithoutNameSpace(){
        accessibility1 = new Accessibility();
        accessibility1.Email = '';
        accessibility1.Profile = profileName;
        initObjectAccessibility(accessibility1);
        initFieldAccessibilityWithoutNameSpace(accessibility1, objectName);
    }
    /*@testVisible void initaccessibility2WithoutNameSpace(){
accessibility2 = new Accessibility();
accessibility2.Email = '';
accessibility2.Profile = profileName;
initObjectAccessibility(accessibility2);
initFieldAccessibilityWithoutNameSpace(accessibility2, objectName);
}*/
    @testVisible void initFieldAccessibilityWithoutNameSpace(Accessibility accessibility, String objname){
        list<FieldPermissions> fldper =  [SELECT Id,Field, PermissionsRead, PermissionsEdit, sobjectType, ParentId 
                                          FROM FieldPermissions 
                                          WHERE parentId IN (SELECT id 
                                                             FROM permissionset 
                                                             WHERE PermissionSet.Profile.Name = :accessibility.Profile)
                                          AND sObjectType = :objname]; 
        for(FieldPermissions fp:fldper){
            
            Accessibility.FieldAccess fldaccess=new Accessibility.FieldAccess();
            fldaccess.hasReadAccess = fp.PermissionsRead;
            fldaccess.hasEditAccess = fp.PermissionsEdit;
            accessibility.Fieldaccessibility.put(fp.Field.toLowerCase() , fldaccess);
        }
        adjustFieldAccessibilityMapwithoutNameSpace(accessibility.Fieldaccessibility);
    }
    @testVisible void initFieldsWithoutNameSpace (){
        permittedfieldList = new List<FieldName>();
        String s = objectName + '.';
        for(String fld: getDefaultFields(objectName)){
            
            FieldName fn = new FieldName(fld.toLowerCase(), s+fld.toLowerCase());
            permittedfieldList.add(fn);
        }
    }
    @testVisible void initRecordsWithoutNameSpace(){
        //String query = 'SELECT '+ String.join(getfieldLst(), ', ') + ' FROM ' + objectName + ' Limit 10';
        
        //permittedrecordList = Database.query(query);
    }
    @testVisible void adjustFieldAccessibilityMapwithoutNameSpace(Map<String, Accessibility.FieldAccess> fieldAccessMap){
        
        List<String> reqFld = getRequiredFields();
        for(FieldName fld: permittedfieldList){
            //fld.fieldNameWithoutNamespace = getParentObjectField(objName, fld.fieldNameWithoutNamespace);
            Accessibility.FieldAccess fldaccess=new Accessibility.FieldAccess();
            
            if( !reqFld.contains(fld.fieldNameWithoutNamespace.toLowerCase())){
                string f = getParentObjectField(fld.fieldNameWithNamespace).toLowerCase();
                if(!fieldAccessMap.containsKey(f)){
                    
                    fldaccess.hasReadAccess = false;
                    fldaccess.hasEditAccess = false;
                    fieldAccessMap.put(fld.fieldNameWithoutNamespace, fldaccess);
                    
                }else{
                    
                    fldaccess.hasReadAccess = fieldAccessMap.get(f).hasReadAccess; // Undefined???????????????
                    fldaccess.hasEditAccess = fieldAccessMap.get(f).hasEditAccess;// Undefined???????????????
                    fieldAccessMap.put(fld.fieldNameWithoutNamespace, fldaccess);
                }
            }else{
                
                fldaccess.hasReadAccess = true; // Undefined???????????????
                fldaccess.hasEditAccess = true; // Undefined???????????????
                fieldAccessMap.put(fld.fieldNameWithoutNamespace, fldaccess);
            }
            
        }
    }
    
    public String getParentObjectField(String fld){
        
        String newFld = fld;
        Map<String, sobjectType> sp = Schema.getGlobalDescribe();
        if(fld.containsIgnoreCase(sp.get(objName).getDescribe().getName())){
            fld = fld.substring(sp.get(objName).getDescribe().getName().length() + 1);
        }
        Schema.DescribeFieldResult f = sp.get(objName).getDescribe().fields.getMap().get(fld).getDescribe();
        if(f.getRelationshipName() != null){
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                fld= sp.get(objName).getDescribe().getName().toLowerCase() +'.'+ reference.getDescribe().getName().toLowerCase();
                
            }
        }else{
            fld = newFld;
        }    
        
        return fld;
        
    }
}