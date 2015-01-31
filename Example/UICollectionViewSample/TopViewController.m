//
//  TopViewController.m
//  UICollectionViewSample
//
//  Created by keygx on 2015/01/18.
//  Copyright (c) 2014年 keygx. All rights reserved.
//

#import "TopViewController.h"
#import "CollectionCell.h"

@interface TopViewController () <UICollectionViewDataSource/*, UICollectionViewDelegate*/>

@property (nonatomic) NSMutableArray *dataList;
@property (nonatomic) NSMutableArray *selectedList;
@property (nonatomic) UIImageView *dragImageView;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *drop;

@end

@implementation TopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    
    [self resetDataList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)resetDataList
{
    self.dataList = [@[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg", @"8.jpg", @"9.jpg", @"10.jpg", @"11.jpg", @"12.jpg", @"13.jpg", @"14.jpg", @"15.jpg", @"16.jpg", @"17.jpg", @"18.jpg", @"19.jpg", @"20.jpg"] mutableCopy];
    
    self.selectedList = [@[] mutableCopy];
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // cellの設定
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.dataList[indexPath.row]];
    cell.tag = indexPath.row; // cellにtagを設定
    
    // cellに長押しジェスチャーを追加
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
    longPressGesture.minimumPressDuration = 1.0;
    longPressGesture.allowableMovement = 10.0;
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

/*- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // タップDelegate
    NSLog(@"tapped:%@", @(indexPath.row));
}*/

// 長押し
- (void)didLongPressCell:(UILongPressGestureRecognizer *)sender
{
    // 長押しされたcellのtag
    NSInteger tag = sender.view.tag;
    // 長押しされた画面座標
    CGPoint pressPoint = [sender locationOfTouch:0 inView:self.view];
    
    UIImage *img;
    CGFloat w = 88;
    CGFloat h = 84;
    CGFloat centerX = pressPoint.x-w/2;
    CGFloat centerY = pressPoint.y-h/2;
    CollectionCell *cell;
    
    // 対象のcellを探索
    for (id view in self.collectionView.subviews) {
        if ([view isKindOfClass:[CollectionCell class]]) {
            CollectionCell *cc = (CollectionCell *)view;
            if (cc.tag == tag) {
                cell = cc;
                break;
            }
        }
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 長押し開始
        NSLog(@"pressed cell tag:%@", @(tag));
        // ドラッグ用のImageViewを作成
        self.dragImageView = [[UIImageView alloc] initWithFrame:CGRectMake(centerX, centerY, w, h)];
        self.dragImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.dragImageView.layer.shadowOffset = CGSizeMake(2, 2);
        self.dragImageView.layer.shadowOpacity = 0.4f;
        self.dragImageView.image = cell.imageView.image;
        [self.view addSubview:self.dragImageView];
        // 対象のcellにあるImageViewを非表示
        cell.imageView.hidden = YES;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        // ドラッグ中
        //NSLog(@"press point: %@", NSStringFromCGPoint(pressPoint));
        
        // ドラッグ中座標更新
        self.dragImageView.frame = CGRectMake(centerX, centerY, w, h);
        
        // dropViewの範囲判定
        CGFloat minX = self.drop.frame.origin.x - w;
        CGFloat maxX = self.drop.frame.origin.x + self.drop.frame.size.width;
        CGFloat minY = self.drop.frame.origin.y - h;
        CGFloat maxY = self.drop.frame.origin.y + self.drop.frame.size.height;
        //NSLog(@"x:%f ~ %f, y:%f ~ %f", minX, maxX, minY, maxY);
        //NSLog(@"x:%f, y:%f", pressPoint.x, pressPoint.y);
        if ((minX <= centerX && centerX <= maxX) && (minY <= centerY && centerY <= maxY)) {
            // 範囲内
            self.drop.backgroundColor = [UIColor orangeColor];
            self.selected = YES;
        } else {
            // 範囲外
            self.drop.backgroundColor = [UIColor lightGrayColor];
            self.selected = NO;
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // リリースされた
        img = nil;
        self.dragImageView.image = nil;
        [self.dragImageView removeFromSuperview];
        // 対象のcellにあるImageViewを表示
        cell.imageView.hidden = NO;
        // dropViewの色を戻す
        self.drop.backgroundColor = [UIColor lightGrayColor];
        
        if (self.isSelected) {
            // 選択済みデータに追加
            [self.selectedList addObject:self.dataList[tag]];
            
            // 該当データの削除
            self.selected = NO;
            [self.dataList removeObjectAtIndex:tag];
            [self.collectionView reloadData];
        }
    }
}

- (IBAction)drop:(id)sender
{
    // タイトル、メッセージ
    NSString *title = @"";
    NSString *message = @"";
    
    if ([self.selectedList count] > 0) {
        title = @"Selected ...";
        NSString *last = [self.selectedList lastObject];
        for (NSString *str in self.selectedList) {
            if (str == last) {
                message = [message stringByAppendingString:str];
            } else {
                message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", str]];
            }
        }
    } else {
        title = @"No Selected Items.";
    }
    
    // アラート
    UIAlertController *alert = nil;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      [wself resetDataList];
                                                  }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc
{
    self.dataList = nil;
    self.selectedList = nil;
    self.dragImageView = nil;
}

@end
