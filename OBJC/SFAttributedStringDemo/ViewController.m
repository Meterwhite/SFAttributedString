//
//  ViewController.m
//  SFAttributedStringDemo
//
//  Created by MeterWhite on 2020/7/17.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

#import "ViewController.h"
#import "SFAttributedString.h"

@interface ViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lb;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *bt;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *txtv;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtfd;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lb2;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    [self configBeforeUse];
    self = [super initWithCoder:coder];
    return self;
}

- (void)configBeforeUse {
    [SFAtStringCore registerAttributes:@{
        NSForegroundColorAttributeName : UIColor.systemBlueColor,
        NSFontAttributeName : [UIFont systemFontOfSize:21 weight:(UIFontWeightMedium)],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
    } forLabel:@"A"];
    [SFAtStringCore registerAttributes:@{
        NSForegroundColorAttributeName : UIColor.darkGrayColor,
        NSFontAttributeName : [UIFont systemFontOfSize:16 weight:(UIFontWeightRegular)],
    } forLabel:@"B"];
    [SFAtStringCore registerAttributes:@{
        NSForegroundColorAttributeName : UIColor.systemRedColor,
        NSFontAttributeName : [UIFont systemFontOfSize:21 weight:(UIFontWeightMedium)],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
    } forLabel:@"A1"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *string_sf = @"[A]Give [[!]star] to [B]SFAttributedString";
//    NSString *string_sf = @"[A][[!]star]012345[[!]star,0,-5.00,21,21]6789[B]][[][[!]][[[[!]star,0,-5.00,21,21]";
    NSLog(@"%@",string_sf.sf_unformattedString);
    [_lb2 setSf_text:string_sf];
    [_lb2 setSf_text:string_sf];
}


@end
