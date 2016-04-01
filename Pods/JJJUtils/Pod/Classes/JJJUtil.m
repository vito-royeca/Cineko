//
//  JJJUtil.m
//  JJJ
//
//  Created by Jovito Royeca on 11/22/13.
//  Copyright (c) 2013 Jovito Royeca. All rights reserved.
//

#import "JJJUtil.h"

@implementation JJJUtil

#pragma mark - Strings
+ (BOOL) string:(NSString *)string containsString:(NSString*)x
{
    NSRange isRange = [string rangeOfString:x options:NSCaseInsensitiveSearch];
    if(isRange.location == 0)
    {
        return YES;
    }
    else
    {
        NSRange isSpacedRange = [string rangeOfString:x options:NSCaseInsensitiveSearch];
        if(isSpacedRange.location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL) isEmptyString:(NSString*)string
{
    return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0;
}

+ (BOOL) isAlphaStart:(NSString*)string
{
//    return [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:0]];
    return isalpha([string characterAtIndex:0]);
}

+ (NSString*) arrayToString:(NSArray*)arr
{
    NSMutableString *retString = [[NSMutableString alloc] init];

    for (id i in [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)])
    {
        [retString appendFormat:@"%@%@", retString.length>0 ? @" ":@"", i];
    }
    
    return retString;
}

+ (NSString*) toUTF8:(NSString*)string
{
    if ([string canBeConvertedToEncoding:NSISOLatin1StringEncoding])
    {
        NSString *utf8 = [NSString stringWithCString:[string cStringUsingEncoding:NSISOLatin1StringEncoding]
                                  encoding:NSUTF8StringEncoding];
        
        return utf8 ? utf8 : string;
    }
    else
    {
        return string;
    }
}

+ (NSString*) toASCII:(NSString*)string
{
    if ([string canBeConvertedToEncoding:NSASCIIStringEncoding])
    {
        NSString *ascii = [NSString stringWithCString:[string cStringUsingEncoding:NSASCIIStringEncoding]
                                             encoding:NSUTF8StringEncoding];
        
        return ascii ? ascii : string;
    }
    else
    {
        return string;
    }
}

+ (NSString*) trim:(NSString*)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*) superScriptOf:(NSString*)string
{
    NSMutableString *p = [[NSMutableString alloc] init];
    
    for (int i =0; i<string.length; i++)
    {
        unichar chara=[string characterAtIndex:i];
        
        switch (chara)
        {
            case '1':
            {
                [p appendFormat:@"%@", @"\u00B9"];
                break;
            }
            case '2':
            {
                [p appendFormat:@"%@", @"\u00B2"];
                break;
            }
            case '3':
            {
                [p appendFormat:@"%@", @"\u00B3"];
                break;
            }
            case '4':
            {
                [p appendFormat:@"%@", @"\u2074"];
                break;
            }
            case '5':
            {
                [p appendFormat:@"%@", @"\u2075"];
                break;
            }
            case '6':
            {
                [p appendFormat:@"%@", @"\u2076"];
                break;
            }
            case '7':
            {
                [p appendFormat:@"%@", @"\u2077"];
                break;
            }
            case '8':
            {
                [p appendFormat:@"%@", @"\u2078"];
                break;
            }
            case '9':
            {
                [p appendFormat:@"%@", @"\u2079"];
                break;
            }
            case '0':
            {
                [p appendFormat:@"%@", @"\u2070"];
                break;
            }
            case '+':
            {
                [p appendFormat:@"%@", @"\u207A"];
                break;
            }
            case '-':
            {
                [p appendFormat:@"%@", @"\u207B"];
                break;
            }
            case '=':
            {
                [p appendFormat:@"%@", @"\u207C"];
                break;
            }
            case '(':
            {
                [p appendFormat:@"%@", @"\u207D"];
                break;
            }
            case ')':
            {
                [p appendFormat:@"%@", @"\u207E"];
                break;
            }
            case 'n':
            {
                [p appendFormat:@"%@", @"\u207F"];
                break;
            }
            default:
            {
                [p appendFormat:@"%@", [string substringWithRange:NSMakeRange(i, 1)]];
                break;
            }
        }
    }
    
    return p;
}

