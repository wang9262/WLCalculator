//
//  OpeningViewController.h
//  Calculator
//
//  Created by wang on 13-10-15.
//  Copyright (c) 2013年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpeningViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *gotoMainViewBtn;

- (IBAction)gotoMainView:(id)sender;

@end
