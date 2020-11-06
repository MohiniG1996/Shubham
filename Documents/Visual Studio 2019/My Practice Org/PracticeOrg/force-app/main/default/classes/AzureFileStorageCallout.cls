public class AzureFileStorageCallout {
    
    public static void azureStorageCallout(){
        String accessToken=AccessToken.getAccessToken();
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
                    
                   // String endpoint='https://utillabazurefilestorage.file.core.windows.net/?restype=directory&comp=list&prefix='+cv.Title+'.'+cv.FileExtension+accessToken;
            Http http = new Http();
            httpRequest request = new httpRequest();
            request.setHeader('x-ms-date', DateTime.now().format('EEE, dd MMM yyyy HH:mm:ss z'));
            request.setHeader('Content-Type','multipart/form-data');        
            request.setHeader('x-ms-version', '2019-07-07');
            request.setHeader('x-ms-blob-type','BlockBlob');
            request.setBodyAsBlob(cv.VersionData);
            String endpoint = 'https://utillabazurefilestorage.blob.core.windows.net/utilarianlabazure/' + cv.Title+'?sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2020-08-26T02:25:24Z&st=2020-08-25T18:25:24Z&spr=https&sig=jDTw8qyQNoijZeAYory56KYYHJNQgQJsXnh6a4Dmzns%3D';
        	request.setEndpoint( endpoint);

            request.setMethod('PUT');
            httpResponse res = new httpResponse();
            res = http.send(request);
            integer statusCode = res.getStatusCode();
            string resBody = res.getBody();
            system.debug('#### sc: ' + statusCode);
            system.debug('#### rb: ' + resBody);                

            
        }
        
        
    }
    
}