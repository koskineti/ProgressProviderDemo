//
//  SMCProgressViewPresenter.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 31/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressViewPresenter.h"

#import "SMCProgressProvider.h"
#import "SMCProgressViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressViewPresenter () <SMCProgressObserver>

@property (nonatomic, readwrite, getter=isPresented) BOOL presented;

@property (nonatomic) SMCProgressProvider *progressProvider;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, weak) SMCProgressViewController *progressViewController;

@end

@implementation SMCProgressViewPresenter

#pragma mark - Properties

- (BOOL)isPresentable
{
    return ((self.parentViewController != nil) && (self.progressViewController != nil));
}

#pragma mark - Initialization

- (instancetype)initWithProgressProvider:(SMCProgressProvider *)progressProvider
{
    self = [super init];

    if (self != nil)
    {
        _presented = NO;
        _progressProvider = progressProvider;

        [progressProvider addProgressObserver:self];
    }

    return self;
}

#pragma mark - Public

- (void)addProgressViewControllerToParentViewController:(UIViewController *)parentViewController
{
    SMCProgressViewController *progressViewController = [[SMCProgressViewController alloc] initWithNibName:nil bundle:nil];

    [self _addProgressViewController:progressViewController toParentViewController:parentViewController];
    [self _addLayoutConstraintsForProgressViewController:progressViewController parentViewController:parentViewController];

    [self.progressProvider addProgressObserver:progressViewController];

    self.parentViewController = parentViewController;
    self.progressViewController = progressViewController;
    self.progressViewController.view.alpha = 0.0;
}

- (void)_addProgressViewController:(UIViewController *)progressViewController toParentViewController:(UIViewController *)parentViewController
{
    [parentViewController addChildViewController:progressViewController];
    [parentViewController.view addSubview:progressViewController.view];
    [progressViewController didMoveToParentViewController:parentViewController];
}

- (void)_addLayoutConstraintsForProgressViewController:(UIViewController *)progressViewController parentViewController:(UIViewController *)parentViewController
{
    UIView *view = progressViewController.view;
    UIView *superview = parentViewController.view;

    view.translatesAutoresizingMaskIntoConstraints = NO;

    // Anchor the progress view controller's view to the leading, trailing, and top edges
    // of the parent view controller's view. Note that the height of the progress view is
    // identical to the height of the parent view controller's status bar, but it's not
    // set here.

    // The size of the status is not known until after the first layout pass, i.e.,
    // if `-viewDidLayoutSubviews` has not been called, the `length` property of a view
    // controller's `topLayoutGuide` is zero. Because of this, the height constraint is
    // added to the progress view in `-[SMCProgressViewController viewDidLayoutSubviews]`.

    [NSLayoutConstraint activateConstraints:@[
                                              [superview.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
                                              [superview.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
                                              [superview.topAnchor constraintEqualToAnchor:view.topAnchor]
                                              ]];
}


- (void)presentAnimated:(BOOL)animated
{
    if (self.isPresentable && !self.presented)
    {
        self.presented = YES;

        if (animated)
        {
            [UIView animateWithDuration:0.25f delay:0.1f options:0 animations:^{
                self.progressViewController.view.alpha = 1.0f;
            } completion:NULL];

            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.parentViewController setNeedsStatusBarAppearanceUpdate];
            } completion:NULL];
        }
        else
        {
            self.progressViewController.view.alpha = 1.0f;
            [self.parentViewController setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (self.isPresentable && self.presented)
    {
        self.presented = NO;

        if (animated)
        {
            [UIView animateWithDuration:0.25f delay:1.0f options:0 animations:^{
                self.progressViewController.view.alpha = 0.0f;
            } completion:NULL];

            [UIView animateWithDuration:0.25f delay:1.1f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.parentViewController setNeedsStatusBarAppearanceUpdate];
            } completion:NULL];
        }
        else
        {
            self.progressViewController.view.alpha = 0.0f;
            [self.parentViewController setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)presentIfNeededAnimated:(BOOL)animated
{
    if (self.progressProvider.isActive)
    {
        [self presentAnimated:animated];
    }
}

- (void)dismissIfNeededAnimated:(BOOL)animated
{
    if (!self.progressProvider.isActive)
    {
        [self dismissAnimated:animated];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return self.isPresented;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - SMCProgressObserver

- (void)progressProvider:(SMCProgressProvider *)provider didUpdateProgress:(float)progress
{
    // Empty implementation.
}

- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider
{
    [self presentAnimated:YES];
}

- (void)progressProviderDidFinish:(SMCProgressProvider *)provider
{
    [self dismissAnimated:YES];
}

- (void)progressProviderDidCancel:(SMCProgressProvider *)provider
{
    [self dismissAnimated:YES];
}

@end

NS_ASSUME_NONNULL_END
