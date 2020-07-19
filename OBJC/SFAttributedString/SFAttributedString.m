//
//  SFAttributedString.m
//  SFAttributedString
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

#import "SFAttributedString.h"
/// String : Dictionary
static NSMutableDictionary  *_cached_lb_adic;
/// weak(View) : copy(String|Dictionary)
static NSMapTable           *_cached_v_sftxt;
static NSRegularExpression  *_rgx;

@implementation SFAtStringCore
+ (void)initialize {
    if(self != SFAtStringCore.class) return;
    _cached_lb_adic = [NSMutableDictionary dictionary];
    _cached_v_sftxt = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPersonality) valueOptions:(NSPointerFunctionsCopyIn|NSPointerFunctionsObjectPersonality)];
    _rgx = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+\\]" options:0 error:nil];
}

+ (void)registerAttributes:(NSDictionary<NSAttributedStringKey, id> *)adic forLabel:(NSString *)lb {
    NSAssert(adic && lb, @"Nonnull!");
    _cached_lb_adic[[NSString stringWithFormat:@"[%@]",lb]] = adic;
}

+ (NSAttributedString *)evalScript:(NSString *)string {
    NSArray<NSTextCheckingResult *> *rts = [_rgx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableAttributedString *     mRet = [NSMutableAttributedString new];
    NSRange                         iRangeTxt;
    
    if(rts.firstObject.range.location != 0 && nil == _cached_lb_adic[[string substringWithRange:rts.firstObject.range]]) {
        NSAssert(0, @"The first attribute label is missing!");
        return nil;
    }
    /// Filter
    rts = [rts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSTextCheckingResult *rt, NSDictionary<NSString *,id> * _) {
        return (_cached_lb_adic[[string substringWithRange:rt.range]] != nil);
    }]];
    if(rts.count == 0) {
        NSAssert(0, @"Missing attribute label!");
        return nil;
    }
    for (NSInteger i = 0; i < rts.count; i++) {
        NSTextCheckingResult *curr = rts[i];
        iRangeTxt.location = curr.range.location + curr.range.length;
        if(i == rts.count - 1) {
            if(iRangeTxt.location >= string.length) {
                NSAssert(0, @"Missing text at the end of the string!");
                return nil;
            }
            iRangeTxt.length = string.length - iRangeTxt.location;
        } else {
            NSTextCheckingResult *next = rts[i+1];
            iRangeTxt.length = next.range.location - iRangeTxt.location;
        }
        NSString *iTxt = [string substringWithRange:iRangeTxt];
        NSString *iLb  = [string substringWithRange:curr.range];
        id adic = _cached_lb_adic[iLb];
        [mRet appendAttributedString:[NSAttributedString.alloc initWithString:iTxt attributes:adic]];
    }
    return [mRet copy];
}

+ (NSString *)unformatted:(NSString *)string {
    NSTextCheckingResult            *item;
    NSEnumerator                    *etor;
    NSMutableString                 *ret = [string mutableCopy];
    NSArray<NSTextCheckingResult *> *rts = [_rgx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSAssert(rts.firstObject.range.location == 0 &&
             _cached_lb_adic[[string substringWithRange:rts.firstObject.range]],
             @"The first attribute label is missing!");
    /// Filter
    rts = [rts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSTextCheckingResult *rt, NSDictionary<NSString *,id> * _) {
        return (_cached_lb_adic[[string substringWithRange:rt.range]] != nil);
    }]];
    etor = rts.reverseObjectEnumerator;
    while (nil != (item = etor.nextObject)) {
        [ret deleteCharactersInRange:item.range];
    }
    return [ret copy];
}
@end

@implementation NSString(SimpleFormatAttributedString)
- (nonnull NSAttributedString *)sf_evalString {
    return [SFAtStringCore evalScript:self];
}

- (NSString *)sf_unformattedString {
    return [SFAtStringCore unformatted:self];
}
@end

#pragma mark - Private extention/UIView
@interface UIView (SimpleFormatAttributedString)
@property (nullable,nonatomic,copy) NSString *sf_text;
@end

@implementation UIView (SimpleFormatAttributedString)

- (void)setSf_text:(NSString *)sf_text {
    [_cached_v_sftxt setObject:sf_text forKey:self];
}

- (NSString *)sf_text {
    return [_cached_v_sftxt objectForKey:self];
}

@end

#pragma mark - IB Inspectable supported

@implementation UITextView (SimpleFormatAttributedString)

- (void)setSf_text:(NSString *)sf_text {
    [super setSf_text:sf_text];
    [self setAttributedText:sf_text.sf_evalString];
}

@end

@implementation UITextField (SimpleFormatAttributedString)

- (void)setSf_text:(NSString *)sf_text {
    [super setSf_text:sf_text];
    [self setAttributedText:sf_text.sf_evalString];
}

@end

@implementation UIButton (SimpleFormatAttributedString)
- (NSString *)sf_title_default {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    return userInfo[@(UIControlStateNormal)];
}

- (void)setSf_title_default:(NSString *)tt {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    userInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    userInfo[@(UIControlStateNormal)] = tt;
    [_cached_v_sftxt setObject:userInfo forKey:self];
    [self setAttributedTitle:tt.sf_evalString forState:UIControlStateNormal];
}

- (NSString *)sf_title_highlighted {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    return userInfo[@(UIControlStateHighlighted)];
}

- (void)setSf_title_highlighted:(NSString *)tt {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    userInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    userInfo[@(UIControlStateHighlighted)] = tt;
    [_cached_v_sftxt setObject:userInfo forKey:self];
    [self setAttributedTitle:tt.sf_evalString forState:UIControlStateHighlighted];
}

- (NSString *)sf_title_selected {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    return userInfo[@(UIControlStateSelected)];
}

- (void)setSf_title_selected:(NSString *)tt {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    userInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    userInfo[@(UIControlStateSelected)] = tt;
    [_cached_v_sftxt setObject:userInfo forKey:self];
    [self setAttributedTitle:tt.sf_evalString forState:UIControlStateSelected];
}

- (NSString *)sf_title_disabled {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    return userInfo[@(UIControlStateDisabled)];
}

- (void)setSf_title_disabled:(NSString *)tt {
    id userInfo = [_cached_v_sftxt objectForKey:self];
    userInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    userInfo[@(UIControlStateDisabled)] = tt;
    [_cached_v_sftxt setObject:userInfo forKey:self];
    [self setAttributedTitle:tt.sf_evalString forState:UIControlStateDisabled];
}
@end

@implementation UILabel (SimpleFormatAttributedString)

- (void)setSf_text:(NSString *)sf_text {
    [super setSf_text:sf_text];
    [self setAttributedText:sf_text.sf_evalString];
}

@end
