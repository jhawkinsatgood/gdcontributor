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

package com.good.example.contributor.jhawkins.appkinetics.core;

import com.good.example.contributor.jhawkins.pathstore.PathStore;
import com.good.gd.GDAndroid;
import com.good.gd.GDServiceProvider;
import com.good.gd.GDServiceProviderType;
import com.good.gd.icc.GDICCForegroundOptions;
import com.good.gd.icc.GDService;
import com.good.gd.icc.GDServiceClient;
import com.good.gd.icc.GDServiceClientListener;
import com.good.gd.icc.GDServiceException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Vector;

/** Application-Based Services service request.
 * Use objects of this class to represent application-based service requests.
 * This class is suitable to use as a base class. The class can include elements
 * of the service definition, and a reply to the request.
 * 
 * This class can represent:
 * 
 * -   A service request that is being composed and sent by the application.
 * -   A service request that has been received by the application from another
 *     application.
 * 
 * The Dispatcher instance creates objects of this class to represent received
 * requests for dispatch to service provider instance.
 * 
 * **ToDo**:
 * 
 * -   Parameter structure and its navigation.
 * -   Sequence of calls for service discovery and service request sending.
 * -   How to use as a provider.
 */
public class Request implements GDServiceClientListener {
    // This PathStore will hold all details, including:
    // - Service ID and version, Method name, parameters
    // - Definition
    private PathStore store = new PathStore(new JSONObject());

    /** Set this service request to be the same as another.
     * 
     * @param request Request object from which details will be set.
     */
    public Request storeFrom(Request request) {
        store = request.store;
        return this;
    }
    
    /** JSON representation of the service request, without indentation.
     * This method returns a "flat" JSON representation of the service request.
     * 
     * @return `String` containing a JSON representation of the service request.
     */
    public String toString() {
        return store.toString();
    }

    /** JSON representation of the service request, with indentation if
     *  possible.
     * This method returns a JSON representation of the service request if this
     * is possible, or a "flat" representation otherwise.
     * 
     * The method calls the native JSON programming interface to produce its
     * result. The native interface can throw an exception. If it does, then
     * this method falls back to the flat representation, which never throws an
     * exception.
     * 
     * @return `String` containing a JSON representation of the service request.
     */
    public String toString(int indentSpaces) {
        try {
            return store.toString(indentSpaces);
        } catch (JSONException e) {
            return store.toString();
        }
    }

    /** Getters and setters for Request properties.
     * 
     */

    /** Get the service identifier.
     * @return `String` containing the service identifier.
     */
    public String getServiceID() {
        return store.pathGetString("Definition", "service-id");
    }
    /** Set the service identifier.
     * @param serviceID `String` containing the new service identifier.
     * 
     * @return Reference to the service request object.
     */
    public Request setServiceID(String serviceID) {
        store.pathSet(serviceID, "Definition", "service-id");
        return this;
    }

    /** Get the service version.
     * @return `String` containing the service version.
     */
    public String getServiceVersion() {
        return store.pathGetString("Definition", "version");
    }
    /** Set the service version.
     * @param serviceVersion `String` containing the new service version.
     * 
     * @return Reference to the service request object.
     */
    public Request setServiceVersion(String serviceVersion) {
        store.pathSet(serviceVersion, "Definition", "version");
        return this;
    }

    /** Define methods.
     * Call this method to add methods to the service definition.
     * 
     * @param methods variable number of `String` objects, each containing a
     * method name.
     * 
     * @return Reference to the service request object.
     */
    public Request addDefinedMethods(String... methods)
    {
        store.pathSetAppend(methods, "Definition", "methods");
        return this;
    }
    /** Get defined methods.
     * @return `String[]` of method names.
     */
    public String[] getDefinedMethods()
    {
      return store.pathGetStringArray("Definition", "methods");
    }

    /** Get the method that is being requested.
     * @return `String` containing the method that is being requested.
     */
    public String getMethod() {
        return store.pathGetString("Request", "Method");
    }
    /** Set the method that is being requested.
     * @param method `String` containing the name of the method that is being
     * requested.
     * 
     * @return Reference to the service request object.
     */
    public Request setMethod(String method) {
        store.pathSet(method, "Request", "Method");
        return this;
    }

