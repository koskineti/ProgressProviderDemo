//
//  SMCProgressProvider.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressProvider.h"

#import "SMCProgressObserver.h"
#import "SMCProgressSource.h"
#import "SMCProgressSourceObserver.h"
#import "SMCZeroingWeakReferenceArray.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SMCProgressNotificationMethod)
{
    SMCProgressNotificationMethodNone              = 0,
    SMCProgressNotificationMethodDidUpdateProgress = 1,
    SMCProgressNotificationMethodDidBecomeActive   = 2,
    SMCProgressNotificationMethodDidFinish         = 3,
    SMCProgressNotificationMethodDidCancel         = 4
};

@interface SMCProgressProvider () <SMCProgressSourceObserver>

@property (nonatomic, readonly) SMCZeroingWeakReferenceArray *observers;
@property (nonatomic, readonly) SMCZeroingWeakReferenceArray *sources;

@property (nonatomic, readonly) NSUInteger activeSourceCount;

@end

@implementation SMCProgressProvider

#pragma mark - Properties

- (BOOL)isActive
{
    return (self.activeSourceCount > 0);
}

- (float)progress
{
    float progress = 0.0f;
    NSArray<id<SMCProgressSource>> *sources = self.sources.objects;

    if (sources.count > 0)
    {
        NSUInteger activeSources = 0;
        float activeSourceProgress = 0.0f;

        for (id<SMCProgressSource> source in sources)
        {
            if (source.isActive)
            {
                activeSources++;
                activeSourceProgress += source.progress;
            }
        }

        if (activeSources > 0)
        {
            // Take the average of the total progress of all active sources and
            // just to be safe, clamp the value to the range [0.0 .. 1.0].
            float averageActiveSourceProgress = (activeSourceProgress / (float)activeSources);
            float clampedActiveSourceProgress = [[self class] _clampProgress:averageActiveSourceProgress];

            progress = clampedActiveSourceProgress;
        }
    }

    return progress;
}

- (NSUInteger)activeSourceCount
{
    NSUInteger activeSourceCount = 0;
    NSArray<id<SMCProgressSource>> *sources = self.sources.objects;

    for (id<SMCProgressSource> source in sources)
    {
        if (source.isActive)
        {
            activeSourceCount++;
        }
    }

    return activeSourceCount;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];

    if (self != nil)
    {
        _observers = [SMCZeroingWeakReferenceArray new];
        _sources = [SMCZeroingWeakReferenceArray new];
    }

    return self;
}

#pragma mark - Public

+ (BOOL)isProgress:(float)progress1 equalToProgress:(float)progress2
{
    return (fabsf(progress1 - progress2) <= FLT_EPSILON);
}

#pragma mark - Public (Observers)

- (BOOL)addProgressObserver:(id<SMCProgressObserver>)observer
{
    return [self _addObject:observer toArray:self.observers];
}

- (BOOL)removeProgressObserver:(id<SMCProgressObserver>)observer
{
    return [self _removeObject:observer fromArray:self.observers];
}

- (BOOL)hasProgressObserver:(id<SMCProgressObserver>)observer
{
    return [self.observers containsObject:observer];
}

#pragma mark - Public (Sources)

- (BOOL)addProgressSource:(id<SMCProgressSource>)source
{
    BOOL sourceAdded = [self _addObject:source toArray:self.sources];

    if (sourceAdded)
    {
        [source progressSourceObserver:self didAddProgressSource:source];
    }

    return sourceAdded;
}

- (BOOL)removeProgressSource:(id<SMCProgressSource>)source
{
    BOOL sourceRemoved = [self _removeObject:source fromArray:self.sources];

    if (sourceRemoved)
    {
        [source progressSourceObserver:self didRemoveProgressSource:source];
    }

    return sourceRemoved;
}

- (BOOL)hasProgressSource:(id<SMCProgressSource>)source
{
    return [self.sources containsObject:source];
}

#pragma mark - Public (Source callbacks)

- (void)progressSource:(id<SMCProgressSource>)source didUpdateProgress:(float)progress
{
    [self _notifyObserversWithMethod:SMCProgressNotificationMethodDidUpdateProgress source:source];
}

- (void)progressSourceDidBecomeActive:(id<SMCProgressSource>)source
{
    [self _notifyObserversWithMethod:SMCProgressNotificationMethodDidBecomeActive source:source];
}

