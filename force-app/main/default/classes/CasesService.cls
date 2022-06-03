/**
 * @author Nicholas Schumacher
 * @date May 2022
 * 
 * @description A class to service logic for Cases regard of type/Business Unit.
 */
public with sharing class CasesService {
    
    public static void validateDescriptionDetails(Case myCase) {
        if(myCase.Description == null) {
            myCase.addError('Description cannot be null');
        } else {
            myCase.Description = myCase.Description + '\n Validated in super class.';
        }
    }

    public static void addDefaultsToDescription(Case myCase) {
        myCase.Description = myCase.Description + '\n Applied defaults in super class.';
    }
    
    public static void addAdditionalDetailsToDescription(Case myCase) {
        myCase.Description = myCase.Description + '\n super onBeforeInsert actions happened.';
    }

    public static FeedItem buildSimpleChatterReminderOnAccount(Case myCase) {
        if (myCase.AccountId != null) {
            /**
             * It would be wise to create a ChatterService class to house the logic for creating a post.
             * As business needs shift, this logic could be swapped out for more robust logic.
             *
             *  i.e. This simple approach doesn't allow for mentions -- using the Connect API would be a 
             * better option to implement
             * 
             * ChatterService.createPost(parentId, Body);
             */
            FeedItem post = new FeedItem();
            post.ParentId = myCase.AccountId;
            post.Body = 'Simple reminder post.'; // It would be better to store this in a Custom Label
            return post;
        }
        return null;
    }

    @future(callout=true)
    public static void exportNewCaseDetails(Set<Id> newCaseIdList) {
        
        /**
         * The below is a very rudimentary outline of a callout taken from Trailhead. In reality, there
         * are many additional pieces you'd want to put together: build a proper body for the payload, use a 
         * service class for making callouts so exception handling is consistent, a named credential for 
         * securing authentication information, exception logic for logging exceptions, and perhaps more.
         */


        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        // Set the body as a JSON object. It would be more effective to create a private wrapper class to encapsulate
        // the case list/information and serialize that
        request.setBody('{"name":"mighty moose"}');

        HttpResponse response = http.send(request);

        // Parse the JSON response
        if(response.getStatusCode() != 201) {
            // Should log to a custom object to keep track of failed integration calls
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            // Handle Success
            System.debug(response.getBody());
        }
    }
}
