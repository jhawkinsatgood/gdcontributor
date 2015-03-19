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

import com.good.example.contributor.jhawkins.appkinetics.specific.RequestOpenHTTPURL;
import com.good.example.contributor.jhawkins.demoframework.Component;

public class DemoConsumeOpenHTTPURL extends Component {
   private RequestOpenHTTPURL request = null;
    
    public DemoConsumeOpenHTTPURL() {
        super();
        demoExecuteLabel = "Open HTTP URL";
    }

    public String[] demoExecuteOrPickList()
    {
        if (request == null) { request = new RequestOpenHTTPURL(); }
        return request.queryProviders().getProviderNames();
    }
    
    @Override
    public void demoPickAndExecute(int pickListIndex)
    {
        request.setURL("http://helpdesk")
        .selectProvider(pickListIndex).sendOrMessage();
        // The above returns a message if there is an error in the send. The
        // message is also inserted into the Request object, which is dumped
        // below, so there is no need to log it additionally.
        if (userInterface != null)
            userInterface.demoLog("Sent request:" + request.toString(2) + "\n");
        return;
    }
}