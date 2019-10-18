//
//  GHDropMenuFilterSwitch.h
//  GHDropMenuDemo
//
//  Created by jinming on 2019/10/18.
//  Copyright © 2019 GHome. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class GHDropMenuFilterSwitch,GHDropMenuModel;

@protocol GHDropMenuFilterSwitchDelegate <NSObject>

- (void)dropMenuFilterSwitch: (GHDropMenuFilterSwitch *)switchItem dropMenuModel:(GHDropMenuModel *)dropMenuModel;

@end

@interface GHDropMenuFilterSwitch : UICollectionViewCell

@property (nonatomic, strong) GHDropMenuModel *dropMenuModel;
@property (nonatomic, weak) id <GHDropMenuFilterSwitchDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
