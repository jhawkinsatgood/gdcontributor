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

#import "MainPageForGoodDynamics.h"
#import <GD/GDiOS.h>

#import "gdRuntimeDispatcher.h"

@interface MainPageForGoodDynamics()
-(instancetype)init;
@property (nonatomic, assign) BOOL hasSetUp;
@property (nonatomic, assign) BOOL hasLoadedStoryBoard;
@property (nonatomic, assign) BOOL hasAuthorized;
-(void)didAuthorize;
@end

@implementation MainPageForGoodDynamics

+(instancetype)sharedInstance
{
    static MainPageForGoodDynamics *mainPageForGoodDynamics = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        mainPageForGoodDynamics = [[MainPageForGoodDynamics alloc] init];
    });
    return mainPageForGoodDynamics;
}

-(instancetype)init
{
    self = [super init];
    _mainPage = [MainPage new];
    _hasAuthorized = NO;
    _hasSetUp = NO;

    _uiWebView = nil;
    _uiApplicationDelegate = nil;
    _storyboardName = nil;
    return self;
}

-(void)setUIApplicationDelegate:(id<UIApplicationDelegate>)uiApplicationDelegate
{
    _uiApplicationDelegate = uiApplicationDelegate;
    [self didAuthorize];
}

-(void)setUIWebView:(UIWebView *)uiWebView
{
    _uiWebView = uiWebView;
    [self didAuthorize];
}

-(void)setStoryboardName:(NSString *)storyboardName
{
    _storyboardName = storyboardName;
    [self didAuthorize];
}

-(void)didAuthorize
{
    if (self.hasAuthorized) {
        if (self.uiWebView) {
            // Following line also sets mainPage as the UIWebView delegate.
            [self.mainPage setUIWebView:self.uiWebView];
            [self.mainPage load];
        }
        else {
            if (self.storyboardName != nil && !self.hasLoadedStoryBoard) {
                // If a storyboard has been specified but not yet loaded, then
                // load it now.
                UIStoryboard *uiStoryboard =
                [UIStoryboard storyboardWithName:self.storyboardName
                                          bundle:nil];
                self.hasLoadedStoryBoard = YES;
                
                // Next line kicks off loading of the view controller, which
                // will in turn result in the uiWebView property being set.
                self.uiApplicationDelegate.window.rootViewController =
                [uiStoryboard instantiateInitialViewController];
            }
            // If the end user has authorised, but there is no uiWebView, and
            // there is no storyboard specified or the storyboard is already
            // supposed to have loaded, then do nothing.
        }
    }
    
    // If the end user has not yet authorised, do nothing.
}

-(void)setUp
{
    if ([self.mainPage information] == nil) {
        // The mainBundle is used for a string that is passed to the user
        // interface builder.
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        [self.mainPage setInformation:[NSString stringWithFormat:@"%@ %@",
                                       [[GDiOS sharedInstance] getVersion],
                                       [infoDictionary
                                        objectForKey:@"GDApplicationID"]] ];
    }

    if (!self.hasSetUp) {
        [[gdRuntimeDispatcher sharedInstance]
         addObserverForEventType:GDAppEventAuthorized
         usingBlock:GDRUNTIMEOBSERVER(event) {
             // This event is also received when the user unlocks the UI after
             // inactivity. There is no need to re-run didAuthorize at that time
             // or at any time.
             if (!self.hasAuthorized) {
                 self.hasAuthorized = YES;
                 [self didAuthorize];
             }
         }];
        self.hasSetUp = YES;
    }
  
}

@end
