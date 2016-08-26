//
//  AppDelegate.h
//  Stock Moving Average Calculator
//
//  Created by Christopher Boggs on 12/10/14.
//  Copyright (c) 2014 Christopher Boggs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSTextField *TickerList;
@property (weak) IBOutlet NSTextField *MinorDays;
@property (weak) IBOutlet NSTextField *MajorDays;
@property (unsafe_unretained) IBOutlet NSTextView *Output;
@property NSMutableArray *MaintickerArray;
@property (weak) IBOutlet NSTextField *HoldingPeriod;

- (IBAction)StartAction:(id)sender;
- (IBAction)Clear:(id)sender;




@end

