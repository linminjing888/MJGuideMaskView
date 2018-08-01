//
//  ViewController.m
//  MJGuideMaskView
//
//  Created by MinJing_Lin on 2018/7/30.
//  Copyright © 2018年 MinJing_Lin. All rights reserved.
//

#import "ViewController.h"
#import "MXRGuideMaskView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *tapBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupGuideView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupGuideView{
    
//    CGRect rect1 = [self.view convertRect:self.textLabel.frame fromView:self.view];
    
    NSArray * imageArr = @[@"image_01",@"image_02",@"image_03"];
    CGRect rect1 = self.textLabel.frame;
    CGRect rect2 = self.tapBtn.frame;
    CGRect rect3 = self.bgImg.frame;
    NSArray * imgFrameArr = @[
                              [NSValue valueWithCGRect:CGRectMake(rect1.origin.x-118, CGRectGetMaxY(rect1)-123, 118, 123)],
                              [NSValue valueWithCGRect:CGRectMake(CGRectGetMaxX(rect2), rect2.origin.y-108, 206, 108)],
                              [NSValue valueWithCGRect:CGRectMake(CGRectGetMaxX(rect3)-80, CGRectGetMaxY(rect3), 144 , 113)]
                              ];
    NSArray * transparentRectArr = @[[NSValue valueWithCGRect:rect1],[NSValue valueWithCGRect:rect2],[NSValue valueWithCGRect:rect3]];
    // @[@3]
    // @[@1,@1,@1]
    NSArray * orderArr = @[@1,@2];
    MXRGuideMaskView *maskView = [MXRGuideMaskView new];
    [maskView addImages:imageArr imageFrame:imgFrameArr TransparentRect:transparentRectArr orderArr:orderArr];
    [maskView showMaskViewInView:self.view];
}

@end
