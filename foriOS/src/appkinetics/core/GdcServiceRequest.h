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

#import <Foundation/Foundation.h>
#import <GD/GDServices.h>

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
 * The GdcServiceDispatcher instance creates objects of this class to represent
 * received requests for dispatch to service provider instance.
 * 
 * **ToDo**:
 * 
 * -   Parameter structure and its navigation.
 * -   Sequence of calls for service discovery and service request sending.
 * -   How to use as a provider.
 */
@interface GdcServiceRequest : NSObject

/** Set this service request to be the same as another.
 * 
 * @param request GdcServiceRequest object from which details will be set.
 */
-(instancetype)storeFrom:(GdcServiceRequest *)request;

/** Service identifier.
 * The unique identifier of the service, for example
 * "com.good.gdservice.transfer-file".
 */
@property (nonatomic)NSString *serviceID;

/** Service version.
 * The version of the service.
 */
@property (nonatomic)NSString *serviceVersion;

/** Methods of the service.
 * An `NSArray` of `NSString` objects, each representing a defined method of the
 * service. This is part of the service definition.
 */
@property (nonatomic)NSArray *definedMethods;

/** Requested method.
 * Method being invoked in this service request.
 */
@property (nonatomic)NSString *method;

/** Request identifier.
 * The unique identifier of this request. This should only be set by a
 * dispatcher that implements the service delegate protocol.
 */
@property (nonatomic)NSString *requestID;

/** Request foreground preference.
 * Set this property to specify the foreground preference of the request, or
 * read this property to determine the foreground preference of a received
 * request.
 */
@property (nonatomic)GDTForegroundOption foregroundPreference;

/** Reply foreground preference.
 * Set this property to specify the foreground preference of a reply to the
 * request.
 */
@property (nonatomic)GDTForegroundOption replyForegroundPreference;

/** Set a request parameter.
 * Call this function to set a parameter in the request. This method is for
 * setting parameters that are specified in the service definition, not for
 * setting generic parameters such as the service version.
 * 
 * The parameter is specified as a path consisting of a sequence of numeric and
 * text values that specify the array elements or dictionary keys respectively.
 * 
 * @param value containing the parameter value.
 * 
 * @param path `NSArray` of `NSNumber` and `NSString` objects that specify the
 * navigation to the parameter within the service request.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setParameter:(id)value path:(NSArray *)path;

/** Set a single value as the request parameter.
 * Call this function to set the request parameter to a single value. Calling
 * this function is equivalent to calling the `setParameter:path:` function with
 * an empty array as the path parameter.
 * 
 * @param value containing the parameter value.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setParameter:(id)value;

/** Set a reply parameter.
 * Call this function to set a parameter in a reply to the request. This method
 * is for setting parameters that are specified in the service definition, not
 * for setting generic parameters such as the service version.
 * 
 * The parameter is specified as a path consisting of a sequence of numeric and
 * text values that specify the array elements or dictionary keys respectively.
 * 
 * @param value containing the parameter value.
 * 
 * @param path `NSArray` of `NSNumber` and `NSString` objects that specify the
 * navigation to the parameter within the service reply.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setReplyParameter:(id)value path:(NSArray *)path;

/** Set a single value as the reply parameter.
 * Call this function to set the reply parameter to a single value. Calling this
 * function is equivalent to calling the `setReplyParameter:path:` function with
 * an empty array as the path parameter.
 * 
 * @param value containing the parameter value.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setReplyParameter:(id)value;

/** Set all the parameters from a received request (dispatcher only).
 * Call this function to set all the parameters of this request from a received
 * request. This should only be called by a dispatcher that implements the
 * service delegate interface.
 * 
 * @param icc object containing the parameter values.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setParameterFromICC:(NSObject *)icc;

/** Append to an array parameter.
 * Call this function to append one or more values to an array parameter in the
 * request. This method is for setting parameters that are specified in the
 * service definition, not for setting generic parameters such as the service
 * version.
 * 
 * The parameter is specified as a path consisting of a sequence of numeric and
 * text values that specify the array elements or dictionary keys respectively.
 * 
 * @param values `NSArray` of objects containing the parameter values to be
 * appended.
 * 
 * @param path `NSArray` of `NSNumber` and `NSString` objects that specify the
 * navigation to the parameter within the service request.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)setParameterAppend:(NSArray *)values path:(NSArray *)path;

/** Get a request parameter.
 * This function returns the value of a request parameter.
 * 
 * @param path `NSArray` of `NSNumber` and `NSString` objects that specify the
 * navigation to the parameter within the service request.
 * 
 * @return The value of the parameter, or `nil`.
 */
