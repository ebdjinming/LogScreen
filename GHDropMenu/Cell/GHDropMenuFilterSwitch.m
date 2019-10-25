//
//  GHDropMenuFilterSwitch.m
//  GHDropMenuDemo
//
//  Created by jinming on 2019/10/18.
//  Copyright © 2019 GHome. All rights reserved.
//

#import "GHDropMenuFilterSwitch.h"
#import "GHDropMenuModel.h"

@interface GHDropMenuFilterSwitch()

@property (nonatomic, strong) UISwitch *switchItem;

@end

@implementation GHDropMenuFilterSwitch

- (void)setDropMenuModel:(GHDropMenuModel *)dropMenuModel {
    _dropMenuModel = dropMenuModel;
    _switchItem.on = dropMenuModel.logSwitch;
    [self setupUI];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _switchItem.frame = CGRectMake(20, 0, 80, 40);
    //设置点击事件
    [_switchItem addTarget:self action:@selector(swChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.switchItem];
}

- (UISwitch *)switchItem {
    if (_switchItem == nil) {
        _switchItem = [[UISwitch alloc] init];
    }
    return _switchItem;
}

- (void)swChange {
    NSLog(@"切换switch!");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropMenuFilterSwitch:dropMenuModel:)]) {
        [self.delegate dropMenuFilterSwitch:self dropMenuModel:self.dropMenuModel];
    }
}


@end
