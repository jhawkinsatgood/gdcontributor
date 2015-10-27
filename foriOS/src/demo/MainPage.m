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

#import "MainPage.h"
#import <objc/runtime.h>

#import "DemoComponent.h"

@interface MainPage ()
@property (nonatomic) NSString *results;
@property (nonatomic) NSString *editData;
@property (nonatomic) NSArray *pickList;
@property (assign, nonatomic) int pickFor;

@property DemoComponent *save;
@property NSMutableArray *demos;
@property NSMutableArray *demoPanels;
@property (assign) BOOL hasLoaded;

-(instancetype)showEditData:(NSString *)newEditData;
-(BOOL)handleCommand:(NSString *)command withParameter:(NSString *)parameter;
+(NSString *)_commandHTML:(NSString *)command
                    label:(NSString *)label
                valuespec:(NSString *)valuespec;
+(NSString *)HTMLreplace:(NSString *)str newlines:(BOOL)nls;
+(NSString *)getFormText:(NSURLRequest *)urlRequest;

+(int)fromString:(NSObject *)string;

-(instancetype)reloadHTML;
@end

@implementation MainPage

-(void)segueToSecondViewFrom:(DemoPanel *)sender
{
    if (self.segueToSecond != nil) {
        [self.uiWebView.window.rootViewController
         performSegueWithIdentifier:self.segueToSecond
         sender:sender];
    }
}

-(instancetype)init
{
    if (self = [super init]) {
        // Apple say not to use accessors in the initialiser.
        _uiWebView = nil;
        
        _backgroundColour = @"LightYellow";
        _title = @"MainPage";
        _information = nil;
        _results = nil;
        _editData = nil;
        _pickList = nil;
        _pickFor = -1;
        
        _save = nil;
        
        _demos = nil;
        _hasLoaded = NO;
    }
    return self;
}

-(void)demoLogString:(NSString *)message
{
    if (message) {
        if (self.results) {
            self.results = [self.results stringByAppendingString:message];
        }
        else {
            self.results = [NSString stringWithString:message];
        }
    }
    else {
        self.results = nil;
    }
    [self reloadHTML];
}

-(void)demoLogFormat:(NSString *)format, ...
{
    va_list parameters;
    va_start(parameters, format);
    NSString *message = [[NSString alloc] initWithFormat:format
                                               arguments:parameters];
    va_end(parameters);

    [self demoLogString:message];
}

-(void)demoEdit:(NSString *)content savingTo:(id<DemoComponent>)saver
{
    self.save = saver;
    [self showEditData:content];
}

-(instancetype)addDemoClass:(Class)class
{
    if (!self.demos) self.demos = [NSMutableArray new];
    DemoComponent<DemoComponent> *demo = [class new];
    demo.demoUserInterface = self;
    [self.demos addObject:demo];
    return self;
}
-(instancetype)addDemoClasses:(NSArray *)classes
{
    for (int i=0; i<classes.count; i++) {
        [self addDemoClass:classes[i]];
    }
    return self;
}
-(instancetype)addDemoClassNamed:(char *)classname
{
    return [self addDemoClass:objc_getClass(classname)];
}

-(void)addDemoPanelClass:(Class)class
{
    if (!self.demoPanels) self.demoPanels = [NSMutableArray new];
    DemoPanel *demoPanel = [[class alloc] init];
    [demoPanel setDemoUserInterface:self];
    [self.demoPanels addObject:demoPanel];
}
-(void)addDemoPanelClasses:(NSArray *)classes
{
    for (int i=0; i<classes.count; i++) {
        [self addDemoPanelClass:classes[i]];
    }
}
-(void)addDemoPanelClassNamed:(char *)className
{
    [self addDemoClass:objc_getClass(className)];
}

-(void)setUIWebView:(UIWebView *)uiWebView
{
    _uiWebView = uiWebView;
    if (self.uiWebView) {
        [self.uiWebView setDelegate:self];
    }
    [self reloadHTML];
}

-(void)setBackgroundColour:(NSString *)backgroundColour
{
    _backgroundColour = backgroundColour;
    [self reloadHTML];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    [self reloadHTML];
}

