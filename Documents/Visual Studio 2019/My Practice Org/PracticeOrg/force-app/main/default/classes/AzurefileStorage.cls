public class AzurefileStorage {
    public static void upload(){
        
    string storageKey = '<your access key here>';
    string storageAccount = '<your storage account name here>';    
    string containerName = '<your container name here>';
    string blobName = 'test.txt';

    string method = 'PUT';
    string sampleContent = 'This is sample text.';
    integer contentLength = 100;
    string requestUri = 'https://utillabazurefilestorage.blob.core.windows.net/utilarianlabazure/'+blobName;
	Http http = new Http();
            httpRequest request = new httpRequest();
            request.setHeader('x-ms-date', DateTime.now().format('EEE, dd MMM yyyy HH:mm:ss z'));
            request.setHeader('Content-Type','text/plain; charset=UTF-8');        
            request.setHeader('x-ms-version', '2019-07-07');
            request.setHeader('x-ms-blob-type','BlockBlob');
        request.setHeader('Authorization','');
        
    }
}