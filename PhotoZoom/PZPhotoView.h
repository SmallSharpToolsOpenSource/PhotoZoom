//
//  PZPhotoView.h
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZPhotoViewDelegate;

@interface PZPhotoView : UIScrollView

@property (assign, nonatomic) id<PZPhotoViewDelegate> photoViewDelegate;

- (void)prepareForReuse;
- (void)displayImage:(UIImage *)image;

- (void)startWaiting;
- (void)stopWaiting;

- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;

@end

@protocol PZPhotoViewDelegate <NSObject>

@optional

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView;
- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView;
- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView;

@end