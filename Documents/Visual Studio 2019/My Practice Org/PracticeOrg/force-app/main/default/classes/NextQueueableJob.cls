public with sharing class NextQueueableJob {
    public NextQueueableJob() {

    }
    public void execute(QueueableContext context){
        Contact con=new Contact(FirstName='Mohini',LastName='Testing');
        insert con;
    }

}