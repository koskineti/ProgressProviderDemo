//
//  SMCCircularProgressViewController.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SMCProgressObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCCircularProgressViewController : UIViewController <SMCProgressObserver>

@property (nonatomic, readonly, getter=isPresented) BOOL presented;
@property (nonatomic) float progress;

@end

NS_ASSUME_NONNULL_END
