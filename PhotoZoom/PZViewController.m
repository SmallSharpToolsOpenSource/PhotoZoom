//
//  PZViewController.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZViewController.h"

#import <CoreGraphics/CoreGraphics.h>

#import "PZPhotoView.h"
#import "PZPhotosDataSource.h"

@interface PZViewController () <PZPhotoViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (readonly) NSArray *customToolbarItems;

@property (strong, nonatomic) PZPhotosDataSource *photosDataSource;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *screenView;
@property (weak, nonatomic) IBOutlet UIImageView *rotationImageView;

@end

@implementation PZViewController {
    BOOL _isFullScreen;
    NSIndexPath *_currentIndexPath;
    CGFloat _currentZoomScale;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photosDataSource = [[PZPhotosDataSource alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.toolbar.translucent = TRUE;
    self.navigationController.toolbar.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.translucent = TRUE;
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [self setToolbarItems:self.customToolbarItems animated:FALSE];

    self.navigationController.navigationBar.hidden = FALSE;
    self.navigationController.toolbar.hidden = FALSE;
    [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // resetDisplay will set the content size and position the frames (not ideal to do it this way)
}

- (BOOL)prefersStatusBarHidden {
    return _isFullScreen;
}

#pragma mark - User Actions
#pragma mark -

- (NSArray *)customToolbarItems {
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                   action:nil];
    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                  action:nil];
    UIBarButtonItem *flexItem3 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                  target:self
                                  action:nil];
    UIBarButtonItem *flexItem4 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                  target:self
                                  action:nil];
    
    UIBarButtonItem *maximumButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Maximum"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                   action:@selector(showMaximumSize:)];
    
    UIBarButtonItem *mediumButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Medium"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(showMediumSize:)];
    
    UIBarButtonItem *minimumButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Minimum"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                  action:@selector(showMinimumSize:)];
    
    return @[flexItem1, maximumButton, flexItem2, mediumButton, flexItem3, minimumButton, flexItem4];
}

- (PZPhotoView *)visiblePhotoView {
    NSArray *visibleCells = [self.collectionView visibleCells];
    
    if (visibleCells.count) {
        UIView *cell = visibleCells[0];
        UIView *view = [cell viewWithTag:1];
        if ([view isKindOfClass:[PZPhotoView class]]) {
            return (PZPhotoView *)view;
        }
    }
    
    return nil;
}

- (void)showMaximumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    [photoView updateZoomScale:photoView.maximumZoomScale];
}

- (void)showMediumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    CGFloat newScale = (photoView.minimumZoomScale + photoView.maximumZoomScale) / 2.0;
    [photoView updateZoomScale:newScale];
}

- (void)showMinimumSize:(id)sender {
    PZPhotoView *photoView = [self visiblePhotoView];
    [photoView updateZoomScale:photoView.minimumZoomScale];
}

- (IBAction)takeScreenshot:(id)sender {
    self.rotationImageView.image = [self screenshotOfCurrentItem];
    self.rotationImageView.hidden = FALSE;
    self.rotationImageView.alpha = 1.0f;
    self.screenView.hidden = FALSE;
    self.screenView.alpha = 1.0f;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.screenView.hidden = TRUE;
        self.rotationImageView.hidden = TRUE;
    });
}

- (void)toggleFullScreen {

    DebugLog(@"toggling full screen");
    
    _isFullScreen = !_isFullScreen;
    
    if (!_isFullScreen) {
        // fade in navigation
        
        DebugLog(@"fading in");
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 1.0;
            self.navigationController.toolbar.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        // fade out navigation
        
        DebugLog(@"fading out");
        
        [UIView animateWithDuration:0.4 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = 0.0;
            self.navigationController.toolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    DebugLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    DebugLog(@"### PZViewController ###");
    [self logRect:self.view.window.bounds withName:@"self.view.window.bounds"];
    [self logRect:self.view.window.frame withName:@"self.view.window.frame"];

    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    [self logRect:applicationFrame withName:@"application frame"];
}

#pragma mark - Orientation
#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // ensure the item is dislayed after rotation
    _currentIndexPath = [self indexPathForCurrentItem];
    
    self.rotationImageView.image = [self screenshotOfCurrentItem];
    self.rotationImageView.alpha = 1.0f;
    self.rotationImageView.hidden = FALSE;
    self.screenView.hidden = FALSE;
    self.screenView.alpha = 1.0f;
}

// changes in this method will be included with view controller's animation block
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (_currentIndexPath) {
            DebugLog(@"item: %li", (long)_currentIndexPath.item);
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView scrollToItemAtIndexPath:_currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:FALSE];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.screenView.hidden = TRUE;

                UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
                [UIView animateWithDuration:0.5 delay:0.0 options:options animations:^{
                    self.rotationImageView.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    self.rotationImageView.hidden = TRUE;
                }];
            });
        }
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return TRUE;
}

#pragma mark - PZPhotoViewDelegate
#pragma mark -

- (void)photoViewDidSingleTap:(PZPhotoView *)photoView {
    [self toggleFullScreen];
}

- (void)photoViewDidDoubleTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidTwoFingerTap:(PZPhotoView *)photoView {
    // do nothing
}

- (void)photoViewDidDoubleTwoFingerTap:(PZPhotoView *)photoView {
    [self logLayout];
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoView" forIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:1];
    if ([view isKindOfClass:[PZPhotoView class]]) {
        PZPhotoView *photoView = (PZPhotoView *)view;
        
        [photoView prepareForReuse];
        
        [photoView startWaiting];
        [self.photosDataSource photoForIndex:indexPath.item withCompletionBlock:^(UIImage *photo, NSError *error) {
            [photoView stopWaiting];
            if (error != nil) {
                DebugLog(@"Error: %@", error);
            }
            else {
                photoView.alpha = 0.0f;
                [photoView displayImage:photo];
                [UIView animateWithDuration:0.35f animations:^{
                    photoView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                }];
            }
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
}

#pragma mark - Private
#pragma mark -

- (UIImage *)screenshotOfCurrentItem {
    if (!floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        NSCAssert(FALSE, @"iOS 7 or later is required.");
    }

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[self indexPathForCurrentItem]];
    
    LOG_FRAME(@"collectionView", self.collectionView.frame);
    LOG_FRAME(@"cell", cell.frame);
    
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0.0);
    [cell drawViewHierarchyInRect:cell.bounds afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}

- (NSIndexPath *)indexPathForCurrentItem {
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if (indexPaths.count) {
        return indexPaths[0];
    }
    
    return nil;
}

@end
