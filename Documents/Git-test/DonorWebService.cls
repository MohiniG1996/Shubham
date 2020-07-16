@RestResource(urlMapping='/OneTime_PaymentDonor_Service')
global class DonorWebService {       
    @HttpPost
    global static DonorDetailRequestWrapper.DonorDetail_ResponseWrapper doPost(){
        DonorDetailRequestWrapper.DonorDetail_ResponseWrapper res=new DonorDetailRequestWrapper.DonorDetail_ResponseWrapper();
            res=DonorWebService_Handler.createDonorWebService();
            return res;
     }
}