public class cGoogleAuthenticationHelper {
    private string redirect_uri = 'https://'+ System.URL.getSalesforceBaseUrl().getHost()+'/apex/GoogleDriveVFPage';
    private String codemeniaIdentificationToken ; 
    
    public cGoogleAuthenticationHelper()
    {
        codemeniaIdentificationToken = ApexPages.currentPage().getParameters().get('code') ;
        System.debug('codemeniaIdentificationToken==>'+codemeniaIdentificationToken);
        if(codemeniaIdentificationToken != '' && codemeniaIdentificationToken != null)
        {
           // AccessToken();
        } 
    }
    public static GoogleDrive__c getCustomSetting(){
        GoogleDrive__c drive = GoogleDrive__c.getValues('Google Drive');	
        return drive;
    }
    public static String AccessToken(String codemeniaIdentificationToken,String redirecturi)
    {
        String access_token=null;
        //getting custom setting
        GoogleDrive__c drive=getCustomSetting();
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //End point for authentication
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        //Message body for Authentication
        String messageBody = 'code='+codemeniaIdentificationToken+'&client_id='+drive.Client_Key__c+'&client_secret='+drive.Client_Secret_Key__c+'&redirect_uri='+redirecturi+'&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(res.getStatusCode()==200){
            cGoogleAuthenticationHelper.AccessTokenResponse response = (cGoogleAuthenticationHelper.AccessTokenResponse)JSON.deserialize(res.getBody(), cGoogleAuthenticationHelper.AccessTokenResponse.class);
            access_token=response.access_token;
        }else{
            System.debug('Status Code==>'+res.getStatusCode());
            System.debug('Status==>'+res.getStatus());
            System.debug('res body==>'+res.getBody());
        }
        return access_token;
    }
    public class AccessTokenResponse{
        public String access_token;
        public String expire_in;
        public String scope;
        public String token_type;
    }
    
}