-(id)getParameter:(NSArray *)path;

/** Add file attachments to the request.
 * Call this function to attach one or more files to the request.
 * 
 * @param attachments `NSArray` of `NSString` objects, each containing a path in
 * the secure file system to be attached to the request.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)addAttachments:(NSArray *)attachments;

/** Get attachments to the request.
 * @return `NSArray` of `NSString` objects, each containing the path of an
 * attachment. If there are no attachments, this function returns an empty array
 * or `nil`.
 */
-(NSArray *)getAttachments;

/** Get the first attachment to the request.
 * This function is a shorthand for calling `getAttachments` and then reading the
 * first element of the returned array. It is of most use for providers of
 * services that accept only one file.
 * 
 * @return `NSString` containing the path of the first attachment. If there are
 * no attachments, this function returns `nil`.
 */
-(NSString *)getAttachment;

/** Add file attachments to the reply.
 * Call this function to attach one or more files to the reply.
 * 
 * @param attachments `NSArray` of `NSString` objects, each containing a path in
 * the secure file system to be attached to the reply.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)addReplyAttachments:(NSArray *)attachments;

/** Get attachments to the reply.
 * @return `NSArray` of `NSString` objects, each containing the path of an
 * attachment. If there are no attachments, this function returns an empty array
 * or `nil`.
 */
-(NSArray *)getReplyAttachments;

/** Interface for service discovery and inter-application communication.
 * 
 */

/** Select provider from service discovery results.
 * Call this function to select one of the providers found by a prior service
 * discovery query. The selection is stored internally in the service request
 * object.
 * 
 * Only call this function after having called the `queryProviders` function.
 * 
 * @param index int representing the ordinal number of the service provider to
 * select.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)selectProvider:(int)index;

/** Execute a service discovery query.
 * Call this function to execute a service discovery query. The results of the
 * query are stored internally in the service request object.
 * 
 * The query parameters are read from the service identifier and version
 * properties of the request object. The query is restricted to
 * application-based service providers.
 * 
 * If there is exactly one provider, then it is selected. Otherwise, no provider
 * is selected.
 * 
 * @return Reference to the service request object.
 */
-(instancetype)queryProviders;

/** Dump service discovery results.
 * @return `NSString` containing a JSON representation of the results of the
 * service discovery query. The value is intended for diagnostic and logging
 * purposes.
 */
-(NSString *)getProvidersDump;

/** Get service provider names.
 * This function returns the display names of the providers found by a service
 * discovery query. The values are suitable for display in the user interface,
 * for example in a list from which a provider will be selected.
 * 
 * Only call this function after having called the `queryProviders` function.
 * 
 * @return `NSArray` of `NSString` objects, each containing an application
 * display name. Or an empty array if no service providers were found.
 */
-(NSArray *)getProviderNames;

/** Get service provider addresses.
 * This function returns the addresses of the providers found by a service
 * discovery query. The values are used internally when the request is being
 * sent, but could also be used for logging and diagnostic purposes.
 * 
 * Only call this function after having called the `queryProviders` function.
 * 
 * @return `NSArray` of `NSString` objects, each containing an application
 * address. Or an empty array if no service providers were found.
 */
-(NSArray *)getProviderAddresses;

/** Identifier of the sending or receiving application.
 * Native identifier of:
 * 
 * -   The selected provider application, if this is an outbound request.
 * -   The sending application, if this is a received request.
 * 
 * This should only be set directly by a dispatcher that implements the service
 * delegate protocol.
 */
@property (nonatomic)NSString *application;

/** Send the request or return an error message.
 * Call this function to send the service request. The `GDServiceClient` `sendTo`
 * method is called to send the request.
 * 
 * Only call this function after:
 * 
 * -   Executing a service discovery query, by calling `queryProviders`.
 * -   Selecting one of the providers, if there is more than one.
 * 
 * If exactly one provider is found by the service discovery query, then it will
 * be selected implicitly.
 * 
 * @param error for returning an `NSError` object if an error occurs. If `nil`,
 * no object will be returned.
 * 
 * @return `NSString` containing an error message if the service provider hasn't
 * been set, or an exception was thrown by a lower-level interface. Or `nil` if
 * no error occurs. The error message is also stored internally.
 */
-(NSString *)sendOrMessage:(NSError **)error;

/** Send a reply or return an error message.
 * Call this function to send a reply to the service request. The `GDService`
 * `replyTo` method is called to send the request. This function should only be
 * called by service providers.
 */
-(NSString *)replyOrMessage:(NSError **)error;
@end
