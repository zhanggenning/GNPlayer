//
//  HeaderView.m
//  GNPlayerControllerDemo
//
//  Created by zhanggenning on 16/2/17.
//  Copyright © 2016年 zhanggenning. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView ()

{
    CGFloat _mainTitleHeight;
    CGFloat _playNumberHeight;
    CGFloat _detailTextHeight;
}

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;

//控件
@property (weak, nonatomic) IBOutlet UILabel *detailText;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleText;
@property (weak, nonatomic) IBOutlet UILabel *playNumberText;

//约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Contraint_mainTitleLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Contraint_mainTitleTail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Contraint_mainTitleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Contraint_mainTitleBottom;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Contraint_expendBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Containt_expendBtnTail;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Containt_zanViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Containt_zanViewHeight;
@end

@implementation HeaderView

- (void)awakeFromNib
{

}

+ (instancetype)headerView
{
    HeaderView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HeaderView class]) owner:nil options:nil] firstObject];
    
    return view;
}


#pragma mark -- 计算高度
- (CGFloat)calculateTextHeight:(NSString *)str withSystemFontSize:(CGFloat)fontSize withConstraintWidth:(CGFloat)constraintWidth
{
    CGSize constraintSize = CGSizeMake(constraintWidth, 100);
    
    CGRect rect =  [str boundingRectWithSize:constraintSize
                                     options: NSStringDrawingUsesLineFragmentOrigin
                                  attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                     context:nil];
    return rect.size.height + 1.0;
}

- (CGFloat)calculateMainTitleHeight:(CGFloat)cellWidth
{
    NSString *str = _mainTitleText.text;
    CGFloat systemFontSize = _mainTitleText.font.pointSize;
    CGFloat constraintWidth = cellWidth - _Containt_expendBtnTail.constant
                                        - _Contraint_expendBtnWidth.constant
                                        - _Contraint_mainTitleTail.constant
                                        - _Contraint_mainTitleLeading.constant;
    
    CGFloat singleLineHeight = [self calculateTextHeight:@"单行" withSystemFontSize:systemFontSize withConstraintWidth:constraintWidth];
    
    CGFloat limiteHeight = _mainTitleText.numberOfLines * singleLineHeight;
    CGFloat realHeight = [self calculateTextHeight:str withSystemFontSize:systemFontSize withConstraintWidth:constraintWidth];
    
    return (realHeight > limiteHeight ? limiteHeight : realHeight);
}

- (CGFloat)calculateDetailTitleHeight:(CGFloat)cellWidth
{
    NSString *str = _detailText.text;
    CGFloat systemFontSize = _detailText.font.pointSize;
    CGFloat constraintWidth = cellWidth - _Contraint_mainTitleLeading.constant
                                        - _Contraint_mainTitleTail.constant;
    
    CGFloat height = [self calculateTextHeight:str withSystemFontSize:systemFontSize withConstraintWidth:constraintWidth];
    
    return height;
}

- (CGFloat)calculatePlayNumberTextHeight:(CGFloat)cellWidth
{
    NSString *str = @"单行";
    CGFloat systemFontSize = _playNumberText.font.pointSize;
    CGFloat constraintWidth = cellWidth;

    return [self calculateTextHeight:str withSystemFontSize:systemFontSize withConstraintWidth:constraintWidth];
}


- (CGFloat)cellHeight:(CGFloat)cellWidth
{
    _cellWidth = cellWidth;
    
    _mainTitleHeight = [self calculateMainTitleHeight:cellWidth];
    _playNumberHeight = [self calculatePlayNumberTextHeight:cellWidth];
    _detailTextHeight = [self calculateDetailTitleHeight:cellWidth];
    
    return self.cellHeight;
}

- (CGFloat)cellHeight
{
    return  (_Contraint_mainTitleTop.constant +
             _mainTitleHeight +
             _Contraint_mainTitleBottom.constant +
             _playNumberHeight +
             _Containt_zanViewTop.constant +
             _Containt_zanViewHeight.constant +
             _Contraint_mainTitleTop.constant);  //保持上下间距一样
}


- (IBAction)packUpBtn:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"收起"])
    {
        [sender setTitle:@"展开" forState:UIControlStateNormal];

        _detailText.hidden = YES;
        _Containt_zanViewTop.constant -= _detailTextHeight;
    }
    else
    {
        [sender setTitle:@"收起" forState:UIControlStateNormal];
        
        _detailText.hidden = NO;
        _Containt_zanViewTop.constant += _detailTextHeight;
    }
    
    CGRect rect = self.frame;
    rect.size.height = self.cellHeight;
    self.frame = rect;
    
    if (_expendBtnBlock)
    {
        _expendBtnBlock();
    }
}

@end
