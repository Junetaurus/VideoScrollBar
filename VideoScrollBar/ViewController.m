//
//  ViewController.m
//  VideoScrollBar
//
//  Created by Zhang on 2019/11/25.
//  Copyright © 2019 CUE. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"

static CGFloat itemWidth = 60.0f;
static NSInteger hoursTotal = 24;

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *showLabel;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *flagLabel;
@property (nonatomic, strong) NSMutableArray *timeArray;

@end

@implementation ViewController

- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
        _showLabel.textColor = [UIColor redColor];
        _showLabel.font = [UIFont systemFontOfSize:15];
        _showLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_showLabel];
    }
    return _showLabel;
}

- (void)test {
    NSString *time = @"22:22:22";
    CGFloat offset =  [self getCoordinatesWithTime:time];
    offset = offset - _collectionView.contentInset.left;
    CGPoint point = CGPointMake(offset, 0);
    [_collectionView setContentOffset:point animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    //
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, 100);
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.center = self.view.center;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    CGFloat edgeInsets = CGRectGetWidth(_collectionView.bounds)/2.0 - itemWidth/2;
    _collectionView.contentInset = UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    [_collectionView registerClass:CollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(CollectionViewCell.class)];
    [self.view addSubview:_collectionView];
    
    _flagLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 2)/2, 0, 2, 100)];
    _flagLabel.center = self.view.center;
    _flagLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:_flagLabel];
    
    
    [self test];
}

- (NSMutableArray *)timeArray {
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
        for (NSInteger i = 0; i < hoursTotal; i++) {
            [_timeArray addObject:@(i)];
        }
    }
    return _timeArray;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return hoursTotal + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(CollectionViewCell.class) forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%ld", indexPath.item];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self stop:scrollView.contentOffset.x];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stop:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stop:scrollView.contentOffset.x];
    }
}

- (void)stop:(CGFloat)offsetX {
    NSLog(@"%s - %f",__func__, offsetX + _collectionView.contentInset.left);
    self.showLabel.text = [self getTimeWithCoordinates:offsetX + _collectionView.contentInset.left];
}

#pragma mark - 坐标和时间之间的转换
- (NSString *)getTimeWithCoordinates:(CGFloat)offset {
    offset = round(offset);
    //
    NSLog(@"%s - %f", __func__, offset);
    //
    NSInteger at = 3600 * hoursTotal;
    //校验
    NSInteger index = 0;
    for (NSNumber *time in self.timeArray) {
        if ([time integerValue] * itemWidth == offset) {
            index = [_timeArray indexOfObject:time];
            //
            at = at - [time integerValue] * 3600;
            offset = offset - itemWidth;
            //
            return [NSString stringWithFormat:@"%0.f:%@:%@", [time floatValue], @"00", @"00"];
            break;
        }
    }
    //剩余时间
    CGFloat ms = at * (offset/(itemWidth * (hoursTotal - index)));
    //
    NSInteger ss = 1;
    NSInteger mi = ss * 60;
    NSInteger hh = mi * 60;
    NSInteger dd = hh * 24;
    //剩余的
    NSInteger day = 0;// 天
    NSInteger hour = (ms - day * dd) / hh;// 时
    NSInteger minute = (ms - day * dd - hour * hh) / mi;// 分
    NSInteger second = (ms - day * dd - hour * hh - minute * mi) / ss;// 秒
    //
    return [NSString stringWithFormat:@"%ld:%ld:%ld", hour, minute, second];
}

- (CGFloat)getCoordinatesWithTime:(NSString *)time {
    CGFloat offset = 0.0;
    NSArray *array = [time componentsSeparatedByString:@":"];
    if (array && array.count == 3) {
        NSInteger hour = [array[0] integerValue];// 时
        NSInteger minute = [array[1] integerValue];// 分
        NSInteger second = [array[2] integerValue];// 秒
        //校验
        NSInteger index = 0;
        for (NSNumber *time in self.timeArray) {
            if ([time integerValue] == hour) {
                index = [_timeArray indexOfObject:time];
                offset = itemWidth * index;
                break;
            }
        }
        //
        NSInteger ms = minute * 60 + second;
        offset = offset + ms * itemWidth / 3600.0;
    }
    return offset;
}

@end
