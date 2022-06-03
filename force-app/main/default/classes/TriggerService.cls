public with sharing class TriggerService {
   
    public static Boolean isTriggerBypassed(String objectType) {
        Trigger_Bypass__c bypassSetting = Trigger_Bypass__c.getInstance();

        if(bypassSetting.Bypass_All__c) {
            return true;
        }

        switch on objectType {
            when 'Case' {
                if (bypassSetting.Case__c) {
                    return true;
                }
            }
            // ...expand for other objects here
        }

        return false;
    }
}
