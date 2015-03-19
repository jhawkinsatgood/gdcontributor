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

import java.util.Vector;

import org.json.JSONException;
import org.json.JSONObject;

import com.good.example.contributor.jhawkins.pathstore.PathStore;
import com.good.gd.GDAndroid;
import com.good.gd.GDServiceProvider;
import com.good.gd.GDServiceProviderType;
import com.good.gd.icc.GDICCForegroundOptions;
import com.good.gd.icc.GDService;
import com.good.gd.icc.GDServiceClient;
import com.good.gd.icc.GDServiceClientListener;
import com.good.gd.icc.GDServiceException;

public class Request implements GDServiceClientListener
{
    // This PathStore will hold all details, including:
    // - Service ID and version, Method name, parameters
    // - Definition
    private PathStore store = new PathStore(new JSONObject());

    public Request storeFrom(Request request) {
        store = request.store;
        return this;
    }
    
    public String toString() {
        return store.toString();
    }

    public String toString(int indentSpaces) {
        try {
            return store.toString(indentSpaces);
        } catch (JSONException e) {
            return store.toString();
        }
    }

    // Getters and setters for pseudo-fields.
    //
    public String getServiceID() {
        return store.pathGetString("Definition", "service-id");
    }
    public Request setServiceID(String serviceID) {
        store.pathSet(serviceID, "Definition", "service-id");
        return this;
    }

    public String getServiceVersion() {
        return store.pathGetString("Definition", "version");
    }
    public Request setServiceVersion(String version) {
        store.pathSet(version, "Definition", "version");
        return this;
    }

    public Request addDefinedMethods(String... methods)
    {
        store.pathSetAppend(methods, "Definition", "methods");
        return this;
    }
    public String[] getDefinedMethods()
    {
      return store.pathGetStringArray("Definition", "methods");
    }

    
    public String getMethod() {
        return store.pathGetString("Request", "Method");
    }
    public Request setMethod(String method) {
        store.pathSet(method, "Request", "Method");
        return this;
    }

    public String getRequestID() {
        return store.pathGetString("Request", "ID");
    }
    public Request setRequestID(String requestID) {
        store.pathSet(requestID, "Request", "ID");
        return this;
    }
    
    public GDICCForegroundOptions getForegroundPreference() {
        return (GDICCForegroundOptions)store.pathGet(
                "Request", "ForegroundPreference");
    }
    public Request setForegroundPreference(GDICCForegroundOptions value) {
        store.pathSet( value, "Request", "ForegroundPreference");
        return this;
    }
    
    public GDICCForegroundOptions getReplyForegroundPreference() {
        return (GDICCForegroundOptions)store.pathGet(
                "Reply", "ForegroundPreference");
    }
    public Request setReplyForegroundPreference(GDICCForegroundOptions value) {
        store.pathSet( value, "Reply", "ForegroundPreference");
        return this;
    }
    
    // Getters and setters for param values and attachments.
    //
    private final static Object[] paramTop = {"Request", "Parameter"};
    private final static Object[] paramReplyTop = {"Reply", "Parameter"};
    
    private void _setParameter(Object value, Object[] top, Object[] path)
    {
        if (path.length <= 0) {
            // Simple parameter, just set it
            store.pathSet(value, top);
        }
        else {
            // Complex parameter, see if there are already complex parameters
            Object paramo = store.pathGet(top);
            if (paramo != null && paramo.getClass() == PathStore.class) {
                // Already have complex parameters, add this one.
                ((PathStore)paramo).pathSet(value, path);
            }
            else {
                // No parameters set yet, or current parameter is simple.
                // Create a new PathStore for the parameters and put them in.
                store.pathSet(
                        new PathStore(new JSONObject()).pathSet(value, path),
                        top);
            }
        }
    }
    
    public Request setParameter(Object value, Object... param_path)
    {
        _setParameter(value, paramTop, param_path);
        return this;
    }
    
    public Request setReplyParameter(Object value, Object... param_path)
    {
        _setParameter(value, paramReplyTop, param_path);
        return this;
    }
    
