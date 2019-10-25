//
//  PBNewConsoleLogCell.m
//  MPBBank
//
//  Created by jinming on 2019/10/23.
//

#import "PBNewConsoleLogCell.h"
#import <CMBPBVendor/PureLayout.h>

@interface PBNewConsoleLogCell()

@property (nonatomic, strong) NSMutableArray *strArray;
@property (nonatomic, strong) NSMutableArray *attributedStrArray;

//显示内容的label
@property (nonatomic ,strong) UILabel *date;
@property (nonatomic ,strong) UILabel *fileFunc;
@property (nonatomic ,strong) UILabel *line;
@property (nonatomic ,strong) UILabel *thread;
@property (nonatomic ,strong) UILabel *logType;
@property (nonatomic ,strong) UILabel *content;

@end

@implementation PBNewConsoleLogCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.attributedStrArray = [NSMutableArray array];
        [self configView];
    }
    return self;
}

- (void)configView {
    _date = [[UILabel alloc] init];
    [self addSubview:_date];
    
    _fileFunc = [[UILabel alloc] init];
    [self addSubview:_fileFunc];
    
    _line = [[UILabel alloc] init];
    [self addSubview:_line];
    
    _thread = [[UILabel alloc] init];
    [self addSubview:_thread];
    
    _logType = [[UILabel alloc] init];
    [self addSubview:_logType];
    
    _content = [[UILabel alloc] init];
    [self addSubview:_content];
}

- (void)setlayout {
    
    CGFloat labelHeight = [self getWidth:75 title:@"file&func:" fontSize:16];
    CGFloat width = ScreenWidth-75-20-10;
    //第一行 LogTime
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.text = @"logTime:";
    _date.attributedText = _attributedStrArray[0];
    [self addSubview:dateLabel];
    
    CGFloat dateHeight = [self getWidth:width title:_strArray[0] fontSize:16];
    [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [dateLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [dateLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_date autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [_date autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:dateLabel withOffset:10];
    [_date autoSetDimensionsToSize:CGSizeMake(width, dateHeight)];
    
    //第二行 file&func
    UILabel *fileFuncLabel = [[UILabel alloc] init];
     
    fileFuncLabel.text = @"file&func:";
    _fileFunc.attributedText = _attributedStrArray[1];
    _fileFunc.font = [UIFont fontWithName:@"Helvetica" size:16];
    _fileFunc.numberOfLines = 0;
    [self addSubview:fileFuncLabel];
    
    
    CGFloat fileFuncHeight = [self getWidth:ScreenWidth-40 title:_strArray[1] fontSize:16];
    [fileFuncLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_date withOffset:5];
    [fileFuncLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [fileFuncLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_fileFunc autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:fileFuncLabel];
    [_fileFunc autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [_fileFunc autoSetDimensionsToSize:CGSizeMake(ScreenWidth-20, fileFuncHeight)];
    
    //第三行 line
    UILabel *lineLabel = [[UILabel alloc] init];
    
    lineLabel.text = @"line:";
    _line.attributedText = _attributedStrArray[2];
    [self addSubview:lineLabel];
    
    CGFloat lineHeight = [self getWidth:width title:_strArray[2] fontSize:16];
    [lineLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_fileFunc withOffset:5];
    [lineLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [lineLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_fileFunc withOffset:5];
    [_line autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lineLabel withOffset:10];
    [_line autoSetDimensionsToSize:CGSizeMake(width, lineHeight)];
    
    //第四行 thread
    UILabel *threadLabel = [[UILabel alloc] init];
    threadLabel.text = @"thread:";
    [self addSubview:threadLabel];
    _thread.attributedText = _attributedStrArray[3];
    
    CGFloat threadHeight = [self getWidth:ScreenWidth-20 title:_strArray[3] fontSize:16];
    [threadLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:5];
    [threadLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [threadLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_thread autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:threadLabel withOffset:10];
    [_thread autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:5];
    [_thread autoSetDimensionsToSize:CGSizeMake(width, threadHeight)];
    
    //第五行 logType
    UILabel *logTypeLabel = [[UILabel alloc] init];
    logTypeLabel.text = @"logType:";
    [self addSubview:logTypeLabel];
    _logType.attributedText = _attributedStrArray[4];
    
    CGFloat logTypeHeight = [self getWidth:width title:_strArray[4] fontSize:16];
    [logTypeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_thread withOffset:5];
    [logTypeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [logTypeLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_logType autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:logTypeLabel withOffset:10];
    [_logType autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_thread withOffset:5];
    [_logType autoSetDimensionsToSize:CGSizeMake(width, logTypeHeight)];

    //第六行 content
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"content:";
    [self addSubview:contentLabel];
    
    _content.attributedText = _attributedStrArray[5];
    _content.font = [UIFont fontWithName:@"Helvetica" size:16];
    _content.numberOfLines = 0;
    
    CGFloat contentHeight = [self getWidth:ScreenWidth-20 title:_strArray[5] fontSize:16];
    [contentLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_logType withOffset:5];
    [contentLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [contentLabel autoSetDimensionsToSize:CGSizeMake(75, labelHeight)];
    [_content autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [_content autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:contentLabel];
    [_content autoSetDimensionsToSize:CGSizeMake(ScreenWidth-20, contentHeight)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentArray:(NSArray *)contentArray {
    if (contentArray == nil || contentArray.count == 0) {
        return;
    }
    _strArray = [[NSMutableArray alloc] initWithArray:contentArray];
    [self highlightContentWithKeywordArray:_keywords];
    if (_attributedStrArray.count != 6) {
        return;
    }
    //重新布局
    [self setlayout];
}

- (void)highlightContentWithKeywordArray:(NSArray *)keywords {
    
    if (!_strArray || _strArray.count == 0) {
        return;
    }
    
    for (NSString *content in _strArray) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:content];
        for (NSString *keyword in keywords) {
            //忽略大小写
            NSString *lowContent = [content lowercaseString];
            NSString *lowKeyword = [keyword lowercaseString];
            NSArray *rangeArray = [self rangeOfSubString:lowKeyword inString:lowContent];
            for (NSValue *value in rangeArray) {
                NSRange range = [value rangeValue];
                [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            }
        }
        [_attributedStrArray addObject:text];
    }
}

- (NSArray*)rangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSRange targetRange = NSMakeRange(0, string.length);
    NSRange range = targetRange;
    while (true) {
        range = [string rangeOfString:subStr options:NSLiteralSearch range:targetRange];
        if (range.location != NSNotFound) {
            [rangeArray addObject:[NSValue valueWithRange:range]];
            targetRange = NSMakeRange(NSMaxRange(range), string.length-NSMaxRange(range));
        } else {
            break;
        }
    }
    return rangeArray;
}

- (CGFloat)getWidth:(CGFloat)width title:(NSString *)title fontSize:(NSInteger)fontSize {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    // 自适应
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

@end
