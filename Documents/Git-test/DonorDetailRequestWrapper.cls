global class DonorDetailRequestWrapper {
    public String firstname{get;set;}
    public String lastname{get;set;}
    public String phone{get;set;}
    public String email{get;set;}
    public String address{get;set;}
    public String city{get;set;}
    public String state{get;set;}
    public String pincode{get;set;}
    public Integer amount{get;set;}
    public String status{get;set;}
    
    global class DonorDetail_ResponseWrapper{
        public String status_code{get;set;}
        public String status_message{get;set;}
        public String account_id{get;set;}
        public String account_name{get;set;}
        public String opportunity_id{get;set;}
        public String opportunity_Name{get;set;}
        
    }
    
}