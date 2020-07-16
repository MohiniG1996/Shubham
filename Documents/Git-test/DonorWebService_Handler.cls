public class DonorWebService_Handler {
    public static DonorDetailRequestWrapper.DonorDetail_ResponseWrapper createDonorWebService(){
        DonorDetailRequestWrapper.DonorDetail_ResponseWrapper res=new DonorDetailRequestWrapper.DonorDetail_ResponseWrapper();
        RestRequest req = Restcontext.Request;
        String jsonString = req.requestBody.toString();
        DonorDetailRequestWrapper reqWrapper=(DonorDetailRequestWrapper)JSON.deserialize(jsonString,DonorDetailRequestWrapper.class);
        System.debug('reqWrapper==>'+reqWrapper);
        List<Account> accRec;
        Account acc;
        Opportunity opp;
        List<Account> accList=new List<Account>();
        try{
            if(reqWrapper!=null && reqWrapper.status=='Pledged'){
                System.debug('reqWrapper@@@');
                if(!String.isEmpty(reqWrapper.email) && !String.isEmpty(reqWrapper.phone)){
                    accRec=[select id,Name,Email__c,Phone,ShippingCity,ShippingState,ShippingStreet,ShippingPostalCode from Account where Email__c=:reqWrapper.email AND Phone=:reqWrapper.phone limit 1];
                }if(!String.isEmpty(reqWrapper.email)){
                    accRec=[select id,Name,Email__c,Phone,ShippingCity,ShippingState,ShippingStreet,ShippingPostalCode from Account where Email__c=:reqWrapper.email limit 1];
                }if(!String.isEmpty(reqWrapper.phone)){
                    accRec=[select id,Name,Email__c,Phone,ShippingCity,ShippingState,ShippingStreet,ShippingPostalCode from Account where Phone=:reqWrapper.phone limit 1];
                }
                System.debug('accRec==>'+accRec);
                //if Donor already exist in Salesforce System & updating existing account if some info is new
                if(accRec!=null && accRec.size()>0){
                    for(Account ac:accRec){
                        if(String.isEmpty(ac.Name)){
                            ac.Name=reqWrapper.firstName+' '+reqWrapper.lastname;
                        }
                        if(String.isEmpty(ac.Email__c)){
                            ac.Email__c=reqWrapper.email;
                        }
                        if(String.isEmpty(ac.Phone)){
                            ac.Phone=reqWrapper.phone;
                            ac.Mobile__c=reqWrapper.phone;
                        }
                        if(String.isEmpty(ac.BillingCity)){
                            ac.BillingCity=reqWrapper.city;
                        }
                        if(String.isEmpty(ac.BillingState)){
                            ac.BillingState=reqWrapper.state;
                        }
                        if(String.isEmpty(ac.BillingStreet)){
                            ac.BillingStreet=reqWrapper.address;
                        }
                        if(String.isEmpty(ac.BillingPostalCode)){
                            ac.BillingPostalCode=reqWrapper.pincode;
                        }
                        accList.add(ac);
                    }
                    opp=new Opportunity();
                    if(!String.isEmpty(reqWrapper.firstname) && !String.isEmpty(reqWrapper.lastname)){
                        opp.Name=reqWrapper.firstname+'_'+reqWrapper.lastname+'_'+reqWrapper.amount;
                    }else if(!String.isEmpty(reqWrapper.firstname)){
                        opp.Name=reqWrapper.firstname+'_'+reqWrapper.amount;
                    }else{
                        opp.Name=reqWrapper.lastname+'_'+reqWrapper.amount;
                    }
                    
                    opp.Amount=reqWrapper.amount;
                    opp.CloseDate=System.today();
                    opp.AccountId=accRec[0].Id;
                    opp.Rzp_payment_Status__c=reqWrapper.status;
                    if(reqWrapper.status=='Pledged'){
                            opp.StageName='Prospecting'; 
                        }else if(reqWrapper.status=='Posted'){
                            opp.StageName='Closed Won'; 
                            
                        }else{
                            opp.StageName='Closed Lost'; 
                        }
						opp.Payment_Mode__c='Razorpay';
                    System.debug('recordtypeid'+Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Donation').getRecordTypeId());
                    Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Donation').getRecordTypeId();
                    opp.RecordTypeId= oppRecordTypeId;
                    insert opp;
                }else{
                    //When Donor doesnot exist in Salesforce System & creating new Donor
                    if(!String.isEmpty(reqWrapper.phone)){
                        acc=new Account();
                        if(!String.isEmpty(reqWrapper.firstname) && !String.isEmpty(reqWrapper.lastname)){
                            acc.Name=reqWrapper.firstname+'_'+reqWrapper.lastname;
                        }
                        else if(!String.isEmpty(reqWrapper.firstname)){
                            acc.Name=reqWrapper.firstname;
                        }
                        else{
                            acc.Name=reqWrapper.LastName;
                        }
                        
                        acc.Email__c=reqWrapper.email;
                        acc.Phone=reqWrapper.phone;
                        acc.Mobile__c='91'+reqWrapper.phone;
                        acc.BillingCity=reqWrapper.city;
                        acc.BillingState=reqWrapper.state;
                        acc.BillingStreet=reqWrapper.address;
                        acc.BillingPostalCode=reqWrapper.pincode;
                        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
                        insert acc;
                        
                        opp=new Opportunity();
                        if(!String.isEmpty(reqWrapper.firstname) && !String.isEmpty(reqWrapper.lastname)){
                            opp.Name=reqWrapper.firstname+'_'+reqWrapper.lastname+'_'+reqWrapper.amount;
                        }else if(!String.isEmpty(reqWrapper.firstname)){
                            opp.Name=reqWrapper.firstname+'_'+reqWrapper.amount;
                        }else{
                            opp.Name=reqWrapper.lastname+'_'+reqWrapper.amount;
                        }
                        
                        opp.Amount=reqWrapper.amount;
                        opp.CloseDate=System.today();
                        opp.AccountId=acc.Id;
                        opp.Payment_Mode__c='Razorpay';
                        if(reqWrapper.status=='Pledged'){
                            opp.StageName='Prospecting'; 
                        }else if(reqWrapper.status=='Posted'){
                            opp.StageName='Closed Won'; 
                            
                        }else{
                            opp.StageName='Closed Lost'; 
                        }
                    	opp.Rzp_payment_Status__c=reqWrapper.status;
                        System.debug('recordtypeid'+Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Donation').getRecordTypeId());
                        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Online_Donation').getRecordTypeId();
                        opp.RecordTypeId= oppRecordTypeId;
                        insert opp;
                    }
                    else{
                        res=getResponse(acc,opp,reqWrapper);
                    }
                }
                if(accList.size()>0)
                {
                    update accList;
                }
                
            }else{
                if(reqWrapper!=null && (reqWrapper.status=='Posted' || reqWrapper.status=='Rejected')){
                    List<Opportunity> updateOpportunity=new List<Opportunity>();
                    String searchKey='%'+reqWrapper.firstname+'_'+reqWrapper.lastname+'_'+reqWrapper.amount+'%';
                    List<Opportunity> oppList=[select Id,Name,Rzp_payment_Status__c from opportunity where Name like:searchKey]; 
                    System.debug('oppList==>'+oppList);
                    for(Opportunity oppRecord:oppList){
                        oppRecord.Rzp_payment_Status__c=reqWrapper.status;
                        oppRecord.CloseDate=System.today();
                        if(reqWrapper.status=='Posted'){
                            oppRecord.StageName='Closed Won'; 
                            
                        }else{
                            oppRecord.StageName='Closed Lost'; 
                        }
                        updateOpportunity.add(oppRecord);
                    }
                    if(updateOpportunity.size()>0){
                        update updateOpportunity;
                    }
                }
            }
            return res=getResponse(acc,opp,reqWrapper);
        }catch(Exception e){
            System.debug('Line Number==>'+e.getLineNumber()+'Error message'+e.getMessage());
            res.status_code = '400';
            res.status_message ='Error Occurred';
            res.account_id = '';
            res.account_name='';
            res.opportunity_id='';
            res.opportunity_Name='';
            return res;
        }
    }
    public static DonorDetailRequestWrapper.DonorDetail_ResponseWrapper getResponse(Account acc,Opportunity opp,DonorDetailRequestWrapper reqWrapper){
        DonorDetailRequestWrapper.DonorDetail_ResponseWrapper res=new DonorDetailRequestWrapper.DonorDetail_ResponseWrapper();
        if(acc==null && opp==null && reqWrapper.status=='Pledged'){
            res.status_code = '400';
            res.status_message = 'Please give proper phone number';
        }else if(reqWrapper.status=='Posted'){
            res.status_code = '200';
            res.status_message = 'Transaction Posted Successfully!!';
            res.account_id = '';
            res.account_name='';
            res.opportunity_id='';
            res.opportunity_Name='';
            
        }else if(reqWrapper.status=='Rejected'){
            res.status_code = '400';
            res.status_message = 'Transaction Rejected!!';
            res.account_id = '';
            res.account_name='';
            res.opportunity_id='';
            res.opportunity_Name='';
        }
        else{
            res.status_code = '200';
            res.status_message = 'Record Created Successfully!';
            if(acc != null){
                res.account_id = acc.Id;
                res.account_name=acc.Name;
            }else{
                res.account_id = ' ';
                res.account_name= ' ';
            }          
            res.opportunity_id=opp.Id;
            res.opportunity_Name=opp.Name;
            
        }
        return res;    
    }
    public static boolean isValidPhoneNumber(String phoneNumber){
        Integer counter = 0;
        for(String str : phoneNumber.split(''))
        {
            Pattern ptn = Pattern.compile('\\d+');
            Matcher m = ptn.matcher(str);
            
            if(m.find()) {
                counter++;  
            }
        }
        if(counter==10){
            return true;
        }else{
            return  false;
        }
    }
}