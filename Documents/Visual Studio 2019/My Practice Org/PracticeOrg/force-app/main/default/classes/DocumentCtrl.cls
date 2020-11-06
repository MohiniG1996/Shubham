public class DocumentCtrl {
    @AuraEnabled
    public static void processData(String fileData,String sobjectName,List<String> fields) {
        System.debug('fileData:::'+filedata);
        System.debug('sobjectName:::'+sobjectName);
        System.debug('fields:::'+fields);
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectName);
        try{
            Map<String,Schema.DisplayType> fieldDataTypeMap=getDataTypeMap(fields,sobjectName);
            if(fileData!=null){ 
                String[] fileLines = new String[]{};
                    fileLines = fileData.split('\n');
                //for content
                List<sObject> myList = new List<sObject>();
                for (Integer i=1,j=fileLines.size();i<j;i++){
                    System.debug('fileLines==>'+fileLines[i]);
                    String[] inputvalues = new String[]{};
                        inputvalues = fileLines[i].split(',');
                    System.debug('inputValues==>'+inputvalues);
                    sObject obj = targetType.newSObject();
                    integer rowsize=inputvalues.size();
                    System.debug('rowsize::'+rowsize);
                    System.debug('fields size'+fields.size());
                    for(integer l=0;l<rowsize;l++){
                        System.debug('field==>'+fields.get(l));
                        System.debug('#####'+inputvalues[l]+'#####');
                        inputvalues[l]=inputvalues[l].replace('\r','');
                        System.debug('#####'+inputvalues[l]+'#####');
                        System.debug('input values i==>'+inputvalues[l]);
                        String fNm=fields.get(l);
                        Schema.DisplayType fieldDataType=fieldDataTypeMap.get(fields.get(l));
                        if(fieldDataType==Schema.DisplayType.DOUBLE){
                            if(String.isNotBlank(inputvalues[l]) ){
                                String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                                obj.put(fields.get(l),Double.valueOf(value));
                            }
                        }  
                        else if(fieldDataType==Schema.DisplayType.DATE){
                            List<String> dateParameters;
                            if(String.isNotBlank(inputvalues[l]) ){
                                String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                                if(value.contains('-')){
										dateParameters=value.split('-'); 
                                }else{
										dateParameters=value.split('/');   
                                }
                                System.debug('date Parameters==>'+dateParameters);
                                obj.put(fields.get(l),date.newInstance(Integer.valueOf(dateParameters[2]),Integer.valueOf(dateParameters[1]),Integer.valueOf(dateParameters[0])));
                            }
                        }
                        else if(fieldDataType==Schema.DisplayType.CURRENCY){
                            if(String.isNotBlank(inputvalues[l]) ){
                                String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                                obj.put(fields.get(l),Integer.valueOf(value));
                            }
                        }
                        else if(fieldDataType==Schema.DisplayType.BOOLEAN){
                            if(String.isNotBlank(inputvalues[l]) ){
                                String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                               obj.put(fields.get(l),Boolean.valueOf(value));
                            }
                        }
                        else{
                            if(String.isNotBlank(inputvalues[l]) ){
                                String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                                obj.put(fields.get(l),value);
                            }
                        }
                    }
                    myList.add(obj);
                }
                System.debug('mylist==>'+myList);
                insert myList;
            }
            
        }catch(Exception e){
            System.debug('exception'+e+'Line Number'+e.getLineNumber());   
        }
        
    }
    @AuraEnabled
    public static Document getDocTemplate(String objName){
        Document doc;
        try{
            if(objName.equals('Account')){
                doc=[select id,Name,Body,BodyLength from Document where Name='Account Template'];
            }
            if(objName.equals('Contact')){
                doc=[select id,Name,Body,BodyLength from Document where Name='Contact Template'];
            }
            return doc;
            
        }catch(Exception e){
            System.debug('Error:'+e.getMessage()+'Error Line Number:'+e.getLineNumber());
        }
        return null;
    }
    public static Schema.DisplayType getFieldDataType(String objectName,String fieldAPIName){
        Schema.DisplayType type = Schema.getGlobalDescribe() 
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldAPIName)
            .getDescribe()
            .getType(); 
        System.debug('DataType==>'+type);
        return type;
    }
    public static Map<String,Schema.DisplayType> getDataTypeMap(List<String> fields,String objectName){
        Map<String,Schema.DisplayType> fieldDataTypeMap=new Map<String,Schema.DisplayType>();
        for(String fieldAPIName:fields){
            Schema.DisplayType dtype=getFieldDataType(objectName,fieldAPIName);
            fieldDataTypeMap.put(fieldAPIName,dtype);
        }
        return fieldDataTypeMap;
    }
    
    
}