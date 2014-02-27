//
//  CalculatorViewController.h
//  Calculator
//
//  Created by wang on 13-10-15.
//  Copyright (c) 2013年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kClear          10   // C
#define kDel            11	// DEL
#define kDevide         12	// ÷
#define kMultiply       13	// x
#define kSub            14	// -
#define kPlus           15	// +
#define kEqual          16	// =
#define kRightBracket   17  // )
#define kLeftBracket    18  // (
#define kDot            19	// .
#define kPower          20  // ^
#define kSin            21  // sin
#define kCos            22  // cos
#define kTan            23  // tan
#define kLog            24  // log 此处是以10为底
#define kLn             25  // ln
#define kRadical        26  // √ 根号
#define kMod            27  //  %求模

@interface CalculatorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalResultLabel;
@property (weak, nonatomic) IBOutlet UITextField *resultText;


- (IBAction)tapAction:(UIButton *)sender;
- (IBAction)showAnswerHistory:(UIButton *)sender;
- (IBAction)appendAnswer:(UIButton *)sender;

//方法原型放在这里不容易报错
- (void)clearAll;                                   // 清屏，以及清楚answer history
- (void)deleteBack;									// DEL,回退



@end
