//
//  MXRGuideMaskView.m
//  MJGuideMaskView
//
//  Created by MinJing_Lin on 2018/7/30.
//  Copyright © 2018年 MinJing_Lin. All rights reserved.
//

#import "MXRGuideMaskView.h"

NSInteger countNum = 0;

@interface MXRGuideMaskView ()

/// 图层
@property (nonatomic, weak)   CAShapeLayer   *fillLayer;
/// 路径
@property (nonatomic, strong) UIBezierPath   *overlayPath;
/// 透明区数组
@property (nonatomic, strong) NSMutableArray *transparentPaths;
/// 图片数组
@property (nonatomic, strong) NSMutableArray *imageArr;
/// 图片frame数组
@property (nonatomic, strong) NSMutableArray *frameArr;
/// 点击计数
@property (nonatomic, assign) NSInteger index;
/// 图片frame数组
@property (nonatomic, strong) NSMutableArray *orderArr;
/// 是否单张循环，默认YES
@property (nonatomic, assign) BOOL isSingle;
@end

@implementation MXRGuideMaskView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.index = 0;
    self.isSingle = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *maskColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.fillLayer.path      = self.overlayPath.CGPath;
    self.fillLayer.fillRule  = kCAFillRuleEvenOdd;
    self.fillLayer.fillColor = maskColor.CGColor;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickedMaskView)];
    [self addGestureRecognizer:tapGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - 公有方法

//- (void)addTransparentOvalRect:(CGRect)rect {
//    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithOvalInRect:rect];
//
//    [self addTransparentPath:transparentPath];
//}

- (void)addImages:(NSArray *)images imageFrame:(NSArray *)imageframeArr TransparentRect:(NSArray *)rectArr{
    if (images.count != imageframeArr.count || images.count != rectArr.count) {
        return;
    }
    self.isSingle = YES;
    [images enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage * image = [UIImage imageNamed:obj];
        [self.imageArr addObject:image];
    }];
    
    self.frameArr = [imageframeArr mutableCopy];
    [self addImage:_imageArr[0] withFrame:[_frameArr[0] CGRectValue]];
    
    for (NSInteger i=0; i<rectArr.count; i++) {
        UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRoundedRect:[rectArr[i] CGRectValue] cornerRadius:5];
        [self.transparentPaths addObject:transparentPath];
    }
    [self addTransparentPath:_transparentPaths[0]];
    
}

- (void)addImages:(NSArray *)images imageFrame:(NSArray *)imageframeArr TransparentRect:(NSArray *)rectArr orderArr:(NSArray *)orderArr{
    if (images.count != imageframeArr.count || images.count != rectArr.count) {
        return;
    }
    //判断顺序数组总数是否等于图片数组
    NSInteger numCount = 0;
    for (NSNumber * num in orderArr) {
        NSInteger order = [num integerValue];
        numCount += order;
    }
    if (numCount != images.count) {
        return;
    }
    
    self.isSingle = NO;
    self.orderArr = [orderArr mutableCopy];
    [images enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage * image = [UIImage imageNamed:obj];
        [self.imageArr addObject:image];
    }];
    self.frameArr = [imageframeArr mutableCopy];
    
    for (NSInteger i=0; i<rectArr.count; i++) {
        UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRoundedRect:[rectArr[i] CGRectValue] cornerRadius:5];
        [self.transparentPaths addObject:transparentPath];
    }
    
    // 控制多个显示逻辑
    for (NSInteger i=0; i<[orderArr[0] integerValue]; i++) {
        [self addImage:_imageArr[i] withFrame:[_frameArr[i] CGRectValue]];
        [self addTransparentPath:_transparentPaths[i]];
    }
    
}

- (void)addImage:(UIImage*)image withFrame:(CGRect)frame{
    
    UIImageView * imageView   = [[UIImageView alloc]initWithFrame:frame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image           = image;
    
    [self addSubview:imageView];
}

- (void)addTransparentPath:(UIBezierPath *)transparentPath {
    
    [self.overlayPath appendPath:transparentPath];
    self.fillLayer.path = self.overlayPath.CGPath;
}

#pragma mark - 显示/隐藏

- (void)showMaskViewInView:(UIView *)view{
    
    self.alpha = 0;
    if (view != nil) {
        [view addSubview:self];
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)tapClickedMaskView{
    
    //    __weak typeof(self)weakSelf = self;
    
    _index++;
    if (_isSingle) {
        if (_index < _imageArr.count) {
            
            [self refreshMask];
            [self addTransparentPath:_transparentPaths[_index]];
            
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self addImage:_imageArr[_index] withFrame:[_frameArr[_index] CGRectValue]];
        }else{
            [self dismissMaskView];
            
        }
    }else{
        if (_index < _orderArr.count) {
            
            [self refreshMask];
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            // 控制多个显示逻辑
            NSInteger baseNum = [_orderArr[_index-1] integerValue];
            countNum = countNum + baseNum;
            NSInteger endNum = [_orderArr[_index] integerValue]+countNum;
            for (NSInteger i=countNum; i<endNum; i++) {
                
                [self addTransparentPath:_transparentPaths[i]];
                [self addImage:_imageArr[i] withFrame:[_frameArr[i] CGRectValue]];
            }
        }else{
            countNum = 0;
            [self dismissMaskView];
        }
    }
}

- (void)dismissMaskView{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)refreshMask {
    
    UIBezierPath *overlayPath = [self generateOverlayPath];
    self.overlayPath = overlayPath;
    
}

- (UIBezierPath *)generateOverlayPath {
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    return overlayPath;
}

#pragma mark - 懒加载Getter Methods

- (UIBezierPath *)overlayPath {
    if (!_overlayPath) {
        _overlayPath = [self generateOverlayPath];
    }
    
    return _overlayPath;
}

- (CAShapeLayer *)fillLayer {
    if (!_fillLayer) {
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.frame = self.bounds;
        [self.layer addSublayer:fillLayer];
        
        _fillLayer = fillLayer;
    }
    
    return _fillLayer;
}

- (NSMutableArray *)transparentPaths {
    if (!_transparentPaths) {
        _transparentPaths = [NSMutableArray array];
    }
    
    return _transparentPaths;
}

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    
    return _imageArr;
}

- (NSMutableArray *)frameArr {
    if (!_frameArr) {
        _frameArr = [NSMutableArray array];
    }
    
    return _frameArr;
}

- (NSMutableArray *)orderArr {
    if (!_orderArr) {
        _orderArr = [NSMutableArray array];
    }
    
    return _orderArr;
}


@end
