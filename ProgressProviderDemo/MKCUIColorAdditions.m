//
//  MKCUIColorAdditions.m
//  MKCKit
//
//  Created by Juri Pakaste on 25.11.11.
//  Copyright 2011 Marko Karppinen & Co. LLC. All rights reserved.
//

#import "MKCUIColorAdditions.h"


@implementation UIColor (RichieUIColorAdditions)

-(instancetype)richie_initWithMKCUIColorStruct:(RichieUIColorStruct)cs
{
	return [self initWithRed:cs.red green:cs.green blue:cs.blue alpha:cs.alpha];
}

+(UIColor*)richie_colorWithMKCUIColorStruct:(RichieUIColorStruct)cs
{
	return [[self alloc] richie_initWithMKCUIColorStruct:cs];
}

-(instancetype)richie_initWithRGB:(NSUInteger)rgb
{
	return [self initWithRed:(rgb >> 16 & 0xff) / 255.0f
					   green:(rgb >> 8 & 0xff) / 255.0f
						blue:(rgb & 0xff) / 255.0f
					   alpha:1];
}

-(instancetype)richie_initWithRGBA:(NSUInteger)rgba
{
	return [self initWithRed:(rgba >> 24 & 0xff) / 255.0f
					   green:(rgba >> 16 & 0xff) / 255.0f
						blue:(rgba >> 8 & 0xff) / 255.0f
					   alpha:(rgba & 0xff) / 255.0f];
}

+(instancetype)richie_colorWithRGB:(NSUInteger)rgb
{
	return [[self alloc] richie_initWithRGB:rgb];
}

+(instancetype)richie_colorWithRGBA:(NSUInteger)rgba
{
	return [[self alloc] richie_initWithRGBA:rgba];
}

+(instancetype)richie_colorWithRGBHexString:(NSString *)hexString
{
	return [self richie_colorWithRGBAHexString:[hexString stringByAppendingString:@"ff"]];
}

+(instancetype)richie_colorWithRGBAHexString:(NSString *)hexString
{
	unsigned int rgba;
	if ([[NSScanner scannerWithString:hexString] scanHexInt:&rgba])
		return [self richie_colorWithRGBA:rgba];
	else
		return nil;
}

-(NSString *)richie_RGBHexString
{
	CGFloat r, g, b, a;
	
	if(![self getRed:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [NSString stringWithFormat:@"%02x%02x%02x", (int)(255.0 * r), (int)(255.0 * g), (int)(255.0 * b)];
}

@end
