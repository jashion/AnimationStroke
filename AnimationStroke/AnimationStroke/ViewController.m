//
//  ViewController.m
//  AnimationStroke
//
//  Created by jashion on 15/12/29.
//  Copyright © 2015年 BMu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) UIView *circleView;
@property (nonatomic) BOOL animating;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgView.backgroundColor = [UIColor colorWithRed: 159 / 255.f green: 247 / 255.f blue: 18 / 255.f alpha: 1.f];
    
    self.circleView = [[UIView alloc] init];
    self.circleView.bounds = CGRectMake(0, 0, 50, 50);
    self.circleView.center = CGPointMake(150, 100);
    self.circleView.backgroundColor = [UIColor whiteColor];
    self.circleView.clipsToBounds = YES;
    self.circleView.layer.cornerRadius = 25;
    self.circleView.userInteractionEnabled = YES;
    [_bgView addSubview: self.circleView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(stokeAnimation:)];
    [_circleView addGestureRecognizer: tap];
}

- (void)stokeAnimation: (UITapGestureRecognizer *)tap {
    if (self.animating) {
        return;
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setValue: @"loadingView" forKey: @"layerName"];
    
    //使用贝塞尔曲线先把整个路径画出来
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(156, 135)];
    [path addLineToPoint: CGPointMake(156, 95)];
    
    //如何把两段对称的曲线无缝连接在一起？这里有一个技巧就是，两条曲线分别是二次贝塞尔曲线，所以，都只有一个控制点，把整个一段完成的曲线看成是一个矩形内切园的一部分，曲线和矩形的切点就是这两段贝塞尔曲线的起点和终点，两个控制点就是矩形的两个角，这样的两段对称的曲线会完美连接在一起
    [path addQuadCurveToPoint: CGPointMake(150, 85) controlPoint: CGPointMake(156, 85)];
    [path addQuadCurveToPoint: CGPointMake(144, 95) controlPoint: CGPointMake(144, 85)];
    
    [path addLineToPoint: CGPointMake(144, 105)];
    
    [path addQuadCurveToPoint: CGPointMake(148, 112) controlPoint: CGPointMake(144, 112)];
    [path addQuadCurveToPoint: CGPointMake(152, 105) controlPoint: CGPointMake(152, 112)];
    
    [path addLineToPoint: CGPointMake( 152, 97)];
    
    [path addQuadCurveToPoint: CGPointMake(150, 92) controlPoint: CGPointMake(152, 92)];
    [path addQuadCurveToPoint: CGPointMake(148, 97) controlPoint: CGPointMake(148, 92)];
    
    [path addLineToPoint: CGPointMake(148, 135)];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = _bgView.bounds;
    shapeLayer.strokeColor = [UIColor colorWithRed: 159 / 255.f green: 247 / 255.f blue: 18 / 255.f alpha: 1.f].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 2.f;
    
    [_bgView.layer addSublayer: shapeLayer];
    
    //关键的stroke animation
    //这里动画都是居于原始图层的操作，在这里是指线画好之后的操作
    //strokeEnd动画，fromValue: 线开始消失的点  toValue: 线消失结束的点
    CABasicAnimation *animationStart = [CABasicAnimation animation];
    animationStart.keyPath = @"strokeEnd";
    animationStart.duration = 1.f;
    animationStart.fromValue = @(0);
    animationStart.toValue = @(1);
    animationStart.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    
    //strokeStart动画，fromValue: 开始画线的点 toValue: 画线结束的点
    CABasicAnimation *animationEnd = [CABasicAnimation animation];
    animationEnd.keyPath = @"strokeStart";
    animationEnd.beginTime = 0.6f;
    animationEnd.duration = 0.8f;
    animationEnd.fromValue = @(0);
    animationEnd.toValue = @(1);
    animationEnd.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.4f;
    animationGroup.animations = @[animationStart, animationEnd];
    animationGroup.delegate = self;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    [animationGroup setValue: @"loadingAnimation" forKey: @"animationName"];
    
    [shapeLayer addAnimation: animationGroup forKey: nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.animating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey: @"animationName"] isEqualToString: @"loadingAnimation"]) {
        for (CALayer *layer in _bgView.layer.sublayers) {
            if ([[layer valueForKey: @"layerName"] isEqualToString: @"loadingView"]) {
                [layer removeFromSuperlayer];
                self.animating = NO;
            }
        }
    }
}

@end
