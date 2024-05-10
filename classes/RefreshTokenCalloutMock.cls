@isTest
global class RefreshTokenCalloutMock implements HttpCalloutMock{
    global static HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setStatusCode(200);
        res.setBody('{"access_token": "01020304050607.123456789","signature": "abcdefghijklmnopq","scope": "refresh_token full","instance_url": "https://test.salesforce.com","id": "https://test.salesforce.com/id/0","token_type": "Bearer","issued_at": "1627054"}');
        return res;
    }
}