//
//  PZImagesDataSource.h
//  PhotoZoom
//
//  Created by Brennan Stehling on 5/7/13.
//  Copyright (c) 2013 SmallSharptools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZPhotosDataSource : NSObject

@property (readonly) NSUInteger count;

- (void)photoForIndex:(NSUInteger)index withCompletionBlock:(void (^)(UIImage *, NSError *))completionBlock ;
@end
