//
//  AVRAuraLayer.m
//  AuraViewer
//

#import "AVRAuraLayer.h"

@implementation AVRAuraLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    int separate = [_plots count];
    CGContextBeginPath(ctx);
    for (int i = 0; i < separate; ++i) {
        CGContextMoveToPoint(ctx, center.x, center.y);
        NSNumber *plot = (NSNumber *)_plots[i];
        float x = [plot floatValue] * cos(i * (2 * M_PI) / separate);
        float y = [plot floatValue] * sin(i * (2 * M_PI) / separate);
        CGContextAddLineToPoint(ctx, x, y);
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithHue:_hsb saturation:_hsb brightness:1.0f alpha:1.0f].CGColor);
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

@end
