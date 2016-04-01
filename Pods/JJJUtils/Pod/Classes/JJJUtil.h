//
//  JJJUtil.h
//  JJJ
//
//  Created by Jovito Royeca on 11/19/13.
//  Copyright (c) 2013 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "JJJConstants.h"

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
@import UIKit;
#endif

#define COMPOUND_SEPARATOR @"&#&"

//#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface JJJUtil : NSObject

#pragma mark - Strings
+ (BOOL) string:(NSString *)string containsString:(NSString*)x;
+ (BOOL) isEmptyString:(NSString*)string;
+ (BOOL) isAlphaStart:(NSString*)string;
+ (NSString*) arrayToString:(NSArray*)arr;
+ (NSString*) toUTF8:(NSString*)string;
+ (NSString*) toASCII:(NSString*)string;
+ (NSString*) trim:(NSString*)string;
+ (NSString*) superScriptOf:(NSString*)string;
+ (NSString*) subScriptOf:(NSString*)string;
+ (NSArray*) alphabetWithWildcard;
+ (NSString*) termInitial:(NSString*) term;
+ (NSString*) highlightTerm:(NSString*) term withQuery:(NSString*) query;
+ (BOOL) stringContainsSpace:(NSString*)string;
+ (NSString*) reverseString:(NSString*) string;
+ (NSString*) stringWithNewLinesAsBRs:(NSString*)text;
+ (NSString*) removeNewLines:(NSString*)text;

#pragma mark - Networking
+ (void) downloadResource:(NSURL*) url toPath:(NSString*) path;
+ (BOOL) addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

#pragma mark - Dates
+ (NSString*) formatInterval: (NSTimeInterval) interval;
+ (NSString *) formatIntervalHumanReadable: (NSTimeInterval) interval;
+ (NSDate*) parseDate:(NSString*)date withFormat:(NSString*) format;
+ (NSString*) formatDate:(NSDate *)date withFormat:(NSString*) format;


#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
#pragma mark - Colors
+ (UIColor*) colorFromRGB:(NSUInteger) rgbValue;
+ (UIColor*) colorFromHexString:(NSString *)hexString;
+ (NSString*) colorToHexString:(UIColor*) color;
+ (UIColor*) inverseColor:(UIColor*) color;

#pragma mark - Imaging
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

#pragma mark - UI
+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (void)alertWithTitle:(NSString*) title
               message:(NSString*) message
     cancelButtonTitle:(NSString*) cancelTitle
     otherButtonTitles:(NSDictionary*) otherButtons
     textFieldHandlers:(NSArray*) textFieldHandlers;

#endif

#pragma mark - Miscellaneous
+ (NSString*) runCommand:(NSString*) command;

@end