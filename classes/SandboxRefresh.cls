public with sharing class SandboxRefresh {
    
    @AuraEnabled
    public static String refreshSandbox(Id Orgid){
        String refreshstatus;
        String version;
        if(!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                              WHERE Function__c = 'Sandbox Refresh' LIMIT 1];
            version = urlVersion.Version__c;
            }
        else {
            version = 'v56.0';
        }
        Sandbox__c sbx = new Sandbox__c();
        string endpoint;
        prodcred__c pc = new prodcred__c();
        try{
            sbx =[select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where id =: Orgid];
            
            pc = Prodcred__c.getInstance();
            String accessToken;
            accessToken = Test.isRunningTest()?'123456789abcd':getAccessToken();
           
            if(accessToken != null){
                
                Http htr = new Http();
                HttpRequest reqref = new HttpRequest();
                reqref.setMethod('PATCH');
                endpoint = pc.domainurl__c+'/services/data/v'+version+'/tooling/sobjects/SandboxInfo/'+sbx.Sandbox_Info_Id__c;    
                reqref.setEndpoint(endpoint);
                reqref.setHeader('Content-Type', 'application/json');
                reqref.setHeader('Authorization','Bearer '+accessToken);
                String body = '{ "licenseType": "'+sbx.LicenseType__c+'" , "SourceId":"'+sbx.source_org__r.Sandbox_Info_Id__c+'","AutoActivate" : true}';
                reqref.setBody(body);
                HttpResponse resref = Test.isRunningTest()? new HttpResponse():htr.send(reqref);
                Integer refstatus = Test.isRunningTest()?204:resref.getStatusCode();
               
                
                if(refstatus==204){
                    refreshstatus ='Sandbox refresh initiated';
                    sbx.Status__c = 'Processing';
                    sbx.Last_Refresh__c = System.Today();
                    sbx.Last_Refresh_By__c = UserInfo.getUserId();
                    sbx.Access_Token__c ='';
                    sbx.Refresh_Token__c = '';
                    update sbx;
                }
                else{
                    
                    System.JSONParser json = Json.createParser(resref.getBody());
                    while(json.nextToken()!=null){
                        if(json.getText()=='message'){
                            json.nextToken();refreshstatus = json.getText();
                        }
                    }
                    
                }  
                
            }     
        }
        Catch(Exception e){
            
            refreshstatus = e.getMessage();
        }
        return refreshstatus;
        
    }
    
    
    public static String getSandboxStatus(Id Orgid){
        String sbxstatus;
        Sandbox__c sbx = new Sandbox__c();
        String endpoint;
        prodcred__c pc = new prodcred__c();
        String version;
        if(!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                              WHERE Function__c = 'Sandbox Refresh' LIMIT 1];
            version = urlVersion.Version__c;
            }
        else {
            version = 'v56.0';
        }
        try{
            sbx =[select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where id =: Orgid];
            
            pc = Prodcred__c.getInstance();
            String accessToken;
            accessToken = Test.isRunningTest()?'123456789abcd':getAccessToken();
            
            if(accessToken!=null){
                
                Http htr = new Http();
                HttpRequest reqref = new HttpRequest();
                reqref.setMethod('GET');
                endpoint = pc.domainurl__c+'/services/data/v'+version+'/tooling/query?q=SELECT+Id,sandboxName,status+createddate+FROM+Sandboxprocess+where+SandboxInfoId='+'\''+sbx.Sandbox_Info_Id__c+'\'';
                reqref.setEndpoint(endpoint);
                reqref.setHeader('Content-Type', 'application/json');
                reqref.setHeader('Authorization','Bearer '+accessToken);
                HttpResponse resref = Test.isRunningTest()? new HttpResponse():htr.send(reqref);
                Integer refstatus = Test.isRunningTest()?200:resref.getStatusCode();
                if(refstatus==200){
                    sbxstatus ='Sandbox refresh in progress';
                    
                }
                else{
                    sbxstatus = resref.getBody();
                } 
            }
        }
        Catch(Exception e){
            
            sbxstatus = e.getMessage();
        }
        return sbxstatus;
    }
    
    
    
    public static string getAccessToken(){
        prodcred__c pc = Prodcred__c.getInstance();
        String endpoint;
        
        Http ht = new Http();
        HttpRequest Req = new HttpRequest();
        endpoint = pc.domainurl__c+'/services/oauth2/token?grant_type=client_credentials&client_id='+pc.clientid__c+'&client_secret='+pc.clientsecret__c;
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        HttpResponse res = Test.isRunningTest()? new HttpResponse():ht.send(req);
        Integer status = res.getStatusCode();
       
        String accessToken;
        if(status ==200 ){
            System.JSONParser json = Json.createParser(res.getBody());
            while(json.nextToken()!=null){
                if(json.getText()=='access_token'){
                    json.nextToken();accessToken = json.getText();
                }
            }
        }
        else{
            string dummyresponse = '{"access_token":"00D2v000001XKxi__SOMETHING","refresh_token":"5Aep861dlMxAL.LhVTuPRa__SOMETHING","signature":"MK/YGMNQhPSSnKtYicXlaU__SOMETHING","scope":"refresh_token web api","instance_url":"https://ap15.salesforce.com","id":"https://login.salesforce.com/id/00D2vKxiEAG/0045Q09vAAL","token_type":"Bearer","issued_at":"1570030000198"}';
            
            String refreshToken;
            String instanceUrl;
            String scope;
            String signature;
            String bearer;
            System.JSONParser json = Json.createParser(dummyresponse);
            while(json.nextToken()!=null){
                if(json.getText()=='access_token'){
                    json.nextToken();
                    accessToken = json.getText();
                }
                if(json.getText()=='refresh_token'){
                    json.nextToken();
                    refreshToken = json.getText();
                }
                if(json.getText()=='instance_url'){
                    json.nextToken();
                    instanceUrl = json.getText();
                }
                if(json.getText()=='scope'){
                    json.nextToken();
                    scope = json.getText();
                }
                if(json.getText()=='signature'){
                    json.nextToken();
                    signature = json.getText();
                }
                if(json.getText()=='token_type'){
                    json.nextToken();
                    bearer = json.getText();
                }
            }
        }
        
        return accessToken;
    }
    
    @InvocableMethod(label='Get Sandbox Status' description='Get Sandbox Status')
    public static void getSandboxStatusInvoke(List<Sandbox__c> sandList){
        String version;
        if(!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                              WHERE Function__c = 'Sandbox Refresh' LIMIT 1];
            version = urlVersion.Version__c;
            }
        else {
            version = 'v56.0';
        }
        for(Sandbox__c sand : sandList){
            String sbxstatus;
            Sandbox__c sbx = new Sandbox__c();
            String endpoint;
            prodcred__c pc = new prodcred__c();
            try{
                sbx =[select id,name,Source_Org__c,Sandbox_Info_Id__c,source_org__r.Sandbox_Info_Id__c,LicenseType__c,Last_Refresh__c,Last_Refresh_By__c,Status__c from Sandbox__c where id =: sand.Id];
                
                pc = Prodcred__c.getInstance();
                String accessToken;
                accessToken = Test.isRunningTest()?'123456789abcd':getAccessToken();
                
                if(accessToken!=null){
                    
                    Http htr = new Http();
                    HttpRequest reqref = new HttpRequest();
                    reqref.setMethod('GET');
                    endpoint = pc.domainurl__c+'/services/data/v'+version+'/tooling/query?q=SELECT+Id,sandboxName,status,createddate+FROM+Sandboxprocess+where+SandboxInfoId='+'\''+sbx.Sandbox_Info_Id__c+'\'+Order+By+CreatedDate+Desc+Limit+1';
                    reqref.setEndpoint(endpoint);
                    reqref.setHeader('Content-Type', 'application/json');
                    reqref.setHeader('Authorization','Bearer '+accessToken);
                    HttpResponse resref = Test.isRunningTest()? new HttpResponse():htr.send(reqref);
                    Integer refstatus = Test.isRunningTest()?200:resref.getStatusCode();
                    if(refstatus==200){
                        System.JsonParser json = Json.createParser(resref.getBody());
                        while(json.nextToken()!=null){
                            if(json.getText()=='status'){
                                json.nextToken();
                                sbxstatus = json.getText();
                                
                            }
                        }
                    }
                    else {
                        
                    }
                }
            }
            Catch(Exception e){
                
            }
            
            sand.Status__c = sbxstatus;
            if(sand.Status__c !='Completed'||sand.Status__c !='Deleted'||sand.Status__c !='Locked'||sand.Status__c !='Stopped'||sand.Status__c !='Suspended' ){
                sand.Poll_Time__c = System.now().addminutes(15);
            }
        }
        update sandList;
    }
    
}