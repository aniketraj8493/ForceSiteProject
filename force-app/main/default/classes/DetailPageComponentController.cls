public class DetailPageComponentController {
    
    @testVisible String objName;
    @testVisible String recId;
    public sObject record {get;set;}
    public sObject dummyRecord {get;set;}
    public list<String> selectedFieldLst {get; set;}
    public String detailMode {get;set;}
    
    public String getobjName(){
        return objName;
    }
    
    public void setobjName(String obNm){
        //System.debug('###' + obNm);
        if(objName == null){
            objName = obNm;
        }
        
    }
    
    public void initRecord(){
        selectedFieldLst= getFieldApiName();
        list<sobject> sobjList ; 
        //System.debug('select ' + String.join(selectedFieldLst, ', ') + ' From ' + objName + ' Where id =  ' + recId);
        sobjList = database.query('select ' + String.join(selectedFieldLst, ', ') + ' From ' + objName + ' Where id =  \'' + recId +'\'');
        
        record = sobjList[0];
        dummyRecord = record.clone();
        dummyRecord.put('id', null);
    }
    public String getrecId(){
        return recId;
    }
    
    public void setrecId(String recordId){
        
        if(recId == null){
            recId = recordId;
            initRecord();
        }
        
    } 
    
    public DetailPageComponentController(){
        detailMode =  'output';
    }
    
    public list<string>  getFieldApiName(){
        
        list<string> fldlst = new list<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            Schema.DisplayType fielddataType = dfr.getType();
            if(dfr.isCreateable()  && dfr.accessible && !fieldName.containsIgnoreCase('geocode')){
                fldlst.add(FieldName);
            }
        }
        if( fldlst.contains('ownerid')){
            fldLst.remove(fldlst.indexOf('ownerid'));
        }
        
        return fldlst ;
    }
        
    public PageReference saveRecord(){
        
        dummyrecord.put('id', Record.get('id'));

        try{
            update dummyrecord;
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.CONFIRM, 'Record Upadte Successfully'));
        }catch(Exception e){
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, e.getMessage()));
        }
        dummyRecord.put('id', null);
        return null;
    }
    
}