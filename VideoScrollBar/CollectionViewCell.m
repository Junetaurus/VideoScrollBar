//
//  CollectionViewCell.m
//  VideoScrollBar
//
//  Created by Zhang on 2019/11/26.
//  Copyright © 2019 CUE. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        _label= [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor redColor];
        _label.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_label];
        //
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_line];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.bounds;
    _line.frame = CGRectMake(0, 20, 2, self.bounds.size.height - 40);
    _line.center = _label.center;
}

@end
