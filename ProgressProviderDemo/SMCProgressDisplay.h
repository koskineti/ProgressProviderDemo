//
//  SMCProgressDisplay.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 20/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SMCProgressDisplay <NSObject>

@property (nonatomic) float progress;

@end

NS_ASSUME_NONNULL_END
