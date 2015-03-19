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

package com.good.example.contributor.jhawkins.appkinetics.core;

import java.util.ArrayList;

public class Provider
{
    private ArrayList<Listener> listeners = null;
    private Request template = null;
    private Boolean registered = false;
    
    public Provider() {
        super();
        template = new Request();
        listeners = new ArrayList<Listener>();
    }
    
    public String toString() {
        return template.toString();
    }
    
    public String toString(int indentSpaces) {
        return template.toString(indentSpaces);
    }
    
    public String getServiceID() {
        return template.getServiceID();
    }
    public Provider setServiceID(String serviceID) {
        template.setServiceID(serviceID);
        return this;
    }
    
    public String getServiceVersion() {
        return template.getServiceVersion();
    }
    public Provider setServiceVersion(String serviceVersion) {
        template.setServiceVersion(serviceVersion);
        return this;
    }
    
    public Provider addDefinedMethods(String... methods)
    {
        template.addDefinedMethods(methods);
        return this;
    }
    public String[] getDefinedMethods()
    {
      return template.getDefinedMethods();
    }

    /** Subclass for listener.
     * Pass an instance of this subclass to the addListener method, below.
     */
    public interface Listener {
        Request onReceiveMessage (Request request);
    }

    public Provider addListener(Listener listener)
    {
        listeners.add(listener);
        // Register when the first listener is added.
        if (!registered) {
            Dispatcher.getInstance().register(this);
            registered = true;
        }
        return this;
    }

    public Request onReceiveRequest( Request request )
    {
        for(Listener listener: listeners) {
            request = listener.onReceiveMessage(request);
            if (request == null) break;
        }
        return request;
    }
}
