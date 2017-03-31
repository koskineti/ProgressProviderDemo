//
//  SMCProgressSource.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMCProgressProvider;

@protocol SMCProgressSourceObserver;

NS_ASSUME_NONNULL_BEGIN

@protocol SMCProgressSource <NSObject>

@property (nonatomic, readonly, getter=isActive) BOOL active;
@property (nonatomic, readonly) float progress;

- (void)progressSourceObserver:(id<SMCProgressSourceObserver>)observer didAddProgressSource:(id<SMCProgressSource>)source;
- (void)progressSourceObserver:(id<SMCProgressSourceObserver>)observer didRemoveProgressSource:(id<SMCProgressSource>)source;

@end

NS_ASSUME_NONNULL_END
