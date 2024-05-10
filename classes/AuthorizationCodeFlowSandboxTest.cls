@isTest
public class AuthorizationCodeFlowSandboxTest {
@isTest
    static void testMet(){
        Sandbox__c org = SandboxTestDataFactory.createOrg();
        SandboxTestDataFactory.createCredsCustomSetting();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizationCodeFlowMockSandbox());
        String checkStr = AuthorizationCodeFlowSandbox.auth(org.Id);
        Assert.areEqual(checkStr, 'Redirected to the Login Page');
    }
}