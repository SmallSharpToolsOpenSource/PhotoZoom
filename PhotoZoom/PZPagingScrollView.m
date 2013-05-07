//
//  PZPagingScrollView.m
//  PhotoZoom
//
//  Created by Brennan Stehling on 11/9/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import "PZPagingScrollView.h"

#pragma mark -  Class Extension
#pragma mark -

@interface PZPagingScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableSet *recycledPages;
@property (strong, nonatomic) NSMutableSet *visiblePages;

@end

@implementation PZPagingScrollView {
    NSUInteger _currentPagingIndex;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView {
    self.pagingEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    // it is very important to auto resize
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.recycledPages = [[NSMutableSet alloc] init];
    self.visiblePages  = [[NSMutableSet alloc] init];
}

- (void)didReceiveMemoryWarning {
    [self didReceiveMemoryWarning];
    
    @synchronized (self) {
        // in case views start to pile up, make it possible to clear them out when memory gets low
        if (self.recycledPages.count > 3) {
            [self.recycledPages removeAllObjects];
        }
    }
}

#pragma mark - Calculations for Size and Positioning
#pragma mark -

#define PADDING  4

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect pageFrame = self.bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (self.bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    NSAssert(self.pagingViewDelegate != nil, @"Invalid State");
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    
    return CGSizeMake(self.bounds.size.width * count, self.bounds.size.height);
}

- (CGPoint)scrollPositionForIndex:(NSUInteger)index {
    CGFloat x = self.bounds.size.width * index;
    return CGPointMake(x, 0);
}

- (NSUInteger)currentPagingIndex {
    NSUInteger index = (NSUInteger)(ceil(self.contentOffset.x / self.bounds.size.width));
    return index;
}

- (void)configurePage:(UIView *)page forIndex:(NSUInteger)index {
    NSAssert(self.pagingViewDelegate != nil, @"Invalid State");
    
    if (self.pagingViewDelegate != nil) {
        [self.pagingViewDelegate pagingScrollView:self preparePageViewForDisplay:page forIndex:index];
    }
    
    page.frame = [self frameForPageAtIndex:index];
    page.tag = index;
}

- (void)tilePages {
    if (self.suspendTiling) {
        // tiling during rotation causes odd behavior so it is best to suspend it
        return;
    }
    
    NSAssert(self.pagingViewDelegate != nil, @"Invalid State");
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    
    // Calculate which pages are visible
    CGRect visibleBounds = self.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, count - 1);
    
    // Recycle no-longer-visible pages
    for (UIView *page in self.visiblePages) {
        NSUInteger index = page.tag;
        if (index < firstNeededPageIndex || index > lastNeededPageIndex) {
            [self.recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            UIView *page = [self dequeueRecycledPage:index];
            [self configurePage:page forIndex:index];
            [self addSubview:page];
            [self.visiblePages addObject:page];
        }
    }
}

#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    DebugLog(@"%@: %f, %f / %f, %f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
    DebugLog(@"#### PZPagingScrollView ###");
    
    [self logRect:self.bounds withName:@"self.bounds"];
    [self logRect:self.frame withName:@"self.frame"];
    
    DebugLog(@"contentSize: %f, %f", self.contentSize.width, self.contentSize.height);
    DebugLog(@"contentOffset: %f, %f", self.contentOffset.x, self.contentOffset.y);
    DebugLog(@"contentInset: %f, %f, %f, %f", self.contentInset.top, self.contentInset.right, self.contentInset.bottom, self.contentInset.left);
    
    if ([self.visiblePageView respondsToSelector:@selector(logLayout)]) {
        [self.visiblePageView performSelector:@selector(logLayout)];
    }
}

#pragma mark - Reuse Queue
#pragma mark -

- (UIView *)dequeueRecycledPage:(NSUInteger)index {
    UIView *page = nil;
    
    NSAssert(self.pagingViewDelegate != nil, @"Invalid State");
    
    if (self.pagingViewDelegate != nil) {
        for (UIView *recycledPage in self.recycledPages) {
            if ([recycledPage isKindOfClass:[self.pagingViewDelegate pagingScrollView:self classForIndex:index]]) {
                page = recycledPage;
                break;
            }
        }
        if (page != nil) {
            if ([page respondsToSelector:@selector(prepareForReuse)]) {
                [page performSelector:@selector(prepareForReuse)];
            }
            [self.recycledPages removeObject:page];
        }
        else {
            page = [self.pagingViewDelegate pagingScrollView:self pageViewForIndex:index];
        }
    }
    
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (UIView *page in self.visiblePages) {
        NSUInteger pageIndex = page.tag;
        if (pageIndex == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

#pragma mark - Public Implementation
#pragma mark -

- (UIView *)visiblePageView {
    NSUInteger index = [self currentPagingIndex];
    for (UIView *pageView in self.visiblePages) {
        NSUInteger pageIndex = pageView.tag;
        if (pageIndex == index) {
            return pageView;
        }
    }
    
    return nil;
}

- (void)displayPagingViewAtIndex:(NSUInteger)index {
    NSAssert([self conformsToProtocol:@protocol(UIScrollViewDelegate)], @"Invalid State");
    NSAssert(self.delegate == self, @"Invalid State");
    NSAssert(self.pagingViewDelegate != nil, @"Invalid State");
    
    _currentPagingIndex = index;
    
    self.contentSize = [self contentSizeForPagingScrollView];
    [self setContentOffset:[self scrollPositionForIndex:index] animated:FALSE];
    
    [self tilePages];
}

- (void)resetDisplay {
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    NSAssert(_currentPagingIndex < count, @"Invalid State");
    
    self.contentSize = [self contentSizeForPagingScrollView];
    [self setContentOffset:[self scrollPositionForIndex:_currentPagingIndex] animated:FALSE];
    
    for (UIView *pageView in self.visiblePages) {
        NSUInteger index = pageView.tag;
        pageView.frame = [self frameForPageAtIndex:index];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self tilePages];
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPagingIndex = [self currentPagingIndex];
}

@end
