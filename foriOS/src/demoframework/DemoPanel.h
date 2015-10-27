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

#import "DemoUserInterface.h"

typedef void(^DemoPanelSegueBlock)(UIStoryboardSegue *uiStoryboardSegue);
#define DEMOPANELSEQUEBLOCK(SEGUE) ^void (UIStoryboardSegue *SEGUE)

@interface DemoPanel : NSObject
-(void)setDemoUserInterface:(id<DemoUserInterface>)demoUserInterface;
-(id<DemoUserInterface>)demoUserInterface;
@property (copy) DemoPanelSegueBlock demoPanelSegueBlock;

@property (readonly)unsigned long demoPanelDivisionCount;

@property (strong, nonatomic)NSMutableArray *demoPanelItemDivisions;

// Load can happen later in the start-up cycle than init. For example, the
// application code could call DemoUserInterface load after Good Dynamics
// authentication processing has finished.
-(void)demoPanelLoad:(BOOL)andRefresh;

-(unsigned long)addDivisionWithItem:(NSObject *)demoPanelItem;
-(unsigned long)addDivisionWithArray:(NSArray *)demoPanelItemArray;
-(NSArray *)appendToDivision:(unsigned long)division
                        item:(NSObject *)demoPanelItem;

-(void)deleteAllDivisions;

@end

typedef NS_ENUM(NSInteger, DemoPanelItemType)
{
    DemoPanelItemTypeLabel=0,
    DemoPanelItemTypeCommandOn,
    DemoPanelItemTypeCommandBack
};

// Forward declaration, so that the DemoPanelItemClick typedef can be compiled.
@class DemoPanelItem;

typedef void (^DemoPanelItemClick) (DemoPanelItem *);
#define DEMOPANELITEMCLICK(ITEM) ^void (DemoPanelItem *ITEM)

@interface DemoPanelItem : NSObject
@property (nonatomic)DemoPanel *demoPanel;
@property (strong, nonatomic)NSArray *location;

@property (assign, nonatomic)DemoPanelItemType type;
@property (strong, nonatomic)NSString *label;
@property (copy) DemoPanelItemClick clickBlock;

@property (strong, nonatomic)NSObject *userData;

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                          userData:(NSObject *)userData
                             panel:(DemoPanel *)demoPanel
                          location:(NSArray *)location;

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                          userData:(NSObject *)userData;

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                        clickBlock:(DemoPanelItemClick)clickBlock;

+(instancetype)demoPanelItemLabel:(NSString *)label;

@end
