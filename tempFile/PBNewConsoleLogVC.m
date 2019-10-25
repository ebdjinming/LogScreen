//
//  PBNewConsoleLogVC.m
//  MPBBank
//
//  Created by jinming on 2019/10/23.
//

#import "PBNewConsoleLogVC.h"
#import "PBConsoleLogCell.h"
#import "PBNewConsoleLogCell.h"
#import "GHDropMenu.h"
#import "GHDropMenuModel.h"
#import <CMBPBFoundation/NSDate+Additions.h>
#import <CMBPBDatabase/PBKeyValueStore.h>
#import <CMBPBVendor/PBJSOnParser.h>

static NSString * const cellID = @"PBNewConsoleLogCell";

@interface PBNewConsoleLogVC ()<UITableViewDelegate, UITableViewDataSource, GHDropMenuDelegate>

@property (nonatomic, strong) UITableView *tableView;
//从文件中读取的log内容
@property (nonatomic, strong) NSString *content;
//日志过滤时展示的内容
@property (nonatomic, strong) NSArray *displayItems;
//日志未过滤时展示的全部内容
@property (nonatomic, strong) NSArray *originItems;
//筛选菜单配置
@property (nonatomic , strong) GHDropMenuModel *configuration;

@property (nonatomic , strong) GHDropMenu *dropMenu;
//筛选条件字典
@property (nonatomic, strong) NSMutableDictionary *screenDict;
//关键字数组  传递给cell  突出显示
@property (nonatomic, strong) NSMutableArray *keywords;

@end

@implementation PBNewConsoleLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //视图布局
    [self configView];
    //数据加载
    [self loadData];
}

#pragma mark - 页面布局
- (void)configView {
    self.pbNavigationBar.title = @"CocoaLumberjack日志";
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#c9c9ce"];
    //右侧筛选按钮
    [self setupRightNavBarItem];
    
    //tableView初始化
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    //筛选页面初始化
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
    configuration.titles = [configuration creaFilterDropMenuData];
    configuration.recordSeleted = NO;
    self.configuration = configuration;
}

