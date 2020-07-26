//
//  SFAttributedString.h
//  SFAttributedString
//  https://github.com/Meterwhite/SFAttributedString
//
//  Created by MeterWhite on 2020/7/18.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Category for NSString

@interface NSString(SimpleFormatAttributedString)

/// Core
- (nonnull NSAttributedString *)sf_evalString;

/// No text labels, no image labels
- (nonnull NSString *)sf_unformattedString;

@end

#pragma mark - SFAtStringCore

@interface SFAtStringCore :NSObject

/// Register an attribute label
/// @param lb Letters, numbers, underscores are allowed.(允许字母，数字，下划线。)
+ (void)registerAttributes:(nonnull NSDictionary<NSAttributedStringKey, id> *)adic forLabel:(nonnull NSString *)lb;

@end

#pragma mark - IB Inspectable supported(Support setting on XIB editor)
@interface UITextView(SimpleFormatAttributedString)

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_text;

@end

@interface UITextField(SimpleFormatAttributedString)

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_text;

@end

@interface UIButton(SimpleFormatAttributedString)

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_title_default;

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_title_highlighted;

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_title_selected;

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_title_disabled;

@end

@interface UILabel(SimpleFormatAttributedString)

@property (nullable,nonatomic,copy) IBInspectable NSString* sf_text;

@end
