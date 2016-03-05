//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <Foundation/Foundation.h>
#import "Muse.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface LoggingListener : NSObject<
    IXNMuseDataListener, IXNMuseConnectionListener
>

// Designated initializer.
- (instancetype)initWithDelegate:(AppDelegate *)delegate viewController:(ViewController *)view;
- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet;
- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet;
- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet;

@end
