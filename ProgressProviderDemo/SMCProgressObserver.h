//
//  SMCProgressObserver.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMCProgressProvider;

NS_ASSUME_NONNULL_BEGIN

@protocol SMCProgressObserver <NSObject>

- (void)progressProvider:(SMCProgressProvider *)provider didUpdateProgress:(float)progress;
- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider;
- (void)progressProviderDidFinish:(SMCProgressProvider *)provider;
- (void)progressProviderDidCancel:(SMCProgressProvider *)provider;

@end

NS_ASSUME_NONNULL_END
