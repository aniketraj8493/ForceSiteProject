public class DetailPageController {
    public string query {get; set;}
    public list<String> fieldLst {get; set;}
    
    public DetailPageController(){
        query = 'SELECT Name, Industry, Type, Phone From Account';
        fieldLst = new list<string>();
        fieldLst.add('name');
        fieldLst.add('Industry');
        fieldLst.add('Type');
        fieldLst.add('Phone');
        
    }

}