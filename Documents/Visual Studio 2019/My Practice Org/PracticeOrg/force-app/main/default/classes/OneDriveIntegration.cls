public class OneDriveIntegration {
    
    public static void uploadImageCallout(){
        String accessToken=AccessToken.getAccessToken();
        System.debug('accesToken===>'+accessToken);
        Set<Id> conDocLinksList=new Set<Id>();
        List<ContentDocumentLink> conDocLinks =[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = '0032x000003sW8WAAU'];
        for(ContentDocumentLink CD:conDocLinks){
            conDocLinksList.add(CD.ContentDocumentId);
        }
        System.debug('conDocLinksList==>'+conDocLinksList);
        List<ContentVersion> conVerList = [SELECT Id, Title, FileType,FileExtension,VersionData from ContentVersion WHERE ContentDocumentId IN:conDocLinksList];
        System.debug('conVerList==>'+conVerList);
        for (ContentVersion cv : conVerList)
        {
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
    }
    
}