//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMellow:(IXNMuseDataPacket *)packet
{
    NSLog(@"Mellow: %@", packet.values[0]);
    
    NSNumber *value = packet.values[0];
    float valueF = [value floatValue];
    CGFloat alpha = 0.3 + (0.7) * (valueF - 0);
    _mellowView.backgroundColor = [_mellowView.backgroundColor colorWithAlphaComponent:alpha];
    
    [self.mData setText:[NSString stringWithFormat:@"%f", valueF]];
}

- (void)updateConcentration:(IXNMuseDataPacket *)packet
{
    NSLog(@"Concentration: %@", packet.values[0]);
    
    NSNumber *value = packet.values[0];
    float valueF = [value floatValue];
    CGFloat alpha = 0.3 + (0.7) * (valueF - 0);
    _concentrationView.backgroundColor = [_concentrationView.backgroundColor colorWithAlphaComponent:alpha];
    
    [self.cData setText:[NSString stringWithFormat:@"%f", valueF]];
}

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
    
    if (batteryRead < 20 && batteryRead > 10)
    {
        batteryLevel = 1;
    }
        else if (batteryRead < 40)
        {
            batteryLevel = 2;
        }
        else if (batteryRead < 60)
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
