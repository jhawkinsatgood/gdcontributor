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

package com.good.example.contributor.jhawkins.demo;

import java.io.FileNotFoundException;
import java.io.IOException;

import com.good.example.contributor.jhawkins.appkinetics.core.Provider;
import com.good.example.contributor.jhawkins.appkinetics.core.Request;
import com.good.example.contributor.jhawkins.appkinetics.specific.ProviderEditFile;
import com.good.example.contributor.jhawkins.appkinetics.specific.RequestEditFile;
import com.good.example.contributor.jhawkins.appkinetics.specific.RequestSaveEditedFile;
import com.good.example.contributor.jhawkins.demoframework.Component;

// Note that only Good Dynamics file classes are imported, not native file 
// classes.
import com.good.gd.file.FileInputStream;

/** Provide the Edit File service for diagnostic and illustration purposes.
 * This class illustrates use of the ProvideEditFile class.
 */
public class DemoProvideEditFile extends Component {
    private ProviderEditFile provider = null;
    RequestEditFile request = null;

    public DemoProvideEditFile() {
        super();
        demoExecuteLabel = null;
    }

    @Override
	public String[] demoExecuteOrPickList() {
		return null;
	}

    /** Illustrative service provider.
     * Call this method to set an illustrative implementation of the service,
     * which logs a stat of the received file and the initial bytes.
     * 
     * @param myLogger Logger instance for printing messages. The logMessage
     * method of the instance will be invoked a number of times every time a
     * service request is received. It will be passed a message to log on each
     * invocation.
     */
    public void demoLoad()
    {
        if (userInterface == null) {
            throw new Error(
                    this.getClass().getSimpleName() + " load attempted " +
            		"without user interface. Call demoSetUserInterface before " +
            		"demoLoad.");
        }

        provider = new ProviderEditFile();
        provider.addListener(
                // Instantiate an anonymous inner class that calls out to the
                // onReceiveMessage in the outer class.
                new Provider.Listener() {
                    public Request onReceiveMessage(Request request) {
                        return DemoProvideEditFile.this.onReceiveMessage(
                                request);
                    }
                });
        userInterface.demoLog("Ready for: " + provider.getServiceID() + "\n");
    }

    private String transcribe(byte[] bytes)
    {
        if (bytes == null) return "null";
        return "\"" + new String(bytes) + "\"";
    }

    @Override
    public Boolean demoSave(String content)
    {
        userInterface.demoLog("demoSave() for " + 
                transcribe(request.getIdentificationData()) + "\n" );

        // If savedData isn't null, write it to a temporary file, in the secure
        // store, so that it can be sent back to the original application.
        // TODO: The file should get deleted later, in the onMessageSent 
        // callback.
        String filename = null; 
        if (content != null) {
            // Create a temporary file name from the name of this class, plus the
            // request ID, plus a suffix.
            // TODO: Use a proper temporary filename generator.
            filename = this.getClass().getSimpleName() + "-" + 
                    request.getRequestID() + "tempfile";
            String error = Utility.createFileOrError(filename, content);
            if (error != null) {
                userInterface.demoLog(error);
                return false;
            }
            userInterface.demoLog("Created file \"" + filename + "\".\n");
        }
        
        // Send the service request back to the application that sent the file
        // in the first place.
        // If filename is null then the method will be releaseEdit.
        // Otherwise the method will be saveEdit and the file created above is
        // added as an attachment.
        RequestSaveEditedFile requestSave = new RequestSaveEditedFile();
        requestSave.setApplication( request.getApplication() );
        if (filename == null) {
            requestSave.setMethodReleaseEdit();
        }
        else {
            requestSave.setMethodSaveEdit().addAttachments(filename);
        }
        requestSave.setIdentificationData(request.getIdentificationData())
        .sendOrMessage();
        // The above returns a message if there is an error in the send. The
        // message is also inserted into the Request object, which is dumped
        // below, so there is no need to log it additionally.
        userInterface.demoLog("Sent request: " + requestSave.toString(2) + 
                "\n");
        return true;
    }
    
    /** Illustrative service provider implementation.
     * This method implements the illustrative handling of the service and is
     * called from an anonymous inner class in the setLogger method, below.
     */
    public Request onReceiveMessage( Request request )
    {
        userInterface.demoLog(this.getClass().getName() + " received " + 
                request.toString(2));
        this.request = (RequestEditFile)request;

        String filename = this.request.getAttachment();

        // Read the file contents into a StringBuilder
        StringBuilder strEdit = new StringBuilder("");
        try {
            FileInputStream receivedStream = new FileInputStream(filename);
            int readi;
            while ( (readi = receivedStream.read()) > 0) {
                strEdit.append((char)readi);
            }
            receivedStream.close();
        } catch (FileNotFoundException e) {
            userInterface.demoLog("Could not open attachment. " + e.getMessage());
        } catch (IOException e) {
            userInterface.demoLog("Could not read attachment. " + e.getMessage());
        }
        
        // Now open the editor. Pass as a parameter an anonymous inner class
        // instance that will invoke the saveFromEditor in this class when the 
        // editor saves or releases the file.
        userInterface.demoEdit(strEdit.toString(), this);
        return request;
    }
}
