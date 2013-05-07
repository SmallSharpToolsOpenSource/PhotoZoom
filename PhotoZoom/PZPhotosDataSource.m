//
//  PZImagesDataSource.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 5/7/13.
//  Copyright (c) 2013 SmallSharptools LLC. All rights reserved.
//

#import "PZPhotosDataSource.h"

#import <CoreGraphics/CoreGraphics.h>

#pragma mark - Class Extension
#pragma mark -

@interface PZPhotosDataSource ()

@property (readonly) NSArray *photos;

@end

@implementation PZPhotosDataSource

- (NSArray *)photos {
    return @[[self image1], [self image2], [self image3], [self image4]];
}

- (NSUInteger)count {
    return self.photos.count;
}

- (void)photoForIndex:(NSUInteger)index withCompletionBlock:(void (^)(UIImage *, NSError *))completionBlock {
    // prevent a range exception
    if (self.count == 0 || index > self.count - 1) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : @"Index is out of range."};
        NSError *error = [[NSError alloc] initWithDomain:@"Photos" code:100 userInfo:userInfo];
        completionBlock(nil, error);
    }
    
    // simulate a delay for downloading a photo
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completionBlock) {
            UIImage *photo = self.photos[index];
            completionBlock(photo, nil);
        }
    });
}

#pragma mark - Images
#pragma mark -

- (UIImage *)image1 {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(800, 600), NO, 0.0f);
        
        
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed: 0 green: 0 blue: 0.886 alpha: 1];
        UIColor* color = [UIColor colorWithRed: 0.114 green: 0.41 blue: 1 alpha: 1];
        
        //// Gradient Declarations
        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)color.CGColor,
                                   (id)fillColor.CGColor, nil];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        
        //// Abstracted Attributes
        NSString* bottomContent = @"Bottom";
        NSString* labelContent = @"1";
        NSString* topContent = @"Top";
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 800, 600)];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(400, 0), CGPointMake(400, 600), 0);
        CGContextRestoreGState(context);
        
        
        //// Bottom Drawing
        CGRect bottomRect = CGRectMake(0, 566, 800, 34);
        [[UIColor whiteColor] setFill];
        [bottomContent drawInRect: bottomRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Label Drawing
        CGRect labelRect = CGRectMake(0, 250, 800, 100);
        [[UIColor whiteColor] setFill];
        [labelContent drawInRect: labelRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 72] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Top Drawing
        CGRect topRect = CGRectMake(0, 0, 800, 34);
        [[UIColor whiteColor] setFill];
        [topContent drawInRect: topRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)image2 {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1200, 900), NO, 0.0f);
        
        
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0.219 alpha: 1];
        UIColor* color2 = [UIColor colorWithRed: 0.295 green: 0.886 blue: 0 alpha: 1];
        
        //// Gradient Declarations
        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)color2.CGColor,
                                   (id)fillColor.CGColor, nil];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        
        //// Abstracted Attributes
        NSString* bottomContent = @"Bottom";
        NSString* labelContent = @"2";
        NSString* topContent = @"Top";
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 1200, 900)];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(600, 0), CGPointMake(600, 900), 0);
        CGContextRestoreGState(context);
        
        
        //// Bottom Drawing
        CGRect bottomRect = CGRectMake(0, 866, 1200, 34);
        [[UIColor whiteColor] setFill];
        [bottomContent drawInRect: bottomRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Label Drawing
        CGRect labelRect = CGRectMake(0, 400, 1200, 100);
        [[UIColor whiteColor] setFill];
        [labelContent drawInRect: labelRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 72] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Top Drawing
        CGRect topRect = CGRectMake(0, 0, 1200, 34);
        [[UIColor whiteColor] setFill];
        [topContent drawInRect: topRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)image3 {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000, 1000), NO, 0.0f);
        
        
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* color2 = [UIColor colorWithRed: 0.657 green: 0 blue: 0.657 alpha: 1];
        UIColor* color3 = [UIColor colorWithRed: 0.657 green: 0 blue: 0.219 alpha: 1];
        
        //// Gradient Declarations
        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)color2.CGColor,
                                   (id)color3.CGColor, nil];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        
        //// Abstracted Attributes
        NSString* bottomContent = @"Bottom";
        NSString* labelContent = @"3";
        NSString* topContent = @"Top";
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 1000, 1000)];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(500, 0), CGPointMake(500, 1000), 0);
        CGContextRestoreGState(context);
        
        
        //// Bottom Drawing
        CGRect bottomRect = CGRectMake(0, 966, 1000, 34);
        [[UIColor whiteColor] setFill];
        [bottomContent drawInRect: bottomRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Label Drawing
        CGRect labelRect = CGRectMake(0, 450, 1000, 100);
        [[UIColor whiteColor] setFill];
        [labelContent drawInRect: labelRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 72] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Top Drawing
        CGRect topRect = CGRectMake(0, 0, 1000, 34);
        [[UIColor whiteColor] setFill];
        [topContent drawInRect: topRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)image4 {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000, 2000), NO, 0.0f);
        
        
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed: 0.114 green: 0.114 blue: 1 alpha: 1];
        UIColor* color2 = [UIColor colorWithRed: 0 green: 0 blue: 0.657 alpha: 1];
        
        //// Gradient Declarations
        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)color2.CGColor,
                                   (id)fillColor.CGColor, nil];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        
        //// Abstracted Attributes
        NSString* bottomContent = @"Bottom";
        NSString* labelContent = @"4";
        NSString* topContent = @"Top";
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 1000, 2000)];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient, CGPointMake(500, 0), CGPointMake(500, 2000), 0);
        CGContextRestoreGState(context);
        
        
        //// Bottom Drawing
        CGRect bottomRect = CGRectMake(0, 1966, 1000, 34);
        [[UIColor whiteColor] setFill];
        [bottomContent drawInRect: bottomRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Label Drawing
        CGRect labelRect = CGRectMake(0, 950, 1000, 100);
        [[UIColor whiteColor] setFill];
        [labelContent drawInRect: labelRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 72] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Top Drawing
        CGRect topRect = CGRectMake(0, 0, 1000, 34);
        [[UIColor whiteColor] setFill];
        [topContent drawInRect: topRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 24] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

@end