    public Request setParameterFromICC(Object icc)
    {
        store.pathSet(PathStore.createFromICC(icc), "Request", "Parameter");
        return this;
    }

    // This method is the same as setParameter but calls pathSetAppend instead
    // of pathSet where appropriate.
    public Request setParameterAppend(Object value, Object... param_path)
    {
        if (param_path.length <= 0) {
            // Simple parameter, just set it
            store.pathSetAppend(value, paramTop);
        }
        else {
            // Complex parameter, see if there are already complex parameters
            Object paramo = store.pathGet(paramTop);
            if (paramo != null && paramo.getClass() == PathStore.class) {
                // Already have complex parameters, add this one.
                ((PathStore)paramo).pathSetAppend(value, param_path);
            }
            else {
                // No parameters set yet, or current parameter is simple.
                // Create a new PathStore for the parameters and put them in.
                store.pathSet( new PathStore(new JSONObject())
                    .pathSetAppend(value, param_path),
                    paramTop );
            }
        }
        return this;
    }

    // This method is the same as setParameterAppend but with a different 
    // prototype that hence calls an overloaded pathSetAppend.
    public Request setParameterAppend(Object[] values, Object... param_path)
    {
        if (param_path.length <= 0) {
            // Simple parameter, just set it
            store.pathSetAppend(values, paramTop);
        }
        else {
            // Complex parameter, see if there are already complex parameters
            Object paramo = store.pathGet(paramTop);
            if (paramo != null && paramo.getClass() == PathStore.class) {
                // Already have complex parameters, add this one.
                ((PathStore)paramo).pathSetAppend(values, param_path);
            }
            else {
                // No parameters set yet, or current parameter is simple.
                // Create a new PathStore for the parameters and put them in.
                store.pathSet( new PathStore(new JSONObject())
                    .pathSetAppend(values, param_path),
                    paramTop );
            }
        }
        return this;
    }

    public Object getParameter(Object... param_path)
    {
        Object paramo = store.pathGet(paramTop);
        if (paramo != null && paramo.getClass() == PathStore.class) {
            return ((PathStore)paramo).pathGet(param_path);
        }
        else {
            return paramo;
        }
    }

    private Object getSendParameter()
    {
        Object paramo = store.pathGet(paramTop);
        if (paramo != null && paramo.getClass() == PathStore.class) {
            return ((PathStore)paramo).toICCObject();
        }
        else {
            return paramo;
        }
    }

    private Object getReplyParameter()
    {
        Object paramo = store.pathGet("Reply", "Parameter");
        if (paramo != null && paramo.getClass() == PathStore.class) {
            return ((PathStore)paramo).toICCObject();
        }
        else {
            return paramo;
        }
    }

    public Request addAttachments(String... attachments)
    {
        store.pathSetAppend(attachments, "Request", "Attachments");
        return this;
    }
    public String[] getAttachments()
    {
      return store.pathGetStringArray("Request", "Attachments");
    }
    // getAttachment() is a shorthand for getting the first attachment.
    // It's of most use with services that expect only a single attachment.
    public String getAttachment()
    {
      return store.pathGetString("Request", "Attachments", 0);
    }

    public Request addReplyAttachments(String... attachments)
    {
        store.pathSetAppend(attachments, "Reply", "Attachments");
        return this;
    }
    public String[] getReplyAttachments()
    {
      return store.pathGetStringArray("Reply", "Attachments");
    }

    // Methods for getting the list of providers and sending requests
    //

