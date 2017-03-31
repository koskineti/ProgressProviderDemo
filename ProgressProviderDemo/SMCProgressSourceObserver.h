//
//  SMCProgressSourceObserver.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 28/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMCProgressSource;

@protocol SMCProgressSourceObserver <NSObject>

- (void)progressSource:(id<SMCProgressSource>)source didUpdateProgress:(float)progress;
- (void)progressSourceDidBecomeActive:(id<SMCProgressSource>)source;
- (void)progressSourceDidFinish:(id<SMCProgressSource>)source;
- (void)progressSourceDidCancel:(id<SMCProgressSource>)source;

@end
