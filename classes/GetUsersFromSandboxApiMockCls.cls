@isTest
public class GetUsersFromSandboxApiMockCls implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        // Initialize a new HttpResponse object
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        // Provide a mock response body
        Id sid = UserInfo.getUserId();
        if(req.getEndpoint().contains('/query?q=Select+Id,Name,userName,Email+From+User')) {
            res.setBody('{"totalSize":1,"records":[{"Id":"'+sid+'","Email":"test@example.com","Username":"test@example.com"}]}');
        }
        else if(req.getEndpoint().contains('services/data/v58.0/sobjects/User/')) {
            res.setStatusCode(201);
            res.setBody('{"totalSize":1,"Records":[{"Id":"'+sid+'","Email":"test@example.com","Username":"test@example.com"},"attributes":{"type":"test","url":"testUrl"}]}');
        }
        else if(req.getEndpoint().contains('/services/data/v58.0/query?q=SELECT+Id,Name,Username,Email+FROM+User+WHERE+IsActive+=+true')) {
            res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"User","url":"/services/data/v55.0/sobjects/User/00552000006z2paAAA"},"Id":"00552000006z2paAAA","Name":"Pavani Kandru","Username":"test@example.com","Email":"test@example.com"}]}');
        }
        else if(req.getEndpoint().contains('/services/data/v58.0/query?q=SELECT+Id,Name+FROM+PermissionSet')) {
            res.setBody('{"totalSize":1,"records":[{"Id":"'+sid+'","Name":"TestPermissionSet","attributes":{"type":"test","url":"testUrl"}}]}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('/services/data/v58.0/sobjects/User/'+sid+'/password')) {
            res.setBody('success');
            res.setStatusCode(200);
        }
       
        // Add more conditions as needed to mock responses for other endpoints
        
        return res;
    }
}