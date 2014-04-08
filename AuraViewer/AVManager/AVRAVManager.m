//
//  AVRAVManager.m
//  AuraViewer
//

#import "AVRAVManager.h"

@interface AVRAVManager ()

@property AVCaptureDevice *audioDevice;
@property AVCaptureDevice *videoDevice;
@property AVCaptureDeviceInput *audioDeviceInput;
@property AVCaptureDeviceInput *videoDeviceInput;
@property AVCaptureAudioDataOutput *audioOutput;
@property AVCaptureVideoDataOutput *videoOutput;
@property AVCaptureSession *session;

@end

@implementation AVRAVManager

+ (BOOL)isInitable
{
    BOOL hasAudio = NO;
    BOOL hasVideo = NO;
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if ([device hasMediaType:AVMediaTypeAudio]) {
            hasAudio = YES;
        }
        if ([device hasMediaType:AVMediaTypeVideo]) {
            hasVideo = YES;
        }
    }
    return (hasAudio && hasVideo);
}

- (id)init
{
    self = [super init];
    if (self && [AVRAVManager isInitable]) {
        _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // ignore errors
        NSError *audioError;
        NSError *videoError;
        _audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&audioError];
        _videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoError];
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
        [_audioOutput setSampleBufferDelegate:self queue:dispatch_queue_create("AudioQueue", DISPATCH_QUEUE_SERIAL)];
        if (
            audioError ||
            videoError ||
            !_audioDeviceInput ||
            !_videoDeviceInput
            ) {
            @throw @"This device does not have required media devices";
        }
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
        } else {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
        [_session beginConfiguration];
        if ([_session canAddInput:_audioDeviceInput]) {
            [_session addInput:_audioDeviceInput];
        }
        if ([_session canAddInput:_videoDeviceInput]) {
            [_session addInput:_videoDeviceInput];
        }
        if ([_session canAddOutput:_audioOutput]) {
            [_session addOutput:_audioOutput];
        }
        if ([_session canAddOutput:_videoOutput]) {
            [_session addOutput:_videoOutput];
        }
        [_session commitConfiguration];
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _overlayLayer = [AVRAuraLayer layer];
        [_previewLayer addSublayer:_overlayLayer];
    }
    return self;
}

- (void)startCapturing
{
    [_session startRunning];
}

- (void)stopCapturing
{
    [_session stopRunning];
}

#pragma mark -
#pragma AVCaptureVideoDataOutputSampleBufferDelegate

- (void)    captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection
{
    CMBlockBufferRef blockBuffer;
    AudioBufferList audioBufferList;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                            NULL,
                                                            &audioBufferList,
                                                            sizeof(audioBufferList),
                                                            NULL,
                                                            NULL,
                                                            0,
                                                            &blockBuffer);
    // AudioBufferList to wave signal array
    NSMutableArray *signals = [@[] mutableCopy];
    UInt32 frames, i, j;
    SInt16 *input;
    float signal = 0;
    for (i = 0; i <= (audioBufferList.mNumberBuffers - 1); ++i) {
        frames = audioBufferList.mBuffers[i].mDataByteSize / sizeof(SInt16);
        input = audioBufferList.mBuffers[i].mData;
        for (j = 0; j < frames; ++j) {
            signal = (float)input[j];
            [signals addObject:[NSNumber numberWithFloat:signal]];
        }
    }
    //NSLog(@"@%@", [signals description]);

    // audioChannels maybe contain only 1 channel
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([connection.audioChannels count] > 0) {
            AVCaptureAudioChannel *channel = connection.audioChannels[0];
            CGFloat v = channel.averagePowerLevel / 100.0f;
            if (v < 0) {
                v = v * -1;
            }
            //NSLog(@"%f", v);
            _overlayLayer.hsb = v;
        }
        _overlayLayer.plots = signals;
        [_overlayLayer setNeedsDisplay];
    });
}

@end
