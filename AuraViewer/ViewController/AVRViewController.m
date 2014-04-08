//
//  AVRViewController.m
//  AuraViewer
//

#import "AVRViewController.h"
#import "AVRAVManager.h"

@interface AVRViewController ()

@property AVRAVManager *avManager;

@end

@implementation AVRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![AVRAVManager isInitable]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"エラー")
                                    message:NSLocalizedString(@"This device dose not have required madia devices.", @"この端末はカメラとマイクが利用できません")
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil] show];
    } else {
        _avManager = [[AVRAVManager alloc] init];
        [_avManager.previewLayer setFrame:self.view.bounds];
        [_avManager.overlayLayer setFrame:_avManager.previewLayer.frame];
        [self.view.layer addSublayer:_avManager.previewLayer];
        [_avManager startCapturing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
