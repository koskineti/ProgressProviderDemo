//
//  SMCZeroingWeakReferenceArray.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMCZeroingWeakReferenceArray : NSObject

//! Contains all objects previously added to the receiver which are still alive.
@property (nonatomic, readonly) NSArray *objects;

/**
 @param object Adds the given object into the receiver. The object is not retained by the receiver.
 */
- (void)addObject:(id)object;

- (void)removeObject:(id)object;

- (BOOL)containsObject:(id)object;

@end

NS_ASSUME_NONNULL_END
