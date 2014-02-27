//
//  CalculatorDetails.m
//  Calculator
//
//  Created by wang on 13-10-15.
//  Copyright (c) 2013年 wang. All rights reserved.
//

#import "CalculatorDetails.h"

@interface CalculatorDetails ()

    @property (nonatomic,strong)NSMutableArray        *dealedArray;     //存储经过处理的表达式
    @property (nonatomic,strong)NSDictionary          *opPriority;      //运算符优先级表
    @property (nonatomic,strong)NSMutableArray        *bracketHandledArray;
    @property BOOL bracketAfterSingle;
@end

@implementation CalculatorDetails
-(id)init

{
    
    if (self =  [super  init]){
        //运算符优先级表；0优先级最大，向后优先级越小
        _opPriority=@{@"(":@0, @"^":@1,@"√":@2,@"%":@2, @"x":@3,@"/":@3, @"+":@4, @"-":@4,@")":@5,@"#":@6};
    }
    _bracketAfterSingle = NO;
    return  self;
}

-(NSString*)calculatingWithString:(NSString *)str andAnswerString:(NSString *)answerString
{
    //判断单目运算是否有括号，若有则将单目运算之前的处理过的字符存至_brakectHandledArray中。
    if (_bracketAfterSingle) {
        _bracketHandledArray = [NSMutableArray arrayWithArray:_dealedArray];
    }
    
    //将表达式从字符串变成数组
    [self handleInputString:str andAnswerString:answerString];
    
    //数组头部和尾部插入#，方便处理
    [_dealedArray    addObject:@"#"];
    [_dealedArray   insertObject:@"#"atIndex:0];
    
    NSInteger   count = [_dealedArray  count];
    
    NSString *finalResult = [NSString  string];
//      从表达式尾部向前找，遇到“(”就用i标记该位置，再从该位置向尾部找配对的第一个“)”，将括号里面的子表达式，
//      取出来进行合法性判断和计算结果处理，将结果返回并代替原表达式（包括一对括号也一起被取代）
    
    for (int i= (int)count - 2; i>= 0;i--)
    { 
        //遇到#的时候就判断是不是表达式数组为("#",5,"#")形式，如果是则5就是最终的结果，如果不是则说明原表达式不合法
        
        NSString *str1 = [_dealedArray  objectAtIndex:i];
        if ([str1    isEqualToString:@"#"]) {
            finalResult = [_dealedArray   objectAtIndex:1];
            if ([_dealedArray   count]>3) {
                finalResult =@"error";                          //【三角函数嵌套显示的“error”来自这里】
            }
            return finalResult;
        }
        if ([str1  isEqualToString:@"("])
        {
            //遇到了"("就向尾部寻找配对括号，找不到配对括号，说明表达式不合法
            
            NSString *subResult = [NSString  string];
            for (NSInteger j = i + 1; j <= count - 1; j++)
            {
                NSString *str2 = [_dealedArray   objectAtIndex:j];
                
                //括号不匹配
                if ([str2   isEqualToString:@"#"]) {
                    finalResult =@"error";
                    return   finalResult;
                }
                
                if ([str2    isEqualToString:@")"])
                {
                    NSRange range =NSMakeRange(i+1, j-i-1);
                    //生成子数组，生成的子数组肯定不存在括号问题
                    NSArray *subArray = [_dealedArray   subarrayWithRange:range];
                    NSMutableArray *arr = [NSMutableArray    arrayWithArray:subArray];
                    subResult = [self calculateNumbers:arr];
                    if ([subResult    isEqualToString:@"error"]) {
                        finalResult =@"error";
                        return  finalResult;
                    }
                    //将返回结果代替表达式，包括括号一起代替
                    range = NSMakeRange(i,j - i +1);
                    [_dealedArray    replaceObjectsInRange:range
                                    withObjectsFromArray: [NSArray arrayWithObject:subResult]];
                    //代替之后，重新获取新表达式的count
                    count = [_dealedArray  count];
                    i = (int)count - 1 ;
                    break;
                }
            }
        }
    }
    return finalResult;   
}



