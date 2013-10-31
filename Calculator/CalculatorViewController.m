//
//  CalculatorViewController.m
//  Calculator
//
//  Created by wang on 13-10-15.
//  Copyright (c) 2013年 wang. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorDetails.h"

@interface CalculatorViewController (){
    NSMutableArray *_resultArray;
    NSString *_tempStr;
    CalculatorDetails *_calcultor;
    NSString *_lastAnswer;
    NSString *_passString;
    //计算次数标识符
    int countFlat;
}

- (void)clearAll;                                   // 清屏，以及清楚answer history
- (void)deleteBack;									// DEL,回退


@end

@implementation CalculatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //读取历史记录
    _resultArray = [NSMutableArray array];
    _resultText.text = @"";
	_totalResultLabel.text = @"";
    _lastAnswer = @"";
    _calcultor = [[CalculatorDetails alloc]init];
    _tempStr = [NSString string];
    _passString = [NSString string];
}

#pragma - mark Button Actions
- (IBAction)tapAction:(UIButton *)sender {
    long int tag = sender.tag;
    switch (tag) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case kDot:
        case kRightBracket:
        case kLeftBracket:
        case kDevide:
        case kSub:
        case kPlus:
        case kMultiply:
        case kPower:
        case kRadical:
        case kSin:
        case kCos:
        case kTan:
        case kLn:
        case kLog:
        case kMod:
        {
            //若为第一次运算
            if (countFlat == 0) {
                if (tag == kRadical) {
                    //若为根号,则将按钮的ⁿ√x显示成√，主要是为了显示效果
                    _resultText.text = [_tempStr stringByAppendingString:@"√"];
                }else{
                    _resultText.text = [_tempStr stringByAppendingString:sender.titleLabel.text];
                }
            }
            //不是第一次运算
            else{
                if (tag == kPower || tag == kRightBracket || tag == kLeftBracket ||tag == kDevide ||tag == kSub ||tag == kPlus || tag== kMultiply || tag == kRadical || tag == kMod) {
                    if (![_resultText.text isEqualToString:@"error"]) {
                        //判断是否为根号，若为根号，把ⁿ√x换成√，主要是为了改善显示，就是所谓的用户体验
                        if (tag == kRadical) {
                            _resultText.text = [_tempStr stringByAppendingString:@"√"];
                        }else{
                            _resultText.text = [_resultText.text stringByAppendingString:sender.titleLabel.text];
                        }
                    }else{
                        if (tag == kRadical) {
                            _resultText.text = [_tempStr stringByAppendingString:@"√"];
                        }else{
                            _resultText.text = [@"0" stringByAppendingString:sender.titleLabel.text];
                        }
                        
                    }
                }else{
                    _resultText.text = [_tempStr stringByAppendingString:sender.titleLabel.text];
                }
            }
            _tempStr = _resultText.text;
            
        }
            break;
        case kClear:
            [self clearAll];
            break;
        case kDel:
            [self deleteBack];
            break;
        case kEqual:
        {
            if (![_tempStr isEqualToString:@""]) {
                _passString = [self replaceInputStrWithPassStr:_tempStr];
                _totalResultLabel.text = [_tempStr stringByAppendingString:sender.titleLabel.text];
                _lastAnswer = [_resultArray lastObject];
                if ([_lastAnswer isEqualToString:@"error"]||countFlat == 0 ||[_lastAnswer isEqualToString:@""]) {
                    _tempStr = [_calcultor calculatingWithString:_passString andAnswerString:@"0"];
                }else{
                    _tempStr = [_calcultor calculatingWithString:_passString andAnswerString:_lastAnswer];
                }
                
                _resultText.text = _tempStr;
                _lastAnswer = _tempStr;
                if (![_lastAnswer isEqualToString:@"error"]) {
                    [_resultArray addObject:_lastAnswer];
                }
                //每一次求完之后，将_temp清空
                _tempStr = [NSString string];
                //执行过一次计算后，使flag置1
                countFlat = 1;
            }
            
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)showAnswerHistory:(UIButton *)sender {
    if (_resultArray.count > 0) {
        UITableView *historyAnsView = [[UITableView alloc]initWithFrame:CGRectMake(20, 150, 270, 350) style:UITableViewStylePlain];
        historyAnsView.dataSource = self;
        historyAnsView.delegate = self;
        historyAnsView.backgroundColor = [UIColor darkGrayColor];
        historyAnsView.tag = 1024;
        historyAnsView.showsHorizontalScrollIndicator = YES;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 500, 270, 40);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.backgroundColor = [UIColor darkGrayColor];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeHistoryView) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1025;
        [self.view addSubview:btn];
        [self.view addSubview:historyAnsView];
    }
}

