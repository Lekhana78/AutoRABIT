public class CallbackControllerSandbox {
    public static String orgId;
    public static String code { get; set; }
    public static Boolean val { get; set; }
    public static void captureCode() {
        val = false;
        code = ApexPages.currentPage().getParameters().get('code');
        getAccessToken();
        val = true;
    }
    public static void getAccessToken(){
        SandboxId__c org = SandboxId__c.getInstance();
        String orgId = org.Id__c;
        System.debug(orgId);
        ConnectedAppCredentialsSandbox__c creds = ConnectedAppCredentialsSandbox__c.getInstance();
        Sandbox__c orgMain = [Select Id, Domain_Url__c from Sandbox__c where Id =: orgId];
        Http http = New Http();
        HttpRequest req = New HttpRequest();
        req.setEndpoint(orgMain.Domain_URL__c+'/services/oauth2/token?grant_type=authorization_code&code='+code+'&client_id='+creds.Key__c+'&client_secret='+creds.Secret__c+'&redirect_uri='+creds.CallbackUrl__c);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        HttpResponse res = New HttpResponse();
       /* if(Test.isRunningTest()){
            res = CallbackControllerMock.respond(req);
        }
        else{*/
            res = http.send(req);
        //}
        if(res.getStatusCode() == 200){
            AuthCodeWrapperSandbox authWrap = (AuthCodeWrapperSandbox) Json.deserialize(res.getBody(), AuthCodeWrapperSandbox.class);
            /*Map<String,String>authData = New Map<String,String>();
			authData.put('AccessToken',authWrap.access_token.subString(15));
			authData.put('RefreshToken',authWrap.refresh_token);
			System.debug(authData);*/
            //OrgAuthCredentials.orgAuth(authWrap.access_token.subString(15), authWrap.refresh_token);
            System.debug('Bodyyyy===='+res.getBody());
            String url = authWrap.instance_url;
            System.debug(url);
            orgMain.Refresh_Token__c = authWrap.refresh_token;
            orgMain.Access_Token__c = authWrap.access_token.subString(15);
            orgMain.Domain_URL__c = url;
            update orgMain;
        }
        else {
            System.debug(res.getStatusCode());
        }
    }
}