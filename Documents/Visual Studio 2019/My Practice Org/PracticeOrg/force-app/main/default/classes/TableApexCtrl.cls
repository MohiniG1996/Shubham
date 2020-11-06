public class TableApexCtrl {
    
    @AuraEnabled
    public static Map<String,String> getFieldMap(String objName){
        try{
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            List<String> standardFields=new List<String>{
                'ownerid',
                    'createddate',
                    'createdbyid',
                    'lastmodifieddate',
                    'lastmodifiedbyid',
                    'systemmodstamp',
                    'lastactivitydate',
                    'lastvieweddate',
                    'lastreferenceddate'};
                        
                        Schema.SObjectType leadSchema = schemaMap.get(objName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            Map<String,String> fieldNameMap=new Map<String,String>();
            for (String fieldName: fieldMap.keySet()) {
                System.debug(standardFields.contains(fieldName));
                if(!standardFields.contains(fieldName)){
                    fieldNameMap.put(fieldMap.get(fieldName).getDescribe().getName(), fieldMap.get(fieldName).getDescribe().getLabel());
                }
            }
            return fieldNameMap;
        }catch(Exception e){
            System.debug('@@@@'+e.getMessage()+' AT '+e.getLineNumber()+' STACKTRACE '+e.getStackTraceString());
            return null;
        }  
    }
    public static String getField(Map<String,String> fieldMap){
        String fieldNames='';
        List<String> fieldAPIName=new List<String>();
        for(String field:fieldMap.keySet()){
            fieldAPIName.add(field);
        }
        System.debug('fields'+fieldAPIName);
        for(Integer i=0; i<fieldAPIName.size(); i++){
            if(i==fieldAPIName.size()-1){
                fieldNames=fieldNames+fieldAPIName[i];
            }else{
                fieldNames=fieldNames+fieldAPIName[i]+',';
            }
        }
        return fieldNames;
    }
    @AuraEnabled
    public static List<sobject> getAllRecord(String objName){
        try{
            List<sobject> recordList;
            if(objName!=null){
                Map<String,String> fieldMap=TableApexCtrl.getFieldMap(objName);
                String fields=TableApexCtrl.getField(fieldMap);
                String searchQuery='select '+fields+' from '+objName+' limit 100';
                System.debug(searchQuery);
                recordList=Database.query(searchQuery);
            }
            if(recordList.size()>0){
                return recordList;
            }
            
        }catch(Exception e){
            System.debug('@@@@'+e.getMessage()+' AT '+e.getLineNumber()+' STACKTRACE '+e.getStackTraceString());
        }
        return null; 
        
    }
    @AuraEnabled
    public static String deleteRecord(List<Id> idList){
        try{
            String res='';
            Database.DeleteResult[] drList= Database.delete(idList,true);
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    res='Success';
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        res='unSuccess';
                    }
                }
            }
            return res;
            
        }catch(Exception e){
            System.debug('@@@@'+e.getMessage()+' AT '+e.getLineNumber()+' STACKTRACE '+e.getStackTraceString());
            return null; 
        }
    }
}