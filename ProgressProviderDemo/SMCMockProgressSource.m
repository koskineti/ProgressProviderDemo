//
//  SMCMockProgressSource.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 24/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCMockProgressSource.h"

#import "SMCProgressSourceObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCMockProgressSource ()

@property (nonatomic, weak) id<SMCProgressSourceObserver> observer;

@property (nonatomic, nullable) NSTimer *timer;
@property (nonatomic, nullable) NSArray<NSNumber *> *timeIntervals;
@property (nonatomic, nullable) NSArray<NSNumber *> *progressValues;
@property (nonatomic) NSUInteger progressIndex;

@end

@implementation SMCMockProgressSource

#pragma mark - Properties

- (BOOL)isActive
{
    return (self.timer != nil);
}

- (float)progress
{
    if (self.isActive)
    {
        return [self.progressValues[self.progressIndex] floatValue];
    }
    else
    {
        return 0.0f;
    }
}

#pragma mark - Initialization

+ (instancetype)sourceWithTimeIntervals:(NSArray<NSNumber *> *)timeIntervals
                         progressValues:(NSArray<NSNumber *> *)progressValues
{
    return [[[self class] alloc] initWithTimeIntervals:timeIntervals progressValues:progressValues];
}

- (instancetype)initWithTimeIntervals:(NSArray<NSNumber *> *)timeIntervals
                       progressValues:(NSArray<NSNumber *> *)progressValues
{
    self = [super init];

    if (self != nil)
    {
        _timeIntervals = timeIntervals;
        _progressValues = progressValues;
        _progressIndex = 0;
    }
    
    return self;

}

- (instancetype)init
{
    NSArray<NSNumber *> *timeIntervals =  @[ @(0.0f), @(3.0f), @(3.0f) ];
    NSArray<NSNumber *> *progressValues = @[ @(0.0f), @(0.5f), @(1.0f) ];

    return [self initWithTimeIntervals:timeIntervals progressValues:progressValues];
}

#pragma mark - Public

- (void)start
{
    if (!self.isActive)
    {
        self.progressIndex = 0;

        [self _scheduleTimer];
        [self.observer progressSourceDidBecomeActive:self];
        [self.observer progressSource:self didUpdateProgress:self.progress];
    }
}

- (void)cancel
{
    if (self.isActive)
    {
        [self _invalidateTimer];
        [self.observer progressSourceDidCancel:self];
    }
}

#pragma mark - SMCProgressSource

- (void)progressSourceObserver:(id<SMCProgressSourceObserver>)observer didAddProgressSource:(id<SMCProgressSource>)source
{
    if (source == self)
    {
        self.observer = observer;
    }
}

- (void)progressSourceObserver:(id<SMCProgressSourceObserver>)observer didRemoveProgressSource:(id<SMCProgressSource>)source
{
    if (source == self)
    {
        self.observer = nil;
    }
}

#pragma mark - Private

- (void)_scheduleTimer
{
    if (self.progressIndex < self.timeIntervals.count)
    {
        NSTimeInterval timeInterval = [self.timeIntervals[self.progressIndex] floatValue];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                      target:self
                                                    selector:@selector(_updateProgressWithTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)_invalidateTimer
{
    if (self.timer != nil)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)_updateProgressWithTimer:(NSTimer *)timer
{
    self.progressIndex++;

    if (self.progressIndex < self.timeIntervals.count)
    {
        [self.observer progressSource:self didUpdateProgress:self.progress];
        [self _scheduleTimer];
    }
    else
    {
        [self _invalidateTimer];
        [self.observer progressSourceDidFinish:self];
    }
}

@end

NS_ASSUME_NONNULL_END
