//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "LoggingListener.h"

@interface LoggingListener () {
    dispatch_once_t _connectedOnceToken;
}
@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL sawOneBlink;
@property (nonatomic, weak) AppDelegate* appDelegate;
@property (nonatomic) id<IXNMuseFileWriter> fileWriter;
@property (nonatomic, strong) ViewController *viewControl;
@end

@implementation LoggingListener

- (instancetype)initWithDelegate:(AppDelegate *)delegate viewController:(ViewController *)viewControl {
    _appDelegate = delegate;
    _viewControl = viewControl;
    /**
     * Set <key>UIFileSharingEnabled</key> to true in Info.plist if you want
     * to see the file in iTunes
     */
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(
//        NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath =
//        [documentsDirectory stringByAppendingPathComponent:@"new_muse_file.muse"];
//    self.fileWriter = [IXNMuseFileFactory museFileWriterWithPathString:filePath];
//    [self.fileWriter addAnnotationString:1 annotation:@"fileWriter created"];
//    [self.fileWriter flush];
    return self;
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet {
    switch (packet.packetType) {
        case IXNMuseDataPacketTypeBattery:
            NSLog(@"battery packet received");
            [self.viewControl updateBattery:packet];
//            [self.fileWriter addDataPacket:1 packet:packet];
            break;
        case IXNMuseDataPacketTypeMellow:
            [self.viewControl updateMellow:packet];
            break;
        case IXNMuseDataPacketTypeConcentration:
            [self.viewControl updateConcentration:packet];
            break;
        case IXNMuseDataPacketTypeQuantization:
            [self.viewControl updateQuantization:packet];
            break;
        case IXNMuseDataPacketTypeAccelerometer:
            break;
        default:
            break;
    }
}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet {
    if (!packet.headbandOn)
        return;
    if (!self.sawOneBlink) {
        self.sawOneBlink = YES;
        self.lastBlink = !packet.blink;
    }
    if (self.lastBlink != packet.blink) {
        if (packet.blink)
            NSLog(@"blink");
        self.lastBlink = packet.blink;
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
//            [self.fileWriter addAnnotationString:1 annotation:@"disconnected"];
//            [self.fileWriter flush];
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
//            [self.fileWriter addAnnotationString:1 annotation:@"connected"];
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
//            [self.fileWriter addAnnotationString:1 annotation:@"connecting"];
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
    NSLog(@"connect: %@", state);
    if (packet.currentConnectionState == IXNConnectionStateConnected) {
        [self.appDelegate sayHi];
    } else if (packet.currentConnectionState == IXNConnectionStateDisconnected) {
        // XXX IMPORTANT
        // -connect, -disconnect, and -execute *MUST NOT* be on any code path
        // that starts with a connection event listener, except through an
        // asynchronous scheduled event, such as the below call to reconnect.
        //
        // These messages can cause this connection listener to synchronously
        // fire, without giving the OS a chance to clean up resources or
        // perform scheduled IO. This is a known issue that will be fixed in a
        // future release of the SDK.
        [self.appDelegate performSelector:@selector(reconnectToMuse)
                            withObject:nil
                            afterDelay:0];
    }
}

@end