- (IBAction)appendAnswer:(UIButton *)sender {
    //如果Ans前面是数字，则自动在其后面补上乘号
    _tempStr = _resultText.text;
    if ([_tempStr hasSuffix:@"1"]||[_tempStr hasSuffix:@"2"]||[_tempStr hasSuffix:@"3"]||[_tempStr hasSuffix:@"4"]||[_tempStr hasSuffix:@"5"]||[_tempStr hasSuffix:@"6"]||[_tempStr hasSuffix:@"7"]||[_tempStr hasSuffix:@"8"]||[_tempStr hasSuffix:@"9"]||[_tempStr hasSuffix:@"0"]||[_tempStr hasSuffix:@"Ans"]) {
        _resultText.text = [_tempStr stringByAppendingString:@"x"];
        _resultText.text = [_resultText.text stringByAppendingString:sender.titleLabel.text];
    }else {
        _resultText.text = [_resultText.text stringByAppendingString:sender.titleLabel.text];
    }
    _tempStr = _resultText.text;
}

- (void)removeHistoryView{
    UIView *view1 = [self.view viewWithTag:1024];
    UIView *view2 = [self.view viewWithTag:1025];
    [view1 removeFromSuperview];
    [view2 removeFromSuperview];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        cell.textLabel.text = _resultArray[indexPath.row];
    }
    return  cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _tempStr = _resultText.text;
    //点击某个历史记录，如果前面有数字则自动补上乘号，否则直接加入
    if ([_tempStr hasSuffix:@"1"]||[_tempStr hasSuffix:@"2"]||[_tempStr hasSuffix:@"3"]||[_tempStr hasSuffix:@"4"]||[_tempStr hasSuffix:@"5"]||[_tempStr hasSuffix:@"6"]||[_tempStr hasSuffix:@"7"]||[_tempStr hasSuffix:@"8"]||[_tempStr hasSuffix:@"9"]||[_tempStr hasSuffix:@"0"]) {
        _resultText.text = [_tempStr stringByAppendingString:@"x"];
        _resultText.text = [_resultText.text stringByAppendingString:_resultArray[indexPath.row]];
    }else {
        _resultText.text = [_resultText.text stringByAppendingString:_resultArray[indexPath.row]];
    }
    _tempStr = _resultText.text;
    [self removeHistoryView];
}

#pragma - mark Ultity Methods
- (NSString *)replaceInputStrWithPassStr:(NSString *)inputStr{
    NSString *tempString = inputStr;
    //将字符串长度大于1的运算符换成单字符，以便后面的操作
    if (!([tempString rangeOfString:@"sin"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"sin" withString:@"s"];
    }
    if (!([tempString rangeOfString:@"cos"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"cos" withString:@"c"];
    }
    if (!([tempString rangeOfString:@"tan"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"tan" withString:@"t"];
    }
    if (!([tempString rangeOfString:@"log"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"log" withString:@"l"];
    }
    if (!([tempString rangeOfString:@"ln"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"ln" withString:@"e"];
    }
    //替换根号符，由于除号编码超过了unichar，所以换成字母
    if (!([tempString rangeOfString:@"√"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"√" withString:@"g"];
    }
    //替换除号，由于除号编码超过了unichar，所以换成字母
    if (!([tempString rangeOfString:@"÷"].location == NSNotFound)) {
        tempString = [tempString stringByReplacingOccurrencesOfString:@"÷" withString:@"d"];
    }
    //将Ans换成上一次答案，若上一次出错或者为空，则使其置0
    if (!([tempString rangeOfString:@"Ans"].location == NSNotFound)) {
        if ([_lastAnswer isEqualToString:@"error"]||[_lastAnswer isEqualToString:@""]) {
            tempString = [tempString stringByReplacingOccurrencesOfString:@"Ans" withString:@"0"];
        }else
        tempString = [tempString stringByReplacingOccurrencesOfString:@"Ans" withString:[NSString stringWithFormat:@"%g",[_lastAnswer doubleValue]]];
    }
    return tempString;
}

- (void)clearAll
{
	_resultText.text = @"";
	_totalResultLabel.text = @"";
    _resultArray = nil;
    _tempStr = @"";
    _passString = @"";
    countFlat = 0;
    _lastAnswer = @"";
}

- (void)deleteBack{
    if (![_resultText.text isEqual:@""]) {
        if (([_resultText.text length] == 1)||[_resultText.text isEqualToString: @"error"]) {
            _resultText.text = @"";
        }else{
            _resultText.text = [_resultText.text substringToIndex:_resultText.text.length -1];
        }
        _tempStr = _resultText.text;
    }else{
        return;
    }
}

#pragma - mark Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _resultArray = nil;
    _resultText = nil;
    _tempStr =nil;
    _totalResultLabel = nil;
    _calcultor = nil;
}

@end
