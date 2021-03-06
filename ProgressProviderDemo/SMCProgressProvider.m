//
//  SMCProgressProvider.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressProvider.h"

#import <QuartzCore/QuartzCore.h>

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
@property (nonatomic, readonly) NSMutableArray<id<SMCProgressSource>> *sources;

@property (nonatomic, readonly) NSUInteger activeSourceCount;

@property (nonatomic, readwrite) CFTimeInterval lastUpdateTime;

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

    if (self.sources.count > 0)
    {
        NSUInteger activeSources = 0;
        float activeSourceProgress = 0.0f;

        for (id<SMCProgressSource> source in self.sources)
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

    for (id<SMCProgressSource> source in self.sources)
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
        _sources = [NSMutableArray new];
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
    BOOL observerAdded = [self _addObject:observer toArray:self.observers];

    if (observerAdded && [observer respondsToSelector:@selector(progressProvider:didAddObserver:)])
    {
        [observer progressProvider:self didAddObserver:observer];
    }

    return observerAdded;
}

- (BOOL)removeProgressObserver:(id<SMCProgressObserver>)observer
{
    BOOL observerRemoved = [self _removeObject:observer fromArray:self.observers];

    if (observerRemoved && [observer respondsToSelector:@selector(progressProvider:didRemoveObserver:)])
    {
        [observer progressProvider:self didRemoveObserver:observer];
    }

    return observerRemoved;
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

+ (float)_clampProgress:(float)progress
{
    return fmaxf(0.0f, fminf(progress, 1.0f));
}

- (BOOL)_addObject:(id)object toArray:(id)array
{
    BOOL shouldAddObject = NO;

    if ([array respondsToSelector:@selector(containsObject:)] && [array respondsToSelector:@selector(addObject:)])
    {
        shouldAddObject = ![array containsObject:object];

        if (shouldAddObject)
        {
            [array addObject:object];
        }
    }

    return shouldAddObject;
}

- (BOOL)_removeObject:(id)object fromArray:(id)array
{
    BOOL shouldRemoveObject = NO;

    if ([array respondsToSelector:@selector(containsObject:)] && [array respondsToSelector:@selector(removeObject:)])
    {
        shouldRemoveObject = [array containsObject:object];

        if (shouldRemoveObject)
        {
            [array removeObject:object];
        }
    }

    return shouldRemoveObject;
}

- (void)_notifyObserversWithMethod:(SMCProgressNotificationMethod)method source:(id<SMCProgressSource>)source
{
    // We're firing off a notification for a progress update, store the current media time.
    // Observers that are removed and re-added while this progress provider is running
    // can use the last update time to resume their animations from the correct position
    // instead of always animating from 0 to the provider's current progress values.
    self.lastUpdateTime = CACurrentMediaTime();

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
