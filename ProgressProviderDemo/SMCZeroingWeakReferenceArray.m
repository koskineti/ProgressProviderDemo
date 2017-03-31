//
//  SMCZeroingWeakReferenceArray.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCZeroingWeakReferenceArray.h"

@interface SMCZeroingWeakReferenceArray()
@property (nonatomic, strong) NSMutableArray *blocks;
@end

@implementation SMCZeroingWeakReferenceArray

#pragma mark - Public

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.blocks = [NSMutableArray array];
    }
    
    return self;
}

- (NSArray *)objects
{
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *goneBlocks = [NSMutableArray array];
    
    for (id(^block)() in self.blocks)
    {
        id object = block();
        
        if (object != nil)
        {
            [objects addObject:object];
        }
        else
        {
            [goneBlocks addObject:block];
        }
    }
    
    [self.blocks removeObjectsInArray:goneBlocks];
    
    return objects;
}

- (void)addObject:(id)object
{
    __weak id objectWeakReference = object;
    id (^block)() = ^{ return objectWeakReference; };
    
    [self.blocks addObject:[block copy]];
}

- (void)removeObject:(id)object
{
    id (^goneBlock)() = NULL;

    for (id(^block)() in self.blocks)
    {
        if (block() == object)
        {
            goneBlock = block;
            break;
        }
    }

    if (goneBlock != NULL)
    {
        [self.blocks removeObject:goneBlock];
    }
}

- (BOOL)containsObject:(id)object
{
    BOOL containsObject = NO;

    for (id(^block)() in self.blocks)
    {
        if (block() == object)
        {
            containsObject = YES;
            break;
        }
    }

    return containsObject;
}

@end
