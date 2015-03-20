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

/* Demo class for Service Discovery.
 */

var com;

if (!com) { com = {}; }
if (!com.good) { com.good = {}; }
if (!com.good.example) { com.good.example = {}; }
if (!com.good.example.contributor) { com.good.example.contributor = {}; }
if (!com.good.example.contributor.jhawkins) { com.good.example.contributor.jhawkins = {}; }
if (!com.good.example.contributor.jhawkins.demo) { com.good.example.contributor.jhawkins.demo = {}; }

com.good.example.contributor.jhawkins.demo.demoappkinetics = {};
(function( ns ){
    
    var request = {
        "serviceId": "com.good.gfeservice.send-email",
        "serviceVersion": "1.0.0.0",
        "method": "sendEmail"
    };
    var logger;

    function logMessage(/* ... */) {
        for (var i=0; i < arguments.length; i++) {
            message = arguments[i];
            if (typeof message == "object") {
                logger(JSON.stringify(message));
            }
            else {
                logger("" + message);
            }
        }
    }
    
    function sendEmail() {
        logger("About to sendEmail");
        window.plugins.GDAppKineticsPlugin.callAppKineticsService(
            request.query[0].address, request.serviceId, request.serviceVersion,
            request.method, {
                "to" : [
                    "diagnostic.to_address.one@example.com",
                    "diagnostic.to_address.two_nodomain" ] },
            [  ],     // File attachment
            function(result) {
                        logMessage("Email sent: ", result);
            },
            function(result) {
                        logMessage("Failed to send email: ", result);
            } );
    }

    function demoExecute(myLogger) {
        logger = myLogger;

        window.plugins.GDInterAppCommunication.getGDAppDetails(
            request.serviceId, request.serviceVersion,
            function (result) {
                logMessage("Application details: ", result);
                request.query = result;
                sendEmail();
            },
            function (result) {
                logMessage("Failed to get application details: ", result);
            } );
    }
    
    function demoLabel() {
        return "AppKinetics";
    }
    
    // Public methods
    ns.demoExecute = demoExecute;
    ns.demoLabel = demoLabel;

})(com.good.example.contributor.jhawkins.demo.demoappkinetics);

