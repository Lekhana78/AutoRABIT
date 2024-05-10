@isTest
public class SandboxRefreshMock implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndPoint().contains('/SandboxInfo')){
            res.setStatusCode(401);
        }
        if(req.getEndPoint().contains('/services/oauth2/token?grant_type=client_credentials&client_id=')){
            res.setStatusCode(200);
        }
        if(req.getEndPoint().contains('Sandboxprocess')){
            res.setStatusCode(200);
            res.setBody('{"status":"Completed"}');
        }
        return res;
    }
}