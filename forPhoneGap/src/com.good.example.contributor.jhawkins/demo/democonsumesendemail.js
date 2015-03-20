/* Copyright (c) 2014 Good Technology Corporation
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/* Demo class for Send Email service.
 */

var module;
com.good.example.contributor.jhawkins._package(
    "com.good.example.contributor.jhawkins.demo.democonsumesendemail", module,
function (namespace) {
   
    var request = {
        "serviceId": "com.good.gfeservice.send-email",
        "serviceVersion": "1.0.0.0",
        "method": "sendEmail"
    };
    var logger;

    function sendRequest() {
        request.application = request.query[0].address;
        logger("About to send:", request);
        window.plugins.GDAppKineticsPlugin.callAppKineticsService(
            request.application, request.serviceId, request.serviceVersion,
            request.method, {
                "to" : [
                    "diagnostic.to_address.one@example.com",
                    "diagnostic.to_address.two_nodomain" ] },
            [ ],     // File attachment
            function(result) {
                logger("Request sent: ", result);
            },
            function(result) {
                logger("Failed to send request: ", result);
            } );
    }

    function demoExecute(myLogger) {
        logger = myLogger;

        window.plugins.GDInterAppCommunication.getGDAppDetails(
            request.serviceId, request.serviceVersion,
            function (result) {
                var result_array = result;
                if ((typeof result) == "string") {
                    result_array = eval( '(' + result + ')');
                }
                request.query = result_array.slice(0);
                logger("Application details: ", request.query);
                sendRequest();
            },
            function (result) {
                logger("Failed to get application details: ", result);
            } );
    }
    
    function demoLabel() {
        return "Send Email";
    }
    
    // Public methods
    namespace.demoExecute = demoExecute;
    namespace.demoLabel = demoLabel;

});