-(void)setInformation:(NSString *)information
{
    _information = information;
    [self reloadHTML];
}

-(instancetype)load
{
    if (self.demos) for (int i=0; i<self.demos.count; i++) {
        DemoComponent<DemoComponent> *demoi = self.demos[i];
        [demoi demoLoad];
    }

    if (self.demoPanels) for (int i=0; i<self.demoPanels.count; i++) {
        DemoPanel *demoPaneli = self.demoPanels[i];
        [demoPaneli demoPanelLoad:NO];
    }
    
    self.hasLoaded = YES;
    [self reloadHTML];
    return self;
}

-(instancetype)showEditData:(NSString *)newEditData
{
    self.editData = newEditData;
    return [self reloadHTML];
}

+(int)fromString:(NSObject *)string
{
    return [[[NSNumberFormatter new] numberFromString:(NSString *)string ]
            intValue];
}

-(BOOL)handleCommand:(NSString *)command withParameter:(NSString *)parameter
{
    if ([command isEqualToString:@"CLEAR"]) {
        [self demoLogString:nil];
        return YES;
    }
    else if ([command isEqualToString:@"panel"]) {
        NSArray *parameters = [parameter componentsSeparatedByString:@","];
        int panel = [MainPage fromString:parameters[0]];
        int division = [MainPage fromString:parameters[1]];
        int item =  [MainPage fromString:parameters[2]];
        DemoPanel *demoPanel = (DemoPanel *)(self.demoPanels[panel]);
        NSArray *divisioni = demoPanel.demoPanelItemDivisions[division];
        DemoPanelItem *demoPanelItem = (DemoPanelItem *)divisioni[item];
        demoPanelItem.clickBlock(demoPanelItem);
        [self reloadHTML];
        return YES;
    }
    else if ([command isEqualToString:@"execute"]) {
        int parameter_int = [[[NSNumberFormatter new]
                              numberFromString:parameter] intValue];
        DemoComponent<DemoComponent> *demoi = self.demos[parameter_int];
        self.pickList = [demoi demoExecuteOrPickList];
        if (self.pickList == nil) {
            // Demo returned nil to indicate no need for a pick.
            [self reloadHTML];
        }
        else if ( self.pickList.count < 1 ) {
            // Empty pick list.
            self.pickList = nil;
            [self demoLogString:@"No options."];
            // demoLogString triggers reloadHTML.
        }
        else {
            // Actual pick list.
            self.pickFor = parameter_int;
            [self demoLogFormat:@"Options: %d.\n", self.pickList.count];
            // demoLogFormat triggers reloadHTML.
        }
        return YES;
    }
    else if ([command isEqualToString:@"save"]) {
        if (self.save == nil) {
            [self demoLogString:@"save command when save is null.\n"];
        }
        else {
            if ([self.save demoSave:parameter]) {
                // Save OK; delete from here.
                [self showEditData:nil];
            }
            else {
                // Save failed; keep the content here
                [self showEditData:parameter];
            }
        }
        return YES;
    }
    else if ([command isEqualToString:@"discard"]) {
        if (self.save == nil) {
            [self demoLogString:@"discard command when save is null.\n"];
        }
        else {
            [self.save demoSave:nil];
            [self showEditData:nil];
        }
        return YES;
    }
    else if ([command isEqualToString:@"pick"]) {
        int pick_int = [[[NSNumberFormatter new]
                         numberFromString:parameter] intValue];
        DemoComponent *demoi = self.demos[self.pickFor];
        self.pickList = nil;
        self.pickFor = -1;
        [demoi demoPickAndExecute:pick_int];
        [self reloadHTML];
        return YES;
    }
    else if ([command isEqualToString:@"switch"]) {
        int parameter_int = [[[NSNumberFormatter new]
                              numberFromString:parameter] intValue];
        DemoComponent *demoi = self.demos[parameter_int];
        [demoi demoSwitch];
        [self reloadHTML];
        return YES;
    }

    return NO;
}

