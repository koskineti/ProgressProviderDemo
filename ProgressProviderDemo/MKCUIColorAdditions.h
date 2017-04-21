//
//  MKCUIColorAdditions.h
//  MKCKit
//
//  Created by Juri Pakaste on 25.11.11.
//  Copyright 2011 Marko Karppinen & Co. LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// static const MKCUIColorStruct kExampleColor = { .red = 229.0/255f, .green = 0, .blue = 156.0/255f, .alpha = 1 };

typedef struct {
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
} RichieUIColorStruct;


@interface UIColor (RichieUIColorAdditions)

-(instancetype)richie_initWithMKCUIColorStruct:(RichieUIColorStruct)cs;
+(UIColor*)richie_colorWithMKCUIColorStruct:(RichieUIColorStruct)cs;

// initWithRGB:0xffaa9b etc
-(instancetype)richie_initWithRGB:(NSUInteger)rgb;
-(instancetype)richie_initWithRGBA:(NSUInteger)rgba;
+(instancetype)richie_colorWithRGB:(NSUInteger)rgb;
+(instancetype)richie_colorWithRGBA:(NSUInteger)rgba;
+(instancetype)richie_colorWithRGBHexString:(NSString *)hexString;
+(instancetype)richie_colorWithRGBAHexString:(NSString *)hexString;

-(NSString *)richie_RGBHexString;

@end
