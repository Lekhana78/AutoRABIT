@isTest
public class RefreshTokenCalloutTest {
    @testSetup
    public static void testData(){
        Sandbox__c sand = New Sandbox__c();
        sand.Name = 'TestOrg';
        sand.Access_Token__c='0123456';
        sand.Sandbox_Info_Id__c='12345';
        insert sand;
    }
	@isTest
    static void testRun(){
        Sandbox__c org = [Select Id from Sandbox__c where Name = 'TestOrg'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RefreshTokenCalloutMock());
        String checkStr = RefreshTokenFlow.getAccessToken(org.Id);
        Assert.areEqual(checkStr, '123456789');
    }
}