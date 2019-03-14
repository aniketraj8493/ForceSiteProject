public class PaginationComponentController {
    
    @testVisible String query;
    
    @testVisible String queryType;
    
    @testVisible String objName;
    
    @testVisible List<String> fieldLst;
    
    @testVisible Integer QUERY_LIMIT;
    
    @testVisible Integer initialPageSize;
    
    public id recId {get; set;}
    public boolean isTask {get; set;}
    public String profileName{get;set;}
    public list<string> recordIdLst {get; set;}
    public List<RecordWrapper> recordList {get;set;}
    
    public Map<Id, RecordWrapper> mapHoldingRecordList {get;set;}
    
    public Integer pageSize {get;set;}
    
    public Boolean isSelectAll {get;set;}
    
    public Integer selectedTotal{get;set;}
    
    // initialized to DateTime.now() when setCon is initiallized
    @testVisible DateTime setControllerBirthday {get; set;} 
    
    // Make SetController safe 
    private void BubblewrapSetController() {
  
        if (setControllerBirthday < Datetime.now().addMinutes(-10)) {
            Integer pageNum = setCtrl.getPageNumber();  //maintain current page
            Id filterId = setCtrl.getFilterId();        //maintain current filter
   
            setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            setctrl.setFilterId(filterId);                //restore filter
            setCtrl.setPageNumber(pageNum);             //restore page
            setControllerBirthday = DateTime.now();    //restart the clock
        }
    }
    
    // Sorting a Column
    private Boolean updateQuery = true;
    private String sortDirection = '';
    private String sortExp = '';
    private string sortFullExp = '';
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp){
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }
            else{
               sortDirection = 'ASC';
            }
            
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    public String getqueryType(){
        return queryType;
    }
    public String dumobj ;
    public string refereshMode;
    userInfo__C customUser;
    public string  dummyquery ;
     Myuser__C user;
    public void setqueryType(String qt){
       
        
        id uId = apexpages.currentPage().getParameters().get('userId');
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');//isCreate, isTable, isGlobalTable, isTaskEvent, isHome
            customUser= UserInfo__c.getInstance(user.Name);
           // recordList = new List<RecordWrapper>();
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
        }
       
        if(queryType == null || dumobj != objName || qt != queryType || refereshMode =='update' || refereshMode == 'delete'){
            
            queryType = qt;
            setCtrl = null;
            CheckPermission();
            init();
            if(refereshMode == 'delete')
                selectedTotal = 0;
            dumobj = objName;
            refereshMode='';
            customUser.isGlobalTable__c = false;
            dummyquery = query;
        }
    }
   
    public String getquery(){
        return query;
    }
    
    public void setquery(String q){
      
        if(query == null || query != q){
            query = q;
        }
    }
    
    public String getobjName(){
        return objName;
    }
    
    public void setobjName(String o){
         isSelectAll = false;
        if(objName == null || objName != o){
        
           mapHoldingRecordList = new Map<Id, RecordWrapper>();
            objName = o;
            selectedTotal=0;
            isSelectAll = false;
            setCtrl = null;
            
        }
        
    }
    
    public List<String> getfieldLst(){
       
        return fieldLst;
    }
    
    public void setfieldLst(List<String> fidLst){
        if(fieldLst == null || fieldLst != fidLst){
            fieldLst = fidLst;
            
        }
    }
    
    public Integer getQUERY_LIMIT(){
        return QUERY_LIMIT;
    }
    
    public void setQUERY_LIMIT(Integer ql){
        if(QUERY_LIMIT == null){
            QUERY_LIMIT = ql;
        }
    }
    
    public Integer getinitialPageSize(){
        return initialPageSize;
    }
    
    public void setinitialPageSize(Integer ips){
        if(initialPageSize == null){
            initialPageSize = ips;
        }
    }
    
    public PageReference sortData() {
        //build the full sort expression
        sortFullExp = sortExpression  + ' ' + sortDirection;
        //query the database based on the sort expression
        updateQuery = true;
        init();
        return null;
    }
    
    public List<String> getNameUniqueField(String objType)
    {  
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
    
    public void adjustQueryForSoql(){
        Integer index = query.indexOf('ORDER BY');
        if(index != -1){
            query = query.substring(0, index);
        }
        query += ' ORDER BY ';   
        if(sortExpression != null && sortExpression != '' && sortDirection != null && sortDirection != ''){
            query += sortFullExp;
        }else{
            query += getNameUniqueField(objName)[0] + ' ASC';
        }
        query += ' LIMIT ' + QUERY_LIMIT ;
        updateQuery = false;
    }
    
    public void adjustQueryForSosl(){
        String q = query.substring(0, (query.lastIndexOf(')')));
        q += ' ORDER BY ';
        if(sortExpression != null && sortExpression != '' && sortDirection != null && sortDirection != ''){
            q += sortFullExp;
        }else{
            
            q += getNameUniqueField(objName)[0] + ' ASC';
        }
         q += ' ) LIMIT ' + QUERY_LIMIT ;
        
      query =q;
        updateQuery = false;
    }
    
    ApexPages.StandardSetController setCtrl{get{
       
    	if(setCtrl == null || updateQuery){
            try{
                if(queryType == 'SOQL'){
                    adjustQueryForSoql();
                    setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                }else if(queryType == 'SOSL'){
                    adjustQueryForSosl();
                    setCtrl = new ApexPages.StandardSetController(Search.Query(query)[0]);
                }
            }catch (Exception e) {
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, e.getMessage()));
                setCtrl = new ApexPages.StandardSetController(new List<Account>());
            }
            pageSize = (pageSize == null)? initialPageSize: pageSize;
            selectedTotal = 0;
        }
        return setCtrl;
    }set;}
    
    public PaginationComponentController(){
        refereshMode = '';
        recordList = new List<RecordWrapper>();
        mapHoldingRecordList = new Map<Id, RecordWrapper>();
        setControllerBirthday = DateTime.now();
    }
    
    public void init(){
        
        
        setCtrl.setPageSize(pageSize);
        updatemapHoldingRecordList();
        recordList = new List<RecordWrapper>();
        if(accessibility1.objectAccessibility.containskey(objName.toLowerCase())){
            
            for(sObject rec: setCtrl.getRecords()){
             
            if(mapHoldingRecordList != null && mapHoldingRecordList.containsKey(rec.Id)){
                recordList.add(mapHoldingRecordList.get(rec.Id));
            }else{
                recordList.add(new RecordWrapper(rec, false));
            }
        }
        }
    }
    
    public void updatemapHoldingRecordList() {
        recordIdLst = new List<String>();
            for(RecordWrapper recWrap : recordList){
                if(recordToDelete != null && recordToDelete.size() > 0){
                    if(recWrap.isSelected && !recordToDelete.contains(recWrap.record.id)){
                        mapHoldingRecordList.put(recWrap.record.id, recWrap);
                        recordIdLst.add(recWrap.record.id);
                    }
                    
                }else{
                    if(recWrap.isSelected){
                        mapHoldingRecordList.put(recWrap.record.id, recWrap);
                        recordIdLst.add(recWrap.record.id);
                    }
                }
                if(recWrap.isSelected == false && mapHoldingRecordList.containsKey(recWrap.record.id)){
                    if(recordIdLst.contains(recWrap.record.id))
                        recordIdLst.remove(recordIdLst.indexOf(recWrap.record.id));
                    mapHoldingRecordList.remove(recWrap.record.id);
                }
            }
        selectedTotal = mapHoldingRecordList.size();
    }
    
    public PageReference showRelatedList(){
        PageReference pgr = new PageReference('/apex/HeaderMainPage');
        pgr.getParameters().put('recId', recid);
        pgr.getParameters().put('objectName', objName);
        pgr.getParameters().put('UserId', apexpages.currentPage().getparameters().get('Userid'));
        //pgr.setRedirect(true);
       
        return pgr;
    }
    public void saveRecordWrapper(){
        List<sObject> recs = new List<sObject>();
        for(RecordWrapper recWrap : recordList){
            if(recWrap.isSelected){
                recs.add(recWrap.record);
                mapHoldingRecordList.put(recWrap.record.id, recWrap);
            }
            if(recWrap.isSelected == false && mapHoldingRecordList.containsKey(recWrap.record.id)){
                mapHoldingRecordList.remove(recWrap.record.id);
            }
        }
        selectedTotal = mapHoldingRecordList.size();
    }
    
    public void saveRecords(List<sObject> recs){
        try{
            update recs;
        }catch(Exception e){
            
        }
    }
    
    public Integer getpageNumber(){
        return setCtrl.getpageNumber();
    }
    
    public Integer getresultSize(){
        return setCtrl.getResultSize();
    }
    
    
    public Boolean gethasNext(){
        return setCtrl.getHasNext();
    }
    
    public Boolean gethasPrevious(){
        return setCtrl.getHasPrevious();
    }
    
    public void next(){
        dummyquery='';
        BubblewrapSetController();
        setCtrl.next();
        init();
    }
    
    public void previous(){
        BubblewrapSetController();
        setCtrl.previous();
        init();
    }
    
    public void first(){
        BubblewrapSetController();
        setCtrl.first();
        init();
    }
    
    public void last(){
        BubblewrapSetController();
        setCtrl.last();
        init();
    }

    public PageReference updateRecords(){
       
        if(accessibility1.objectAccessibility.containskey(objName)){
            Accessibility.ObjectAccess objAccess = accessibility1.objectAccessibility.get(objName);
            if(objAccess.hasEditAccess){
                updatemapHoldingRecordList();
            System.debug(mapHoldingRecordList.values());
            list<sobject> recordToUpdate  = new list<sobject>();
            for(id rId : mapHoldingRecordList.keySet()){
                Sobject s = mapHoldingRecordList.get(rId).dummyRecord;
                s.put('id', rId);
                recordToUpdate.add(s);
            }
            
            Database.SaveResult []srList = Database.update(recordToUpdate, false);
            String error = '';
            for(Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                     refereshMode = 'update';
                }
                else {               
                    for(Database.Error err : sr.getErrors()) {
                        error += ('<b>' + err.getStatusCode() + '</b>: ' + err.getMessage()) + '<br/><br/>';
                        if(err.getFields().size() > 0)
                            error += ('Fields that affected this error: ' + err.getFields() + '<br/><br/>');
                    }
                }
            }
            if(error != ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }else{
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All selected records have been updated successfully'));
            } 
            }else{
               updateQuery =true;
                ApexPages.addMessage(new ApexPages.message(apexpages.Severity.WARNING, 'Insufficient Privileges'));
                 init();
            }
        }
        return null;
    }
    list<id> recordToDelete ;
    public PageReference deleteRecords(){
       
       
        if(accessibility1.objectAccessibility.containskey(objName)){
            
            Accessibility.ObjectAccess objAccess = accessibility1.objectAccessibility.get(objName);
            if(objAccess.hasDeleteAccess){
                
                recordToDelete = new list<id>();
                updatemapHoldingRecordList();
                recordToDelete.addAll(mapHoldingRecordList.keySet());
                Database.DeleteResult []srList = Database.delete(recordToDelete, false);
                String error = '';
                recordToDelete  = new list<id>();
                for(Database.DeleteResult sr : srList) {
                    if (sr.isSuccess()){
                         refereshMode= 'delete';
                        recordToDelete.add(sr.getId());
                        mapHoldingRecordList.remove(sr.getId());
                        
                    }
                    else {               
                        for(Database.Error err : sr.getErrors()) {
                            error += ('<b>' + err.getStatusCode() + '</b>: ' + err.getMessage()) + '<br/><br/>';
                            if(err.getFields().size() > 0)
                                error += ('Fields that affected this error: ' + err.getFields() + '<br/><br/>');
                        }
                    }
                }
                if(error != ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }else{
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All selected records have been deleted successfully'));
                } 
            }else{
                 updateQuery =true;
                 init();
                 ApexPages.addMessage(new ApexPages.message(apexpages.Severity.WARNING, 'Insufficient Privileges!! Please Contact your Adminsitrator'));
            }
        }
         createHistory();
        return null;
        
    }
    
    public Pagereference createtask(){
        try{
            updatemapHoldingRecordList();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        isTask = true;
        return null;
    }
    
    public class RecordWrapper{
        
        public sObject record {get;set;}
        public sObject dummyRecord {get;set;}
        public Boolean isSelected {get;set;}
        
        public RecordWrapper(sObject record, Boolean isSelected){
            this.record = record;
            this.dummyRecord = record.clone();
            this.isSelected = isSelected;
        }
    }
    
    
    ///####Create History #### ///////////////
    public void createHistory(){
         
        
        list<SiteHistory__C> siteHistoryObjlst = new List<SiteHistory__C>();
      
        SiteHistory__C histryobj;
        
        System.debug( objName + 'in update ' + user);
        switch on objName {
            when 'account' {
                for(id sId : recordToDelete){
                    histryobj = new SiteHistory__C();
                    if(user != null){
                        histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                        histryobj.Email__c = user.Name;
                        histryobj.Account__c = sId;
                    }
                    siteHistoryObjlst.add(histryobj);
                }
            }
            when 'opportunity' {
                for(id sId : recordToDelete){
                    histryobj = new SiteHistory__C();
                    if(user != null){
                        histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                        histryobj.Email__c = user.Name;
                        histryobj.opportunity__C = sId;
                    }
                    siteHistoryObjlst.add(histryobj);
                }
            }
            when 'contact' {
                 for(id sId : recordToDelete){
                    histryobj = new SiteHistory__C();
                    if(user != null){
                        histryobj.user_Name__C = user.First_Name__C + ' ' + user.Last_Name__C;
                        histryobj.Email__c = user.Name;
                        histryobj.contact__C = sId;
                    }
                    siteHistoryObjlst.add(histryobj);
                }
            }
        }
        Database.SaveResult [] srList;
        if(siteHistoryObjlst != null){
            srList = Database.insert(siteHistoryObjlst);
        }
        String error='';
        for(Database.SaveResult sr : srList) {
            if (sr.isSuccess()){
            }
            else {               
                for(Database.Error err : sr.getErrors()) {
                    error += ('<b>' + err.getStatusCode() + '</b>: ' + err.getMessage()) + '<br/><br/>';
                    if(err.getFields().size() > 0)
                        error += ('Fields that affected this error: ' + err.getFields() + '<br/><br/>');
                }
            }
        }
        if(error != ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
        }else{
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All selected records have been updated successfully'));
        } 
    }
    
    
    
    
    
   //###########The following code is for object level and field level Security//
    
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
            initFields();
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
    
    @testVisible void initFields (){
        permittedfieldList = new List<FieldName>();
        String s = objectNameWithNamespace + '.' + namespacePrefix + '__';
        for(String fld: getfieldLst()){
            FieldName fn = new FieldName(fld, s+fld);
            permittedfieldList.add(fn);
        }
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
        for(String fld: getfieldLst()){
            
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
    
    
    ////###############  History Method ###############///////////////////
    
}