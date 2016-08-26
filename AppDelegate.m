//
//  AppDelegate.m
//  Stock Moving Average Calculator
//
//  Created by Christopher Boggs on 12/10/14.
//  Copyright (c) 2014 Christopher Boggs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;


@end

@implementation AppDelegate




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _MaintickerArray = [[NSMutableArray alloc]init];
    
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)StartAction:(id)sender {
    
    
    
    [_MaintickerArray removeAllObjects];
    //swap minor and major days if its not looking good
    if (_MinorDays.floatValue > _MajorDays.floatValue) {
        NSString *holder = _MinorDays.stringValue;
        _MinorDays.stringValue = _MajorDays.stringValue;
        _MajorDays.stringValue = holder;
    }
    
    if (_HoldingPeriod.floatValue > _MajorDays.floatValue) {
        _HoldingPeriod.stringValue = _MajorDays.stringValue;
    }
    
    //Makes sure formatting is correct
    //formatting for loop;
    for (int i = 0; i < 10; i++) {
        _TickerList.stringValue = [_TickerList.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        _TickerList.stringValue = [_TickerList.stringValue stringByReplacingOccurrencesOfString:@",," withString:@","];
        _TickerList.stringValue = [_TickerList.stringValue stringByReplacingOccurrencesOfString:@",," withString:@","];
        
    }
    
    while([[_TickerList.stringValue substringFromIndex: [_TickerList.stringValue length] - 1] isEqualToString:@","])
    {
        _TickerList.stringValue = [_TickerList.stringValue substringToIndex: [_TickerList.stringValue length] - 1];
        NSLog(@"Found Comma - Deleted It");
        
    }
    //if A user entered a URL - load from that URL;
    if ([self DoesFileOfThisURLStringExist:_TickerList.stringValue]) {
        _TickerList.stringValue = [self GetStringContentsOfComputerFileWithURL:_TickerList.stringValue];
    }
    
   // NSMutableArray *MainTickerArray = [[NSMutableArray alloc]init];
    
    NSArray *firstTickerArray = [_TickerList.stringValue componentsSeparatedByString:@","];
    
    NSString *YahooFeedUrl = [NSString stringWithFormat:@"http://ichart.finance.yahoo.com/table.csv?d=6&e=1&f=%@&g=d&a=7&b=19&c=2000%@&ignore=.csv&s=", @"2019" ,@"%20"];

    NSLog(@"Getting Data -");
    //getting historical data and putting it into the array
    NSString *internetDataOutput = @"";
    
    for (int i = 0; i < firstTickerArray.count && i < 50; i++) {
    
        NSMutableArray *CompanyOutput = [[NSMutableArray alloc]init];
        NSMutableArray *historicalData = [[NSMutableArray alloc]init];
        [CompanyOutput addObject:[firstTickerArray objectAtIndex:i]];
        
        //add yahoo data array into the 1st column;
        internetDataOutput = [self GetStringContentsOfWebfileWithURL:[NSString stringWithFormat:@"%@%@", YahooFeedUrl, [firstTickerArray objectAtIndex:i]]];
        
        // Makes sure this ticker is valid, if it isnt, it'll just ignore the ticker
        if (![self Does:internetDataOutput Contain:@"404 Not Found"]) {
            
        historicalData = [[internetDataOutput componentsSeparatedByString:@"\n"] mutableCopy];
        [historicalData removeLastObject];
        
        for (int x = 1; x < historicalData.count; x++) {
            NSMutableArray *RowhistoricalData = [[NSMutableArray alloc]init];
            RowhistoricalData = [[[historicalData objectAtIndex:x] componentsSeparatedByString:@","] mutableCopy];
            
            [RowhistoricalData addObject:[NSString stringWithFormat:@"%.3f", (([[RowhistoricalData objectAtIndex: 4] floatValue] / [[RowhistoricalData objectAtIndex: 1] floatValue] -1) *100)]]; // 7 - Percentage Change
            [RowhistoricalData addObject:@""]; // 8 Minor-day percent moving average
            [RowhistoricalData addObject:@""]; // 9 Derv Of each Minor moving average
            [RowhistoricalData addObject:@""]; // 10 Minor day Derv Moving average
            [RowhistoricalData addObject:@""]; // 11 Major-day percent moving average
            [RowhistoricalData addObject:@""]; // 12 Derv Of each Major moving average
            [RowhistoricalData addObject:@""]; // 13 Major-day percent moving average
             [RowhistoricalData addObject:@""]; // Certianty
            
            
            [historicalData replaceObjectAtIndex:(x-1) withObject:RowhistoricalData];
        }
        
        [CompanyOutput addObject:historicalData];
        [_MaintickerArray addObject:CompanyOutput];
        }
    
    }
    
    // Calculate Moving Averages for percentage change
    NSLog(@"Calculating Moving Averages -");
    for (int i = 0; i < _MaintickerArray.count; i++) {
        //calculation minor day moving average
        [self MovingAverageFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] ofLength:_MinorDays.floatValue FromDataContainedinColumn:7 andPutIntoColumn:8];
        
        // calculation major day moving average
        [self MovingAverageFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] ofLength:_MajorDays.floatValue FromDataContainedinColumn:7 andPutIntoColumn:11];
        
        [self DervitiveFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] FromDataContainedinColumn:8 andPutIntoColumn:9];
        
        // calculation major day moving average
        [self DervitiveFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] FromDataContainedinColumn:11 andPutIntoColumn:12];
        
        //calculation minor day Derv moving average
        [self MovingAverageFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] ofLength:_MinorDays.floatValue FromDataContainedinColumn:9 andPutIntoColumn:10];
        
        // calculation major day Derv moving average
        [self MovingAverageFromMutableArray:[[_MaintickerArray objectAtIndex:i] objectAtIndex:1] ofLength:_MajorDays.floatValue FromDataContainedinColumn:12 andPutIntoColumn:13];
    }
    
    // Calculate Dervitatives for moving averages
    
    
    
    
    // backtest
    NSLog(@"Backtesting -");
    for (int companyNumber = 0; companyNumber < _MaintickerArray.count; companyNumber++) {
        [[_MaintickerArray objectAtIndex:companyNumber] addObject: @"No Action Recommended"];
        
        
       // NSLog(@"%lu", (unsigned long)[[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] count]);
        float timesCorrect = 0;
        float timesGuessed = 0;
        
        
        for (int i = 0; i < [[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] count] - _MajorDays.floatValue; i++) {

            
            BOOL Guessed = false;
            BOOL ItWillGoUp = false;
            BOOL ItWillGoDown = false;
            
            float minorMovingAverage = [[[[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] objectAtIndex:i] objectAtIndex:10] floatValue];
            float majorMovingAverage = [[[[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] objectAtIndex:i] objectAtIndex:13] floatValue];

            
            if ((minorMovingAverage < 0 && majorMovingAverage > 0)
                ||(minorMovingAverage > 0 && majorMovingAverage < 0) ) {
              
                Guessed = true;
                timesGuessed ++;
                
                if (minorMovingAverage > 0 && majorMovingAverage < 0) {
                   
                    ItWillGoUp = true;
                }
                else{
                    ItWillGoDown = true;
                }
            }
            if (Guessed) {
                
                
            
            float NetGain = 1;
            for (int x = 0; x < _HoldingPeriod.floatValue && (x+i < [[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] count]); x++) {

                float whereItActuallyWent = [[[[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] objectAtIndex:i+x] objectAtIndex:7] floatValue];
                NetGain *= (whereItActuallyWent + 100)/100;
            }
                
                
                if (ItWillGoUp && NetGain > 1) {
                    timesCorrect ++;
                }
                if (ItWillGoDown && NetGain < 1) {
                    timesCorrect ++;
                }
            }
            
            if (i == 0) {
                if (ItWillGoDown) {
                    [[_MaintickerArray objectAtIndex:companyNumber] replaceObjectAtIndex:2 withObject:@"Recommended Short"];
                }
                if (ItWillGoUp) {
                     [[_MaintickerArray objectAtIndex:companyNumber] replaceObjectAtIndex:2 withObject:@"Recommended Long"];
                }
            }
            //over the next 10 days;

        }
        
        
        
        [[_MaintickerArray objectAtIndex:companyNumber] addObject:[NSString stringWithFormat:@"%.3f", (timesCorrect/timesGuessed) * 100]];
    }
    
    //sort
    NSLog(@"Sorting -");
    for (int companyNumber = 0; companyNumber < _MaintickerArray.count; companyNumber++) {
        
        if ([[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:2] isEqualToString:@"Recommended Short"]) {
            [_MaintickerArray insertObject:[_MaintickerArray objectAtIndex:companyNumber] atIndex:0];
            [_MaintickerArray removeObjectAtIndex:companyNumber +1];
           // companyNumber--;
        }
    }
    
    for (int companyNumber = 0; companyNumber < _MaintickerArray.count; companyNumber++) {
        
        if ([[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:2] isEqualToString:@"Recommended Long"]) {
            [_MaintickerArray insertObject:[_MaintickerArray objectAtIndex:companyNumber] atIndex:0];
            [_MaintickerArray removeObjectAtIndex:companyNumber +1];
            //companyNumber--;
        }
    }
    
    NSLog(@"Printing -");
    for (int companyNumber = 0; companyNumber < _MaintickerArray.count; companyNumber++){
    
        _Output.string = [NSString stringWithFormat:@"%@%@ - Company: %@ -  I'm %@%% sure with %i referenced points\n",
                        _Output.string,
                        [[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:2],
                        [[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:0],
                        [[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:3],
                        (int)[[[_MaintickerArray objectAtIndex:companyNumber] objectAtIndex:1] count]];
    }
    
    
}

- (IBAction)Clear:(id)sender {
    
    _Output.string = @"";
}


-(void)MovingAverageFromMutableArray:(NSMutableArray *)MainArray ofLength:(float) Days FromDataContainedinColumn:(float) DataColumn andPutIntoColumn: (float) ResultColumn{

    for (int i = 0; i < MainArray.count - Days; i++) {
        
        float Sum;
        for (int x = 0; x < Days; x++) {
            Sum += [[[MainArray objectAtIndex:i+x] objectAtIndex:DataColumn] floatValue];
        }
        
        [[MainArray objectAtIndex:i] replaceObjectAtIndex:ResultColumn withObject:[NSString stringWithFormat:@"%.3f", Sum/Days]];
        
    }
    
    
}

-(void)DervitiveFromMutableArray:(NSMutableArray *)MainArray FromDataContainedinColumn:(float) DataColumn andPutIntoColumn: (float) ResultColumn{
    
    for (int i = 0; i < (MainArray.count - 2); i++) {
        
        float first = [[[MainArray objectAtIndex:i] objectAtIndex:DataColumn] floatValue];
        float Second = [[[MainArray objectAtIndex:i+1] objectAtIndex:DataColumn] floatValue];
        
        [[MainArray objectAtIndex:i] replaceObjectAtIndex:ResultColumn withObject:[NSString stringWithFormat:@"%.3f", first - Second]];
        
    }
    
    
}

- (void)CreateFileAtFileURLof:(NSString *) fileLocation{
    if (![self DoesFileOfThisURLStringExist:fileLocation]){
        NSString *text = @" ";
        [text writeToURL:[NSURL fileURLWithPath:fileLocation] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
}
- (void)replaceAllContentsOfFileUrL:(NSString *)URLstring withString:(NSString *)Newcontents{
    NSString *AlreadyURL = [NSString stringWithFormat:@"%@",URLstring];
    NSURL *PreviousUrl = [NSURL fileURLWithPath:AlreadyURL];
    NSString *newText = [NSString stringWithFormat:@"%@",Newcontents];
    [newText writeToURL:PreviousUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
- (BOOL)DoesFileOfThisURLStringExist:(NSString*) URLstring{
    
    NSString *Infostring = [self GetStringContentsOfComputerFileWithURL:URLstring];
    
    // NSLog(@"Infostring Length: %lu",(unsigned long)Infostring.length);
    
    if (Infostring.length == 0){
        
        return FALSE;}
    
    
    return TRUE;
    
}
- (NSString *) GetStringContentsOfComputerFileWithURL: (NSString *) FileURL{
    
    NSURL *PreviousUrl = [NSURL fileURLWithPath:FileURL];
    NSString *rawContentsFromTextfile = [NSString stringWithContentsOfURL:PreviousUrl encoding:NSUTF8StringEncoding  error:nil];
    
    if (rawContentsFromTextfile.length == 0){
        NSString *rawContentsFromTextfile = [NSString stringWithContentsOfURL:PreviousUrl encoding:NSASCIIStringEncoding  error:nil];
        
        if (rawContentsFromTextfile.length == 0) {
            rawContentsFromTextfile = [NSString stringWithContentsOfURL:PreviousUrl encoding:NSUTF16StringEncoding  error:nil];
        }
        // NSLog(@"SERIOUS PROBLEM - INVALID TEXT URL CONTENTS");
    }
    
    return rawContentsFromTextfile;
}
- (NSString *) GetStringContentsOfWebfileWithURL: (NSString *) WebURL{
    NSError *error;
    return [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", WebURL]] usedEncoding:NULL error:&error];
}
-(BOOL)Does:(NSString *)MainString Contain: (NSString *)Substring{
    if ([MainString rangeOfString:Substring].location == NSNotFound) {
        return false;
    } else {
        return true;
    }
}
-(NSString *)GetDataIn:(NSString *)returnData RangeOf:(NSString *)Search andEndOf:(NSString *)endSearch{
    if ([returnData rangeOfString:Search].length == 0 || [returnData rangeOfString:endSearch].length == 0 ){
        return @"N/A";}
    else{
        return [returnData substringWithRange:NSMakeRange(((float)([returnData rangeOfString:Search].location+Search.length)), [[returnData substringWithRange:NSMakeRange(((float)([returnData rangeOfString:Search].location+Search.length)), [returnData length]- ((float)([returnData rangeOfString:Search].location+Search.length)))] rangeOfString:endSearch].location)]; // +start - start)
    }
    return @"";
    
}
- (void)PlaceAtEndOfFile:(NSString *)fileLocation  inFileAt:(NSString *)text {
    NSString *AlreadyURL = [NSString stringWithFormat:@"%@",fileLocation];
    NSURL *PreviousUrl = [NSURL fileURLWithPath:AlreadyURL];
    NSString *PreviousInfoString = [NSString stringWithContentsOfURL:PreviousUrl encoding:NSUTF8StringEncoding  error:nil];
    NSString *newText = [NSString stringWithFormat:@"%@%@", PreviousInfoString,text];
    [newText writeToURL:PreviousUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    
}




@end
