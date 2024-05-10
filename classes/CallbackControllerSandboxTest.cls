@isTest
public class CallbackControllerSandboxTest {
@isTest
    static void testVFPageCallback(){
        String testCode = 'testCode';
        CallbackControllerSandbox.code = testCode;
        SandboxTestDataFactory.createOrg();
        SandboxTestDataFactory.createCustomSetting();
        SandboxTestDataFactory.createCredsCustomSetting();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CallbackControllerMockSandbox());
        CallbackControllerSandbox.captureCode();
        Sandbox__c org = [Select Id, Name,Refresh_Token__c from Sandbox__c where Name =: 'TestOrg123' Limit 1];
        Assert.areEqual(org.Refresh_Token__c, 'abcdefghijklmnopqrstuvwxyz');
        Test.stopTest();
    }
}