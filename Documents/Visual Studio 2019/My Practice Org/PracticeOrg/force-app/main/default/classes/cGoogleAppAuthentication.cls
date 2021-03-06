public class cGoogleAppAuthentication
{
    private string key = '127150638317-ln0td9dj3vhqmhj6jshmq6kak1ekmioi.apps.googleusercontent.com' ;
    private string secret = 'wwBqmaKu5uN7wc_A5CMdaE37';
    private string redirect_uri = 'https://'+ System.URL.getSalesforceBaseUrl().getHost()+'/apex/GoogleDriveVFPage';
    private String codemeniaIdentificationToken ; 
    private String folderId='';
    private String access_token; 
    private List<String> FileLst;
    public Map<String,String> FileIdAndNameMapFortheAccount{get;set;}
    public boolean val { get;set;}
    public blob file {get;set;}
    public String filetype {get;set;}
    public String filename {get;set;}
    public cGoogleAppAuthentication()
    {
        codemeniaIdentificationToken = ApexPages.currentPage().getParameters().get('code') ;
        
        FileLst=new List<String>();
        FileIdAndNameMapFortheAccount=new Map<String,String>();
        if(codemeniaIdentificationToken != '' && codemeniaIdentificationToken != null)
        {
            AccessToken();
        } 
    }
        public void AccessToken()
    {
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //End point for authentication
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        //Message body for Authentication
        String messageBody = 'code='+codemeniaIdentificationToken+'&client_id='+key+'&client_secret='+secret+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        //Salesforce defined JSON Parser
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) 
        {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token'))
            {
                parser.nextToken();
                access_token=parser.getText();
                System.debug('@@@'+access_token);
                break;
            }
        }
        if (access_token!='' && access_token != null)
        {
            ListFiles();
        }
    }

    public void Upload() {
        System.debug('folder_id==>'+folderId);
        String boundary = '----------9889464542212';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(file);
        String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + filename + '",' + ' "mimeType" : "' + filetype + '" }' + delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files');
        req.setHeader('Authorization', 'Bearer ' +access_token );
        req.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setBody(body);
        req.setMethod('POST');
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode()==200){
            System.debug('Successfully Uploaded file');
        }else{
            System.debug('resp==>'+resp.getStatusCode());
            System.debug('resp==>'+resp.getBody());
            
        }
        filetype = '';
        filename = '';
    }
    public PageReference DriveAuth()
    {
        PageReference pg = new PageReference(new cAuthURIForApiREq(key , redirect_uri).AuthenticationURI) ;
        return pg;
    }
    
    public PageReference ListFiles()
    {  
        Google_Drive_Info__c g=new Google_Drive_Info__c();
        g=[SELECT id__c FROM Google_Drive_Info__c WHERE Name=:'main'];
        String FolderId=g.id__c;
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('GET');
        //End point for List of Files in Folder
        req1.setEndpoint('https://www.googleapis.com/drive/v2/files/'+FolderId+'/children');
        req1.setHeader('content-type', 'application/x-www-form-urlencoded');
        req1.setHeader('Content-length', '0');
        //Specific Authorization Syntax
        req1.setHeader('Authorization' , 'Bearer'+' '+ access_token);
        req1.setTimeout(60*1000);
        Http h2 = new Http();
        HttpResponse resl = h2.send(req1);
       // System.debug('^^^^^'+resl.getBody());
        JSONParser parserD = JSON.createParser(resl.getBody());
        while (parserD.nextToken() != null) 
        {
            if ((parserD.getCurrentToken() == JSONToken.FIELD_NAME) && (parserD.getText() == 'id'))
            {
                parserD.nextToken();
                FileLst.add(parserD.getText());
            }
        }
        Map<String,String> FileIdAndNameMap=FileProperties();
        for(String s:FileLst)
        {
            FileIdAndNameMapFortheAccount.put(s, FileIdAndNameMap.get(s));
        }
        //('FileIdAndNameMapFortheAccount==>'+FileIdAndNameMapFortheAccount);
        return null;
    }
    public  Map<String,String> FileProperties()
    {
        Map<String,String> FilePropertiesDetails=new Map<String,String>();
        HttpRequest req2 = new HttpRequest();
        req2.setMethod('GET');
        //End point URL for All the files in the drive and its ID,Name value in JSON Response
        req2.setEndpoint('https://www.googleapis.com/drive/v3/files');
        req2.setHeader('content-type', 'application/x-www-form-urlencoded');
        req2.setHeader('Content-length', '0');
        req2.setHeader('Authorization' , 'Bearer'+' '+ access_token);
        req2.setTimeout(60*1000);
        Http h3 = new Http();
        HttpResponse resls = h3.send(req2);
       // System.debug('^^^^^'+resls.getBody());
        JSONParser parserDr = JSON.createParser(resls.getBody());
        while (parserDr.nextToken() != null) 
        {   
            String FileName='';
            String FileId='';
            if ((parserDr.getCurrentToken() == JSONToken.FIELD_NAME))
            {
                //First TOKEN is Id
                if((parserDr.getText() == 'id'))
                {
                    parserDr.nextToken();               
                    Fileid=parserDr.getText();
                }
                //Moving to Next Parser
                parserDr.nextToken();
                //Next Token is Name
                if((parserDr.getText() == 'name')) 
                {
                    parserDr.nextToken();
                    Filename=parserDr.getText();
                }
                FilePropertiesDetails.put(Fileid, Filename);
            }
        }
        return FilePropertiesDetails;
    }
    public  PageReference  createFolder(){
        HttpRequest req = new HttpRequest();   
        req.setMethod('POST');  
        req.setEndpoint('https://www.googleapis.com/drive/v3/files');   
        req.setHeader('Authorization', 'Bearer '+access_token);
        req.setHeader('content-type', 'application/json');  
        String body = '{"name" :"Rekha","mimeType": "application/vnd.google-apps.folder"}';  
        req.setTimeout(60*1000);   
        req.setBody(body);  
        Http http = new Http();  
        HttpResponse res = http.send(req);  
        if(res.getStatusCode()==200){
            cGoogleAppAuthentication.GoogleDriveFolderResponse response = (cGoogleAppAuthentication.GoogleDriveFolderResponse)JSON.deserialize(res.getBody(), cGoogleAppAuthentication.GoogleDriveFolderResponse.class);
            System.debug(response);
            folderId=response.folder_id;
            System.debug('folderID==>'+folderId);
        }else{
            //System.debug('===== Response==='+ res.getStatusCode());  
            //System.debug('===== Response==='+ res.getBody());  
        }
        return null;
    }
    public PageReference uploadFileInFolder(){
        String boundary = '----------9889464542212';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(file);
        System.debug('File Type==>'+filetype);
        String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + filename + '",' +'"name":"Mohini Testing",' + ' "mimeType" : "' + 'application/vnd.google-apps.folder' +  '",'+ ' "parents" : '+'["1fJnAZgj4EZOCkloAM8ru7sG4xweftAky"]'    +' }' + delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
	
        //String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + filename + '",' +'"name":"Mohini Testing",' + ' "mimeType" : "' + 'application/vnd.google-apps.folder' +  '",'+ ' "parents":["kind":"drive#fileLink","id":"1fJnAZgj4EZOCkloAM8ru7sG4xweftAky"]}' + delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
		//String body='{"title":"'+filename+'","mimeType":"'+filetype+'","parents":[{"kind":"drive#fileLink","id":"1fJnAZgj4EZOCkloAM8ru7sG4xweftAky"}]}';

        //String body='{"id":"1fJnAZgj4EZOCkloAM8ru7sG4xweftAky"}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://www.googleapis.com/drive/v4/files');
        req.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=media');
        req.setHeader('Authorization', 'Bearer ' +access_token );
        req.setHeader('Content-Type', 'application/json');
       req.setHeader('Content-length', String.valueOf(body.length()));
        req.setBody(body);
        req.setMethod('POST');
        req.setTimeout(60 * 1000);
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode()==200){
            System.debug('Successfully Uploaded file');
        }else{
            System.debug('resp==>'+resp.getStatusCode());
            System.debug('resp==>'+resp.getBody());
            
        }
        filetype = '';
        filename = '';

        return null;
    }
    public PageReference createChildFolder(){
        HttpRequest req = new HttpRequest();   
		req.setMethod('POST');   
		req.setEndpoint('https://www.googleapis.com/drive/v2/files');   
		req.setHeader('Authorization', 'Bearer '+access_token);   
        req.setHeader('content-type', 'application/json');  
		String body = '{"title":"childfolder","mimeType":"application/vnd.google-apps.folder","parents": [{"kind": "drive#fileLink","id": "1fJnAZgj4EZOCkloAM8ru7sG4xweftAky"}]}';  
		req.setTimeout(60*1000);   
		req.setBody(body);  
		Http http = new Http();  
		HttpResponse res = http.send(req);    
		System.debug('=====the resp==='+ res.getBody()); 
        return null;
    }
    public class GoogleDriveFolderResponse{
        public String folder_id;
        public String folder_name;
        public String mime_type;
    }
    
}