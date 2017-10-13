//
//  NSString+Emojize.m
//  Field Recorder
//
//  Created by Jonathan Beilin on 11/5/12.
//  Copyright (c) 2014 DIY. All rights reserved.
//

#import "NSString+Emojize.h"
#import "emojis.h"

@implementation NSString (Emojize)

- (NSString *)emojizedString {
    return [NSString emojizedStringWithString:self];
}

+ (NSString *)emojizedStringWithString:(NSString *)text {
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(:[a-z0-9-+_]+:)" options:NSRegularExpressionCaseInsensitive error:NULL];
    });

    __block NSString *resultText = text;
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                NSString *unicode = self.emojiAliases[code];
                if (unicode) {
                    resultText = [resultText stringByReplacingOccurrencesOfString:code withString:unicode];
                }
            }
        }
     }];
    
    return resultText;
}

+ (NSDictionary *)emojiAliases {
    static NSDictionary *_emojiAliases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiAliases = EMOJI_HASH;
    });
    return _emojiAliases;
}

- (BOOL)isFirstCharEmoji {
    const unichar high = [self characterAtIndex:0];
    
    // Surrogate pair (U+1D000-1F77F)
    if (0xd800 <= high && high <= 0xdbff) {
        const unichar low = [self characterAtIndex: 1];
        const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
        
        return (0x1d000 <= codepoint && codepoint <= 0x1f77f) || (0x1F900 <= codepoint && codepoint <=0x1f9ff);
        
    // Not surrogate pair (U+2100-27BF)
    } else {
        return (0x2100 <= high && high <= 0x27bf);
    }
}

@end