+ (NSString*) subScriptOf:(NSString*)string
{
    NSMutableString *p = [[NSMutableString alloc] init];
    
    for (int i =0; i<string.length; i++)
    {
        unichar chara=[string characterAtIndex:i];
        
        switch (chara)
        {
            case '0':
            {
                [p appendFormat:@"%@", @"\u2080"];
                break;
            }
            case '1':
            {
                [p appendFormat:@"%@", @"\u2081"];
                break;
            }
            case '2':
            {
                [p appendFormat:@"%@", @"\u2082"];
                break;
            }
            case '3':
            {
                [p appendFormat:@"%@", @"\u2083"];
                break;
            }
            case '4':
            {
                [p appendFormat:@"%@", @"\u2084"];
                break;
            }
            case '5':
            {
                [p appendFormat:@"%@", @"\u2085"];
                break;
            }
            case '6':
            {
                [p appendFormat:@"%@", @"\u2086"];
                break;
            }
            case '7':
            {
                [p appendFormat:@"%@", @"\u2087"];
                break;
            }
            case '8':
            {
                [p appendFormat:@"%@", @"\u2088"];
                break;
            }
            case '9':
            {
                [p appendFormat:@"%@", @"\u2089"];
                break;
            }
            case '+':
            {
                [p appendFormat:@"%@", @"\u208A"];
                break;
            }
            case '-':
            {
                [p appendFormat:@"%@", @"\u208B"];
                break;
            }
            case '=':
            {
                [p appendFormat:@"%@", @"\u208C"];
                break;
            }
            case '(':
            {
                [p appendFormat:@"%@", @"\u208D"];
                break;
            }
            case ')':
            {
                [p appendFormat:@"%@", @"\u208E"];
                break;
            }
            case 'a':
            {
                [p appendFormat:@"%@", @"\u2090"];
                break;
            }
            case 'e':
            {
                [p appendFormat:@"%@", @"\u2091"];
                break;
            }
            case 'o':
            {
                [p appendFormat:@"%@", @"\u2092"];
                break;
            }
            case 'x':
            {
                [p appendFormat:@"%@", @"\u2093"];
                break;
            }
            case 'h':
            {
                [p appendFormat:@"%@", @"\u2095"];
                break;
            }
            case 'k':
            {
                [p appendFormat:@"%@", @"\u2096"];
                break;
            }
            case 'l':
            {
                [p appendFormat:@"%@", @"\u2097"];
                break;
            }
            case 'm':
            {
                [p appendFormat:@"%@", @"\u2098"];
                break;
            }
            case 'n':
            {
                [p appendFormat:@"%@", @"\u2099"];
                break;
            }
            case 'p':
            {
                [p appendFormat:@"%@", @"\u209A"];
                break;
            }
            case 's':
            {
                [p appendFormat:@"%@", @"\u209B"];
                break;
            }
            case 't':
            {
                [p appendFormat:@"%@", @"\u209C"];
                break;
            }
            default:
            {
                [p appendFormat:@"%@", [string substringWithRange:NSMakeRange(i, 1)]];
                break;
            }
        }
    }
    
    return p;
}

+ (NSArray*) alphabetWithWildcard
{
    static NSArray *arrAlphabet;
    
    if (!arrAlphabet)
    {
        arrAlphabet =  @[@"#",
                         @"A",
                         @"B",
                         @"C",
                         @"D",
                         @"E",
                         @"F",
                         @"G",
                         @"H",
                         @"I",
                         @"J",
                         @"K",
                         @"L",
                         @"M",
                         @"N",
                         @"O",
                         @"P",
                         @"Q",
                         @"R",
                         @"S",
                         @"T",
                         @"U",
                         @"V",
                         @"W",
                         @"X",
                         @"Y",
                         @"Z"];
    }
    
    return arrAlphabet;
}

+ (NSString*) termInitial:(NSString*) term
{
    if ([JJJUtil isAlphaStart:term])
    {
        return [[term substringToIndex:1] uppercaseString];
    }
    else
    {
        return @"#";
    }
}

+ (NSString*) highlightTerm:(NSString*) term withQuery:(NSString*) query
{
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:query
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:NULL];
    return [re stringByReplacingMatchesInString:term
                                        options:0
                                          range:NSMakeRange(0, term.length)
                                   withTemplate:@"<mark>$0</mark>"];
}

+ (BOOL) stringContainsSpace:(NSString*)string
{
    NSRange whiteSpaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return whiteSpaceRange.location != NSNotFound ? YES : NO;
}

+ (NSString*) reverseString:(NSString*) string
{
    NSMutableString *reversedString = [NSMutableString string];
    NSInteger charIndex = [string length];
    
    while (charIndex > 0)
    {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedString appendString:[string substringWithRange:subStrRange]];
    }
    
    return reversedString;
}

+ (NSString*) stringWithNewLinesAsBRs:(NSString*)text
{
    return [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"<br/>"];
}

