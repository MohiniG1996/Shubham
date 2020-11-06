public with sharing class BotController {
    
    //wrapper class
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
    
    @AuraEnabled
    public static BotResponse AllOldMessages(String accId){
        //get Current User full Name
        String CurrentUserName 					= UserInfo.getName();
        List<Conversation__c> oldMessageList	= [Select Id,Name,Message__c,UserName__c from Conversation__c where Account__c=:accId order by CreatedDate asc];
        return new BotResponse(oldMessageList,CurrentUserName);
    }
}