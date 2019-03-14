public with sharing class GoogleAuthController {
    
    public boolean isrecordlistVisible {get; set;}
    public string authtoken{get;set;}
    public string refereshtoken{get;set;}
    public string bodyprint{get;set;}
    public string mybodyprint{get;set;}
    public string status{get;set;}
    public string accessToken;
    public string instanceUrl;
    public string tokenType;
    public string userlist;
    public  String userEmail;
    public MyUser__c user {get; set;}
    public String uid {get; set;}
    private Boolean flag = true;
    public Boolean isLoggedIn {get;set;}
    public boolean isEmailVerified = false;
    public UserInformation userinfo{get;set;}
    
    public Account acc{get;set;}
    public Contact con{get;set;}
    public Opportunity opp{get;set;}
    public String objName{get;set;}
    public String functionality{get;set;}
    public list<String> objList {get; set;}
    
    public static String ORG_CLIENT_SECRET; //Fill as per your registered app settings in connected app
    public static String ORG_CLIENT_ID; //Fill as per your registered app settings in connected app
    public static String ORG_USER_NAME;
    public static String ORG_PASSWORD;
    public static String ORG_SECURITY_TOKEN;
    
    //Settings needed on the Org's Connected App can store this securely in custom settings or an object.
    /*public static final String ORG_CLIENT_SECRET='6046675481206057014'; //Fill as per your registered app settings in connected app
    public static final String ORG_CLIENT_ID='3MVG9dZJodJWITStIS6tSI5SP_TRXImUbc64Vw.qvbfjkTGsYkCQ_5RThPKKCbGWdV7nZ1GUH_OqqDx4QzNQW'; //Fill as per your registered app settings in connected app
    public static final String ORG_USER_NAME='sales@alienbrainz.com.sf';
    public static final String ORG_PASSWORD='Qwertyuiop@%23%2412345';
    public static final String ORG_SECURITY_TOKEN='ti0tK8HnvzNbC2kIf2km9RgPk';*/
    
    public static final String ORG_CODE_END_POINT_URL='https://login.salesforce.com/services/oauth2/token?';
    public static final String ORG_GRANT_TYPE='password';
    public static final String ORG_REDIRECT_URL='http://localhost:8080/';
    
    public static String CLIENT_SECRET; //Fill as per your registered app settings in google console
    public static String CLIENT_ID; //Fill as per your registered app settings in google console
    public static String REDIRECT_URL;
    
    //Settings needed on the google cloud console.One can store this securely in custom settings or an object.
    /*public static final String CLIENT_SECRET='ZpH3EjBufPYchj1t97yerzaA'; //Fill as per your registered app settings in google console
    public static final String CLIENT_ID='472650385442-r0gt7rpvg4f54ao65hiq5m2so4afrs3p.apps.googleusercontent.com'; //Fill as per your registered app settings in google console
    public static final String REDIRECT_URL='https://sales-bodacious-developer-edition.na57.force.com/GoogleAuth';*/
            
    public static final String OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    public static final String OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
    public static final String OAUTH_PROFILE_FETCH_VIA_ACCESS_TOKEN_END_POINT_URL='https://www.googleapis.com/oauth2/v1/userinfo?access_token='; 
    public static final String GRANT_TYPE='grant_type=authorization_code';
    
    //Scope URL as per oauth 2.0 guide of the google 
    public static final String GSCOPE='https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile';
    public static final String STATE='/profile';
    
    //Approval Prompt Constant
    public static final String APPROVAL_PROMPT='force';
    public string customObj {get; set;}
    public string customFunctionality {get; set;}
   
    public GoogleAuthController(){
        
        objList = new List<String>();
        objList.add('account');
        objList.add('contact');
        objList.add('opportunity');
        initBooleanVariable();
        initsObjects();
        initVariables();

        //passUserId();
    }

    @testVisible void initBooleanVariable(){
        isLoggedIn = false;
    }
    
    public void initsObjects(){
        acc = new Account();
        con = new Contact();
        opp = new Opportunity();

    }
    
    @testVisible void initVariables(){
        objName = '';
        functionality = '';
    }
    
    static{
        initCredentials();
    }
    
    @testVisible static Boolean initCredentials(){
        try{
            List<GoogleAndConnectedAppCredentials__C> gcApp = [SELECT GoogleClientSecret__c, GoogleClientId__c, GoogleRedirectURL__c, OrgClientId__c, OrgClientSecret__c,
                                                               OrgPassword__c, OrgSecurityToken__c, OrgUserName__c FROM GoogleAndConnectedAppCredentials__C];
            CLIENT_SECRET = gcApp[0].GoogleClientSecret__c;
            CLIENT_ID = gcApp[0].GoogleClientId__c;
            REDIRECT_URL = gcApp[0].GoogleRedirectURL__c;
            ORG_CLIENT_SECRET = gcApp[0].OrgClientSecret__c;
            ORG_CLIENT_ID = gcApp[0].OrgClientId__c;
            ORG_USER_NAME = gcApp[0].OrgUserName__c;
            ORG_PASSWORD = gcApp[0].OrgPassword__c;
            ORG_SECURITY_TOKEN = gcApp[0].OrgSecurityToken__c;
          
            if(CLIENT_SECRET==null || CLIENT_ID == null || REDIRECT_URL == null || ORG_CLIENT_SECRET == null || ORG_CLIENT_ID == null || ORG_USER_NAME == null || ORG_PASSWORD == null || ORG_SECURITY_TOKEN == null){
                return false;
            }
            
            return true;
        }catch(Exception e){
            return false;
        }
                
    }
    
    public pagereference connect(){
        Boolean res = initCredentials();
        if(!res){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You lack some custom settings needed for the authorization. Please check your custom settings'));
            return null;
        } 
        String x;
        try{
             x = OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(GSCOPE,'UTF-8')+'&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+'&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You lack some custom settings needed for the authorization. Please check your custom settings'));
            return null;
        }
        pagereference p=new pagereference(x); 
      
        return p;
        
    }
    
    public pagereference showtoken(){
        String codeparam=apexpages.currentpage().getparameters().get('code');
        
        System.debug('codeparam: ' + codeparam);
        
        if(codeparam == null){
            return null;
        }
        
        if(flag){
            // Instantiate a new http object
            Http h = new Http();
            
            String body='code='+codeparam+'&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&redirect_uri='+REDIRECT_URL+'&'+GRANT_TYPE;
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(OAUTH_TOKEN_URL);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setBody(body);
            
            system.debug('REQUEST BODY'+body);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            
            bodyprint=res.getbody();
            flag = false;
        }else{
            
        }
        
        fetchProfile();
        
        return null;
        
    }
    
    // fetching basic information of google account
    public void fetchProfile(){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        JSONParser parser = JSON.createParser(bodyprint);
        GoogleAuthController.JsonId obj;
        try{
            obj = (GoogleAuthController.JsonId)parser.readValueAs( GoogleAuthController.JsonId.class);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        String access_token = obj.access_token;
       
        req = new HttpRequest();
        req.setEndpoint(OAUTH_PROFILE_FETCH_VIA_ACCESS_TOKEN_END_POINT_URL + access_token);
        req.setHeader('Authorization','Authorization '+access_token);
        req.setMethod('GET');
        HttpResponse res;
        res = h.send(req);
        string googleInfo = res.getbody();
       
        JSONparser parser1 = JSON.createParser(googleinfo);
        GoogleInfo obj1;
        try{
            obj1 = (GoogleInfo)parser1.readValueAs(GoogleInfo.class);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        userEmail =obj1.email;
        String verified_email = obj1.verified_email;
        
        if(useremail == null || verified_email == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email not found! Please try reconnecting.'));
        }else{
            getOrgInfo();
            isEmailVerified= true;
            passUserId(userEmail);
        }
        
    }
    
    public void getOrgInfo(){
        
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        httpRequest req= new httpRequest();
        http h = new http();
        HttpResponse res;
        req.setEndpoint(ORG_CODE_END_POINT_URL + 'grant_type=' + ORG_GRANT_TYPE + '&client_id=' + ORG_CLIENT_ID + '&client_secret=' + ORG_CLIENT_SECRET + '&username=' + ORG_USER_NAME + '&password=' + ORG_PASSWORD + ORG_SECURITY_TOKEN);
        req.setMethod('POST');
        res= h.send(req);
        System.debug(res.getBody());
        mybodyprint = res.getBody();
        JSONparser parser = JSON.createParser(mybodyprint);
        OrgInfo obj;
        try{
            obj = (OrgInfo)parser.readValueAs(OrgInfo.class);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        accessToken =obj.access_token;
        instanceUrl = obj.instance_url;
        tokenType =  obj.token_type;
        query();
        checkEmail();
    }
    
    
    public void query(){
        Http h = new Http();
        String url = instanceUrl+'/services/data/v43.0/query?q=SELECT%20Name,%20MyUser_PassWord__c%20FROM%20MyUser__c';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setHeader('Authorization',tokenType+' '+accessToken);
        req.setMethod('GET');
        HttpResponse res;
        try{
            res = h.send(req);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        System.debug(res.getBody());
        userList = res.getBody();
    }
    
    public void checkEmail(){
        
        list<string> name = new List<string>();
        //list<string> password = new List<String>();
        JsonParser parser = Json.createParser(userList);
        JSON2Apex obj;
        try{
            obj = (JSON2Apex)parser.readValueAs(JSON2Apex.class);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return;
        }
        for(integer i =0 ; i < obj.records.size();i++){
            name.add(obj.records[i].name);
            //password=obj.records[0].Myuser_Password_c;
        }
        //System.debug(name);
        status = 'Sorry! Your email is not present in our Database.';
        isLoggedIn = false;
        for(integer i = 0 ; i < name.size() ; i++){
            if(useremail==name[i]){
                status = 'Your Email is found in our Database.';
                isLoggedIn = true;
                initCustomSetting(useremail);
                break;
            }
        }
    }
    public void initCustomSetting(String email){
      MyUser__C myuser = [SELECT Profile__C FROM MyUser__C WHERE name = :email];
        UserInfo__C u = new UserInfo__c();
        u.Name = email;
        u.email_id__c = email;
        u.isLogged_in__C = true;
        u.Profile__c =  myUser.profile__c;
        UserInfo__C ui = UserInfo__c.getInstance(email);
        try{
              if(ui!=null)
            update u;
        else
            insert u;
        }catch(Exception e){
            apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, 'Somthing wrong in fetching user Information from custom setting'));
        }
    }
    
    public PageReference saveAccount(){
        Database.SaveResult srLst = Database.insert(acc, false);
        if(srLst.isSuccess()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Account Created Successfully'));
        }else{
            String msg = '';
            for(Database.Error e: srLst.getErrors()){
                msg += '\n' + e.getMessage();
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, msg));
        }
        initsObjects();
        return null;
    }
    
    public PageReference saveContact(){
        Database.SaveResult srLst = Database.insert(con, false);
        if(srLst.isSuccess()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Contact Created Successfully'));
        }else{
            String msg = '';
            for(Database.Error e: srLst.getErrors()){
                msg += '\n' + e.getMessage();
            }
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, msg));
        }
        initsObjects();
        return null;
    }
    
    public PageReference saveOpportunity(){
        Database.SaveResult srLst = Database.insert(opp, false);
        if(srLst.isSuccess()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Opportunity Created Successfully'));
        }else{
            String msg = '';
            for(Database.Error e: srLst.getErrors()){
                msg += '\n' + e.getMessage();
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, msg));
        }
        initsObjects();
        return null;
    }
    
    public void passUserId(String email){
        
        //userEmail='pritamraj.rits@gmail.com';
        try{
            user= database.query('SELECT id, first_Name__C, last_Name__c FROM MyUSer__C Where Name = :email limit 1');
            uid = user.id;
            userinfo();
            UserInfo.userName= user.First_Name__C + '  ' + user.last_Name__C;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'UserId not found!!!' + e.getMessage()));
        }
      
    }
    public void userinfo(){
        UserInfo = new UserInformation();
        UserInfo.isUserlogin = true;
    }
  
    public class JsonId {
        public string access_token;

    }

    public class GoogleInfo{
        public string email;
        public String verified_email;
    }
    
    public class OrgInfo{
        public string access_token;
        public string instance_url;
        public string token_type;
    }
    public class UserInformation{
        public String userName{get; set;}
        public boolean isUserLogin  {get; set;}
     
    }
}