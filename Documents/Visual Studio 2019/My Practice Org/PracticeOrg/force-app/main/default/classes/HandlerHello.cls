public with sharing class HandlerHello implements BotHandler {
    
    public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        //Integer randomNumber = Integer.valueof((Math.random() * sizeof the metadata fetch with classname));
        List<BotChat_Answers_Metadata__mdt> md = new List<BotChat_Answers_Metadata__mdt>();
        md= [select id,Class_Name__c,Response__c from BotChat_Answers_Metadata__mdt where Class_Name__c='HandlerHello'];
        system.debug('md'+md);
        
        Integer randomNumber = Integer.valueof((Math.random() * md.size()));
        String resp='';
        if(md.size()>0){
            resp = md[randomNumber].Response__c;
        }
        return new BotResponse(new BotMessage('Bot', resp ));
    }
    
}