@isTest
public class GetUsersFromSandboxApiClsTest {
    // Helper method to create a test Sandbox__c record
    private static Sandbox__c createTestSandbox() {
        PermissionSetWrapper poc = new PermissionSetWrapper();
        Sandbox__c sandbox = new Sandbox__c(
            Name='TestOrg',
            Sandbox_Info_Id__c='g56hffgtbb',
            Domain_Url__c='https://test.salesforce.com',
            Access_Token__c='testToken'
        );
        insert sandbox;
        return sandbox;
    }
    
    @isTest
    static void testApexMeth() {
        // Setup test data
        Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
        
        Test.startTest();
        // Call the method to test
        Map<String, User> result = GetUsersFromSandboxApiCls.apexMeth(orgName, userEmailMapJson);
        Test.stopTest();
        
        // Assertions to verify the method behavior
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(1, result.size(), 'Expected one user in the result.');
        // Add more assertions as needed to verify the correctness of your method's logic
    }
    
    @isTest
    static void testUpdateUsers() {
        createTestSandbox();
        
        // Assuming userEmailMapJson is a JSON string of a map that needs to be prepared based on expected format
        String userEmailMapJson = '{"test@example.com": "test@example.com"}';
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
        Test.startTest();
        // Call the method you're testing
        String status = GetUsersFromSandboxApiCls.updateUsers('TestOrg', userEmailMapJson);
        
        // Assert results
        System.assertEquals('success', status);
        
        Test.stopTest();
    }
    @isTest
    static void testallotPermSet() {
        createTestSandbox();
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
        Test.startTest();
        String str = GetUsersFromSandboxApiCls.allotPermSet('{"test@example.com": "Opsbridge_Permission_Set, PermTest, JenkinsTest"}', 'TestOrg');
        Assert.areEqual('success',str);        
    }
    
    @isTest
    static void testPasswordreset(){
        createTestSandbox();
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
        Test.startTest();
        String str = GetUsersFromSandboxApiCls.resetPassword('["test@example.com","test@example.com"]', 'TestOrg');
        Assert.areEqual('success',str);
    }
    
    @isTest
    static void testgetPerm(){
        createTestSandbox();
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
        List<String> strList = New List<String>{'test@testforce.com','test@rocf.com'};
        Test.startTest();
        Map<String, String> mapPerm = GetUsersFromSandboxApiCls.getPermData('TestOrg',strList);     
        Assert.isNotNull(mapPerm.values()[0]);
    }
      @isTest
    static void testgetvalidateUser(){
       Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        
        // Mock HTTP callout response
        //      Test.startTest();
        // Call the method to test
        //Map<String, User> result = GetUsersFromSandboxApiCls.validateUser(orgName, userEmailMapJson);        ;
      //  Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiMockCls());
         Test.startTest();
       GetUsersFromSandboxApiCls.validateUser(orgName, userEmailMapJson);   
   		Test.stopTest();
    }
    
    @isTest
    public static void testAuthIssuePerm(){
        createTestSandbox();
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiClsMockAuth());
        List<String> strList = New List<String>{'test@testforce.com','test@rocf.com'};
        Test.startTest();
        String str;
        try{
        Map<String, String> mapPerm = GetUsersFromSandboxApiCls.getPermData('TestOrg',strList);
            }
        catch(exception e){
            str = e.getMessage();
        }
        Assert.isNotNull(str);
    }
    @isTest
    public static void testAuthIssueMeth(){
        Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiClsMockAuth());
        Test.startTest();
        String str;
        try{
        // Call the method to test
        Map<String, User> result = GetUsersFromSandboxApiCls.apexMeth(orgName, userEmailMapJson);
        }
        catch(exception e){
            str = e.getMessage();
        }
        Test.stopTest();
        Assert.isNotNull(str);
    }
    
    @isTest
    public static void testUpdateUserAuth(){
        Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiClsMockAuth());
        Test.startTest();
        String str;
        Set<String> strSet = New Set<String>{'test@example.com'};
       
        // Call the method to test
        Map<String,String> result = GetUsersFromSandboxApiCls.getUsersData(orgName, strSet);
        
        
        Test.stopTest();
        Assert.isNotNull(result);
    }
    
    @isTest
    public static void testgetPermAuth(){
        Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiClsMockAuth());
        Test.startTest();
        String str;
        List<String> strSet = New List<String>{'test@example.com'};
       
        // Call the method to test
            try{
        Map<String,String> result = GetUsersFromSandboxApiCls.getPermData(orgName, strSet);
}
        catch(exception e){
            str = e.getMessage();
        }        
        
        Test.stopTest();
        Assert.isNotNull(str);
    }
    
    @isTest
    public static void resetPassAuth(){
        Sandbox__c testSandbox = new Sandbox__c(Name = 'TestSandbox', Sandbox_Info_Id__c= 'tybgffxxx', Domain_Url__c = 'https://test.salesforce.com', Access_token__c = 'TestAccessToken');
        insert testSandbox;
        // Prepare input parameters
        String orgName = 'TestSandbox';
        String userEmailMapJson = '{"test@example.com":"test@example.com"}';
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new GetUsersFromSandboxApiClsMockAuth());
        Test.startTest();
        String str;
        //List<String> strSet = New List<String>{'test@example.com'};
       
        // Call the method to test
        string result = GetUsersFromSandboxApiCls.resetPassword('["test@example.com"]',orgName);
        
        
        Test.stopTest();
        Assert.isNotNull(result);
    }
}