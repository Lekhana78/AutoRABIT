public class GetUsersFromSandboxApiCls {
    public class UserNotFoundException extends Exception {}
    @AuraEnabled
    public static Map<String, User> apexMeth(String orgName, String userEmailMapJson) {
        Map<String, String> userEmailMap;
        userEmailMap = (Map<String, String>) JSON.deserialize(userEmailMapJson, Map<String, String>.class);
        system.debug(orgName);
        system.debug(userEmailMap);
        List<User> userList = new List<User>();
        String version;
        if(!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        Sandbox__c org = [SELECT Id, Name, Domain_Url__c, Access_token__c FROM Sandbox__c WHERE Name =: orgName LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String userStr = '(\''+String.join(userEmailMap.keySet(),'\',\'')+'\')';
        req.setEndpoint(org.Domain_URL__c+'/services/data/'+version+'/query?q=Select+Id,Name,userName,Email+From+User+Where+IsActive=true+And+Username+In+'+userStr.deleteWhiteSpace());
        req.setHeader('Authorization', 'Bearer '+org.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        Map<String, User> userMap = new Map<String, User>();
        List<String> missingUsers = new List<String>();
        String body;
        Integer statusCode;
        if (res.getStatusCode() == 401) {
            org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
            req.setHeader('Authorization','Bearer '+org.Access_Token__c);
            res = http.send(req);
            if(res.getStatusCode()==200){
                body = res.getBody();
                statusCode = 200;
            }
        }
        else if(res.getStatusCode()==200){
            body = res.getBody();
            statusCode = 200;
        }
        else {
            statusCode = res.getStatusCode();
        }
        
        if (statusCode == 200) {
            UserWrapper userwrp = (UserWrapper) JSON.deserialize(body, UserWrapper.class);
            if (userwrp.records.isEmpty()) {
                throw new UserNotFoundException('No users found in the organization.');
            }
            Map<String, String> userNameMap = new Map<String, String>();
            for (UserWrapper.Records rec : userwrp.records) {
                if (userEmailMap.get(rec.Username) != null) {
                    User u = new User();
                    u.Id = rec.Id;
                    u.Email = rec.Email;
                    u.Username = rec.Username;
                    userNameMap.put(u.Username, u.Id);
                    userMap.put(u.Id, u);
                }
            }
            
            System.debug(userEmailMap.keySet());
            System.debug(userEmailMap);
            System.debug(userNameMap);
            System.debug(userMap);
            
            for (String usnm : userEmailMap.keySet()) {
                System.debug(usnm);
                System.debug(userNameMap.get(usnm));
                System.debug(userMap.get(userNameMap.get(usnm)));
                
                if (!userMap.containsKey(userNameMap.get(usnm))) {
                    missingUsers.add(usnm);             }
            }
            
            if (!missingUsers.isEmpty()) {
                throw new UserNotFoundException('Users not found: ' + String.join(missingUsers, ', '));
            }
            
            for (String usnm : userEmailMap.keySet()) {
                System.debug(userMap.get(userNameMap.get(usnm)).Email);
                userMap.get(userNameMap.get(usnm)).Email = userEmailMap.get(usnm);
            }
        } 
        else {
            throw new UserNotFoundException('Failed to retrieve user data. Status code: ' + res.getStatusCode());
        }
        
        return userMap;
    }
    @AuraEnabled
    public static String updateUsers(String orgName, String userEmailMapJson){
        Map<String, String> userEmailMap;
        system.debug(userEmailMapJson);
        userEmailMap = (Map<String, String>)JSON.deserialize(userEmailMapJson, Map<String, String>.class);
        system.debug(userEmailMap);
        string status;
        Map<String,User> userMap = GetUsersFromSandboxApiCls.apexMeth(orgName, userEmailMapJson);
        Sandbox__c org = [Select Id, name, Domain_Url__c,Access_Token__c from Sandbox__c where name =: orgName LIMIT 1];
        String body = '{"allOrNone": true,"records": [';
        for(String str : userMap.keySet()){
            body = body+'{"attributes":{"type": "User"},"Id": "'+str+'","Username": "'+userMap.get(str).Username+'","Email": "'+userMap.get(str).Email+'"},';
        }
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        Http http = New Http();
        HttpRequest req = New HttpRequest();
        req.setEndPoint(org.Domain_URL__c+'/services/data/'+version+'/composite/sObjects');
        req.setMethod('PATCH');
        req.setHeader('Authorization','Bearer '+org.Access_Token__c);
        req.setHeader('Content-Type','application/json');
        req.setTimeout(120000);
        body = body.removeEnd(',');
        body = body+']}';
        System.debug(body);
        req.setBody(body);
        HttpResponse res = http.send(req);
        String getbody;
        Integer statusCode;
        if(res.getStatusCode()==401){
            org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
            req.setHeader('Authorization','Bearer '+org.Access_Token__c);
            res = http.send(req);
            getbody = res.getBody();
            statusCode = res.getStatusCode();
        }
        if(res.getStatusCode()==201 || res.getStatusCode()==200){
            statusCode = 200;
        }
        if(statusCode == 200){
            status = 'success';
        }
        else {
            status = 'failed';
        }
        return status;
    }
    
    public static Map<String, String> getUsersData(String orgName, Set<String> usernames) {
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
    Sandbox__c org = [SELECT Id, Name, Domain_Url__c, Access_Token__c FROM Sandbox__c WHERE Name = :orgName LIMIT 1];
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    
    String usernameQuery = String.join(new List<String>(usernames), '\',\'');
    String query = 'SELECT Id, Name, Username, Email FROM User WHERE IsActive = true';
    String queryAdd = ' AND Username IN (\'' + usernameQuery + '\')';
    
    req.setEndpoint(org.Domain_URL__c + '/services/data/'+version+'/query?q=SELECT+Id,Name,Username,Email+FROM+User+WHERE+IsActive+=+true' + EncodingUtil.urlEncode(queryAdd, 'UTF-8'));
    req.setHeader('Authorization', 'Bearer ' + org.Access_Token__c);
    req.setMethod('GET');
    req.setTimeout(120000);
    
    HttpResponse res = http.send(req);
    Map<String, String> userMap = new Map<String, String>();
    String body;
    Integer statusCode;
    if (res.getStatusCode() == 401) {
        org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
        req.setHeader('Authorization','Bearer ' + org.Access_Token__c);
        res = http.send(req);
        body = res.getBody();
        statusCode = res.getStatusCode();
    }
        else if(res.getStatusCode()==200){
            body = res.getBody();
            statusCode = res.getStatusCode();
        }
        else {
            statusCode = res.getStatusCode();
        }
    if (statusCode == 200) {
        UserWrapper userwrp = (UserWrapper) JSON.deserialize(body, UserWrapper.class);
        for (UserWrapper.Records rec : userwrp.records) {
            userMap.put(rec.Username, rec.Id);
        }
        
        // Check if all usernames are found in the user map
        Set<String> foundUsernames = userMap.keySet();
        Set<String> missingUsernames = new Set<String>();
        for (String username : usernames) {
            if (!foundUsernames.contains(username)) {
                missingUsernames.add(username);
            }
        }
        
        // If any username is missing, throw UserNotFoundException
        if (!missingUsernames.isEmpty()) {
            throw new UserNotFoundException('Users not found in the organization: ' + String.join(missingUsernames, ', '));
        }
    }
    
    return userMap;
}
    
    
    public static Map<String,String> getPermData(String orgName, List<String> permissionSetList) {
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        Map<String,String> permMap = New Map<String,String>();
        List<String> strFullList = New List<String>(); 
        for(String str : permissionSetList){
            List<String> strStr = str.split(',');
            strFullList.addAll(strStr);
        }
        Set<String> strSet = New Set<String>(strFullList);
        List<String> strListFinal = New List<String>(strSet);
        String permStr = '(\''+String.join(strListFinal,'\',\'')+'\')';
        Sandbox__c org = [SELECT Id, Name, Domain_Url__c, Access_Token__c FROM Sandbox__c WHERE Name = :orgName LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String queryAdd = 'WHERE Name IN :'+permStr;
        req.setEndpoint(org.Domain_URL__c + '/services/data/'+version+'/query?q=SELECT+Id,Name+FROM+PermissionSet+Where+Name+In+'+permStr.deleteWhitespace());
        req.setHeader('Authorization', 'Bearer ' + org.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(120000);
        system.debug(req.getEndPoint());
        HttpResponse res = http.send(req);
        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>();
        String body = '';
        Integer statusCode;
        if (res.getStatusCode() == 401) {
            org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
            req.setHeader('Authorization', 'Bearer ' + org.Access_Token__c);
            HttpResponse res1 = http.send(req);
            body = res1.getBody();
            statusCode = res1.getStatusCode();
        }
        else if(res.getStatusCode()==200){
            body = res.getBody();
            statusCode = res.getStatusCode();
        }
        else {
            body = res.getBody();
            statusCode = res.getStatusCode();
        }
        System.debug(statusCode);
        if (statusCode == 200) {
            PermissionSetWrapper pswrp = (PermissionSetWrapper) JSON.deserialize(body, PermissionSetWrapper.class);
            for (PermissionSetWrapper.records rec : pswrp.records) {
                //permissionSets.add(new PermissionSetData(rec.Assignee.Name, rec.PermissionSet.Name));
                permMap.put(rec.Name,rec.Id);
            }
        }
        else{
            throw new UserNotFoundException('Failed- '+statusCode);
        }
        return permMap;
    }
    
    
    @AuraEnabled
    public static string allotPermSet(String userPermMapJson,String orgName){
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        Map<String, String> userPermMap;
        userPermMap = (Map<String, String>)JSON.deserialize(userPermMapJson, Map<String, String>.class);
        system.debug(userPermMap + '*****************');
        Set<String> usernames =userPermMap.keySet();
        Map<String,String> userNMap = getUsersData(orgName,usernames);
        system.debug(userNMap +'$$$$$$$$$$$$$$$$$$');
        Map<String,String> permSMap = getPermData(orgName,userPermMap.values());
        String emp = '';
        userPermMap.remove(emp);
        Sandbox__c org = [Select Id, name, Domain_Url__c,Access_Token__c from Sandbox__c where name =: orgName limit 1];
        Map<String,String>userPermSetAssnMap = New Map<String,String>();
        Integer i=0;
        Set<String> usSet = New Set<String>(userPermMap.keySet());
        List<String>usList = New List<String>(usSet);
        System.debug(userPermMap);
        String body = '{"allOrNone": true,"records": [';
        for(String str : userPermMap.values()){
            str = str.deleteWhitespace();
            if(str.contains(',')){
                List<String>strList = str.split(',');
                for(String str1 : strList){
                    body = body+'{"attributes": {"type": "PermissionSetAssignment"},"AssigneeId": "'+userNMap.get(usList[i])+'","PermissionSetId":"'+permSMap.get(str1)+'"},';
                }
            } 
            else {
                body = body+'{"attributes": {"type": "PermissionSetAssignment"},"AssigneeId": "'+userNMap.get(usList[i])+'","PermissionSetId":"'+permSMap.get(str)+'"},';
            }
            i=i+1;
        }
        System.debug(userPermSetAssnMap);
        System.debug(userPermSetAssnMap.values().size());
        Http http = New Http();
        HttpRequest req = New HttpRequest();
        req.setEndPoint(org.Domain_URL__c+'/services/data/'+version+'/composite/sObjects');
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer '+org.Access_Token__c);
        req.setHeader('Content-Type','application/json');
        req.setTimeout(120000);
        body = body.removeEnd(',');
        body = body+']}';
        System.debug(body);
        req.setBody(body);
        HttpResponse res = http.send(req);
        String status;
        String getbody;
        Integer statusCode;
        if(res.getStatusCode()==401){
            org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
            req.setHeader('Authorization','Bearer '+org.Access_Token__c);
            res = http.send(req);
            getbody = res.getBody();
            statusCode = res.getStatusCode();
        }
        else if(res.getStatusCode()==201 || res.getStatusCode()==200){
            statusCode = 200;
        }
        else {
            statusCode = res.getStatusCode();
        }
        if(statusCode == 200){
            status = 'success';
        }
        else {
            status = 'failed';
            throw new UserNotFoundException('Failed'+statusCode);
        }
        return status;
    }
    
    /* @AuraEnabled
public static string resetPassword(String usernmList,String orgName) {
List<String>userLst = usernmList.split(',');
Map<String,String> usMap = getUsersData(orgName);

List<Id>idList = New List<Id>();

for(String use : userLst){
idList.add(usMap.get(use));
}
String status;
Sandbox__c org = [Select Id, name, Domain_Url__c,Access_Token__c from Sandbox__c where name =: orgName limit 1];
for(Id idi : idList){
String endpoint = org.Domain_Url__c + '/services/data/v58.0/sobjects/User/' + idi + '/password';

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('DELETE');
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); //use accesstoken here
req.setHeader('Content-Type', 'application/json');

HttpResponse res = new Http().send(req);
if (res.getStatusCode() == 200) {
System.debug('Password reset successful');
status = 'success';
} else {
System.debug('Password reset failed: ' + res.getBody());
status = 'false';
}

}
return status;
}*/
    
    @AuraEnabled
    public static String resetPassword(String usernmList, String orgName) {
        /*ResetPasswordBatchClass rc = New ResetPasswordBatchClass(orgName,usernmList);
Database.executeBatch(rc,100);*/
        System.debug('Received usernmList: ' + usernmList);
        // Parse the JSON string into a list of strings
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        List<String> userLst = (List<String>) JSON.deserialize(usernmList, List<String>.class);
        Set<String> usSet = New Set<String>(userLst);
        Map<String, String> usMap = getUsersData(orgName,usSet);
        
        List<Id> idList = new List<Id>();
        for(String use : userLst) {
            idList.add(usMap.get(use));
        }
        
        String status;
        Sandbox__c org = [SELECT Id, Name, Domain_Url__c, Access_Token__c FROM Sandbox__c WHERE Name =: orgName LIMIT 1];
        
        for(Id idi : idList) {
            String endpoint = org.Domain_Url__c + '/services/data/'+version+'/sobjects/User/' + idi + '/password';
            Http http = New Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('DELETE');
            req.setHeader('Authorization', 'Bearer ' + org.Access_Token__c); // Corrected to use Access_Token__c
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            System.debug(res.getStatusCode());
            String body;
            Integer statusCode;
            if(res.getStatusCode()==401){
                org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
                req.setHeader('Authorization','Bearer '+org.Access_Token__c);
                res = http.send(req);
                body = res.getBody();
                statusCode = res.getStatusCode();
            }
            else if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                statusCode = 200;
            }
            else {
                statusCode = res.getStatusCode();
            }
            if(statusCode == 200){
               System.debug('Password reset successful');
                status = 'success'; 
            }
            else {
                System.debug('Password reset failed: ' + body);
                status = 'failure'; // Changed 'false' to 'failure' for clarity
            }
        }
        return status;
    }
    
    @AuraEnabled
    public static List<user> validateUser(String orgName , string userEmailMapJson) {
        String version;
        if (!Test.isRunningTest()){
        MetadataVersion__mdt urlVersion = [SELECT Function__c, Version__c FROM MetadataVersion__mdt 
                                           WHERE Function__c Like 'Update User%' LIMIT 1];
            version = 'v'+urlVersion.Version__c;
            }
        else {
            version = 'v58.0';
        }
        system.debug('RAMA' + userEmailMapJson);
        Map<String, String> userEmailMap;
        if(userEmailMapJson != null){
            userEmailMap = (Map<String, String>) JSON.deserialize(userEmailMapJson, Map<String, String>.class);
        }
        List<user> userName = new list<user>();
        List<user> userEmail = new list<user>();
        Sandbox__c org = [SELECT Id, Name, Domain_Url__c, Access_Token__c FROM Sandbox__c WHERE Name =: orgName and Domain_Url__c != null LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String userStr = '(\''+String.join(userEmailMap.keySet(),'\',\'')+'\')';
        req.setEndpoint(org.Domain_URL__c+'/services/data/'+version+'/query?q=Select+Id,Name,userName,Email+From+User+Where+IsActive=true+And+Username+In+'+userStr);
        req.setHeader('Authorization', 'Bearer '+org.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        Map<String, User> userMap = new Map<String, User>();
        List<String> missingUsers = new List<String>();
        Integer statusCode;
        String body;
        if (res.getStatusCode() == 401) {
            org.Access_Token__c = RefreshTokenFlow.getAccessToken(org.Id);
            req.setHeader('Authorization','Bearer '+org.Access_Token__c);
            res = http.send(req);
            body = res.getBody();
            statusCode = 200;
        }
        else if (res.getStatusCode()==200){
            body = res.getBody();
            statusCode = 200;
        }
        else {
            statusCode = res.getStatusCode();
        }
        if (statusCode == 200) {
            UserWrapper userwrp = (UserWrapper) JSON.deserialize(body, UserWrapper.class);
            if (userwrp.records.isEmpty()) {
                throw new UserNotFoundException('No users found in the organization.');
            }
            
            
            Map<String, String> userNameMap = new Map<String, String>();
            for (UserWrapper.Records rec : userwrp.records) {
                if (userEmailMap.get(rec.Username) != null) {
                    User u = new User();
                    u.Id = rec.Id;
                    u.Email = rec.Email;
                    u.Username = rec.Username;
                    userEmail.add(u);
                    system.debug('RAM'+ userEmail);
                    
                }
            }
            
        }  
        return userEmail;
    }
}