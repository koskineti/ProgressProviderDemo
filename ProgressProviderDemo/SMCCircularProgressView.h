//
//  SMCCircularProgressView.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SMCProgressDisplay.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface SMCCircularProgressView : UIView <SMCProgressDisplay>

@property (nonatomic, copy) IBInspectable UIColor *trackColor;
@property (nonatomic) IBInspectable CGFloat lineWidth;
@property (nonatomic) IBInspectable CGFloat angleOffset;

@end

NS_ASSUME_NONNULL_END
