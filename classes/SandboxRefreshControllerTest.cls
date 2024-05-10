@isTest
public class SandboxRefreshControllerTest {
    @TestSetup
    static void setup() {
        // Create test data for Sandbox__c
        List<Sandbox__c> sandboxes = new List<Sandbox__c>();
        sandboxes.add(new Sandbox__c(Name='Test Sandbox 1', LicenseType__c='DEVELOPER', Sandbox_Info_Id__c='hdvfc5684hg'));
        sandboxes.add(new Sandbox__c(Name='Test Sandbox 2', LicenseType__c='DEVELOPER_PRO' , Sandbox_Info_Id__c='a547bdfhvur'));
        
        insert sandboxes;
    }
    
    @isTest
    static void testGetSandboxWithType() {
        // Test with a license type that exists
        Test.startTest();
        List<Sandbox__c> results = SandboxRefreshController.getSandbox('DEVELOPER');
        Test.stopTest();
        
        // Assert that the correct records are returned
        System.assertEquals(1, results.size(), 'Expected one record to be returned');
        System.assertEquals('DEVELOPER', results[0].LicenseType__c, 'The license type should match the query');
        
   }
    
    @isTest
    static void testGetSandboxName() {
        // Test the method that retrieves all sandboxes
        Test.startTest();
        List<Sandbox__c> results = SandboxRefreshController.getSandboxName();
        Test.stopTest();
        
        // Assert all records are returned
        System.assertEquals(2, results.size(), 'Expected all sandbox records to be returned');
        
    }
}