+(NSString *)getFormText:(NSURLRequest *)urlRequest
{
    // The form will have consisted of a single textarea control.
    // Get the form contents and decode them.
    NSString *HTTPBodyString =
    [[[[NSString alloc] initWithData:urlRequest.HTTPBody
                            encoding:NSASCIIStringEncoding]
      stringByReplacingOccurrencesOfString:@"+" withString:@" " ]
     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // Now we have a form POST body. Strip the initial part, which will be
    // like field_name=
    // Find the first equals sign ...
    NSRange eqrange = [HTTPBodyString rangeOfString:@"="];
    // ... take everything after it and return it.
    return [HTTPBodyString substringFromIndex:
            eqrange.location + eqrange.length];
}

-(BOOL)            webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    // Type Other is used for loadHTMLString, so this gets allowed immediately.
    if (UIWebViewNavigationTypeOther ==  navigationType) {
        return YES;
    }

    // Otherwise process the request here, and then return NO to cancel
    // propagation.

    // Turn the navigation type into a string for diagnostic purposes.
    char *navType = "Unknown navigation type";
#define ENUM(ENUMVAL) case ENUMVAL: navType = #ENUMVAL; break;
    switch (navigationType) {
        ENUM(UIWebViewNavigationTypeLinkClicked)
        ENUM(UIWebViewNavigationTypeFormSubmitted)
        ENUM(UIWebViewNavigationTypeBackForward)
        ENUM(UIWebViewNavigationTypeReload)
        ENUM(UIWebViewNavigationTypeFormResubmitted)
        ENUM(UIWebViewNavigationTypeOther)
    }
#undef ENUM

    BOOL known = NO;
    NSString *formText = nil;
    // Form submission is used to pass control back from the web page to here.
    // XHR would have been easier to process, but unfortunately XHR requests do
    // not seem to trigger this callback.
    if (UIWebViewNavigationTypeFormSubmitted == navigationType) {
        formText = [MainPage getFormText:request];
        known = [self handleCommand:request.URL.lastPathComponent
                      withParameter:formText];
    }

    if (!known) {
        [self demoLogFormat:@"shouldStartLoadWithRequest %s\n"
          "URL \"%@\", lastPathComponent \"%@\", formText ",
         navType, request.URL, request.URL.lastPathComponent ];
        if (formText == nil) {
            [self demoLogString:@"None"];
        }
        else {
            [self demoLogFormat:@"\"%@\"", formText];
        }
        [self demoLogString:@"\n"];
    }

    return NO;
}

+(NSString *)HTMLreplace:(NSString *)str newlines:(BOOL)nls
{
    NSArray *HTMLreps = @[
        @[ @"&", @"&amp;"],
        @[ @"<", @"&lt;" ],
        @[ @">", @"&gt;" ]
    ];
    if (nls) {
        HTMLreps = [HTMLreps arrayByAddingObjectsFromArray:@[
            @[ @"\r\n", @"<br />" ],
            @[ @"\n", @"<br />" ]
        ]];
    }
    NSMutableString *ret = [[NSMutableString alloc] initWithString:str];
    for (int i=0; i<HTMLreps.count; i++ ) {
        [ret replaceOccurrencesOfString:HTMLreps[i][0]
                             withString:HTMLreps[i][1]
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, ret.length)];
    }
    return ret;
}

+(NSString *)_commandHTML:(NSString *)command
                    label:(NSString *)label
                valuespec:(NSString *)valuespec
{
    return [NSString stringWithFormat:@"<span class=\"command\" "
            "onclick=\"send('%@',%@);\">%@</span>",
            command, valuespec, label];
}
+(NSString *)commandHTML:(NSString *)command
                   label:(NSString *)label
                 control:(NSString *)control
{
    return [MainPage _commandHTML:command
                            label:label
                        valuespec:[NSString
                                   stringWithFormat:
                                   @"document.getElementById('%@').value",
                                   control]];
}
+(NSString *)commandHTML:(NSString *)command
                   label:(NSString *)label
                   value:(int)value
{
    return [MainPage _commandHTML:command
                            label:label
                        valuespec:[NSString stringWithFormat:@"%d", value]];
}
+(NSString *)commandHTML:(NSString *)command
                   label:(NSString *)label
{
    return [self _commandHTML:command label:label valuespec:@"null"];
}
+(NSString *)commandHTML:(NSString *)command
                   label:(NSString *)label
              valueArray:(NSArray *)value
{
    return [MainPage _commandHTML:command
                            label:label
                        valuespec:[NSString stringWithFormat:@"'%@'",
                                   [value componentsJoinedByString:@","]]];
}

