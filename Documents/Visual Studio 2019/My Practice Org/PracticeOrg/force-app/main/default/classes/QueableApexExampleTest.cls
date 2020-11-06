@isTest
private class QueableApexExampleTest {

    static testmethod void test1(){
        Test.startTest();
        	System.enqueueJob(new QueableApexExample());
        Test.stopTest();
        
        Account acc=[select Name,Phone from account where Name='Albus Dumbledore' limit 1];
        System.assertNotEquals(null, acc);
        System.assertEquals('Albus Dumbledore', acc.Name);
    }
}