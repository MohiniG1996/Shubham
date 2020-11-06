public class AccessToken {
    
    public static String getAccessToken(){
        String endPoint = 'https://login.microsoftonline.com/9d94cb2f-05ce-4ac3-96a0-8a8a97437d2a/oauth2/v2.0/token';
        Http http = new Http();
        httpRequest req = new httpRequest();
        req.setMethod('GET');
        req.setEndpoint(endPoint);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String payload = 'client_id='+EncodingUtil.urlEncode('c4b3cb93-cb2a-438d-89b5-e60c3a84b90e','UTF-8')+
            '&client_secret='+EncodingUtil.urlEncode('r9-tExqdo1Pj.K~3PywtS11-KxFpwHT.vz','UTF-8')+
            '&grant_type='+EncodingUtil.urlEncode('Password','UTF-8')+
            '&username='+EncodingUtil.urlEncode('ajeet.kumar@utilitarianlab.com','UTF-8')+
            '&password='+EncodingUtil.urlEncode('jitu@2018','UTF-8')+'&scope='+EncodingUtil.urlEncode('https://graph.microsoft.com/.default','UTF-8');
        req.setBody(payload);
        httpResponse res = new httpResponse();
        res = http.send(req);
        integer statusCode = res.getStatusCode();
        string resBody = res.getBody();
        system.debug('#### sc: ' + statusCode);
        system.debug('#### rb: ' + resBody);  
        AccessToken.ResponseWrapper response = (AccessToken.ResponseWrapper)JSON.deserialize(resBody, AccessToken.ResponseWrapper.class);
		System.debug('response.access_token=='+response.access_token);
        return response.access_token;
    }
    public static void uploadFileOneDrive(String accessToken,ContentVersion cv){
                    Http http = new Http();
            httpRequest req = new httpRequest();
            req.setMethod('PUT');
            
           String endPoint = 'https://graph.microsoft.com/v1.0/me/drives/b!hcWfgE6JM0Kuz0Kn-2xp_EJ0Fk4HkHBMqs9Z8DJpeG7mxhREo38vSZmtUoq46Wmi/items/01TAN3RNZXVYL53ADSJBGYW7KCKAMXM4YD:/'+cv.Title+'.'+cv.FileExtension+':/content';

           //String endPoint = 'https://graph.microsoft.com/v1.0/me/drive/root:/mohini&Gor' + '.'+cv.FileExtension + ':/content';
            system.debug('#### endpoint: ' + endPoint);
            req.setEndpoint(endPoint);
            
            req.setHeader('Authorization', 'bearer ' + accessToken);
    		req.setHeader('Content-Type', 'application/octet-stream');
           req.setHeader('ACCEPT','application/json;odata.metadata=full');

            String bodyDecoded = EncodingUtil.base64Encode(cv.VersionData);
           req.setBody(EncodingUtil.base64Encode(cv.versiondata));   
            httpResponse res = new httpResponse();
            res = http.send(req);
            integer statusCode = res.getStatusCode();
            string resBody = res.getBody();
            system.debug('#### sc: ' + statusCode);
            system.debug('#### rb: ' + resBody);                

    }
    public class ResponseWrapper{
        public String token_type;
        public String scope;
        public String expire_in;
        public String ext_expires_in;
        public String access_token;
    }
    
}