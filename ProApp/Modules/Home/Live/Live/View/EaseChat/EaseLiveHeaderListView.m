//
//  EaseLiveHeaderListView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/15.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveHeaderListView.h"
#import "CBOccupantsCountView.h"
#import "EaseLiveCastView.h"
#import "CBAppLiveVO.h"

#define kCollectionIdentifier @"collectionCell"

@interface EaseLiveHeaderCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *headerImage;

@end

@implementation EaseLiveHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _headerImage = [[UIImageView alloc] init];
        _headerImage.image = [UIImage imageNamed:@"placeholder_head"];
        _headerImage.frame = CGRectMake(0, 0, 30, 30);
        _headerImage.layer.cornerRadius = 15;
        _headerImage.layer.masksToBounds = YES;
        [self.contentView addSubview:_headerImage];
    }
    return self;
}

@end

@interface EaseLiveHeaderListView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    EasePublishModel *_model;
}
// 个人信息
@property (nonatomic, strong) CBAppLiveVO *room;
@property (nonatomic, copy)   NSString *chatRoomId;     ///< 聊天室ID

// 贡献榜单
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EaseLiveCastView *liveCastView;
@property (nonatomic, strong) NSMutableArray <CBAppLiveVO *> *dataArray;

// 总人数
@property (nonatomic, strong) CBOccupantsCountView *occupantsCountView;
@property (nonatomic, assign) NSInteger occupantsCount;
@property (nonatomic, assign) NSUInteger currentPage;   ///< 当前页

@end

@implementation EaseLiveHeaderListView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self addSubview:self.collectionView];
        [self addSubview:self.liveCastView];
        _currentPage = 1;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame room:(CBAppLiveVO*)room
{
    self = [super initWithFrame:frame];
    if (self) {
        _room = room;
        [self addSubview:self.liveCastView];
        [self addSubview:self.occupantsCountView];
        [self addSubview:self.collectionView];
        _currentPage = 1;
    }
    return self;
}

- (void)httpGetLiveRoomOnlineUserList {
    NSString *url = urlGetLiveRoomOnlineUserList;
    NSDictionary *param = @{@"room_id": self.room.room_id,
                            @"token": [CBLiveUserConfig getOwnToken],
                            @"page": @(self.currentPage)};
    [PPNetworkHelper POST:url parameters:param success:^(id responseObject) {
        NSNumber *code = [responseObject valueForKey:@"code"];
        if ([code isEqualToNumber:@200]) {
            NSArray *resultList = [NSArray modelArrayWithClass:[CBAppLiveVO class] json:responseObject[@"data"]];
            if (resultList.count < 20 && self.currentPage > 1) {
                self.currentPage--;
            } else {
                [self.dataArray addObjectsFromArray:resultList];
                [self.collectionView reloadData];
            }
        } else {
            NSString *descrp = responseObject[@"descrp"];
            [MBProgressHUD showAutoMessage:descrp];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - getter

- (NSMutableArray*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView*)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        CGFloat left = self.width - 150 - 10;
        CGFloat width = left - 40 - 10;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(left, 10, width, 30) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseLiveHeaderCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), 0);
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (EaseLiveCastView*)liveCastView {
    if (!_liveCastView) {
        _liveCastView = [[EaseLiveCastView alloc] initWithFrame:CGRectMake(10, 10, 150, 30.f) room:_room];
    }
    return _liveCastView;
}

- (CBOccupantsCountView *)occupantsCountView {
    if (!_occupantsCountView) {
        _occupantsCountView = [[CBOccupantsCountView alloc] initWithFrame:CGRectMake(self.width - 40, 10, 40, 30) room:_room];
    }
    return _occupantsCountView;
}

- (void)setDelegate:(id<EaseLiveHeaderListViewDelegate>)delegate {
    _delegate = delegate;
    self.liveCastView.delegate = delegate;
    self.occupantsCountView.delegate = delegate;
}

#pragma mark - public

// 加载聊天室详细信息
- (void)loadHeaderListWithChatroomId:(NSString*)chatroomId {
    self.chatRoomId = chatroomId;
    @weakify(self);
    // 获取聊天室详情
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        @strongify(self);
        if (!aError) {
            self.occupantsCount = aChatroom.occupantsCount;
//            [self.liveCastView setNumberOfChatroom:self.occupantsCount];
        }
    }];
    
    // 获取聊天室成员列表
    // 不从环信获取聊天室成员，从自己的业务后台获取
//    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:chatroomId cursor:nil pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
//        @strongify(self);
//        if (!aError) {
//            [self.dataArray addObjectsFromArray:aResult.list];
//            [self.collectionView reloadData];
//        }
//    }];
    self.dataArray = [NSMutableArray array];
    [self httpGetLiveRoomOnlineUserList];
}

// 单用户加入直播间
- (void)joinChatroomWithUsername:(NSString *)username
{
//    if ([self.dataArray count] > 10) {
//        [self.dataArray removeObjectAtIndex:0];
//    }
//    if ([self.dataArray containsObject:username]) {
//        return;
//    }
//    [self.dataArray insertObject:[username copy] atIndex:0];
//    self.occupantsCount++;
//    [self.liveCastView setNumberOfChatroom:self.occupantsCount];
//    [self.collectionView reloadData];
}

// 单用户离开直播间
- (void)leaveChatroomWithUsername:(NSString *)username
{
//    for (int index = 0; index < [self.dataArray count]; index ++) {
//        NSString *name = [self.dataArray objectAtIndex:index];
//        if ([name isEqualToString:username]) {
//            [self.dataArray removeObjectAtIndex:index];
//        }
//    }
//    self.occupantsCount--;
//    [self.liveCastView setNumberOfChatroom:self.occupantsCount];
//    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionIdentifier forIndexPath:indexPath];
    [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:self.dataArray[indexPath.row].avatar] placeholderImage:[UIImage imageNamed:@"placeholder_head"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
    }
    if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 30);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeaderWithUsername:)]) {
//        [self.delegate didSelectHeaderWithUsername:nil];
//    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
