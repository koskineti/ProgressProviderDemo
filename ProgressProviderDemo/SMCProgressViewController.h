//
//  SMCDeviceSyncProgressViewController.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SMCProgressObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressViewController : UIViewController <SMCProgressObserver>

@property (nonatomic) float progress;

@end

NS_ASSUME_NONNULL_END

