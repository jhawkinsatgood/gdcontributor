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

#import "AppDelegate.h"
#import "MainPageForGoodDynamics.h"

#import <GD/GDiOS.h>

#import "DemoApplicationConfiguration.h"
#import "DemoApplicationPolicies.h"
#import "DemoAuthenticationToken.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    GDiOS *gdRuntime = [GDiOS sharedInstance];
    
    MainPage *mainPage = [[MainPageForGoodDynamics sharedInstance] mainPage];
    
    // The mainBundle is used for a string that is passed to the user interface
    // builder.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [mainPage setTitle:[infoDictionary objectForKey:@"CFBundleDisplayName"]];
    [mainPage setBackgroundColour:@"LightSalmon"];
    [mainPage addDemoClasses:@[ [DemoApplicationConfiguration class],
                                [DemoApplicationPolicies class],
                                [DemoAuthenticationToken class] ]];
    
	self.window = [gdRuntime getWindow];
    
    [gdRuntime configureUIWithLogo:@"enterpriselogo_xcf.png"
                            bundle:nil
                             color:[UIColor blackColor]];
    
    [[MainPageForGoodDynamics sharedInstance] setStoryboardName:@"MainStoryboard"];
    [[MainPageForGoodDynamics sharedInstance] setUIApplicationDelegate:self];
    // The next line will attach a GD authorization listener that:
    // -   Gets a WebView setting from the ViewController and applies it to the
    //     MainPage instance.
    // -   Causes the demos to be loaded, if they haven't loaded already.
    // -   Sets the information line to display some GD-specific values.
    // Those things only happen when the application authorizes.
    [[MainPageForGoodDynamics sharedInstance] setUp];
	
	// Show the Good Authentication UI.
	[gdRuntime authorize];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
