public class RefreshTokenFlow {
    public static String getAccessToken(Id orgId){
        Sandbox__c org = [Select Id, Name, Refresh_Token__c, Domain_Url__c from Sandbox__c Where Id =: orgId Limit 1];
        Http http = New Http();
        HttpRequest req = New HttpRequest();
        ConnectedAppCredentialsSandbox__c creds = ConnectedAppCredentialsSandbox__c.getInstance();
        req.setEndpoint(org.Domain_URL__c+'/services/oauth2/token?grant_type=refresh_token&client_id='+creds.Key__c+'&client_secret='+creds.Secret__c+'&refresh_token='+org.Refresh_Token__c);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            System.debug(res.getStatusCode());
            RefreshTokenWrapper wrp = (RefreshTokenWrapper) JSON.deserialize(res.getBody(), RefreshTokenWrapper.class);
            System.debug(wrp);
            return  wrp.access_token.subString(15);
        }
        else {
            return res.getStatus()+''+res.getBody();
        }
    }
}