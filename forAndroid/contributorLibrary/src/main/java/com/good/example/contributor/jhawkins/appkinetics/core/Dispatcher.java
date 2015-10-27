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

import android.util.Log;

import com.good.gd.icc.GDICCForegroundOptions;
import com.good.gd.icc.GDService;
import com.good.gd.icc.GDServiceError;
import com.good.gd.icc.GDServiceErrorCode;
import com.good.gd.icc.GDServiceException;
import com.good.gd.icc.GDServiceListener;

import java.util.ArrayList;

public class Dispatcher implements GDServiceListener {
    private static final String TAG = "Dispatcher";
    ArrayList<Provider> providers;

    private static Dispatcher _instance = null;
    private Dispatcher() {
        super();
        providers = new ArrayList<>(0);
    }
    public static Dispatcher getInstance() {
        if (null == _instance) {
            _instance = new Dispatcher();
        }
        return _instance;
    }

    // Register a service provider instance. A null parameter can be passed,
    // which forces registration of the Dispatcher instance with the GD Runtime.
    public Dispatcher register(Provider provider)
    {
        String provider_string = "null";
        if (provider != null) {
            providers.add(provider);
            provider_string = "\"" + provider.toString() + "\"";
        }
        // After adding the instance to the map, ensure that this class is the 
        // registered listener.
        try {
            Log.d(TAG, "GDService.setServiceListener(this)");
            GDService.setServiceListener(this);
        } catch (GDServiceException e) {
            throw new Error(
                    "Failed to set dispatcher as GD Service Listener " +
                    "when registering " + provider_string + ". " +
                    e.getMessage());
        }
        return this;
    }
    public Dispatcher register()
    {
        return register(null);
    }
    
    private class ProviderLookup {
        public GDServiceErrorCode errorCode = null;
        public Provider provider = null;
    }
    
    private ProviderLookup lookupProvider(Request request)
    {
        ProviderLookup ret = new ProviderLookup();
        for (Provider provideri: providers) {

            // Find out what matches
            Boolean matchedServiceID =
                    provideri.getServiceID().equals(request.getServiceID());
            Boolean matchedServiceVersion =
                    provideri.getServiceVersion().equals(
                            request.getServiceVersion());
            Boolean matchedMethod = false;
            for(String method: provideri.getDefinedMethods()) {
                if (method.equals(request.getMethod())) {
                    matchedMethod = true;
                    break;
                }
            }

            // Decision tree.
            // If serviceID didn't match then move to the next provider.
            if (!matchedServiceID) continue;

            // If serviceID matched but something else didn't, set a candidate
            // error code and move to the next provider.
            // A later provider could match, in which case the candidate error
            // code will be cleared. A later provider might also overwrite
            // the candidate error, which doesn't matter.
            if (!matchedServiceVersion) {
                ret.errorCode = GDServiceErrorCode
                        .GDServicesErrorServiceVersionNotFound;
                continue;
            }
            if (!matchedMethod) {
                ret.errorCode = GDServiceErrorCode
                        .GDServicesErrorMethodNotFound;
                continue;
            }

            // Everything matched, we have a winner...
            ret.provider = provideri;
            // Clear any candidate error code...
            ret.errorCode = null;
            // Stop looking.
            break;
        }
        if (ret.provider == null && ret.errorCode == null) {
            // If we get here then no provider matched even the serviceID
            ret.errorCode = 
                    GDServiceErrorCode.GDServicesErrorServiceNotFound;
        }
       
        return ret;
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
    public void onReceiveMessage(String application,
                                 String service,
                                 String version,
                                 String method,
                                 Object params,
                                 String[] attachments,
                                 String requestID )
    {
        Log.d(TAG, "onReceiveMessage(...)");
        // Create a Request object from the received values.
        Request request = new Request()
        .setApplication(application)
        .setServiceID(service)
        .setServiceVersion(version)
        .setMethod(method)
        .setParameterFromICC(params)
        .addAttachments(attachments)
        .setRequestID(requestID);

        // Find a provider for the request
        ProviderLookup lookup = lookupProvider(request);
        
        if (lookup.provider == null) {
            // If there is no provider, return the appropriate GDServiceError
            request
            .setReplyForegroundPreference(
                    GDICCForegroundOptions.PreferPeerInForeground)
            .setReplyParameter(new GDServiceError(lookup.errorCode))
            .replyOrMessage();
        }
        else {
            // Otherwise, invoke the receiver in the provider
            lookup.provider.onReceiveRequest(request);
        }
    }

    @Override
    public void onMessageSent(String application,
                              String requestID,
                              String[] attachments )
    {
        // This callback is invoked to notify the application that a service 
        // response has been sent. This module doesn't take any action at that
        // time.
    }

}
