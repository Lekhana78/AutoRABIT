public class CreateCLRSSClass {
private static String INSTANCE_URL;
    private static String ACCESS_TOKEN;
    
    @AuraEnabled
    public static String upsertMetadataRSS(string orgName,Map<String,String>rssMap){
        system.debug('rssMap = '+rssMap);
        Sandbox__c org = [Select Id, Name, Domain_Url__c, Access_token__c from Sandbox__c where name =: orgName Limit 1];
        INSTANCE_URL = org.Domain_Url__c;
        if(Test.isRunningTest()){
            Access_TOKEN = org.Access_Token__c;
        }
        else {
        Access_TOKEN = RefreshTokenFlow.getAccessToken(org.Id);
        }

        MetadataService.MetadataPort service = createService();
        for(String str : rssMap.keySet()){
            if(rssMap.get(str)!=null){
                MetadataService.RemoteSiteSetting rss = new MetadataService.RemoteSiteSetting();
                    rss.fullName = str;
                    rss.isActive = true;
                    rss.url = rssMap.get(str);
                	rss.disableProtocolSecurity = false;
                	createService().upsertMetadata(new List<MetadataService.Metadata> { rss });
            }
        }
                    return 'success';
    }
    
    @AuraEnabled
    public static String upsertMetadataCL(string orgName,String cljson){
        system.debug('cljson = '+cljson);
        List<CLWrapper> clWrapperList = (List<CLWrapper>)Json.deserialize(cljson,List<CLWrapper>.class);
        Sandbox__c org = [Select Id, Name, Domain_Url__c, Access_token__c from Sandbox__c where name =: orgName Limit 1];
        INSTANCE_URL = org.Domain_Url__c;
        if(Test.isRunningTest()){
            Access_TOKEN = org.Access_Token__c;
        }
        else {
        Access_TOKEN = RefreshTokenFlow.getAccessToken(org.Id);
        }
            
        MetadataService.MetadataPort service = createService();
        
        for(CLWrapper cmp : clWrapperList){
           MetadataService.CustomLabel cl = new MetadataService.CustomLabel();
                    cl.fullName = cmp.fullName;
                    cl.shortDescription = cmp.shortDescription;
                    cl.language = cmp.language;
                	cl.value = cmp.value;
            		cl.categories = cmp.categories;
            		cl.protected_x = false;
            		createService().upsertMetadata(new List<MetadataService.Metadata> { cl });
        }
        return 'success';
    }
    
    // Method to create MetadataService.MetadataPort instance using access token and instance URL
    private static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        String version;
        if(!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                              WHERE Function__c Like 'Custom Label%'OR Function__c Like'Remote Site%' LIMIT 1];
            version = urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        service.endpoint_x = INSTANCE_URL+ '/services/Soap/m/'+version;
        service.SessionHeader.sessionId = ACCESS_TOKEN;
        service.timeout_x = 40000;
        
        return service;
    }
    
    public class CLWrapper {
        public String fullName;
        public String shortDescription;
        public String value;
        public String language;
        public String categories;
        
    }
}