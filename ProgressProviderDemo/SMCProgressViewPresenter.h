//
//  SMCProgressViewPresenter.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 31/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SMCProgressProvider;

@interface SMCProgressViewPresenter : NSObject

@property (nonatomic, readonly, getter=isPresented) BOOL presented;

- (instancetype)initWithProgressProvider:(SMCProgressProvider *)progressProvider NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)addProgressViewControllerToParentViewController:(UIViewController *)parentViewController;
- (void)presentAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

- (BOOL)prefersStatusBarHidden;
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;

@end

NS_ASSUME_NONNULL_END
