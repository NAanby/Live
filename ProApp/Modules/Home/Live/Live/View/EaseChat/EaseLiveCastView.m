//
//  EaseLiveCastView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCastView.h"

#import "CBAppLiveVO.h"

@interface EaseLiveCastView ()
{
    CBAppLiveVO *_room;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation EaseLiveCastView

- (instancetype)initWithFrame:(CGRect)frame room:(CBAppLiveVO*)room
{
    self = [super initWithFrame:frame];
    if (self) {
        _room = room;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = CGRectGetHeight(frame)/2;
        
        [self addSubview:self.headImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.numberLabel];
        
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_room.avatar] placeholderImage:[UIImage imageNamed:@"placeholder_head"]];
        self.nameLabel.text = _room.user_nicename;
        self.numberLabel.text = [NSString stringWithFormat:@"房间号: %@", _room.room_id];
    }
    return self;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(0, 0, self.height, self.height);
        _headImageView.image = [UIImage imageNamed:@"placeholder_head"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = CGRectGetHeight(_headImageView.frame)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeadImage)];
        _headImageView.userInteractionEnabled = YES;
        [_headImageView addGestureRecognizer:tap];
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(_headImageView.width + 8.f, 2.f, self.width - (_headImageView.width + 10.f), self.height/2);
        _nameLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.frame = CGRectMake(_headImageView.width + 8.f, self.height/2+1, self.width - (_headImageView.width + 10.f), self.height/2);
        _numberLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:9];
        _numberLabel.textColor = [UIColor whiteColor];
    }
    return _numberLabel;
}

#pragma mark - action
- (void)didSelectHeadImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeaderWithUsername:)]) {
        [self.delegate didSelectHeaderWithUsername:_room.user_nicename];
    }
}

#pragma mark - public 

- (void)setNumberOfChatroom:(NSInteger)number
{
    _numberLabel.text = [NSString stringWithFormat:@"%ld%@",(long)number ,NSLocalizedString(@"profile.people", @"")];
}

@end
