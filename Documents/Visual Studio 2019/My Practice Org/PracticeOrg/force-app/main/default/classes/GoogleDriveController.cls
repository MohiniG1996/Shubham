public class GoogleDriveController
{
    private static String key = '127150638317-ln0td9dj3vhqmhj6jshmq6kak1ekmioi.apps.googleusercontent.com';
    private Static String secert = 'wwBqmaKu5uN7wc_A5CMdaE37';
  //  private Static string redirect_uri = 'https://'+ System.URL.getSalesforceBaseUrl().getHost();
  	  private static String redirect_uri='https://empathetic-badger-3433rd-dev-ed.lightning.force.com/c/GoogleDriveApp.app';
    
    @AuraEnabled
    public static String createAuthURL() {
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = 'https://accounts.google.com/o/oauth2/auth?'+
        'client_id='+key+
        '&response_type=code'+
        '&scope=https://www.googleapis.com/auth/drive'+
        '&redirect_uri='+uri+
        '&access_type=offline';
        return authuri;
    }
    
    @AuraEnabled
    public static String getAccessToken(String code)
    {
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'code='+code+'&client_id='+key+'&client_secret='+secert+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
         Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody()) ;  
          String token =  String.valueOf(responseMap.get('access_token'));
         return token;

   }
    
    @AuraEnabled
    public static String uploadFile(String fileName, String accessToken,String fileType,String fileE) {
        System.debug('FIleE==>'+fileE);
        blob file=Blob.valueof(fileE);
        String res='Failed';
        String boundary = '----------9889464542212';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(file);
        String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + fileName + '",' + ' "mimeType" : "' + fileType + '" }' + delimiter + 'Content-Type: ' + fileType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files');
        req.setHeader('Authorization', 'Bearer ' +accessToken);
        req.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setBody(body);
        req.setMethod('POST');
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        System.debug('resp==>'+resp.getStatusCode());
        System.debug('resp==>'+resp.getBody());
        if(resp.getStatusCode()==200){
            System.debug('Successfully Uploaded file');
            res='Success';
        }else{
            System.debug('resp==>'+resp.getStatusCode());
            System.debug('resp==>'+resp.getBody());
            
        }
        return res;
    }
        public  String  createFolder(String folderName,String accessToken){
        String folderId;
        HttpRequest req = new HttpRequest();   
        req.setMethod('POST');  
        req.setEndpoint('https://www.googleapis.com/drive/v3/files');   
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('content-type', 'application/json');  
        String body = '{"name" :"'+folderName+'","mimeType": "application/vnd.google-apps.folder"}';  
        req.setTimeout(60*1000);   
        req.setBody(body);  
        Http http = new Http();  
        HttpResponse res = http.send(req);  
            System.debug('res=>'+res.getStatusCode());
            System.debug('resp=>'+res.getBody());

        if(res.getStatusCode()==200){
            cGoogleAppAuthentication.GoogleDriveFolderResponse response = (cGoogleAppAuthentication.GoogleDriveFolderResponse)JSON.deserialize(res.getBody(), cGoogleAppAuthentication.GoogleDriveFolderResponse.class);
            System.debug(response);
            folderId=response.folder_id;
            System.debug('folderID==>'+folderId);
        }
        return folderId;
    }

	
}