//
//  SFAttributedString.m
//  SFAttributedString
//  https://github.com/Meterwhite/SFAttributedString
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

#import "SFAttributedString.h"
@class SFImageLbAttachment;
/// String : Dictionary
static NSMutableDictionary  *_cached_lb_adic;
/// String : NSAttributedString
static NSMutableDictionary  *_cached_txt_ats;
/// weak(View) : copy(String|Dictionary)
static NSMapTable           *_cached_v_sftxt;
static NSRegularExpression  *_rgx_txt;
static NSRegularExpression  *_rgx_img;

/// Return type : NSArray<NSTextCheckingResult*>*
NSArray *combineCks(NSArray *cks_lb,NSArray *cks_img);
/// 0 - Image
/// 1 - Rect
NS_INLINE void setAtmFromImgLb(SFImageLbAttachment *atm,NSString *lb);
NSArray *atmsForImgLb(NSString *string, NSArray *cks_txt);

@interface SFImageLbAttachment : NSTextAttachment
@property (nonatomic) NSRange   conRange;
@property (nonatomic) NSInteger offset;
@property (nonatomic,readonly) NSUInteger inserdex;
@end

@implementation SFImageLbAttachment

- (NSUInteger)inserdex {
    return _conRange.location  - _offset;
}

@end


@implementation SFAtStringCore
+ (void)initialize {
    if(self != SFAtStringCore.class) return;
    _cached_lb_adic = [NSMutableDictionary dictionary];
    _cached_txt_ats = [NSMutableDictionary dictionary];
    _cached_v_sftxt = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPersonality) valueOptions:(NSPointerFunctionsCopyIn|NSPointerFunctionsObjectPersonality)];
    _rgx_txt = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+\\]" options:0 error:nil];
    _rgx_img = [NSRegularExpression regularExpressionWithPattern:@"\\[\\[!\\]\\w+(,(-|\\d|\\.)+)*\\]" options:0 error:nil];
}

+ (void)registerAttributes:(NSDictionary<NSAttributedStringKey, id> *)adic forLabel:(NSString *)lb {
    NSAssert(adic && lb, @"Nonnull!");
    _cached_lb_adic[[NSString stringWithFormat:@"[%@]",lb]] = adic;
}

