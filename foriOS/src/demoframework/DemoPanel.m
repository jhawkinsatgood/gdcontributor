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

#import "DemoPanel.h"

@interface DemoPanel()
@property (weak, nonatomic)id<DemoUserInterface> demoUserInterface;
@end

@implementation DemoPanel

-(unsigned long)demoPanelDivisionCount
{
    unsigned long count = 0L;
    if (self.demoPanelItemDivisions != nil) {
        count = self.demoPanelItemDivisions.count;
    }
    return count;
}

-(unsigned long)addDivisionWithArray:(NSArray *)demoPanelItemArray
{
    unsigned long division = self.demoPanelDivisionCount;
    
    [self appendToDivision:division item:nil];
    
    for (DemoPanelItem *demoPanelItem in demoPanelItemArray) {
        [self appendToDivision:division item:demoPanelItem];
    }

    return division;
}

-(unsigned long)addDivisionWithItem:(DemoPanelItem *)demoPanelItem
{
    return [self addDivisionWithArray:@[demoPanelItem]];
}

-(NSArray *)appendToDivision:(unsigned long)division
                        item:(DemoPanelItem *)demoPanelItem
{
    if (self.demoPanelItemDivisions == nil) {
        self.demoPanelItemDivisions = [NSMutableArray new];
    }
    while (self.demoPanelDivisionCount <= division) {
        [self.demoPanelItemDivisions addObject:[NSMutableArray new]];
    }
    
    NSMutableArray *divisioni = self.demoPanelItemDivisions[division];
    NSArray *location = @[[NSNumber numberWithUnsignedLong:division],
                          [NSNumber numberWithUnsignedLong:divisioni.count]
                          ];
    if (demoPanelItem != nil) {
        demoPanelItem.location = location;
        demoPanelItem.demoPanel = self;
        [divisioni addObject:demoPanelItem];
    }
    return location;
}

-(void)demoPanelLoad:(BOOL)andRefresh
{
    if (andRefresh) {
        [self.demoUserInterface refresh];
    }
}

-(void)deleteAllDivisions
{
    self.demoPanelItemDivisions = nil;
}

@end

@implementation DemoPanelItem

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                          userData:(NSObject *)userData
                             panel:(DemoPanel *)demoPanel
                          location:(NSArray *)location
{
    // Following line uses [self class] so that the new object will be of the
    // subclass. In this function, it has been cast to a DemoPanelItem but when
    // it is returned it is of the subclass.
    DemoPanelItem *demoPanelItem = [[[self class] alloc] init];
    demoPanelItem.demoPanel = demoPanel;
    demoPanelItem.location = location;
    
    demoPanelItem.type = type;
    demoPanelItem.label = label;
    demoPanelItem.userData = userData;
    
    return demoPanelItem;
}

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                          userData:(NSObject *)userData
{
    // Following line uses [self class] so that the new object will be of the
    // subclass. In this function, it has been cast to a DemoPanelItem but when
    // it is returned it is of the subclass.
    DemoPanelItem *demoPanelItem = [[[self class] alloc] init];
    
    demoPanelItem.type = type;
    demoPanelItem.label = label;
    demoPanelItem.userData = userData;
    
    return demoPanelItem;
}

+(instancetype)demoPanelItemOfType:(DemoPanelItemType)type
                             label:(NSString *)label
                        clickBlock:(DemoPanelItemClick)clickBlock
{
    // Following line uses [self class] so that the new object will be of the
    // subclass. In this function, it has been cast to a DemoPanelItem but when
    // it is returned it is of the subclass.
    DemoPanelItem *demoPanelItem = [[[self class] alloc] init];
    
    demoPanelItem.type = type;
    demoPanelItem.label = label;
    demoPanelItem.clickBlock = clickBlock;
    
    return demoPanelItem;
}

+(instancetype)demoPanelItemLabel:(NSString *)label
{
    // Following line uses [self class] so that the new object will be of the
    // subclass. In this function, it has been cast to a DemoPanelItem but when
    // it is returned it is of the subclass.
    DemoPanelItem *demoPanelItem = [[[self class] alloc] init];
    
    demoPanelItem.type = DemoPanelItemTypeLabel;
    demoPanelItem.label = label;
    
    return demoPanelItem;
}

-(void)didClick:(DemoPanelItem *)demoPanelItem
{
    ;
}

@end