//
//  PBNewConsoleLogCell.h
//  MPBBank
//
//  Created by jinming on 2019/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBNewConsoleLogCell : UITableViewCell

//具体显示的内容数组
@property (nonatomic, strong) NSArray *contentArray;
//关键字数组
@property (nonatomic, strong) NSArray *keywords;

@end

NS_ASSUME_NONNULL_END
