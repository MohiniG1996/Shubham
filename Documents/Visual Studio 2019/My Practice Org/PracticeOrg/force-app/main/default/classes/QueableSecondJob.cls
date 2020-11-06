public class QueableSecondJob implements Queueable{
    
    public void execute(QueueableContext context){
        Contact con=new Contact(FirstName='Mohini',LastName='Testing');
        insert con;
    }

}