- (void)progressSourceDidFinish:(id<SMCProgressSource>)source
{
    [self _notifyObserversWithMethod:SMCProgressNotificationMethodDidFinish source:source];
}

- (void)progressSourceDidCancel:(id<SMCProgressSource>)source
{
    [self _notifyObserversWithMethod:SMCProgressNotificationMethodDidCancel source:source];
}

#pragma mark - Private

+ (BOOL)_isValidProgress:(float)progress
{
    BOOL isEqualToOrGreaterThanZero = fabs(0.0f - progress) <= FLT_EPSILON;
    BOOL isEqualToOrLessThanOne = fabs(1.0f - progress) <= FLT_EPSILON;

    return isEqualToOrGreaterThanZero && isEqualToOrLessThanOne;
}

+ (float)_clampProgress:(float)progress
{
    return fmax(0.0f, fmin(progress, 1.0f));
}

- (BOOL)_addObject:(id)object toArray:(SMCZeroingWeakReferenceArray *)array
{
    BOOL shouldAddObject = ![array containsObject:object];

    if (shouldAddObject)
    {
        [array addObject:object];
    }

    return shouldAddObject;
}

- (BOOL)_removeObject:(id)object fromArray:(SMCZeroingWeakReferenceArray *)array
{
    BOOL shouldRemoveObject = [array containsObject:object];

    if (shouldRemoveObject)
    {
        [array removeObject:object];
    }

    return shouldRemoveObject;
}

- (void)_notifyObserversWithMethod:(SMCProgressNotificationMethod)method source:(id<SMCProgressSource>)source
{
    NSArray *observers = self.observers.objects;

    for (id observer in observers)
    {
        if ([observer conformsToProtocol:@protocol(SMCProgressObserver)])
        {
            [self _notifyProgressObserver:observer method:method];
        }

        if ([observer conformsToProtocol:@protocol(SMCProgressSourceObserver)])
        {
            [self _notifyProgressSourceObserver:observer method:method source:source];
        }
    }
}

- (void)_notifyProgressObserver:(id<SMCProgressObserver>)observer method:(SMCProgressNotificationMethod)method
{
    switch ([self _mappedNotificationMethodForMethod:method])
    {
        case SMCProgressNotificationMethodDidUpdateProgress:
            [observer progressProvider:self didUpdateProgress:self.progress];
            break;
        case SMCProgressNotificationMethodDidBecomeActive:
            [observer progressProviderDidBecomeActive:self];
            break;
        case SMCProgressNotificationMethodDidFinish:
            [observer progressProviderDidFinish:self];
            break;
        case SMCProgressNotificationMethodDidCancel:
            [observer progressProviderDidCancel:self];
            break;
        default:
            break;
    }
}

- (void)_notifyProgressSourceObserver:(id<SMCProgressSourceObserver>)observer
                               method:(SMCProgressNotificationMethod)method
                               source:(id<SMCProgressSource>)source
{
    switch (method)
    {
        case SMCProgressNotificationMethodDidUpdateProgress:
            [observer progressSource:source didUpdateProgress:source.progress];
            break;
        case SMCProgressNotificationMethodDidBecomeActive:
            [observer progressSourceDidBecomeActive:source];
            break;
        case SMCProgressNotificationMethodDidFinish:
            [observer progressSourceDidFinish:source];
            break;
        case SMCProgressNotificationMethodDidCancel:
            [observer progressSourceDidCancel:source];
            break;
        default:
            break;
    }
}

- (SMCProgressNotificationMethod)_mappedNotificationMethodForMethod:(SMCProgressNotificationMethod)method
{
    SMCProgressNotificationMethod mappedMethod = method;

    if ((method == SMCProgressNotificationMethodDidBecomeActive) && (self.activeSourceCount > 1))
    {
        // A progress source became active, but it's not the first one. Do not send a provider-level notification.
        mappedMethod = SMCProgressNotificationMethodNone;
    }
    else if (((method == SMCProgressNotificationMethodDidFinish) || (method == SMCProgressNotificationMethodDidCancel)) && (self.activeSourceCount > 0))
    {
        // A progress source finished or was cancelled but there are other active sources.
        // This has an effect on the overall progress of the provider. Instead of sending a
        // finiahed/cancelled notification, send a provider-level progress update notification.
        mappedMethod = SMCProgressNotificationMethodDidUpdateProgress;
    }

    return mappedMethod;
}

@end

NS_ASSUME_NONNULL_END
