#import "NSString+HYPNetworking.h"

@interface NSString (PrivateInflections)

- (BOOL)hyp_containsWord:(NSString *)word;
- (NSString *)hyp_lowerCaseFirstLetter;
- (NSString *)hyp_replaceIdentifierWithString:(NSString *)replacementString;

@end

@implementation NSString (HYPNetworking)

#pragma mark - Private methods

- (nonnull NSString *)hyp_remoteString
{
    NSString *processedString = [self hyp_replaceIdentifierWithString:@"_"];

    return [processedString hyp_lowerCaseFirstLetter];
}

- (nonnull NSString *)hyp_localString
{
    NSString *processedString = self;

    processedString = [processedString hyp_replaceIdentifierWithString:@""];

    BOOL remoteStringIsAnAcronym = ([[NSString acronyms] containsObject:[processedString lowercaseString]]);

    return (remoteStringIsAnAcronym) ? [processedString lowercaseString] : [processedString hyp_lowerCaseFirstLetter];
}

- (BOOL)hyp_containsWord:(NSString *)word
{
    BOOL found = NO;

    NSArray *components = [self componentsSeparatedByString:@"_"];

    for (NSString *component in components) {
        if ([component isEqualToString:word]) {
            found = YES;
            break;
        }
    }

    return found;
}

- (nonnull NSString *)hyp_lowerCaseFirstLetter
{
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:self];
    NSString *firstLetter = [[mutableString substringToIndex:1] lowercaseString];
    [mutableString replaceCharactersInRange:NSMakeRange(0,1)
                                 withString:firstLetter];

    return [mutableString copy];
}

- (nonnull NSString *)hyp_replaceIdentifierWithString:(NSString *)replacementString
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    scanner.caseSensitive = YES;

    NSCharacterSet *identifierSet = [NSCharacterSet characterSetWithCharactersInString:@"_- "];
    NSCharacterSet *alphanumericSet = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];

    NSCharacterSet *lowercaseLettersSet = [NSCharacterSet lowercaseLetterCharacterSet];
    NSCharacterSet *decimalDigitSet = [NSCharacterSet decimalDigitCharacterSet];
    NSMutableCharacterSet *mutableLowercaseSet = [[NSMutableCharacterSet alloc] init];
    [mutableLowercaseSet formUnionWithCharacterSet:lowercaseLettersSet];
    [mutableLowercaseSet formUnionWithCharacterSet:decimalDigitSet];
    NSCharacterSet *lowercaseSet = [mutableLowercaseSet copy];

    NSString *buffer = nil;
    NSMutableString *output = [NSMutableString string];

    while (!scanner.isAtEnd) {
        BOOL isExcludedCharacter = [scanner scanCharactersFromSet:identifierSet intoString:&buffer];
        if (isExcludedCharacter) continue;

        if ([replacementString length] > 0) {
            BOOL isUppercaseCharacter = [scanner scanCharactersFromSet:uppercaseSet intoString:&buffer];
            if (isUppercaseCharacter) {
                for (NSString *string in [NSString acronyms]) {
                    BOOL containsString = ([[buffer lowercaseString] rangeOfString:string].location != NSNotFound);
                    if (containsString) {
                        if (buffer.length == string.length) {
                            buffer = string;
                        } else {
                            buffer = [NSString stringWithFormat:@"%@_%@", string, [[buffer lowercaseString] stringByReplacingOccurrencesOfString:string withString:@""]];
                        }
                        break;
                    }
                }
                [output appendString:replacementString];
                [output appendString:[buffer lowercaseString]];
            }

            BOOL isLowercaseCharacter = [scanner scanCharactersFromSet:lowercaseSet intoString:&buffer];
            if (isLowercaseCharacter) {
                [output appendString:[buffer lowercaseString]];
            }
        } else if ([scanner scanCharactersFromSet:alphanumericSet intoString:&buffer]) {
            if ([[NSString acronyms] containsObject:buffer]) {
                [output appendString:[buffer uppercaseString]];
            } else {
                [output appendString:[buffer capitalizedString]];
            }
        } else {
            output = nil;
            break;
        }
    }

    return output;
}

+ (nonnull NSArray *)acronyms
{
    return @[@"id", @"pdf", @"url", @"png", @"jpg", @"uri", @"json", @"xml"];
}

@end
