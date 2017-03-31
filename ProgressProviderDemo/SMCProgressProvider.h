//
//  SMCProgressProvider.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMCProgressObserver;
@protocol SMCProgressSource;

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressProvider : NSObject

@property (nonatomic, readonly, getter=isActive) BOOL active;
@property (nonatomic, readonly) float progress;

+ (BOOL)isProgress:(float)progress1 equalToProgress:(float)progress2;

- (BOOL)addProgressObserver:(id<SMCProgressObserver>)observer;
- (BOOL)removeProgressObserver:(id<SMCProgressObserver>)observer;
- (BOOL)hasProgressObserver:(id<SMCProgressObserver>)observer;

- (BOOL)addProgressSource:(id<SMCProgressSource>)source;
- (BOOL)removeProgressSource:(id<SMCProgressSource>)source;
- (BOOL)hasProgressSource:(id<SMCProgressSource>)source;

@end

NS_ASSUME_NONNULL_END
