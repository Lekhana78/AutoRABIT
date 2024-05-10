public class CallbackControllerMockSandbox implements HttpCalloutMock{
    public static HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/x-www-form-urlencoded');
        res.setStatusCode(200);
        res.setBody('{"access_token":"SESSION_ID_REMOVED","refresh_token":"abcdefghijklmnopqrstuvwxyz","signature":"woH7/0Dxyzabci123dfc/sROGjJexg=","scope":"refresh_token full","id_token":"ApashyampakKirirki","instance_url":"https://cloudfulcrum--sample.sandbox.my.salesforce.com","id":"https://test.salesforce.com/id/00D3C0000004yjYUAQ/abcdefghihkjk","token_type":"Bearer","issued_at":"1686828818850"}');
        return res;
    }
}