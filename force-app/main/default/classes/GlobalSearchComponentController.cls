public class GlobalSearchComponentController {
    
    public List<SearchWraperClass> globalList {get; set;}
    public string searchQuery {get; set;}
    @testVisible string query ;
    public void setQuery(string q){
        if(query == null || query != q)
            query =q;
    }
    public String getquery(){
        System.debug('SSSSSSSSSSSSSS' + query);
        return query;
    }
    public String objName {get;set;}
    public boolean isPagination {get; set;}
    public list<String> fieldList {get; set;}
    public string delRecordId {get; set;}
    @testVisible String profileName {get; set;}
    @testVisible String searchTerm;
    @testVisible List<String> objApiName = new List<String>{'account', 'opportunity', 'contact'};
    @testVisible List<String> fieldSetName = new List<String>{'FS_Account_Site', 'FS_Opportunity', 'FS_Contact'};
	
    @testVisible Boolean isEditCalled;
    public void setProfilename(String pr){
        System.debug(profileName);
       
        if(ProfileName == null){
            profileName = pr;
        }
    }
    public String getProfilename(){
        return profileName;
    }
    public Boolean openModal{get{
        Myuser__c user;
        UserInfo__c customUser;
        
        try{
            id uId = apexpages.currentPage().getParameters().get('userId');
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');//isCreate, isTable, isGlobalTable, isTaskEvent, isHome
            customUser= UserInfo__c.getInstance(user.Name);
            
            
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
           
        }
         return  customUser.isCreate__c;
    } set;}
    public String rId {get;set;}          
      
    public GlobalSearchComponentController(){
        isEditCalled = false;
        openModal = false;
        isPagination = false;
        globalList = new List<SearchWraperClass>();
    }
    public String getsearchTerm(){
        return searchTerm;
    }
    public void setsearchTerm(String text){
        System.debug(text  + '   ' + isPagination);
        if(searchTerm!=text){
          isPagination= false;
            searchTerm= text;
        }
        if(!isEditCalled){
            openModal = false;
            isEditCalled = false;
        }
        if(isshowMore != text){
             isPagination= false;
        }
        globalList.clear();
        getSearchResult();
    }
    public PageReference getSearchResult(){
        if(searchTerm.length() > 1){
            String searchStr1 = '*'+searchTerm+'*';
            searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING ';
            for(String s : objApiName){
                searchQuery += s + ' (' + String.join(getFields(s), ', ') + ' ), ';
            }
            searchQuery = searchQuery.substring(0, searchQuery.lastIndexOf(','));
            List<List <sObject>> searchList;
            try{
                searchList   = search.query(searchQuery);
            }catch(Exception e){
                searchList = new List<List <sObject>>();
                apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, 'exception occures in search query ' + e.getMessage()));
            }
            if(searchList[0].size() == 0 && searchList[1].size() == 0 && searchList[2].size() == 0){
                apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING, 'No matches found'));
                
            }else{
                SearchWraperClass swrap ;
                for(List<sobject> sl : searchList){
                    integer recordSize = sl.size();
                    if(sl.size() > 3){
                        while(sl.size() > 3){
                            sl.remove(sl.size()-1);
                            
                        }
                    }
                    for(String obj: objApiName){
                        Schema.SObjectType objtype = Schema.getGlobalDescribe().get(obj);
                        if(sl.getSobjectType() == objtype){  
                            swrap= new SearchWraperClass();
                            swrap.count = recordSize;
                            
                            swrap.wObjLst= castRecord(sl, objtype);
                            swrap.wObjName = obj;
                            swrap.wFldLst = getFields(obj);
                            globalList.add(swrap);
                            
                        }
                    }
                }
            }
        }
        else if(searchTerm==''){
            Pagereference pgr = new Pagereference('/apex/HeaderMainPage');
            return pgr;
        }else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            
        }
        return null;
    }
    
    public List<sObject> castRecord(List<sObject> rec, Schema.SObjectType sObjType){
        
        List<sObject> castRecords = new List<Account>();
        
        if (sObjType != null)
        {
            String listType = 'List<' + sObjType + '>';
            castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(rec);
        }
        
        return castRecords;
    }
    
    public list<string> getFields(String selectedobj){
        list<String> searchLst = new List<String>();
        integer index = objApiName.indexOf(selectedobj);
        searchLst = getFieldsFromFieldSet(index);
        return searchLst;
    }
    public String isShowMore ;
    public Pagereference showMore(){
        
        isShowMore = searchTerm;
        fieldList = getFields(objName.toLowerCase());
          query = 'FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING ';
            
                query +=  objName.toLowerCase()+ ' (' + String.join(fieldList, ', ') + ' ), ';
            
      /*  query = searchQuery.substring(0, searchQuery.indexOf('account'));
        query += objName + ' (' + String.join(getFields(objName.toLowerCase()), ', ') + ' )';*/
     isPagination = true;
        return null;
    }
    
    public String dummyObjName {get;set;}
    
    public void turnOffModal(){
        openModal = false;
    }
    
    public PageReference editRecord(){ 
        userInfo__C customUser;
        Myuser__c user;
        id uId = apexpages.currentPage().getParameters().get('userId');
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c, name, Profile__C FROM MyUSer__C Where id = :uId limit 1');//isCreate, isTable, isGlobalTable, isTaskEvent, isHome
            
            customUser= UserInfo__c.getInstance(user.Name);
            customuser.isCreate__c = true;
            update customUser;
            
        }catch(Exception e){
            user = new MyUser__C();
            customUser =new UserInfo__C();
        }
        
        isEditCalled = true;
        openModal = customUser.isCreate__c;
        return null;
    }

    public PageReference deleteRecord(){
        openModal = false;
        
        String q = 'SELECT id FROM ' + dummyObjName + ' WHERE id = \'' + delRecordId + '\'';
        
        try{
            list<sobject> s= database.query(q);
            delete s;
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.CONFIRM, 'Record Deleted Successfully'));
        }catch(Exception e){
            
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, e.getMessage()));   
        }
        
        return null;
    }
    @testVisible List<String> getFieldsFromFieldSet(Integer index){
        List<String> sfld = new List<String>();
        try{
            if(Schema.getGlobalDescribe().get(objApiName[index].toLowerCase()).getDescribe().FieldSets.getMap() == null || !Schema.getGlobalDescribe().get(objApiName[index].toLowerCase()).getDescribe().FieldSets.getMap().containsKey(fieldSetName[index].toLowerCase())){
                return sfld;
            }
            for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(objApiName[index].toLowerCase()).getDescribe().FieldSets.getMap().get(fieldSetName[index].toLowerCase()).getFields())
                sfld.add(f.getFieldPath().toLowerCase());
            
        }catch(Exception e){
            
        }
        return sfld;
    }
    public class SearchWraperClass{
        public integer count {get; set;}
        public String wObjName {get; set;}
        public List<sobject> wObjlst {get; set;}
        public list<string> wFldlst {get; set;}
        
        public SearchWraperClass(){
            wObjlst = new List<sObject>();
            wFldlst = new List<string>();
        }
    }
    
}