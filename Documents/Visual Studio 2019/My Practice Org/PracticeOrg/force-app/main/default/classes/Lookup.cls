public class Lookup 
{
    class HandlerMapping {
        public String handlerClassName;
        public Pattern utterancePattern;
        
        public HandlerMapping(String handlerClassName, String patternStr) {
            this.handlerClassName = handlerClassName;
            this.utterancePattern = Pattern.compile(patternStr);
        }
    }
    
    static List<HandlerMapping> handlerMappings;
    static {
        List<Bot_Command__c> commands = [SELECT apex_class__c, pattern__c FROM Bot_Command__c WHERE Active__c = True ORDER BY Name];
        System.debug(commands);
        List<HandlerMapping> mappings = new List<HandlerMapping>();
        for (Bot_Command__c command : commands) {
            mappings.add(new HandlerMapping(command.apex_class__c, command.pattern__c));
        }
        system.debug('mappings-->'+mappings);
        handlerMappings = mappings;
    }
    
    @AuraEnabled( cacheable=true) 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,Integer lim,String fld_API_Search,String searchText ){
        List<ResultWrapper> lstRet 	= new List<ResultWrapper>();
        List<sObject> sobjList		= new List<sObject>();
        List<String> searchStr		= new List<String>();
        System.debug('searchText==>'+searchText);
        
        try{
            searchStr					= searchText.split('@'); 
            searchText					= '\'%' + String.escapeSingleQuotes(searchStr[1].trim()) + '%\'';
            String query 				= 'SELECT '+fld_API_Text+' ,'+fld_API_Val+' FROM '+objectName+' WHERE '+fld_API_Search+' LIKE '+searchText+' LIMIT '+lim;
            
            
            System.debug('searchStr==>'+searchStr);
            sobjList 				= Database.query(query);
            System.debug('sobjList==>'+sobjList);
            for(SObject s : sobjList){
                ResultWrapper obj 	= new ResultWrapper();
                obj.objName 		= objectName;
                obj.text 			= String.valueOf(s.get(fld_API_Text));
                obj.val 			= String.valueOf(s.get(fld_API_Val)) ;
                lstRet.add(obj);
            } 
        }catch(Exception e){
            System.debug('Error Line==>'+e.getLineNumber()+'Error Message==>'+e.getMessage());
            return null;
        }
        return JSON.serialize(lstRet) ; 
    }
    @AuraEnabled
    public static String sendMessage(String utterance,String accId,List<String> selectedItem) {
        List<String> params 							= new List<String>();
        List<CoverSation_Memebers__c> conversationList	= new List<CoverSation_Memebers__c>();
        Map<String,String> userMap						= new Map<String,String>();
        List<User> userList 							= [SELECT Id,Name,IsActive FROM User where Name IN:selectedItem];
        
        try{
            //Storing messages in conversation object 
            Conversation__c con	= new Conversation__c();
            con.Message__c		= utterance;
            con.From_User__c	= userInfo.getUserId();
            con.Account__c		= accId;
            con.UserName__c		= userInfo.getName();
            insert con;
            
            //Creating User Map
            for(User u:userList){
                userMap.put(u.Name,u.id);
            }
            System.debug('userMap==>'+userMap);
            System.debug('selectedItem==>'+selectedItem);
            for(String selItem:selectedItem){
                System.debug('userMap==>'+userMap.get(selItem));
                CoverSation_Memebers__c conMem	= new CoverSation_Memebers__c();
                conMem.To_User__c				= userMap.get(selItem);
                conMem.Conversation__c			= con.Id;
                conversationList.add(conMem);
            }
            
            system.debug('utterance->'+utterance);
            for (HandlerMapping mapping : Lookup.handlerMappings) {
                Matcher utteranceMatcher = mapping.utterancePattern.matcher(utterance);
                if (utteranceMatcher.matches()) {
                    Type t 			= Type.forName('', mapping.handlerClassName);
                    BotHandler h 	= (BotHandler)t.newInstance();
                    for (Integer i=1; i<=utteranceMatcher.groupCount(); i=i+1) {
                        params.add(utteranceMatcher.group(i).trim());
                    }
                }
            }
            System.debug('conversationList==>'+conversationList);
            if(conversationList.size()>0){
                System.debug('conversationList==>'+conversationList);
                insert conversationList;
            }
            return 'Message Send Successfully!!!!';
        }
        catch (Exception e) {
            System.debug('Error Number:'+e.getLineNumber()+'Error Message:'+e.getMessage());                
            return null;
        }
    }
    
    public class ResultWrapper{
        @AuraEnabled 
        public String objName {get;set;}
        @AuraEnabled 
        public String text{get;set;}
        @AuraEnabled 
        public String val{get;set;}
    }
    
    
}