    public Request selectProvider(int index)
    {
        store.pathSet(index, "Request", "Provider", "Selected");
        setApplication(getProviderAddress());
        return this;
    }
    public Request queryProviders()
    {
        // Execute an AppKinetics service discovery query.
        Vector<GDServiceProvider> provider_details =
                GDAndroid.getInstance().getServiceProvidersFor(
                        getServiceID(), getServiceVersion(),
                        GDServiceProviderType.GDSERVICEPROVIDERAPPLICATION);
        // Store the results in an array in the PathStore
        for (int i=0; i<provider_details.size(); i++) {
            GDServiceProvider provideri = provider_details.elementAt(i);
            store.pathSet( new PathStore(new JSONObject())
                .pathSet(provideri.getIdentifier(), "identifier")
                .pathSet(provideri.getName(), "name")
                .pathSet(provideri.getAddress(), "address")
                .pathSet(provideri.getVersion(), "version"),
                "Request", "Provider", "Query", i);
        }

        if (provider_details.size() == 1) { selectProvider(0); }
        
        return this;
    }
    public String getProvidersDump()
    {
        Object providers = store.pathGet("Request", "Provider", "Query");
        if (providers == null) return null;
        if (providers.getClass() == PathStore.class) {
            try {
                return ((PathStore)providers).toString(2);
            } catch (JSONException e) {
                return ((PathStore)providers).toString();
            }
        }
        return providers.toString();
    }
    private String[] _getProviderDetails(String detail)
    {
        Object providers_object = store.pathGet("Request", "Provider", "Query");
        if (providers_object == null ||
            providers_object.getClass() != PathStore.class
        ) {
            return new String[0];
        }
        
        PathStore providers = (PathStore)providers_object;
        int providers_length = providers.length();
        // Length zero is not treated as a special case.
        String ret[] = new String[providers_length];
        for( int i=0; i<providers_length; i++) {
            ret[i] = providers.pathGetString(i, detail);
        }
        return ret;
    }
    public String[] getProviderNames()
    {
        return _getProviderDetails("name");
    }
    public String[] getProviderAddresses()
    {
        return _getProviderDetails("address");
    }
    
    private String getProviderAddress()
    {
        Integer provideri = store.pathGetInteger(
                "Request", "Provider", "Selected");
        if (provideri == null) return null;
        return store.pathGetString(
                "Request", "Provider", "Query", provideri, "address");
    }

    public String getApplication()
    {
        return store.pathGetString("Request", "Application");
    }
    public Request setApplication(String application)
    {
        store.pathSet(application, "Request", "Application");
        return this;
    }
    
    public String send() throws GDServiceException
    {
        // Check if the recipient application address has been set directly
        if (getApplication() == null) {
            // If it hasn't, check if the provider has been selected.
            // If there is only a single provider, queryProviders() will select 
            // it implicitly.
            if (getProviderAddress() == null) queryProviders();

            // Check again, to see if implicit selection took place.
            String provider = getProviderAddress();

            // If it hasn't, give up now.
            if (provider == null) return "Provider is null.";

            // Otherwise, set the application address from the provider
            setApplication(provider);
        }
 
        // TODO: Replace this with a dispatcher.
        GDServiceClient.setServiceClientListener(this);

        // Finally, send the service request and record the request ID.
        // If sendTo fails, it throws GDServiceException, which this method
        // also throws.
        setRequestID( GDServiceClient.sendTo( getApplication(),
                getServiceID(), getServiceVersion(), getMethod(),
                getSendParameter(), getAttachments(),
                getForegroundPreference() ));

        return null;
    }
    
    public String sendOrMessage()
    {
        String message = null;
        try {
            message = send();
        } catch (GDServiceException e) {
            message = Utility.transcribe(e);
        }
        if (message != null) {
            store.pathSet(message, "Request", "LastError");
        }
        return message;
    }

    public Request reply() throws GDServiceException
    {
        GDService.replyTo( getApplication(), getReplyParameter(),
                getReplyForegroundPreference(), getReplyAttachments(),
                getRequestID() );
        return this;
    }

    public String replyOrMessage()
    {
        String message = null;
        try {
            reply();
        } catch (GDServiceException e) {
            message = Utility.transcribe(e);
        }
        if (message != null) {
            store.pathSet(message, "Reply", "LastError");
        }
        return message;
    }

    @Override
    public void onMessageSent(String arg0, String arg1, String[] arg2) {
        // TODO Auto-generated method stub
        
    }

    @Override
    public void onReceiveMessage(String arg0, Object arg1, String[] arg2,
            String arg3) {
        // TODO Auto-generated method stub
        
    }

}