+(NSString *)HTMLForDemoPanelItem:(DemoPanelItem *)demoPanelItem
                    asLocation:(NSArray *)location
{
    NSMutableString *ret = [NSMutableString
                            stringWithString:@"<span class=\"demo-item\">"];
    if (demoPanelItem.label != nil) {
        switch (demoPanelItem.type) {
            case DemoPanelItemTypeLabel:
                [ret appendFormat:@"<span class=\"demo-label\">%@</span>",
                 demoPanelItem.label];
                break;

            case DemoPanelItemTypeCommandOn:
                [ret appendString:
                 [MainPage commandHTML:@"panel"
                                 label:[demoPanelItem.label
                                        stringByAppendingString:@" &gt;"]
                            valueArray:location
                  ]];
                
                break;
                
            case DemoPanelItemTypeCommandBack:
                [ret appendString:
                 [MainPage commandHTML:@"panel"
                                 label:[@"&lt; " stringByAppendingString:
                                        demoPanelItem.label]
                            valueArray:location
                  ]];
                
                break;
                
//            case DemoPanelItemtypeOption:
//                [ret appendFormat:@"<div class=\"demo-option\">%@ %@</div>",
//                 demoPanelItem.label,
//                 [MainPage commandHTML:@"panel"
//                                 label:@"Go &gt;"
//                            valueArray:location
//                  ]];
//                break;
        }
    }
    [ret appendString:@"</span>"];
    return (NSString *)ret;
}

+(NSString *)HTMLForDemoPanel:(DemoPanel *)demoPanel
                asPanelNumber:(NSNumber *)panelNumber
{
    if (demoPanel.demoPanelItemDivisions.count <= 0) return @"";
    NSMutableString *ret = [NSMutableString
                            stringWithString:@"<div class=\"demo-panel\">"];
    for (int division=0;
         division<demoPanel.demoPanelItemDivisions.count;
         division++)
    {
        NSArray *divisioni = demoPanel.demoPanelItemDivisions[division];
        [ret appendString:@"<div class=\"demo-division\">"];
        for (int item=0; item<divisioni.count; item++) {
            [ret
             appendString:[MainPage
                           HTMLForDemoPanelItem:divisioni[item]
                           asLocation:@[panelNumber,
                                        [NSNumber numberWithInt:division],
                                        [NSNumber numberWithInt:item] ]
                           ]];
        }
        [ret appendString:@"</div>"];
    }
    [ret appendString:@"</div>"];
    return (NSString *)ret;
}

