//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "Muse.h"

@interface ViewController : UIViewController<NSURLConnectionDelegate>

-(void) updateMellow:(IXNMuseDataPacket *) packet;
-(void) updateConcentration:(IXNMuseDataPacket *) packet;
-(void) updateQuantization:(IXNMuseDataPacket *) packet;
-(void) updateBattery:(IXNMuseDataPacket *) packet;

-(void) sendDataToHuzzah:(int)red
                        :(int)green
                        :(int)blue
                        :(int)white
                        :(bool)mellow;

@property IXNMuseDataPacket* mellow;
@property IXNMuseDataPacket* concentration;

@property (strong, nonatomic) IBOutlet UIView *mellowView;
@property (strong, nonatomic) IBOutlet UIView *concentrationView;

- (IBAction)concentrate:(id)sender;
- (IBAction)mellow:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *batteryDisplay;
@property (strong, nonatomic) IBOutlet UILabel *cData;
@property (strong, nonatomic) IBOutlet UILabel *mData;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *sensorViz;

@end
