public class SampleAuraController {
    @AuraEnabled
    public static String getMessage() {
        return 'Hello World!!';
    }

}