-(instancetype)reloadHTML
{
    if (!self.uiWebView || !self.hasLoaded) return self;
    
    NSMutableString *pageHTML = [NSMutableString
                                 stringWithFormat:@"%@%@%@%@%@%@%@",
    @"<html><head>"
    "<style>"
    "  body {font-family: sans-serif; background-color: ", self.backgroundColour, @"}"
    "  div {"
    "      margin-top: 6pt;"
    "      margin-bottom: 6pt;"
    "  }"
    "  .holder {"
    "      margin-top: 12pt;"
    "  }"
    "  div.picker, div.demo-panel {"
    "      margin-top: 12pt;"
    "      border-top: solid 1pt black;"
    "  }"
    "  div.picker div, div.demo-division {"
    "      border-bottom: solid 1pt black;"
    "      padding-bottom: 8pt;"
    "  }"
    "  h1 {margin-top: 20pt; font-size: 24pt;}"
    "  .command {"
    "      text-decoration: none;"
    "      border: 1pt solid black;"
    "      color: black;"
    "      padding: 4pt;"
    "      margin-right: 4pt;"
    "  }"
    "  span.demo-label { margin-right: 4pt; } "
    "  .information {"
    "      font-size: 8pt;"
    "  }"
    "  pre {"
    "      border: 1pt dashed black;"
    "      white-space: pre-wrap;"
    "  }"
    "  textarea {"
    "      font-size: 18pt;"
    "  }"
    "</style>"
    "<script type=\"text/javascript\" >"
    "function CreateNode(tag, text) {"
    "    var elem = document.createElement(tag);"
    "    if ( text != null ) {"
    "       var etxt = document.createTextNode(text);"
    "       elem.appendChild(etxt);"
    "    }"
    "    return elem;"
    "}"
    ""
    "function AppendNode(tag, text, parent) {"
    "   return parent.appendChild( CreateNode(tag, text) );"
    "}"
    ""
    "function send(send_action, send_data) {"
    "    var tform = AppendNode('form', '', document.getElementById('h1'));"
    "    tform.setAttribute( 'action', send_action );"
    "    tform.setAttribute( 'method', 'post' );"
    "    tform.setAttribute('style', 'display: none;' );"
    "    var ttext = AppendNode('textarea', '', tform);"
    "    ttext.setAttribute('name', 'textarea');"
    "    ttext.value = send_data;"
    "    tform.submit();"
    "    tform.parentNode.removeChild(tform);"
    "}"
    "</script>"
    "</head><body>"
    "<h1 id=\"h1\">", self.title, @"</h1><div class=\"information\">",
     (self.information == nil ? @"" : self.information), @"</div>" ];
    if (self.results) {
        [pageHTML appendFormat:@"<div class=\"holder\"><pre>%@</pre>%@</div>",
         [MainPage HTMLreplace:self.results newlines:YES],
         [MainPage commandHTML:@"CLEAR" label:@"&lt; Clear"]];
    }
    
    if (self.pickList) {
        [pageHTML appendString:@"<div class=\"picker\">"];
        for (int i=0; i<self.pickList.count; i++) {
            [pageHTML appendFormat:@"<div>%@ %@</div>", self.pickList[i],
             [MainPage commandHTML:@"pick" label:@"Go &gt;" value:i]];
        }
        [pageHTML appendString:@"</div>"];
    }
    
    if (self.editData) {
        NSString *ctrlname = @"savearea";
        [pageHTML appendFormat:@"\n<div class=\"holder\"><textarea name=\"%@\""
         "id=\"%@\" rows=\"6\" cols=\"40\">%@</textarea></div><div>%@%@</div>",
         ctrlname, ctrlname, [MainPage HTMLreplace:self.editData newlines:NO],
         [MainPage commandHTML:@"discard" label:@"&lt; Discard"],
         [MainPage commandHTML:@"save" label:@"Save &gt;" control:ctrlname]];
    }
    
    if (self.demos) for (int i=0; i<self.demos.count; i++) {
        DemoComponent<DemoComponent> *demoi = self.demos[i];
        NSString *executeLabel = [demoi demoExecuteLabel];
        NSString *switchLabel = [demoi demoGetSwitchLabel];
        if ( i != self.pickFor && (executeLabel != nil || switchLabel != nil) ) {
            [pageHTML appendString:@"<div class=\"holder\"><div>"];
            if (executeLabel != nil) {
                [pageHTML appendString:
                 [MainPage commandHTML:@"execute"
                                 label:[executeLabel
                                        stringByAppendingString:@" &gt;"]
                                 value:i]];
            }
            if (switchLabel != nil) {
                [pageHTML appendString:[MainPage commandHTML:@"switch"
                                                       label:switchLabel
                                                       value:i]];
            }
            [pageHTML appendString:@"</div></div>"];
        }
    }
    
    if (self.demoPanels) for (int panel=0; panel<self.demoPanels.count; panel++) {
        [pageHTML appendString:[MainPage
                                HTMLForDemoPanel:self.demoPanels[panel]
                                asPanelNumber:[NSNumber numberWithInt:panel]]];
    }
    
    [pageHTML appendString:@"</body></html>"];
    [self.uiWebView loadHTMLString:pageHTML baseURL:nil];
    return self;
}

-(void)refresh
{
    [self reloadHTML];
}

@end
