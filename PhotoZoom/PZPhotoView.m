//
//  PZPhotoView.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZPhotoView.h"

#define kZoomStep 1.5

@interface PZPhotoView () <UIScrollViewDelegate>

//@property (weak, nonatomic) UIScrollView *imageScrollView;
@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation PZPhotoView {
    CGPoint  _pointToCenterAfterResize;
    CGFloat  _scaleToRestoreAfterResize;
    BOOL _isObservingOrientationChanges;
}

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews {
    DebugLog(@"layoutSubviews");
    [super layoutSubviews];

    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;

    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    self.imageView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame {
    DebugLog(@"setFrame");
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

//- (void)setContentSize:(CGSize)size {
//    DebugLog(@"setContentSize: %f, %f", size.width, size.height);
//    [super setContentSize:size];
//}

//- (void)setContentOffset:(CGPoint)offset {
//    CGPoint maxContentOffset = [self maximumContentOffset];
//    DebugLog(@"setContentOffset: %f, %f : %f, %f", offset.x, offset.y, maxContentOffset.x, maxContentOffset.y);
//    [super setContentOffset:offset];
//}

#pragma mark - Public Implementation
#pragma mark -

- (void)displayImage:(UIImage *)image {
    // start by dropping any views and resetting the key properties
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.delegate = self;
    self.imageView = nil;
    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
//    scrollView.delegate = self;
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self addSubview:scrollView];
//    self.imageScrollView = scrollView;
    
    self.bouncesZoom = TRUE;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = TRUE;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    
    [self setMaxMinZoomScalesForCurrentBounds:FALSE];
    
    if (!_isObservingOrientationChanges) {
        _isObservingOrientationChanges = TRUE;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

#pragma mark - Gestures
#pragma mark -

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
    [self logLayout];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    CGFloat newScale = MIN([self zoomScale] * kZoomStep, self.maximumZoomScale);
    
    if (self.zoomScale != newScale)
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
    
    if (self.zoomScale != newScale)
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
}

#pragma mark - Orientation
#pragma mark -

- (void)orientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        DebugLog(@"Landscape");
//        [self setNeedsLayout];
//        [self setNeedsDisplay];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
        DebugLog(@"Portrait");
//        [self setNeedsLayout];
//        [self setNeedsDisplay];
    }
}

#pragma mark - Support Methods
#pragma mark -

- (void)updateZoomScaleWithGesture:(UIGestureRecognizer *)gestureRecognizer newScale:(CGFloat)newScale {
    assert(newScale >= self.minimumZoomScale);
    assert(newScale <= self.maximumZoomScale);
    
    CGPoint center = [gestureRecognizer locationInView:gestureRecognizer.view];
    DebugLog(@"center: %f, %f, %f", newScale, center.x, center.y);
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:center];
    DebugLog(@"zoomRect: %f, %f : %f, %f", zoomRect.origin.x, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height);
    DebugLog(@"Image: %f/%f, %f/%f", self.imageView.frame.size.width, self.imageView.frame.size.width * self.zoomScale,
             self.imageView.frame.size.height, self.imageView.frame.size.height * self.zoomScale);
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    DebugLog(@"zoomRectForScale: %f", scale);
    
    assert(scale >= self.minimumZoomScale);
    assert(scale <= self.maximumZoomScale);
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    BOOL isPortait = UIDeviceOrientationIsPortrait(deviceOrientation);
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    if (isPortait) {
        zoomRect.size.width  = self.frame.size.width  / scale;
        zoomRect.size.height = self.frame.size.height / scale;
    }
    else {
        zoomRect.size.width  = self.frame.size.height  / scale;
        zoomRect.size.height = self.frame.size.width / scale;
    }
    
    // choose an origin so as to get the right center.
    if (scale == self.minimumZoomScale) {
        DebugLog(@"min zoom scale");
        CGSize boundsSize = self.bounds.size;
        
        // center the zoom view as it becomes smaller than the size of the screen

        // center horizontally
        if ((zoomRect.size.width * scale) < boundsSize.width)
            zoomRect.origin.x = (boundsSize.width - zoomRect.size.width) / 2;
        else
            zoomRect.origin.x = 0;
        
        // center vertically
        if ((zoomRect.size.height * scale) < boundsSize.height)
            zoomRect.origin.y = (boundsSize.height - zoomRect.size.height) / 2;
        else
            zoomRect.origin.y = 0;
    }
    else {
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    }
    
    return zoomRect;
}

- (void)setMaxMinZoomScalesForCurrentBounds:(BOOL)animated {
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    //    float minimumScale = [self.imageScrollView frame].size.width  / self.imageView.frame.size.width;
    //    [self.imageScrollView setMinimumZoomScale:minimumScale];
    //    [self.imageScrollView setZoomScale:minimumScale];
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.frame.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = imageSize.height > imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
//    self.imageScrollView.zoomScale = minScale;
    [self setZoomScale:minScale animated:animated];
}

- (void)prepareToResize {
    DebugLog(@"prepareToResize");
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.imageView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing {
    DebugLog(@"recoverFromResizing");
    [self setMaxMinZoomScalesForCurrentBounds:FALSE];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:self.imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

- (void)logLayout {
    DebugLog(@"Bounds: %f, %f : %f, %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    DebugLog(@"Frame: %f, %f : %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    DebugLog(@"Image: %f/%f, %f/%f", self.imageView.frame.size.width, self.imageView.frame.size.width * self.zoomScale,
             self.imageView.frame.size.height, self.imageView.frame.size.height * self.zoomScale);
    DebugLog(@"Scale: %f : %f, %f", self.zoomScale, self.minimumZoomScale, self.maximumZoomScale);
    DebugLog(@"Scroll View: %f, %f : %f, %f",
             self.frame.origin.x, self.frame.origin.y,
             self.frame.size.width, self.frame.size.height);
    DebugLog(@"Content Size: %f, %f", self.contentSize.width, self.contentSize.height);
    DebugLog(@"Content Offset: %f, %f", self.contentOffset.x, self.contentOffset.y);
    
    DebugLog(@"Image View: %f, %f : %f, %f",
             self.imageView.frame.origin.x, self.imageView.frame.origin.y,
             self.imageView.frame.size.width, self.imageView.frame.size.height);
}

#pragma mark - UIScrollViewDelegate Methods
#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

/*
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//}
*/

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [self logLayout];
}

@end
