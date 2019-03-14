@RestResource(urlMapping='/MyUsers/*')
global class GoogleRestAPI {
    
    @HttpGet
    global static MyUserWrapper getMyUsers() {
        MyUserWrapper response = new MyUserWrapper();
        boolean flag = false;
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String email = req.requestURI.subString(req.requestURI.lastIndexOf('/')+1);
        List<MyUser__c> u_list = [SELECT Name from MyUser__c];
        for(MyUser__c myuser : u_list){
            if(myuser.Name==email){
                Flag=true;
                break;
            }
        }
        
        if(flag){
            response.status='Yes';
            response.error='NO Error';
        }
            else
            {
                response.status='No';
                response.error='Email not Found';
            }
            return response;
        }
        
        @HttpPost
        global static String createNewMyUser(String Name) {
            MyUser__c u = new MyUser__c();
            u.Name = Name;
            insert u;
            
            return 'Done';
        }
        
        @HttpDelete
        global static String deleteMyUserById() {
            String Id = RestContext.request.params.get('Id');
            List<MyUser__c> u = [ Select ID from MyUser__c where Id= :Id];
            
            delete u;
            
            return 'Deleted MyUser';
        }
        
        @HttpPut
        global static String updateMyUser(String Id, String NewName) {
            MyUser__c u = [ Select ID, Name from MyUser__c where Id= :Id];
            
            u.Name = NewName;
            update u;
            
            return 'MyUser Updated';
        }
        global class MyUserWrapper{
            public string status;
            public string error;
            public MyuserWrapper(){
                status='NA';
                error ='NA';
            }
        }
    }