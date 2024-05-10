public with sharing class SandboxRefreshController {
    @AuraEnabled
    public static List<Sandbox__c> getSandbox(string licenseType){
        system.debug(licenseType);
        return [SELECT Id, Name,Sandbox_Info_Id__c,LicenseType__c FROM Sandbox__c WHERE LicenseType__c = :licenseType];
    }

    @AuraEnabled(cacheable=true)
    public static List<Sandbox__c> getSandboxName(){
        return [SELECT Id, Name,Sandbox_Info_Id__c,LicenseType__c FROM Sandbox__c];
    }
}