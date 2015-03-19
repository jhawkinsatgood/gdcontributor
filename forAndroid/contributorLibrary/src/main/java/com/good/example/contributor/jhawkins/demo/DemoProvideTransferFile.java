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

package com.good.example.contributor.jhawkins.demo;

// Note that only Good Dynamics file classes are imported, not native file 
// classes.
import com.good.example.contributor.jhawkins.appkinetics.core.Provider;
import com.good.example.contributor.jhawkins.appkinetics.core.Request;
import com.good.example.contributor.jhawkins.appkinetics.specific.ProviderTransferFile;
import com.good.example.contributor.jhawkins.demoframework.Component;
import com.good.gd.file.File;

/** Provide the Transfer File service for diagnostic and illustration purposes.
 * This class illustrates use of the ProvideTransferFile class.
 */
public class DemoProvideTransferFile extends Component {
    private ProviderTransferFile provider = null;

    public DemoProvideTransferFile() {
        super();
        demoExecuteLabel = null;
    }
    
    /** Illustrative service provider implementation.
     * This method implements the illustrative handling of the service and is 
     * called from an anonymous inner class in the setLogger method, below.
     */
    private Request onReceiveMessage(Request request)
    {
        String filename = request.getAttachment();
        // If there is no attachment, log a message and return.
        // Note that transfer-file does not define a custom error code for this.
        if (filename == null) {
            userInterface.demoLog("Request has no file attachment:" + 
                    request.toString(2) + "\n");
            return null;
        }

        // Otherwise, print the file's name and length ...
        userInterface.demoLog("Received file: \"" + filename + "\"\n");
        File receivedFile = new File(filename);
        userInterface.demoLog("File length: " + receivedFile.length() + "\n");

        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        userInterface.demoLog( Utility.byteDump(filename) );

        // Enable propagation, in case there is another listener.
        return request;
    }

    /** Illustrative service provider.
     * Call this method to set an illustrative implementation of the service,
     * which logs a stat of the received file and the initial bytes.
     */
    @Override
    public void demoLoad() {
        if (userInterface == null) {
            throw new Error(
                    this.getClass().getSimpleName() + " load attempted " +
            		"without user interface. Call demoSetUserInterface before " +
            		"demoLoad.");
        }

        provider = new ProviderTransferFile();
        provider.addListener(
                // Instantiate an anonymous inner class that calls out to the
                // onReceiveMessage in the outer class.
                new Provider.Listener() {
                    public Request onReceiveMessage(Request request) {
                        return DemoProvideTransferFile.this.onReceiveMessage(
                                request);
                    }
                });
        userInterface.demoLog("Ready for: " + provider.getServiceID() + "\n");
    }

	@Override
	public String[] demoExecuteOrPickList() {
		return null;
	}

}
