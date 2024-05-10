@isTest
public class AuthorizationCodeFlowMockSandbox implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/x-www-form-urlencoded');
        res.setStatusCode(200);
        res.setHeader('Location', 'Redirected to the Login Page');
        return res;
    }
}