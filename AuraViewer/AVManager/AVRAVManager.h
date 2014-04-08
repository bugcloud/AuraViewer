//
//  AVRAVManager.h
//  AuraViewer
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVRAuraLayer.h"

@interface AVRAVManager : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate,
                                    AVCaptureVideoDataOutputSampleBufferDelegate
                                    >

@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVRAuraLayer *overlayLayer;

+ (BOOL)isInitable;
- (void)startCapturing;
- (void)stopCapturing;

@end
