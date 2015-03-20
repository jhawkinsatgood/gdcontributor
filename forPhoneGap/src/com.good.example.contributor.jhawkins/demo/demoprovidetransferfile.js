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

/* Demo class for providing the Transfer File service.
 */

var module;
com.good.example.contributor.jhawkins._package(
    "com.good.example.contributor.jhawkins.demo.demoprovidetransferfile", module,
function (namespace) {
    
    var request = {
        "serviceId": "com.good.gdservice.transfer-file",
        "serviceVersion": "1.0.0.0",
        "method": "transferFile"
    };
    var logger;

    function logMetaData(path) {
       
        function fileSuccess(myFile) {
            logger("File length: " + myFile.size);
        }
        
        function getMetadataSuccess(myMetadata) {
            logger("Metadata:", myMetadata);
        }
        
        function getFileSuccess(myFileEntry) {
            logger('fileEntry.fullPath "' + myFileEntry.fullPath + '"');
            myFileEntry.getMetadata(
                getMetadataSuccess,
                function(myMetadataError) {
                    logger("getMetadata() failed:", myMetadataError);
                }
            );
            myFileEntry.file(
                fileSuccess,
                function name(myFileError) {
                    logger("file() failed:", myFileError);
                }
            )
        }
        
        var path_uri = "file://" + path;
        window.resolveLocalFileSystemURI(
            path_uri,
            getFileSuccess,
            function (event) {
                logger('resolveLocalFileSystemURI(' + path_uri +
                       ',,) failed:', event);
            }
        );
       
    }
 
    function demoExecute(myLogger) {
        logger = myLogger;
        
        var interval = setInterval( function() {
            window.plugins.GDAppKineticsPlugin.retrieveFiles(
                function(receivedFiles) {
                    logger( "receivedFiles:", receivedFiles );
                    logMetaData(receivedFiles[0]);
                },
                function(error) {
                    if (error != "Error - files waiting") {
                        if (typeof error == "string") {
                            logger('Failed to receive files "' + error + '"');
                        }
                        else {
                            logger("Failed to receive files:", error);
                        }
                    }
                } );
            window.plugins.GDAppKineticsPlugin.readyToProvideService(
                request.serviceId, request.serviceVersion,
                function(receivedRequest) {
                    if (receivedRequest != "OK") {
                        logger("receivedRequest:", receivedRequest);
                    }
                },
                function(error) {
                    logger("Failed to provide service:", error);
                } );
        }, 1000 );

        logger("Ready to provide service \"" + request.serviceId +
               "\". Interval: " + interval);
    }
    
    function demoLabel() {
        return "Provide Transfer File";
    }
    
    // Public methods
    namespace.demoExecute = demoExecute;
    namespace.demoLabel = demoLabel;

});
