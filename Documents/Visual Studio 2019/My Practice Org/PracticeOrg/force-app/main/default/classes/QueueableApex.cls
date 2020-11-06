public with sharing class QueueableApex implements Queueable {
    public QueueableApex() {

    }
    public void execute(QueueableContext context){
        Account a=new Account(Name='Albus Dumbledore', Phone='(990)242-8021');
        insert a;
		System.enqueueJob(new QueableSecondJob());        
    }

}