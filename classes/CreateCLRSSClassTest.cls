@isTest
public class CreateCLRSSClassTest 
{
    @testSetup
    public static void testData(){
        Sandbox__c sand = New Sandbox__c();
        sand.Access_Token__c = '0123456789';
        sand.Sandbox_Info_Id__c='1234';
        sand.Domain_URL__c='https://test@test.com';
        sand.LicenseType__c='Developer';
        sand.Name = 'TestBox';
        insert sand;
        
    }
	@isTest
    public static void testRSS(){
        Test.startTest();
        Test.setMock(WebServiceMock.class,new CreateCLRSSClassMock());
        Sandbox__c sand = [Select Id, Access_Token__c, Domain_Url__c, Sandbox_Info_Id__c from Sandbox__c where Name = 'TestBox'];
        Map<String,String> maps = New Map<String,String>();
        maps.put('CopadoBackend','https://login.salesforce.com');
        String str = CreateCLRSSClass.upsertMetadataRSS('TestBox',maps);
        Assert.areEqual('success',str);
    }
    @isTest
    public static void testCL(){
        Test.startTest();
        Test.setMock(WebServiceMock.class,new CreateCLRSSClassMock());
        Sandbox__c sand = [Select Id, Access_Token__c, Domain_Url__c, Sandbox_Info_Id__c from Sandbox__c where Name = 'TestBox'];
        string clJson = '[{"fullname":"TestOps001","shortdescription":"BLR","value":"Test213","language":"en_US"},{"fullname":"TestOps002","shortdescription":"BLR","value":"Test213","language":"en_US"}]';
        String str = CreateCLRSSClass.upsertMetadataCL('TestBox',clJson);
        Assert.areEqual('success',str);
    }
}