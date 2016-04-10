//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

static NSString *huzzahIP = @"http://192.168.4.1/";

int mRed = 0;
int mGreen = 255;
int mBlue = 255;
int mWhite = 255;

int cRed = 255;
int cGreen = 204;
int cBlue = 051;
int cWhite = 255;

bool isMellow = YES;
bool isConcentrated = YES;

bool mellowFake = NO;
bool concetrateFake = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) concentrate:(id)sender
{
    if (concetrateFake == NO)
    {
        [self sendDataToHuzzah:cRed :cGreen :cBlue :cWhite :false];
        concetrateFake = YES;
    }
    else
    {
        [self sendDataToHuzzah:0 :0 :0 :255 :false];
        concetrateFake = NO;
    }
}

- (void) mellow:(id)sender
{
    if (mellowFake == NO)
    {
        [self sendDataToHuzzah:mRed :mGreen :mBlue :mWhite :true];
        mellowFake = YES;
    }
    else
    {
        [self sendDataToHuzzah:0 :0 :0 :255 :true];
        mellowFake = NO;
    }
}

- (void)updateMellow:(IXNMuseDataPacket *)packet
{
    NSNumber *value = packet.values[0];
    float valueF = [value floatValue];
    CGFloat alpha = 0.3 + (0.7) * (valueF - 0);
    _mellowView.backgroundColor = [_mellowView.backgroundColor colorWithAlphaComponent:alpha];
    
    //TODO map white inverse to colour
    //TODO check if value has changed more than 0.1f
    
    if (valueF > 0.40 && isMellow == NO)
    {
        isMellow = YES;
        int r = (int)(mRed * valueF);
        int g = (int)(mGreen*valueF);
        int b = (int)(mBlue*valueF);
        int w = (int)(mWhite*(1.0f - valueF));
        NSLog(@"Mellow");
        [self sendDataToHuzzah:mRed :mGreen :mBlue :0 :true];
    }

    [self.mData setText:[NSString stringWithFormat:@"%03f", valueF]];

    if (valueF < 0.40 && isMellow == YES)
    {
        int r = (int)(mRed * valueF);
        int g = (int)(mGreen*valueF);
        int b = (int)(mBlue*valueF);
        int w = (int)(mWhite*(1.0f - valueF));
        NSLog(@"Not Mellow");
        [self sendDataToHuzzah:0 :0 :0 :255 :true];
        isMellow = NO;
    }

}

- (void)updateConcentration:(IXNMuseDataPacket *)packet
{
    NSNumber *value = packet.values[0];
    float valueF = [value floatValue];
    CGFloat alpha = 0.3 + (0.7) * (valueF - 0);
    _concentrationView.backgroundColor = [_concentrationView.backgroundColor colorWithAlphaComponent:alpha];
    
    //TODO map white inverse to colour
    //TODO check if value has changed more than 0.1f

    
    if (valueF > 0.40 && isConcentrated == NO)
    {
        isConcentrated = YES;
        int r = (int)(cRed * valueF);
        int g = (int)(cGreen*valueF);
        int b = (int)(cBlue*valueF);
        int w = (int)(cWhite*(1.0f - valueF));
        NSLog(@"Concentrated");
        [self sendDataToHuzzah:cRed :cGreen :cBlue :0 :false];
        
    }
    
    if (valueF < 0.40 && isConcentrated == YES)
    {
        int r = (int)(mRed * valueF);
        int g = (int)(mGreen*valueF);
        int b = (int)(mBlue*valueF);
        int w = (int)(mWhite*(1.0f - valueF));
        NSLog(@"Not Concentrated");
        [self sendDataToHuzzah:0 :0 :0 :255 :false];
        isConcentrated = NO;
    }
    
    [self.cData setText:[NSString stringWithFormat:@"%f", valueF]];
}

-(void) sendDataToHuzzah:(int)red :(int)green :(int)blue :(int)white :(bool)mellow
{
    NSMutableString * urlString;
    if (mellow)
    {
        urlString =
        [NSMutableString stringWithFormat:@"%@mellow/r=%03d&g=%03d&b=%03d&w=%03d",
         huzzahIP, red, green, blue, white];
    }
    else
    {
        urlString =
        [NSMutableString stringWithFormat:@"%@concentrated/r=%03d&g=%03d&b=%03d&w=%03d",
         huzzahIP, red, green, blue, white];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"urlRequest: %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:100];
    
    NSURLResponse *response;
    NSError *error;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init ];
    //send it synchronous
    //NSMutableData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
    }];
//    if (responseData != nil)
//    {
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        // check for an error. If there is a network error, you should handle it here.
//        if(!error)
//        {
//            //log response
//            NSLog(@"Response from server = %@", responseString);
//        }
//    }
}


//url = [url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
//_directionsURL = [NSURL URLWithString:url];
//NSData* data =
//[NSData dataWithContentsOfURL:_directionsURL];


-(void)updateQuantization:(IXNMuseDataPacket *)packet
{
    //TODO add sensor connection viz
    for (int sensor = 0; sensor<5; sensor++) {
        for(UIImageView *circle in self.sensorViz)
        {
            if (circle.tag == sensor) {
                circle.hidden = YES;
                NSNumber *value = packet.values[sensor-1];
                float read = [value floatValue];
                if (read < 3) {
                    circle.hidden = NO;
                }
            }
        }
    }
    
}

-(void)updateBattery:(IXNMuseDataPacket *)packet
{
    int batteryLevel = 0;
    NSNumber *numID = packet.values[0];
    float batteryRead = [numID floatValue];
    
    if (batteryRead < 40 && batteryRead > 10)
    {
        batteryLevel = 1;
    }
        else if (batteryRead < 40)
        {
            batteryLevel = 2;
        }
        else if (batteryRead < 70)
        {
            batteryLevel = 3;
        }
        else if(batteryRead<80)
        {
            batteryLevel = 4;
        }
        else if(batteryRead <100)
        {
            batteryLevel = 5;
        }
        
    [self.batteryDisplay setImage:[UIImage imageNamed:[NSString stringWithFormat:@"batt%d", batteryLevel]]];
}

@end
