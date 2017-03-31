//
//  ViewController.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "ViewController.h"

#import "SMCMockProgressSource.h"
#import "SMCProgressObserver.h"
#import "SMCProgressProvider.h"
#import "SMCProgressSourceObserver.h"
#import "SMCProgressViewPresenter.h"

@interface ViewController () <SMCProgressObserver, SMCProgressSourceObserver>

@property (nonatomic, nullable) SMCProgressProvider *progressProvider;
@property (nonatomic, nullable) SMCMockProgressSource *progressSource1;
@property (nonatomic, nullable) SMCMockProgressSource *progressSource2;
@property (nonatomic, nullable) SMCProgressViewPresenter *progressViewPresenter;

@property (nonatomic, nullable) NSNumberFormatter *numberFormatter;

@property (weak, nonatomic) IBOutlet UILabel *progressProviderLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressSource1Label;
@property (weak, nonatomic) IBOutlet UILabel *progressSource2Label;

@property (weak, nonatomic) IBOutlet UIButton *startButton1;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton1;

@property (weak, nonatomic) IBOutlet UIButton *startButton2;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton2;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray<NSNumber *> *timeIntervals1 = @[ @(0.0f), @(5.0f), @(2.5f) ];
    NSArray<NSNumber *> *progressValues1 = @[ @(0.0f), @(0.5f), @(1.0f) ];

    NSArray<NSNumber *> *timeIntervals2 = @[ @(0.0f), @(15.0f), @(12.5f) ];
    NSArray<NSNumber *> *progressValues2 = @[ @(0.0f), @(0.5f), @(1.0f) ];

    self.progressProvider = [SMCProgressProvider new];
    self.progressSource1 = [SMCMockProgressSource sourceWithTimeIntervals:timeIntervals1 progressValues:progressValues1];
    self.progressSource2 = [SMCMockProgressSource sourceWithTimeIntervals:timeIntervals2 progressValues:progressValues2];
    self.progressViewPresenter = [[SMCProgressViewPresenter alloc] initWithProgressProvider:self.progressProvider];

    [self.progressProvider addProgressSource:self.progressSource1];
    [self.progressProvider addProgressSource:self.progressSource2];
    [self.progressProvider addProgressObserver:self];
    [self.progressViewPresenter addProgressViewControllerToParentViewController:self];

    self.numberFormatter = [NSNumberFormatter new];
    self.numberFormatter.locale = [NSLocale currentLocale];
    self.numberFormatter.minimumIntegerDigits = 1;
    self.numberFormatter.minimumFractionDigits = 3;
    self.numberFormatter.maximumFractionDigits = 3;

    self.progressProviderLabel.text = [self.numberFormatter stringFromNumber:@(0.0f)];
    self.progressSource1Label.text = [self.numberFormatter stringFromNumber:@(0.0f)];
    self.progressSource2Label.text = [self.numberFormatter stringFromNumber:@(0.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.progressViewPresenter.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.progressViewPresenter.preferredStatusBarUpdateAnimation;
}

#pragma mark - SMCProgressObserver

- (void)progressProvider:(SMCProgressProvider *)provider didUpdateProgress:(float)progress
{
    self.progressProviderLabel.text = [self.numberFormatter stringFromNumber:@(progress)];
}

- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider
{
    // Empty implementation.
}

- (void)progressProviderDidFinish:(SMCProgressProvider *)provider
{
    self.progressProviderLabel.text = [self.numberFormatter stringFromNumber:@(0.0f)];
}

- (void)progressProviderDidCancel:(SMCProgressProvider *)provider
{
    self.progressProviderLabel.text = [self.numberFormatter stringFromNumber:@(0.0f)];
}

#pragma mark - SMCProgressSourceObserver

- (void)progressSource:(id<SMCProgressSource>)source didUpdateProgress:(float)progress
{
    if (source == self.progressSource1)
    {
        self.progressSource1Label.text = [self.numberFormatter stringFromNumber:@(progress)];
    }
    else if (source == self.progressSource2)
    {
        self.progressSource2Label.text = [self.numberFormatter stringFromNumber:@(progress)];
    }
}

- (void)progressSourceDidBecomeActive:(id<SMCProgressSource>)source
{
    if (source == self.progressSource1)
    {
        self.startButton1.enabled = NO;
        self.cancelButton1.enabled = YES;
    }
    else if (source == self.progressSource2)
    {
        self.startButton2.enabled = NO;
        self.cancelButton2.enabled = YES;
    }
}

- (void)progressSourceDidFinish:(id<SMCProgressSource>)source
{
    [self _progressSourceDidFinishOrCancel:source];
}

- (void)progressSourceDidCancel:(id<SMCProgressSource>)source
{
    [self _progressSourceDidFinishOrCancel:source];
}

#pragma mark - Private

- (void)_progressSourceDidFinishOrCancel:(id<SMCProgressSource>)source
{
    if (source == self.progressSource1)
    {
        self.progressSource1Label.text = [self.numberFormatter stringFromNumber:@(0.0)];
        self.startButton1.enabled = YES;
        self.cancelButton1.enabled = NO;
    }
    else if (source == self.progressSource2)
    {
        self.progressSource2Label.text = [self.numberFormatter stringFromNumber:@(0.0)];
        self.startButton2.enabled = YES;
        self.cancelButton2.enabled = NO;
    }
}

#pragma mark - Actions

- (IBAction)_startProgressSource1:(UIButton *)sender
{
    [self.progressSource1 start];
}

- (IBAction)_cancelProgressSource1:(UIButton *)sender
{
    [self.progressSource1 cancel];
}

- (IBAction)_startProgressSource2:(UIButton *)sender
{
    [self.progressSource2 start];
}

- (IBAction)_cancelProgressSource2:(UIButton *)sender
{
    [self.progressSource2 cancel];
}

@end