+ (NSString*) removeNewLines:(NSString*)text
{
    return [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
}

#pragma mark - Networking
+ (void) downloadResource:(NSURL*) url toPath:(NSString*) path
{
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if (urlData)
    {
        [urlData writeToFile:path atomically:YES];
    }
}

+ (BOOL) addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
}

#pragma mark - Dates
+ (NSString *) formatInterval: (NSTimeInterval) interval
{
    //    if (interval == 0)
    //    {
    //        return @"HH:mm:ss.SSS";
    //    }
    //
    //    unsigned long milliseconds = interval;
    //    unsigned long seconds = milliseconds / 1000;
    //    milliseconds %= 1000;
    //    unsigned long minutes = seconds / 60;
    //    seconds %= 60;
    //    unsigned long hours = minutes / 60;
    //    minutes %= 60;
    //
    //    NSMutableString * result = [NSMutableString new];
    //
    //    if(hours)
    //        [result appendFormat: @"%lu:", hours];
    //
    //    [result appendFormat: @"%2lu:", minutes];
    //    [result appendFormat: @"%2lu:", seconds];
    //    [result appendFormat: @"%2lu",milliseconds];
    //
    //    return result;
    
    if (interval == 0)
    {
        return @"HH:mm:ss";
    }
    
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

+ (NSString *) formatIntervalHumanReadable: (NSTimeInterval) interval {
    if (interval == 0) {
        return @"HH:mm:ss";
    }
    
    NSInteger ti = (NSInteger)interval;
//    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    return [NSString stringWithFormat:@"%@%01ld min", hours>0 ? [NSString stringWithFormat:@"%01ld hr, ", (long)hours] : @"", (long)minutes];
}

+ (NSDate*) parseDate:(NSString*)date withFormat:(NSString*) format
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:date];
}

+ (NSString*) formatDate:(NSDate *)date withFormat:(NSString*) format
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:format];
    return [dateFormat stringFromDate:date];
}


+ (NSString*) runCommand:(NSString*) command
{
#if defined(_OS_OSX)
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", command],
                          nil];
    NSLog(@"run command: %@",command);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;

#else
    return nil;

#endif
}


#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
#pragma mark - Colors
+ (UIColor*) colorFromRGB:(NSUInteger) rgbValue
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:1.0];
}

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor*)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

+ (NSString*) colorToHexString:(UIColor*) color
{
    CGFloat r, g, b, a;
    float max = 255.0;
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    return [NSString stringWithFormat:@"%02x%02x%02x", (int)(max * r), (int)(max * g), (int)(max * b)];
}

+ (UIColor*) inverseColor:(UIColor*) color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}

#pragma mark Imaging
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    CGRect rect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UI
+ (void)alertWithTitle:(NSString*) title andMessage:(NSString*) message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    if (alert!=nil)
    {
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController  presentViewController:alert animated:YES completion:nil];
        
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [messageBox show];
    }
}

+ (void)alertWithTitle:(NSString*) title
               message:(NSString*) message
     cancelButtonTitle:(NSString*) cancelTitle
     otherButtonTitles:(NSDictionary*) otherButtons
     textFieldHandlers:(NSArray*) textFieldHandlers {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    if (alert==nil)
    {
        UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [messageBox show];
        return;
    }
    if (cancelTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancel];
    }
    
    for (NSString *title in [otherButtons allKeys]) {
        void (^handler)(UIAlertController*) = [otherButtons objectForKey:title];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                           handler(alert);
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:action];
    }
    
    for (void(^textFieldHandler)(UITextField*) in textFieldHandlers) {
        
        [alert addTextFieldWithConfigurationHandler:textFieldHandler];
    }
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController  presentViewController:alert animated:YES completion:nil];
}

#endif

#pragma mark - Unused
//+ (NSString*) addSuperScriptToString:(NSString*)string
//{
//    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:string];
//
//    [att beginEditing];
//    [att addAttribute:(NSString*)NSSuperscriptAttributeName
//                value:[NSNumber numberWithInt:1]
//                range:NSMakeRange(0, string.length-1)];
//    [att endEditing];
//
//    return [att string];
//}
//
//+ (NSString*) addSubScriptToString:(NSString*)string
//{
//    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:string];
//        [att beginEditing];
//        [att addAttribute:(NSString*)NSSuperscriptAttributeName
//                    value:[NSNumber numberWithInt:-1]
//                    range:NSMakeRange(0, string.length-1)];
//        [att endEditing];
//
//    return [att string];
//}

@end