//从UILabel中读取的字符串形式的表达式进行拆分处理，并存放到数组中
- (void)handleInputString:(NSString *)inputStr andAnswerString:(NSString *)answerString{
    long int  length = [inputStr  length];
    _dealedArray =  [NSMutableArray array];
    int  i  =  0;
    UniChar c = [inputStr  characterAtIndex:0];
    if (c =='-'|| c == '+'||c == 'x'||c =='/'|| c== '^')
    {
        //如果新输入的是运算符，则在前面补上一次的答案(0或者其他值)
        if (length >1)
        {
            UniChar c1 = [inputStr  characterAtIndex:1];
            if (c1 >='0'&&c1 <= '9')
            {
                [_dealedArray addObject:answerString];
                [_dealedArray addObject:[NSString   stringWithCharacters:&c  length:1]];
                i++;
            }
        }
    }
    NSMutableString *mString = [NSMutableString  string];
    while (i< length)
    {
        c = [inputStr   characterAtIndex:i];
        if ((c >='0'&&c <= '9') || c =='.')
        {
            //遇到数字，就要读取整个数，包括小数点，读取完整后再存入数组中
            [mString  appendFormat:@"%c",c];
            if (i == length -1) {
                [_dealedArray addObject:mString];
                //读取数据完成之后，将mString重新初始化，即清空内容
                mString = [NSMutableString   string];
            }
        }
        else
        {
            if (![mString isEqualToString:@""]) {
                //将完整的数存放到数组中
                [_dealedArray  addObject:mString];
                mString = [NSMutableString  string];
            }
            if (c =='(')
            {
                if (i>0)
                {
                    UniChar xc = [inputStr   characterAtIndex:i-1];
                    if (xc >='0'&&xc <= '9') {  //"7（8+2）"这种省略乘号的写法，要将乘号补充完整
                        [_dealedArray   addObject:@"x"];
                        [_dealedArray   addObject:@"("];
                        i++;
                        continue;
                    }
                }
                if (i< length -1)
                    
                {
                    UniChar c1 = [inputStr  characterAtIndex:i+1];
                    if (c1 =='-'|| c1 == '+') {//"(-7)+6"这种带正负号的数的情况，要补充0；变成(0-7)+6
                        [_dealedArray addObject:@"("];
                        [_dealedArray addObject:@"0"];
                        i++;
                        continue;
                    }
                }
            }
            else  if (c == ')')
            {
                if (i< length -1)
                {
                    UniChar xc = [inputStr   characterAtIndex:i + 1];
                    if (xc >='0'&&xc <= '9') {
                        //"(3+4)7"这种省略乘号的情况，同样补充乘号变成"(3+4)*7"
                        [_dealedArray   addObject:@")"];
                        [_dealedArray  addObject:@"x"];
                        i++;
                        continue;
                    }
                }
            }
            else if (c == 'c' || c == 's'|| c == 't'|| c== 'e'||c == 'l'){
                NSString *tempStr = [NSString string];
                NSString *single = [NSString string];
                for (int j = i + 1; j < length ;j++ ) {
                    UniChar tempx = [inputStr characterAtIndex:j];
                    if ((tempx >='0'&&tempx <= '9') || tempx =='.') {
                       tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",tempx]];
                    }else if (tempx == '('){
                        //如果单目运算后面有括号，则先算出括号内的值然后再单目运算
                        _bracketAfterSingle = YES;
                        NSString *string = [inputStr substringFromIndex:j + 1];
                        for (int k = j+1; k < length; k++) {
                            
                            if ([string rangeOfString:@")"].location) {
                                int location = (int)[string rangeOfString:@")"].location;
                                NSRange range = NSMakeRange(0, location + 1);
                                string = [string substringWithRange:range];
                                single =string;
                                break;
                            }
                        }
                        tempStr = [self calculatingWithString:single andAnswerString:answerString];
                        //计算完单目运算后面括号中的值之后，将原来处理括号之前的已处理字符存入_dealedArray
                        _dealedArray = [NSMutableArray arrayWithArray:_bracketHandledArray];
                        break;
                    }
                    else
                        break;
                }
                if (tempStr.length >0 &&![tempStr isEqualToString:@"error"]) {
                    if (_bracketAfterSingle) {
                        i += single.length + 1;
                        _bracketAfterSingle = NO;
                    }else{
                        i = i + (int)[tempStr length] + 1;
                    }
                    double temp =[tempStr doubleValue];
                    switch (c) {
                            //cos
                        case 'c':
                            temp = cos(temp * M_PI/180.0);
                            break;
                            //sin
                        case 's':
                            temp = sin(temp * M_PI/180.0);
                            break;
                            //tan
                        case 't':
                            temp = tan(temp * M_PI/180.0);
                            break;
                            //log
                        case 'l':
                            temp = log10(temp);
                            break;
                            //ln
                        case 'e':
                            temp = log(temp);
                            break;
                        default:
                            break;
                    }
                    [_dealedArray addObject:[NSString stringWithFormat:@"%g",temp]];
                    continue;
                }
                
            }
            [_dealedArray addObject:[NSString stringWithCharacters:&c length:1] ];
        }
        i++;
    }
    //存完表达式之后，整个表达式用一对()括起来，为了方便处理
    [_dealedArray   insertObject:@"("atIndex:0];
    [_dealedArray   addObject:@")"];
}

