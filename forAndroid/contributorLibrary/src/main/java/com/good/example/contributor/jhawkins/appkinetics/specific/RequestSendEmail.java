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

import com.good.example.contributor.jhawkins.appkinetics.core.Request;
import com.good.gd.icc.GDICCForegroundOptions;

public class RequestSendEmail extends Request {

    public RequestSendEmail() {
        super();
        setServiceID("com.good.gfeservice.send-email");
        setServiceVersion("1.0.0.0");
        setMethod("sendEmail");
        setForegroundPreference(GDICCForegroundOptions.PreferPeerInForeground);
    }

    // Setters for parameters specific to this service.
    public RequestSendEmail addToAddresses(String... addresses) {
        setParameterAppend( addresses, "to" );
        return this;
    }
    public RequestSendEmail addCcAddresses(String... addresses) {
        setParameterAppend( addresses, "cc" );
        return this;
    }
    public RequestSendEmail addBccAddresses(String... addresses) {
        setParameterAppend( addresses, "bcc" );
        return this;
    }
    public RequestSendEmail setSubject(String subject) {
        setParameter( subject, "subject");
        return this;
    }
    public RequestSendEmail setBody(String body) {
        setParameter( body, "body");
        return this;
    }

}
