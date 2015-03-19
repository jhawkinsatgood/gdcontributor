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

package com.good.example.contributor.jhawkins.appkinetics.specific;

import com.good.example.contributor.jhawkins.appkinetics.core.Provider;
import com.good.example.contributor.jhawkins.appkinetics.core.Request;
import com.good.gd.icc.GDICCForegroundOptions;
import com.good.gd.icc.GDServiceError;

public class ProviderEditFile extends Provider implements Provider.Listener {

    public ProviderEditFile() {
        super();
        setServiceID("com.good.gdservice.edit-file");
        setServiceVersion("1.0.0.0");
        addDefinedMethods("editFile");
        addListener(this);
    }

    // The listener in this class does some essential checks on the service
    // request. If any check fails then it sends the required error response
    // and blocks propagation. If all checks pass then it sends the required OK
    // response and creates a specific Request object for propagation.
    public RequestEditFile onReceiveMessage(Request request)
    {
        String errDesc = null;
        String[] attachments = request.getAttachments();
        if (attachments == null) {
            errDesc = new String("No attachments. Should have one."); 
        }
        else if (attachments.length != 1) {
            errDesc = new String(
                    "Wrong number of attachments: " + attachments.length + 
                    ". Should have one."); 
        }

        // Create and send a custom error object with code 1, which applies to 
        // any invalid request.
        if (errDesc != null) {
            request
            .setReplyParameter(new GDServiceError(1, errDesc, null))
            .setReplyForegroundPreference(
                    GDICCForegroundOptions.PreferPeerInForeground)
            .replyOrMessage();
            // Block propagation.
            return null;
        }

        // If the request is valid, send a null response as required by the 
        // service definition.
        request.setReplyForegroundPreference(
                GDICCForegroundOptions.PreferMeInForeground).replyOrMessage();

        RequestEditFile requestEditFile = new RequestEditFile();
        requestEditFile.storeFrom(request);
        // Allow propagation.
        return requestEditFile;
    }

}
