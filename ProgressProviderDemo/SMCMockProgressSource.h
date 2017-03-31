//
//  SMCMockProgressSource.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 24/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMCProgressSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCMockProgressSource : NSObject <SMCProgressSource>

+ (instancetype)sourceWithTimeIntervals:(NSArray<NSNumber *> *)timeIntervals progressValues:(NSArray<NSNumber *> *)progressValues;

- (instancetype)initWithTimeIntervals:(NSArray<NSNumber *> *)timeIntervals progressValues:(NSArray<NSNumber *> *)progressValues NS_DESIGNATED_INITIALIZER;

- (void)start;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
