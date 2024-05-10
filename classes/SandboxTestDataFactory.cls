public class SandboxTestDataFactory {
   public static Sandbox__c createOrg(){
        Sandbox__c org = New Sandbox__c();
        org.Name = 'TestOrg123';
        org.Sandbox_Info_Id__c = '87jhktnffilh8';
        org.Access_Token__c = '8764ynfafif9r3rny23099hiknefprfu920r';
        org.Domain_URL__c='https://cloudfulcrum.copadodev.com';
        org.Status__c = 'Completed';
        insert org;
        return org;
    }
    
    public static void createCredsCustomSetting(){
       //createOrg();
        ConnectedAppCredentialsSandbox__c creds = ConnectedAppCredentialsSandbox__c.getInstance();
        creds.Key__c = 'iuhddiuayd98doqwhd98xsidpsd';
        creds.Secret__c = 'dwdu8wd8hopwndi9w8yd9a8sndoasyud';
        creds.CallbackUrl__c = 'https://cloudfulcrum.copadodev.com';
        upsert creds;
    }
    
    public static void createCustomSetting(){
       createOrg();
        Sandbox__c org = [Select Id,Name,Sandbox_Info_Id__c from Sandbox__c Where Name = 'TestOrg123' Limit 1];
        SandboxId__c orgId = SandboxId__c.getInstance();
        orgId.Id__c = org.Id;
        upsert orgId;
    }
}