global class MyHttpCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"animals": ["majestic badger","fluffy bunny","scary bear","chicken",null]}');
        res.setStatusCode(200);
        return res;
    }
}