+ (NSAttributedString *)evalScript:(NSString *)string {
    /// Cached first
    NSString *k = [string copy];
    if(_cached_txt_ats[k]) {
        return _cached_txt_ats[k];
    }
    /// Split image labels, suspend them.(剥离图片标签，挂起图片标签相关信息)
    NSArray<NSTextCheckingResult *> *cks_txt = [_rgx_txt matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray<NSTextCheckingResult *> *cks_img = [_rgx_img matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray<SFImageLbAttachment *> *img_atms;
    if(cks_img.count) {
        img_atms = atmsForImgLb(string, cks_txt);
        NSMutableString *mstring = string.mutableCopy;
        for (NSTextCheckingResult *item in cks_img.reverseObjectEnumerator) {
            [mstring deleteCharactersInRange:item.range];
        }
        string = mstring.copy;
    }
    /// Here begins to parse the plain text(这里开始解析纯文本)
    cks_txt = [_rgx_txt matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    /// Filter invalid labels
    cks_txt = [cks_txt filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSTextCheckingResult *rt, NSDictionary<NSString *,id> * _) {
        return (_cached_lb_adic[[string substringWithRange:rt.range]] != nil);
    }]];
    NSMutableAttributedString *     m_ret = [NSMutableAttributedString new];
    NSRange                         txtRange;
    if(cks_txt.count == 0) {
        NSAssert(0, @"Missing attribute label!");
        return nil;
    }
    if(cks_txt.firstObject.range.location != 0 ||
       nil == _cached_lb_adic[[string substringWithRange:cks_txt.firstObject.range]]) {
        NSAssert(0, @"The first attribute label is missing!");
        return nil;
    }
    for (NSInteger i = 0; i < cks_txt.count; i++) {
        NSTextCheckingResult *curr = cks_txt[i];
        txtRange.location = curr.range.location + curr.range.length;
        if(i == cks_txt.count - 1) {
            if(txtRange.location >= string.length) {
                NSAssert(0, @"Missing text at the end of the string!");
                return nil;
            }
            txtRange.length = string.length - txtRange.location;
        } else {
            NSTextCheckingResult *next = cks_txt[i+1];
            txtRange.length = next.range.location - txtRange.location;
        }
        NSString *iTxt = [string substringWithRange:txtRange];
        NSString *iLb  = [string substringWithRange:curr.range];
        id adic = _cached_lb_adic[iLb];
        [m_ret appendAttributedString:[NSAttributedString.alloc initWithString:iTxt attributes:adic]];
    }
    /// Append image labels
    if(img_atms.count) {
        for (SFImageLbAttachment *atm in img_atms.reverseObjectEnumerator) {
            [m_ret insertAttributedString:[NSAttributedString attributedStringWithAttachment:atm] atIndex:atm.inserdex];
        }
    }
    _cached_txt_ats[k] = [m_ret copy];
    return [m_ret copy];
}

+ (NSString *)unformatted:(NSString *)string {
    NSMutableString                 *ret = [string mutableCopy];
    NSArray<NSTextCheckingResult *> *cks_txt = [_rgx_txt matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    cks_txt = [cks_txt filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSTextCheckingResult *rt, NSDictionary<NSString *,id> * _) {
        return (_cached_lb_adic[[string substringWithRange:rt.range]] != nil);
    }]];
    NSArray<NSTextCheckingResult *> *cks_img = [_rgx_img matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray<NSTextCheckingResult *> *cks = combineCks(cks_txt, cks_img);
    if(cks.count == 0) {
        NSAssert(0, @"Missing attribute label!");
        return nil;
    }
    if(cks.firstObject.range.location != 0 ||
       ([cks_txt containsObject:cks.firstObject] && nil == _cached_lb_adic[[string substringWithRange:cks.firstObject.range]])) {
        NSAssert(0, @"The first attribute label is missing!");
        return nil;
    }
    for (NSTextCheckingResult *item in cks.reverseObjectEnumerator) {
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

NSArray *combineCks(NSArray *cks_txt,NSArray *cks_img) {
    if(0 == cks_txt.count)  return cks_img;
    if(0 == cks_img.count) return cks_txt;
    NSMutableArray *a = [NSMutableArray array];
    [a addObjectsFromArray:cks_txt];
    [a addObjectsFromArray:cks_img];
    [a sortUsingComparator:^NSComparisonResult(NSTextCheckingResult* obj1, NSTextCheckingResult* obj2) {
        if(obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        } else if (obj1.range.location > obj2.range.location) {
            return NSOrderedDescending;
        }
        assert(0);/// If bug
    }];
    return a.copy;
}

NS_INLINE void setAtmFromImgLb(SFImageLbAttachment *atm,NSString *lb) {
    NSArray<NSString *> *cpts = [[lb substringWithRange:(NSMakeRange(4, lb.length - 5))] componentsSeparatedByString:@","];
    atm.image = [UIImage imageNamed:cpts[0]];
    if(cpts.count == 1) return;
    if(cpts.count != 5) {
        assert(0);/// Invalid image label format.
        return;
    }
    NSDecimalNumber *x_nb = [NSDecimalNumber decimalNumberWithString:cpts[1]];
    NSDecimalNumber *y_nb = [NSDecimalNumber decimalNumberWithString:cpts[2]];
    NSDecimalNumber *w_nb = [NSDecimalNumber decimalNumberWithString:cpts[3]];
    NSDecimalNumber *h_nb = [NSDecimalNumber decimalNumberWithString:cpts[4]];
    atm.bounds = CGRectMake(x_nb.floatValue, y_nb.floatValue, w_nb.floatValue, h_nb.floatValue);
}

NSArray<SFImageLbAttachment *> * atmsForImgLb(NSString *string, NSArray<NSTextCheckingResult *> *cks_txt) {
    NSMutableArray *m_ret = [NSMutableArray array];
    NSInteger offset = 0;
    NSMutableString *nonTxtLbString = string.mutableCopy;
    for (NSTextCheckingResult *item in cks_txt.reverseObjectEnumerator) {
        if(_cached_lb_adic[[nonTxtLbString substringWithRange:item.range]]){
            [nonTxtLbString deleteCharactersInRange:item.range];
        }
    }
    NSArray<NSTextCheckingResult *> *cks_img = [_rgx_img matchesInString:nonTxtLbString options:0 range:NSMakeRange(0, [nonTxtLbString length])];
    for (NSUInteger i = 0; i < cks_img.count; i++) {
        NSTextCheckingResult *ck = cks_img[i];
        SFImageLbAttachment *atm = [SFImageLbAttachment new];
        setAtmFromImgLb(atm,[nonTxtLbString substringWithRange:ck.range]);
        atm.conRange = ck.range;
        atm.offset   = offset;
        offset += (atm.conRange.length);
        [m_ret addObject:atm];
    }
    return m_ret.copy;
}