#pragma mark - 加载数据
- (void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readLogFile];
        _originItems = [self getArrayWithContent:_content];
        //判断日志开关是否打开
        if ([self logFileOpen]) {
            _displayItems = _originItems;
        } else {
            _displayItems = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBNewConsoleLogCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        CGFloat cellHeight = [self cellHeightWithArray:[self arrayWithLogContent:_displayItems[indexPath.row]]];
        cell = [[PBNewConsoleLogCell alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, cellHeight)];
    }
    cell.keywords = _keywords;
    cell.contentArray = [self arrayWithLogContent:_displayItems[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = [self cellHeightWithArray:[self arrayWithLogContent:_displayItems[indexPath.row]]];
    return cellHeight;
}

#pragma mark - 将log内容提取成数组
- (NSArray *)arrayWithLogContent:(NSString *)content {
    if ([NSString isStringEmpty:content]) {
        return nil;
    }
    NSMutableArray *strArray = [NSMutableArray array];
    NSArray<NSString *> *array = [content componentsSeparatedByString:@"->"];
    NSArray<NSString *> *arr1 = [array[0] componentsSeparatedByString:@" ["];
    NSArray<NSString *> *arr2 = [array[2] componentsSeparatedByString:@"\n"];
    //logTime
    [strArray addObject:arr1[0]];
    //logFile and function
    NSString *fileFunc = arr1[1];
    [strArray addObject:[fileFunc substringToIndex:fileFunc.length-1]];
    //line
    NSString *line = array[1];
    [strArray addObject:[line substringWithRange:NSMakeRange(6, line.length-7)]];
    //thread
    NSString *thread = arr2[0];
    [strArray addObject:[thread substringWithRange:NSMakeRange(8, thread.length-9)]];
    //logType
    NSString *logType = arr2[1];
    [strArray addObject:[logType substringWithRange:NSMakeRange(1, logType.length-2)]];
    //logContent
    [strArray addObject:[array[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    return strArray.copy;
}

#pragma mark - 通过获取的数据计算Cell的高度
- (CGFloat)cellHeightWithArray:(NSArray *)array {
    CGFloat height = 0;
    if (array.count > 0) {
        for (NSString *str in array) {
            if (str.length > 20) {
                height += [self getWidth:ScreenWidth-20 title:str fontSize:16];
            } else {
                height += [self getWidth:ScreenWidth-75-20-10 title:str fontSize:16];
            }
        }
        //file&func content 单独留一行，特殊处理
        height += (2 * [self getWidth:ScreenWidth-75-20-10 title:@"content" fontSize:16]);
        height += 5;//顶部留5px的间隔
    }
    return height;
}

#pragma mark - 固定宽度的条件下获取Label的高度
- (CGFloat)getWidth:(CGFloat)width title:(NSString *)title fontSize:(NSInteger)fontSize {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    // 自适应
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height + 5;           //留5px的间隔
    return height;
}

#pragma mark - 数据处理
- (void)readLogFile {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *dirPath = [documentPath stringByAppendingPathComponent:@"PBLog"];
    //遍历目录下的文件，获取文件名
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    NSString *filePath;
    //Todo...
    //未指定log的文件名，所以需要遍历，后续优化
    for(NSString *fileName in enumerator){
        filePath = [dirPath stringByAppendingPathComponent:fileName];
    }
    _content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

- (NSArray *)getArrayWithContent:(NSString *)content {
    if (!content) {
        return nil;
    }
    NSString *str;
    NSMutableArray *strArray = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:content];
    while ([scanner scanUpToString:@"\n20" intoString:&str]) {
        [strArray addObject:str];
    }
    return [strArray copy];
}

# pragma mark - 添加右侧筛选按钮
- (void)setupRightNavBarItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    [button setTitle:@"筛选" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickScreenBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    NSMutableArray *items = [@[item] mutableCopy];
    
    self.pbNavigationBar.rightBarButtonItem = nil;
    self.pbNavigationBar.rightBarButtonItems = nil;
    [self.pbNavigationBar setRightBarButtonItems:items];
}

#pragma mark - 右侧筛选按钮点击事件
- (void)clickScreenBtn {
    weakself(self);
    GHDropMenu *dropMenu = [GHDropMenu creatDropFilterMenuWidthConfiguration:self.configuration dropMenuTagArrayBlock:^(NSArray * _Nonnull tagArray) {
        [weakSelf getStrWith:tagArray];
    }];
    dropMenu.titleSeletedImageName = @"up_normal";
    dropMenu.titleNormalImageName = @"down_normal";
    dropMenu.delegate = self;
    dropMenu.durationTime = 0.5;
    self.dropMenu = dropMenu;
    [dropMenu show];
}

#pragma mark - 点击确认按钮后的代理方法
- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuTitleModel:(GHDropMenuModel *)dropMenuTitleModel {
    self.pbNavigationBar.title = [NSString stringWithFormat:@"筛选结果: %@",dropMenuTitleModel.title];
}

- (void)dropMenu:(GHDropMenu *)dropMenu tagArray:(NSArray *)tagArray {
    //获取筛选条件
    [self getStrWith:tagArray];
    //筛选数据
    [self conditionScreen];
}

- (void)conditionScreen {
    //判断日志开关
    if (![self logFileOpen]) {
        _displayItems = nil;
        //数据刷新
        [_tableView reloadData];
        return;
    }
    
    //数据重置
    _displayItems = _originItems;
    //搜索条件为空 则恢复显示所有数据
    if (_screenDict.count != 0) {
        NSArray *singleArr = _screenDict[@"single"];
        NSArray *checkArr = _screenDict[@"check"];
        NSString *beginTime = _screenDict[@"beginTime"];
        NSString *endTime = _screenDict[@"endTime"];
        
        //单选过滤
        if (singleArr != nil && singleArr.count != 0) {
            for (NSString *screenStr in _screenDict[@"single"]) {
                NSMutableArray *screen = [[NSMutableArray alloc] initWithArray:_displayItems];
                NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", screenStr];
                _displayItems = [screen filteredArrayUsingPredicate:preicate];
            }
        }
        
        NSMutableArray *array = [NSMutableArray array];
        //复选过滤
        if (checkArr != nil && checkArr.count != 0) {
           for (NSString *screenStr in _screenDict[@"check"]) {
                NSMutableArray *screen = [[NSMutableArray alloc] initWithArray:_displayItems];
                NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", screenStr];
                [array addObjectsFromArray:[screen filteredArrayUsingPredicate:preicate]];
            }
        } else {
            [array addObjectsFromArray:_displayItems];
        }

        //时间过滤
        if (beginTime != nil && endTime != nil && [self compareStartDate:beginTime endDate:endTime]) {
            NSMutableArray *dateScreen = [[NSMutableArray alloc] initWithArray:array];
            [array removeAllObjects];
            for (NSString *content in dateScreen) {
                NSArray<NSString *> *arr1 = [content componentsSeparatedByString:@" ["];
                NSString *logTime = [arr1[0] substringWithRange:NSMakeRange(5, 11)];
                if ([self compareStartDate:beginTime endDate:logTime] && [self compareStartDate:logTime endDate:endTime]) {
                    [array addObject:content];
                }
            }
        }
        _displayItems = array.copy;
    }
    //数据刷新
    [_tableView reloadData];
}

#pragma mark - 获取筛选数据
- (void)getStrWith: (NSArray *)tagArray {
    if (_screenDict == nil) {
        _screenDict = [NSMutableDictionary dictionary];
        _keywords = [NSMutableArray array];
    } else {
        [_screenDict removeAllObjects];
        [_keywords removeAllObjects];
    }
    //单选数组
    NSMutableArray *singleArr = [NSMutableArray array];
    //复选数组
    NSMutableArray *checkArr = [NSMutableArray array];
    if (tagArray.count) {
        for (GHDropMenuModel *dropMenuTagModel in tagArray) {
            if (dropMenuTagModel.tagSeleted) {
                if (dropMenuTagModel.tagName.length) {
                    if (dropMenuTagModel.isMultiple) {
                        [checkArr addObject:dropMenuTagModel.tagName];
                    } else {
                        [singleArr addObject:dropMenuTagModel.tagName];
                    }
                }
            }
            if (dropMenuTagModel.singleInput.length) {
                [singleArr addObject:dropMenuTagModel.singleInput];
                //保存输入的文本内容
                [self saveSearchHistoryWithStr:dropMenuTagModel.singleInput];
            }
            if (dropMenuTagModel.beginTime.length) {
                [_screenDict setObject:dropMenuTagModel.beginTime forKey:@"beginTime"];
            }
            if (dropMenuTagModel.endTime.length) {
                [_screenDict setObject:dropMenuTagModel.endTime forKey:@"endTime"];
            }
        }
        if (checkArr.count) {
            [_screenDict setObject:checkArr forKey:@"check"];
            [_keywords addObjectsFromArray:checkArr];
        }
        if (singleArr.count) {
            [_screenDict setObject:singleArr forKey:@"single"];
            [_keywords addObjectsFromArray:singleArr];
        }
    }
}

#pragma mark - 比较日期大小
- (BOOL)compareStartDate:(NSString *)start endDate:(NSString *)end {
    //拼接上年份
    NSString *tmpStr = [NSDate stringWithDate:[NSDate date] format:@"yyyy-"];
    NSString *ystart = [tmpStr stringByAppendingString:start];
    NSString *yend = [tmpStr stringByAppendingString:end];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:ystart];
    NSDate *endDate = [dateFormatter dateFromString:yend];
    if (startDate == nil || endDate == nil ) {
        return NO;
    }
    // 判断是否大于当前时间
    if ([startDate earlierDate:endDate] == startDate) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 保存搜索历史
- (void)saveSearchHistoryWithStr:(NSString *)string {
    NSString *history = [PBKeyValueStore stringForKey:@"PBNewConsoleLogHistory"];
    NSArray *array = [[PBJSONParser objectWithJSONString:history] objectForKey:@"history"];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:array];
    [newArray addObject:string];
    NSDictionary *dict = @{
        @"history":newArray
    };
    NSString *newHistory = [PBJSONParser jsonStringFromObject:dict];
    [PBKeyValueStore setString:newHistory forKey:@"PBNewConsoleLogHistory"];
}

#pragma mark - 日志开关

- (BOOL)logFileOpen {
    BOOL isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"PBTestToolNSLogRedirectIsOpen"];
    return isOpen;
}

#pragma mark - NavigationBar
- (BOOL)needNavigationBar {
    return YES;
}

- (PBBarButtonItemType)preferredLeftBarButtonItemType {
    return PBBarButtonItemTypeBack;
}

@end