    /** Get the request identifier.
     * @return `String` containing the unique identifier of this request.
     */
    public String getRequestID() {
        return store.pathGetString("Request", "ID");
    }
    /** Set the request identifier (dispatcher only).
     * Call this method to set the unique identifier of this request. This
     * should only be set by a dispatcher that implements the service listener
     * interface.
     * 
     * @param requestID `String` containing the value to set.
     * 
     * @return Reference to the service request object.
     */
    public Request setRequestID(String requestID) {
        store.pathSet(requestID, "Request", "ID");
        return this;
    }
    
    /** Get the request foreground preference.
     * @return `GDICCForegroundOptions` value that represents the foreground
     * preference of the request.
     */
    public GDICCForegroundOptions getForegroundPreference() {
        return (GDICCForegroundOptions)store.pathGet(
                "Request", "ForegroundPreference");
    }
    /** Set the request foreground preference.
     * 
     * @param foregroundPreference `GDICCForegroundOptions` value that
     * represents the required foreground preference.
     * 
     * @return Reference to the service request object.
     */
    public Request setForegroundPreference(
            GDICCForegroundOptions foregroundPreference
    ) {
        store.pathSet( foregroundPreference, "Request", "ForegroundPreference");
        return this;
    }
    
    /** Get the reply foreground preference.
     * @return `GDICCForegroundOptions` value that represents the foreground
     * preference of the reply.
     */
    public GDICCForegroundOptions getReplyForegroundPreference() {
        return (GDICCForegroundOptions)store.pathGet(
                "Reply", "ForegroundPreference");
    }
    /** Set the reply foreground preference.
     * 
     * @param foregroundPreference `GDICCForegroundOptions` value that
     * represents the required foreground preference.
     * 
     * @return Reference to the service request object.
     */
    public Request setReplyForegroundPreference(
            GDICCForegroundOptions foregroundPreference
    ) {
        store.pathSet( foregroundPreference, "Reply", "ForegroundPreference");
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

    /** Set a request parameter.
     * Call this method to set a parameter in the request. This method is for
     * setting parameters that are specified in the service definition, not for
     * setting generic parameters such as the service version.
     * 
     * The parameter is specified as a path consisting of a sequence of numeric
     * and text values that specify the array elements or dictionary keys
     * respectively.
     * 
     * @param value containing the parameter value.
     * 
     * @param path variable number of `Number` and `String` objects that specify
     * the navigation to the parameter within the service request.
     * 
     * @return Reference to the service request object.
     */
    public Request setParameter(Object value, Object... path)
    {
        _setParameter(value, paramTop, path);
        return this;
    }
    
    /** Set a reply parameter.
     * Call this method to set a parameter in a reply to the request. This
     * method is for setting parameters that are specified in the service
     * definition, not for setting generic parameters such as the service
     * version.
     * 
     * The parameter is specified as a path consisting of a sequence of numeric
     * and text values that specify the array elements or dictionary keys
     * respectively.
     * 
     * @param value containing the parameter value.
     * 
     * @param path variable number of `Number` and `String` objects that specify
     * the navigation to the parameter within the service reply.
     * 
     * @return Reference to the service request object.
     */
    public Request setReplyParameter(Object value, Object... path)
    {
        _setParameter(value, paramReplyTop, path);
        return this;
    }
    
    /** Set all the parameters from a received request (dispatcher only).
     * Call this method to set all the parameters of this request from a
     * received request. This should only be called by a dispatcher that
     * implements the service listener interface.
     * 
     * @param icc object containing the parameter values.
     * 
     * @return Reference to the service request object.
     */
    public Request setParameterFromICC(Object icc)
    {
        store.pathSet(PathStore.createFromICC(icc), "Request", "Parameter");
        return this;
    }

    /** Append a single value to an array parameter.
     * Calling this method is equivalent to calling the `setParameterAppend`
     * method with a single-element array as the `values` parameter.
     * 
     * @param value object containing the parameter value to be appended.
     * 
     * @param path variable number of `Number` and `String` objects that specify
     * the navigation to the parameter within the service request.
     * 
     * @return Reference to the service request object.
     */
    public Request setParameterAppend(Object value, Object... path)
    {
    // This method is the same as setParameter but calls pathSetAppend instead
    // of pathSet where appropriate.
        if (path.length <= 0) {
            // Simple parameter, just set it
            store.pathSetAppend(value, paramTop);
        }
        else {
            // Complex parameter, see if there are already complex parameters
            Object paramo = store.pathGet(paramTop);
            if (paramo != null && paramo.getClass() == PathStore.class) {
                // Already have complex parameters, add this one.
                ((PathStore)paramo).pathSetAppend(value, path);
            }
            else {
                // No parameters set yet, or current parameter is simple.
                // Create a new PathStore for the parameters and put them in.
                store.pathSet( new PathStore(new JSONObject())
                    .pathSetAppend(value, path),
                    paramTop );
            }
        }
        return this;
    }

    /** Append to an array parameter.
     * Call this method to append one or more values to an array parameter in
     * the request. This method is for setting parameters that are specified in
     * the service definition, not for setting generic parameters such as the
     * service version.
     * 
     * The parameter is specified as a path consisting of a sequence of numeric
     * and text values that specify the array elements or dictionary keys
     * respectively.
     * 
     * @param values array of objects containing the parameter values to be
     * appended.
     * 
     * @param path variable number of `Number` and `String` objects that specify
     * the navigation to the parameter within the service request.
     * 
     * @return Reference to the service request object.
     */
    public Request setParameterAppend(Object[] values, Object... path)
    {
    // This method is the same as setParameterAppend but with a different 
    // prototype that hence calls an overloaded pathSetAppend.
        if (path.length <= 0) {
            // Simple parameter, just set it
            store.pathSetAppend(values, paramTop);
        }
        else {
            // Complex parameter, see if there are already complex parameters
            Object paramo = store.pathGet(paramTop);
            if (paramo != null && paramo.getClass() == PathStore.class) {
                // Already have complex parameters, add this one.
                ((PathStore)paramo).pathSetAppend(values, path);
            }
            else {
                // No parameters set yet, or current parameter is simple.
                // Create a new PathStore for the parameters and put them in.
                store.pathSet( new PathStore(new JSONObject())
                    .pathSetAppend(values, path),
                    paramTop );
            }
        }
        return this;
    }

    /** Get a request parameter.
     * This method returns the value of a request parameter.
     * 
     * @param path variable number of `Number` and `String` objects that specify
     * the navigation to the parameter within the service request.
     * 
     * @return The value of the parameter, or `null`.
     */
    public Object getParameter(Object... path)
    {
        Object paramo = store.pathGet(paramTop);
        if (paramo != null && paramo.getClass() == PathStore.class) {
            return ((PathStore)paramo).pathGet(path);
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

    /** Add file attachments to the request.
     * Call this method to attach one or more files to the request.
     * 
     * @param attachments variable number of `String` objects, each containing a
     * path in the secure file system to be attached to the request.
     * 
     * @return Reference to the service request object.
     */
    public Request addAttachments(String... attachments)
    {
        store.pathSetAppend(attachments, "Request", "Attachments");
        return this;
    }
    /** Get attachments to the request.
     * @return array of `String` objects, each containing the path of an
     * attachment. If there are no attachments, this method returns an empty
     * array or `null`.
     */
    public String[] getAttachments()
    {
      return store.pathGetStringArray("Request", "Attachments");
    }
    /** Get the first attachment to the request.
     * This method is a shorthand for calling `getAttachments` and then reading
     * the first element of the returned array. It is of most use for providers
     * of services that accept only one file.
     * 
     * @return `String` containing the path of the first attachment. If there
     * are no attachments, this method returns `null`.
     */
    public String getAttachment()
    {
      return store.pathGetString("Request", "Attachments", 0);
    }

    /** Add file attachments to the reply.
     * Call this method to attach one or more files to the reply.
     * 
     * @param attachments variable number of `String` objects, each containing a
     * path in the secure file system to be attached to the reply.
     * 
     * @return Reference to the service request object.
     */
    public Request addReplyAttachments(String... attachments)
    {
        store.pathSetAppend(attachments, "Reply", "Attachments");
        return this;
    }
    /** Get attachments to the reply.
     * @return array of `String` objects, each containing the path of an
     * attachment. If there are no attachments, this method returns an empty
     * array or `null`.
     */
    public String[] getReplyAttachments()
    {
      return store.pathGetStringArray("Reply", "Attachments");
    }

    /** Interface for service discovery and inter-application communication.
     * 
     */

    /** Select provider from service discovery results.
     * Call this method to select one of the providers found by a prior service
     * discovery query. The selection is stored internally in the service
     * request object.
     * 
     * Only call this method after having called the `queryProviders` method.
     * 
     * @param index int representing the ordinal number of the service provider
     * to select.
     * 
     * @return Reference to the service request object.
     */
    public Request selectProvider(int index)
    {
        store.pathSet(index, "Request", "Provider", "Selected");
        setApplication(getProviderAddress());
        return this;
    }
    /** Execute a service discovery query.
     * Call this method to execute a service discovery query. The results of the
     * query are stored internally in the service request object.
     * 
     * The query parameters are read from the service identifier and version
     * properties of the request object. The query is restricted to
     * application-based service providers.
     * 
     * If there is exactly one provider, then it is selected. Otherwise, no
     * provider is selected.
     * 
     * @return Reference to the service request object.
     */
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
    /** Dump service discovery results.
     * @return `String` containing a JSON representation of the results of the
     * service discovery query. The value is intended for diagnostic and logging
     * purposes.
     */
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
    /** Get service provider names.
     * This method returns the display names of the providers found by a service
     * discovery query. The values are suitable for display in the user
     * interface, for example in a list from which a provider will be selected.
     * 
     * Only call this method after having called the `queryProviders` method.
     * 
     * @return array of `String` objects, each containing an application display
     * name. Or an empty array if no service providers were found.
     */
    public String[] getProviderNames()
    {
        return _getProviderDetails("name");
    }
    /** Get service provider addresses.
     * This method returns the addresses of the providers found by a service
     * discovery query. The values are used internally when the request is being
     * sent, but could also be used for logging and diagnostic purposes.
     * 
     * Only call this method after having called the `queryProviders` method.
     * 
     * @return array of `String` objects, each containing an application address.
     * Or an empty array if no service providers were found.
     */
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

    /** Get the native identifier of:
     *  
     *  -   The selected provider application, if this is an outbound request.
     * -   The sending application, if this is a received request.
     * 
     * @return `String` containing the native identifier of the application that
     * sent the request.
     */
    public String getApplication()
    {
        return store.pathGetString("Request", "Application");
    }
    /** Set the identifier of the sending application (dispatcher only).
     * Call this method to set the sending application's native identifier, in a
     * received request. This should only be set by a dispatcher that implements
     * the service listener interface.
     * 
     * @return Reference to the service request object.
     */
    public Request setApplication(String application)
    {
        store.pathSet(application, "Request", "Application");
        return this;
    }
    
    /** Send the request or throw an exception.
     * Call this method to send the service request. The `GDServiceClient`
     * `sendTo` method is called to send the request.
     * 
     * Only call this method after:
     * 
     * -   Executing a service discovery query, by calling `queryProviders`.
     * -   Selecting one of the providers, if there is more than one.
     * 
     * If exactly one provider is found by the service discovery query, then it
     * will be selected implicitly.
     * 
     * @return `String` containing an error message if the service provider
     * hasn't been set, or `null` if no error occurs.
     * 
     * @throws GDServiceException as a propagation. Compare the `sendOrMessage`
     * method.
     */
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
    
    /** Send the request or return an error message.
     * Call this method to send the service request. The `GDServiceClient`
     * `sendTo` method is called to send the request.
     * 
     * Only call this method after:
     * 
     * -   Executing a service discovery query, by calling `queryProviders`.
     * -   Selecting one of the providers, if there is more than one.
     * 
     * If exactly one provider is found by the service discovery query, then it
     * will be selected implicitly.
     * 
     * @return `String` containing an error message if the service provider
     * hasn't been set, or an exception was thrown by a lower-level interface.
     * Or `null` if no error occurs. The error message is also stored
     * internally.
     * 
     * This method doesn't propagate exceptions. Compare the `send` method.
     */
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

    /** Send a reply or throw an exception.
     * Call this method to send a reply to the service request. The `GDService`
     * `replyTo` method is called to send the request. This method should only
     * be called by service providers.
     * 
     * @throws GDServiceException as a propagation. Compare the `replyOrMessage`
     * method.
     */
    public Request reply() throws GDServiceException
    {
        GDService.replyTo( getApplication(), getReplyParameter(),
                getReplyForegroundPreference(), getReplyAttachments(),
                getRequestID() );
        return this;
    }

    /** Send a reply or return an error message.
     * Call this method to send a reply to the service request. The `GDService`
     * `replyTo` method is called to send the request. This method should only
     * be called by service providers.
     * 
     * This method doesn't propagate exceptions. Compare the `send` method.
     */
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
    public void onReceivingAttachments(String application,
                                       int numberOfAttachments,
                                       String requestID )
    {

    }

    @Override
    public void onReceivingAttachmentFile(String application,
                                          String path,
                                          long size,
                                          String requestID )
    {

    }

    @Override
    public void onReceiveMessage(String arg0, Object arg1, String[] arg2,
            String arg3) {
        // TODO Auto-generated method stub
        
    }

}
