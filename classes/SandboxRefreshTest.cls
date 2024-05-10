@isTest
public class SandboxRefreshTest {
    @testsetup
    public static void testSet(){
        sandbox__c sbxtest = new Sandbox__c();
        sbxtest.name = 'QATest';
        sbxtest.Sandbox_Info_Id__c ='1234567890';
        sbxtest.Access_Token__c = '01234567';
        sbxtest.LicenseType__c ='DEVELOPER';
        insert sbxtest;

        sandbox__c sbxtest1 = new Sandbox__c();
        sbxtest1.name = 'DevTest';
        sbxtest1.Sandbox_Info_Id__c ='9876543210';
        sbxtest1.LicenseType__c ='DEVELOPER';
        sbxtest1.Access_Token__c = '01234567';
        sbxtest1.Source_Org__c=sbxtest.id;
        insert sbxtest1;

        ProdCred__c pcd = new ProdCred__c();
        pcd.clientid__c ='1234567890';
        pcd.clientsecret__c ='9876543210';
        pcd.domainurl__c = 'https://localhost';
        insert pcd;

    }

    @isTest
    static void testMethod1(){
        sandbox__c sbxdev = [select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where name='DevTest'];
        Test.setMock(HttpCalloutMock.class,new SandboxRefreshMock());
        String str = SandboxRefresh.refreshSandbox(sbxdev.id);
        Assert.isNotNull(str);
    }
    
    @isTest
    static void testMethod2(){
        sandbox__c sbxdev = [select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where name='DevTest'];
        Test.setMock(HttpCalloutMock.class,new SandboxRefreshMock());
        String str = SandboxRefresh.getSandboxStatus(sbxdev.id);
        Assert.isNotNull(str);
    }
    
    @isTest
    static void testMethod3(){
        sandbox__c sbxdev = [select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where name='DevTest'];
        Test.setMock(HttpCalloutMock.class,new SandboxRefreshMock());
        String str = SandboxRefresh.getAccessToken();
        Assert.isNotNull(str);
        
    }
    @isTest
    static void testMethod4(){
        sandbox__c sbxdev = [select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where name='DevTest'];
        Test.setMock(HttpCalloutMock.class,new SandboxRefreshMock());
        List<Sandbox__c> sandboxList = New List<Sandbox__c>{sbxdev};
        SandboxRefresh.getSandboxStatusInvoke(sandboxList);
        sbxdev = [select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,Poll_Time__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where name='DevTest'];
   		Assert.isNotNull(sbxdev.Poll_Time__c);	
    }

}