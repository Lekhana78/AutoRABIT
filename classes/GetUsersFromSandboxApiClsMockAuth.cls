@isTest
public class GetUsersFromSandboxApiClsMockAuth implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        // Initialize a new HttpResponse object
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(401);
        return res;
    }
}