//双目运算，父（子）级运算,即去除括号的
- (NSString *)calculateNumbersWithOperator:(NSString *)operator betweenDouble:(double)x1 andDoule:(double)x2
{
    double  aresult =0;
    unichar  ch = [operator  characterAtIndex:0];
    NSString *string = [NSString  string];
    BOOL   isOK = YES;
    switch (ch)
    {
        case '+':
            aresult = x1 + x2;
            break;
        case '-':
            aresult = x1 - x2;
            break;
        case 'x':
            aresult = x1 * x2;
            break;
            //开任意次根
        case 'g':
            if (x1 ==0){
                string =@"error";
                isOK =NO;
            }
            aresult = pow(x2, 1/x1);
            break;
            //除法
        case 'd':
            if (x2 ==0){
                string =@"error";
                isOK =NO;
            }
            aresult = x1 / x2;
            break;
            //求余数
        case '%':
            if (x2 ==0){
                string =@"error";
                isOK =NO;
            }
            aresult = fmod(x1, x2);
            break;
            //任意次方
        case '^':
            aresult = pow(x1, x2);
            break;
        default:
            isOK =NO;
            string =@"error";
            break;
    }
    if (isOK ==YES){
            string = [NSString stringWithFormat:@"%g",aresult];
    }
    return string;
}


- (NSString *)calculateNumbers:(NSMutableArray *)numberArray{
    //运算数栈，栈底元素设置为error，用于判断合法性
    NSMutableArray *operandStackArray = [NSMutableArray arrayWithObject:@"error"];
    //运算符栈，栈底元素设置为#，最小优先级运算符，方便处理
    NSMutableArray *stack2 = [NSMutableArray arrayWithObject:@"#"];
    
    NSString *result = [NSString string];
    
    //在表达式最后面添加一个#运算符，方便处理
    [numberArray addObject:@"#"];
    
    //绝对循环，知道最终运算结果出来或者不合法跳出
    while (1)
    {
        //获取表达式数组中的第一个元素
        NSString *subStr1 = [numberArray    objectAtIndex:0];
        UniChar c = [subStr1   characterAtIndex:0];
        //如果是数据则添加到数据栈
        if ((subStr1.length > 1 && [subStr1 hasPrefix:@"-"])||(c >='0'&&c <= '9')) {
            //插到数据栈顶
            [operandStackArray insertObject:subStr1 atIndex:0];
            //元素每次进栈之后要在表达式数组中移除该元素
            [numberArray   removeObjectAtIndex:0];
        }
        else
        {
            //元素是运算符，则每次都要跟运算符栈的栈顶元素比较优先级
            NSString *topStack2 = [stack2   objectAtIndex:0];//取得运算符栈栈顶元素
            if ([subStr1   isEqualToString:@"#"] && [topStack2   isEqualToString:@"#"]){
                //当取得元素和栈顶元素都为#时，说明表达式运算结束，获取运算结果
                result = [operandStackArray  objectAtIndex:0];
                break;
            }
            //对取得的元素在优先级表中获取优先级
            NSInteger one = [[_opPriority objectForKey:subStr1]integerValue];
            //对栈顶元素在优先级表中获取优先级
            NSInteger two = [[_opPriority objectForKey:topStack2]integerValue];
            
            if (one < two) {
                //取得的运算符的优先级大于栈顶元素优先级时，该运算符直接进栈
                [stack2 insertObject:subStr1 atIndex:0];
                [numberArray   removeObjectAtIndex:0];
            }
            else
            {
                //优先级不大的时候，就要取栈顶运算符先进行运算
                //先取两个运算数，如果取到error说明，表达式输入不合法，直接终止循环
                NSString *strX = [operandStackArray  objectAtIndex:0];
                if ([strX   isEqualToString:@"error"]) {
                    result =@"error";
                    break;
                }
                double x1 = [strX  doubleValue];
                [operandStackArray removeObjectAtIndex:0];
                strX = [operandStackArray  objectAtIndex:0];
                if ([strX   isEqualToString:@"error"]) {
                    result =@"error";
                    break;
                }
                double x2 = [strX doubleValue];
                [operandStackArray removeObjectAtIndex:0];
                [stack2 removeObjectAtIndex:0];
                //计算结果
                result = [self calculateNumbersWithOperator:topStack2 betweenDouble:x2 andDoule:x1];
                if ([result   isEqualToString:@"error"]) {
                    //如果计算返回的结果是error说明输入的表达式不合法
                    break;
                }
                //返回合法结果，就将结果放进运算数栈，进行下一轮处理
                [operandStackArray insertObject:result atIndex:0];
                
            }
        }
    }
    return result;
}

@end
