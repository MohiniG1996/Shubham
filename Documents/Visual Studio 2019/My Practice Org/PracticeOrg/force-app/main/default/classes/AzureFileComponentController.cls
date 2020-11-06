public class AzureFileComponentController{
    
    @AuraEnabled
    public static Object getFileNamesFromAzure(String relatedAccountId){
        
        String fileNamePrefix = getFileNamePrefix(relatedAccountId);
        
        if(String.isNotBlank(fileNamePrefix)){
            
            String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
			
			//in azure file listing endpoint, we can pass a prefix variable
			//so it will only fetch files whose names are starting with given prefix
			//in this example, I am passing Account number as prefix variable, so I will get only files for respective account
            String strEndpoint = 'https://utillabazurefilestorage.file.core.windows.net/?restype=directory&comp=list&prefix=' + fileNamePrefix;
            
            String stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:' + strGMTDate + '\nx-ms-version:2019-02-02\n//';
            stringToSign += '\ncomp:list\nprefix:' + fileNamePrefix + '\nrestype:directory';
            
            String accountSharedKey = 'drl6q47lOdV/XnSdpXru3XPXtO93T36PSP/U/hO6SegptajTKZzsUzLFSX8DKl0Jl7bISTtlwQELcci5nYnUlA=='; // replace with your accounts shared key
            Blob decodedAccountSharedKey = EncodingUtil.base64Decode(accountSharedKey);
            
            String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
            
            
            //String authHeader = 'SharedKey :' + authToken;
            String authHeader = 'SharedKey utillabazurefilestorage:drl6q47lOdV/XnSdpXru3XPXtO93T36PSP/U/hO6SegptajTKZzsUzLFSX8DKl0Jl7bISTtlwQELcci5nYnUlA==';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(strEndpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', authHeader);
            req.setHeader('x-ms-date', strGMTDate);
            req.setHeader('x-ms-version','2019-02-02');
            System.debug(req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            
            String responseBody = res.getBody();
            
			//extract the file names from returned xml response and prepare a list of all file names
            Matcher regex = Pattern.compile('(?si)(.*?)<\\/Name>').matcher(responseBody);
            List<String> lstFileNames = new List<String>();
            
            while (regex.find()) {
                lstFileNames.add(regex.group(1));
            }
            
            system.debug(lstFileNames);
            return lstFileNames;
        }
        
        return 'noRecords';
    }
    
    public static String getFileNamePrefix(String relatedAccountId){
        
        String filePrefix = '';
        
        try{
            Account accountRecord = [SELECT Id,AccountNumber FROM Account WHERE Id =: relatedAccountId];
            
            if(accountRecord != null){
                
                filePrefix = accountRecord.AccountNumber;
                filePrefix = filePrefix.replaceAll(' ', '_');
                
                return filePrefix;
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        
        return filePrefix;
    }
	
	@AuraEnabled
    public static Object getFileContentFromAzure(String requestedFileName){
		
		if(String.isNotBlank(requestedFileName)){
        
            String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
    
            String strEndpoint = 'https://utillabazurefilestorage.file.core.windows.net//' + requestedFileName;
            
            String stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:' + strGMTDate + '\nx-ms-version:2019-02-02\n///' + requestedFileName;
            
            String accountSharedKey = 'drl6q47lOdV/XnSdpXru3XPXtO93T36PSP/U/hO6SegptajTKZzsUzLFSX8DKl0Jl7bISTtlwQELcci5nYnUlA=='; // replace with your accounts shared key
            Blob decodedAccountSharedKey = EncodingUtil.base64Decode(accountSharedKey);
            
            String authToken = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256',Blob.valueOf(stringToSign), decodedAccountSharedKey));
            
            //String authHeader = 'SharedKey :' + authToken;
            String authHeader = 'SharedKey utillabazurefilestorage:drl6q47lOdV/XnSdpXru3XPXtO93T36PSP/U/hO6SegptajTKZzsUzLFSX8DKl0Jl7bISTtlwQELcci5nYnUlA==';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(strEndpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', authHeader);
            req.setHeader('x-ms-date', strGMTDate);
            req.setHeader('x-ms-version','2019-02-02');
            System.debug(req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res);
            
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        }
        
        return 'noRecords';
	}
}