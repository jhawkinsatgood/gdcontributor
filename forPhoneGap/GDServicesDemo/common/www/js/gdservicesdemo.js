/* Copyright (c) 2015 Good Technology Corporation
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

/* GDServicesDemo - Object that holds data and code for a simple demonstration
 * of application-based services.
 */
var GDServicesDemo = {
    
    /* request - object that holds details of the request.
     */
    request: {
        identifier: null,
        version: null,
        method: null,
        parameters: null,
        attachments: null
    },
    
    /* consumeDemoA - Entry point for demonstration of consuming an
     * application-based service.
     */
    consumeDemoA: function() {
        console.log('GDServicesDemo.consumeDemoA()');
        GDServicesDemo.request.identifier = "com.good.gdservice.transfer-file";
        GDServicesDemo.request.version = "1.0.0.0";
        GDServicesDemo.request.method = "transferFile";
        GDServicesDemo.createFile("att0.txt",
                                  GDServicesDemo.getProvidersAndSend );
    },
    
    /* consumeDemoB - Entry point for demonstration of consuming an alternative
     * application-based service.
     */
    consumeDemoB: function() {
        console.log('GDServicesDemo.consumeDemoB()');
        GDServicesDemo.request.identifier = "com.good.gdservice.launchable";
        GDServicesDemo.request.version = "1.0.0.0";
        GDServicesDemo.request.method = "launch";
        GDServicesDemo.request.parameters = {
            "textValue": "Text Value",
            "numericValue": 23,
            "arrayOfStrings": [
                "First String", "Second String", "Third String"
            ]
        };
        GDServicesDemo.getProvidersAndSend();
    },
    
    /* createFile - Creates a file with a specified name and then runs another
     * function after, unless creation fails.
     */
    createFile: function (filename, after) {
        console.log("createFile(" + filename + ",)");
        
        /* createDirectoryOK - callback for when the directory has been
         * obtained.
         */
        function createDirectoryOK(directoryHandle) {
            console.log("createDirectoryOK " +
                        JSON.stringify(directoryHandle, null, 2));
            directoryHandle.getFile(
                filename, {create:true},
                function(fileHandle) {
                    console.log("directoryHandle.getFile OK " +
                                JSON.stringify(fileHandle));
                    GDServicesDemo.createFileWrite(fileHandle, after);
                },
                function (error) {
                    console.log("directoryHandle.getFile failed " +
                                JSON.stringify(error));
                }
            );
        };

        // File creation starts here, with access to a file system object for
        // the Good Dynamics secure file system.
        window.requestFileSystem(LocalFileSystem.PERSISTENT,
            0,
            // Callback for when the file system object has been obtained.
            function (fileSystem) {
                // Get a directory object for a location in the file system.
                fileSystem.root.getDirectory(
                    "/",
                    {create: true, exclusive: false},
                    createDirectoryOK,
                    function (error) {
                        console.log("getDirectory failed " +
                                    JSON.stringify(error));
                    }
                );
            },
            function (error) {
                console.log("requestFileSystem failed " +
                            JSON.stringify(error));
            }
        );
        
        // The following seems like it should work but it doesn't seem to
        // result in files being written to the secure file system.
        //window.resolveLocalFileSystemURI( cordova.file.dataDirectory,
        //    createDirectoryOK,
        //    function (error) {
        //        console.log("resolveLocalFileSystemURI failed " +
        //                    JSON.stringify(error));
        //    }
        //);
    },
    
    /* createFileWrite - Creates a file from a file handle and then runs
     * another function after, unless creation fails.
     */
    createFileWrite: function(fileHandle, after) {
        console.log("createFileWrite \"" +  fileHandle.fullPath + "\"" );

        // There are two steps:
        // -   Create a FileWriter object.
        // -   Write some content using the FileWriter.
        //
        // Either step could fail.
        //
        fileHandle.createWriter(
            function (fileWriter) {
                console.log("createFileWrite createWriter OK " +
                            JSON.stringify(fileWriter));

                // FileWriter obtained, set up the write.
                //
                // Set a completion callback.
                fileWriter.onwriteend = function(endstate) {
                    console.log("createFileWrite createWriter end " +
                                JSON.stringify(fileHandle, null, 2) );
                    if (GDServicesDemo.request.attachments == null) {
                        GDServicesDemo.request.attachments = [];
                    }
                    GDServicesDemo.request.attachments.push(
                        fileHandle.fullPath
                    );
                    console.log("createFileWrite added attachment " +
                                JSON.stringify(
                                    GDServicesDemo.request.attachments) + " " +
                                JSON.stringify(endstate, null, 2));
                    after();
                };

                // Set an error callback.
                fileWriter.onerror = function(error) {
                    console.log("createFileWrite write failed " +
                                JSON.stringify(error));
                };

                // Actually write some content.
                var content = "Line 1\nLine 2\n";
                console.log("createFileWrite about to write " +
                            JSON.stringify(content));
                fileWriter.write(content);
            },
            
            // Callback for when creation of the FileWriter failed.
            function (error) {
                console.log("createFileWrite createWriter failed " +
                            JSON.stringify(error));
            }
        );
    },
    
    /* getProvidersAndSend - Make a service discovery query and send a service
     * request, based on the details already set in the request attribute.
     */
    getProvidersAndSend: function() {
        // Sending a service request starts here, with a service
        // discovery query.
        window.plugins.GDInterAppCommunication.getGDAppDetails(
            GDServicesDemo.request.identifier,
            GDServicesDemo.request.version,
            GDServicesDemo.getProvidersOK,
            GDServicesDemo.getProvidersFailed
        );
    },

    /* getProvidersOK - Callback for when the service discovery query succeeds.
     * See also getProvidersFailed, below.
     */
    getProvidersOK: function(result) {
        var result_array = result;
        if ((typeof result) == "string") {
            result_array = eval( '(' + result + ')');
        }
        if (result_array.length < 1) {
            console.log("No providers.");
            return;
        }
        var provider = result_array[0];
        console.log("Provider details: ", JSON.stringify(provider));
        GDServicesDemo.request.provider = provider;
        GDServicesDemo.consumeSend();
    },
    
    /* consumeSend - Actually sends a service request, taking details from the
     * collection in the request attribute, above.
     */
    consumeSend: function() {
        if (GDServicesDemo.request.attachments == null) {
            GDServicesDemo.request.attachments = [];
        }
        console.log(
            "About to callAppKineticsService(" +
            GDServicesDemo.request.provider.address + ',' +
            GDServicesDemo.request.identifier + ',' +
            GDServicesDemo.request.version + ',' +
            GDServicesDemo.request.method + ', ' +
            JSON.stringify(GDServicesDemo.request.parameters) + ', ' +
            JSON.stringify(GDServicesDemo.request.attachments) + ",,)"
        );
        window.plugins.GDAppKineticsPlugin.callAppKineticsService(
            GDServicesDemo.request.provider.address,
            GDServicesDemo.request.identifier,
            GDServicesDemo.request.version,
            GDServicesDemo.request.method,
            GDServicesDemo.request.parameters,
            GDServicesDemo.request.attachments,
            function(result) {
                console.log("Request sent: ", result);
            },
            function(result) {
                console.log("Failed to send request: ", result);
            }
        );
    },

    /* getProvidersFailed - Callback for when the service discovery query
     * fails. See also getProvidersOK, above.
     */
    getProvidersFailed: function(result) {
        console.log("Failed to get provider details: ", result);
    },
    
    /*
     *
     */
    provide: function() {
        var interval = setInterval(
            function() {
                window.plugins.GDAppKineticsPlugin.readyToProvideService(
                    "com.good.gdservice.launchable", "1.0.0.0",
                    function(receivedRequest) {
                        if (receivedRequest != "OK" && receivedRequest != null) {
                            console.log("receivedRequest:" +
                                        JSON.stringify(receivedRequest));
                            var attachments = receivedRequest.attachments;
                            if (attachments == null ||
                                attachments == undefined ||
                                attachments.length < 1
                                )
                            {
                                console.log("No attachments.");
                            }
                            else {
                                GDServicesDemo.logMetaData(attachments);
                            }
                        }
                    },
                    function(error) {
                        console.log("Failed to provide service:", error);
                    }
                );
            },
            1000
        );
    
        console.log("Providing service. Interval: " + interval);
    },

    logMetaData: function(paths) {
        function fileSuccess(myFile) {
            console.log("File length: " + myFile.size);
        }
        
        function getMetadataSuccess(myMetadata) {
            console.log("Metadata:", myMetadata);
        }
        
        function getFileSuccess(myFileEntry) {
            console.log('fileEntry.fullPath "' + myFileEntry.fullPath + '"');
            myFileEntry.getMetadata(
                getMetadataSuccess,
                function(myMetadataError) {
                    console.log("getMetadata() failed:", myMetadataError);
                }
            );
            myFileEntry.file(
                fileSuccess,
                function name(myFileError) {
                    console.log("file() failed:", myFileError);
                }
            )
        }
    
        for (var pathsIndex=0; pathsIndex < paths.length; pathsIndex++) {
            var path_uri = "file://" + paths[pathsIndex];
            window.resolveLocalFileSystemURI(
                path_uri,
                getFileSuccess,
                function (event) {
                    console.log('resolveLocalFileSystemURI(' + path_uri +
                                ',,) failed:', JSON.stringify(event) );
                }
            );
        }
    }
    
};
