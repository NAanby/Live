//
//  CBPlayerScrollView.m
//  inke
//
//  Created by Sam on 2/7/17.
//  Copyright © 2017 Zhejiang University of Tech. All rights reserved.
//

#import "CBPlayerScrollView.h"
#import "ALinLive.h"

@interface CBPlayerScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray * lives;
@property (nonatomic, strong) ALinLive *live;
@property (nonatomic, strong) UIImageView *upperImageView, *middleImageView, *downImageView;
@property (nonatomic, strong) ALinLive *upperLive, *middleLive, *downLive;
@property (nonatomic, assign) NSInteger currentIndex, previousIndex;

@end

@implementation CBPlayerScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.contentSize = CGSizeMake(0, frame.size.height * 3);
        self.contentOffset = CGPointMake(0, frame.size.height);
        self.pagingEnabled = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor bgColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        
        // image views
        // blur effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        // blur view
        UIVisualEffectView *visualEffectViewUpper = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        UIVisualEffectView *visualEffectViewMiddle = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        UIVisualEffectView *visualEffectViewDown = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.upperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.middleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        self.downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height*2, frame.size.width, frame.size.height)];
        // add image views
        [self addSubview:self.upperImageView];
        [self addSubview:self.middleImageView];
        [self addSubview:self.downImageView];
        self.upperImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.middleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.downImageView.contentMode = UIViewContentModeScaleAspectFill;
        visualEffectViewUpper.frame = self.upperImageView.frame;
        [self addSubview:visualEffectViewUpper];
        visualEffectViewMiddle.frame = self.middleImageView.frame;
        [self addSubview:visualEffectViewMiddle];
        visualEffectViewDown.frame = self.downImageView.frame;
        [self addSubview:visualEffectViewDown];
    }
    return self;
}

- (void)updateForLives:(NSMutableArray *)livesArray withCurrentIndex:(NSInteger)index {
    if (livesArray.count && [livesArray firstObject])
    {
        [self.lives removeAllObjects];
        [self.lives addObjectsFromArray:livesArray];
        self.currentIndex = index;
        self.previousIndex = index;
        
        _upperLive = [[ALinLive alloc] init];
        _middleLive = (ALinLive *)_lives[_currentIndex];
        _downLive = [[ALinLive alloc] init];
        
        if (_currentIndex == 0) {
            _upperLive = (ALinLive *)[_lives lastObject];
        } else {
            _upperLive = (ALinLive *)_lives[_currentIndex - 1];
        }
        if (_currentIndex == _lives.count - 1) {
            _downLive = (ALinLive *)[_lives firstObject];
        } else {
            _downLive = (ALinLive *)_lives[_currentIndex + 1];
        }
        
        [self prepareForImageView:self.upperImageView withLive:_upperLive];
        [self prepareForImageView:self.middleImageView withLive:_middleLive];
        [self prepareForImageView:self.downImageView withLive:_downLive];
    }
}

- (void)prepareForImageView:(UIImageView *)imageView withLive:(ALinLive *)live {
//    if (![live.creator.portrait hasPrefix:IMAGE_SERVER_HOST]) {
//        live.creator.portrait = [IMAGE_SERVER_HOST stringByAppendingString:live.creator.portrait];
//    }
//    [imageView downloadImage:live.creator.portrait placeholder:@"default_room"];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:live.bigpic]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (self.lives.count) {
        if (offset >= 2*self.frame.size.height)
        {
            // slides to the down player
            scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
            _currentIndex++;
            self.upperImageView.image = self.middleImageView.image;
            self.middleImageView.image = self.downImageView.image;
            if (_currentIndex == self.lives.count - 1) {
                _downLive = [self.lives firstObject];
            }
            else if (_currentIndex == self.lives.count) {
                _downLive = self.lives[1];
                _currentIndex = 0;
            }
            else {
                _downLive = self.lives[_currentIndex+1];
            }
            [self prepareForImageView:self.downImageView withLive:_downLive];
            if (_previousIndex == _currentIndex) {
                return;
            }
            if ([self.playerDelegate respondsToSelector:@selector(playerScrollView:currentPlayerIndex:)]) {
                [self.playerDelegate playerScrollView:self currentPlayerIndex:_currentIndex];
                _previousIndex = _currentIndex;
                NSLog(@"current index in delegate: %ld -%s",_currentIndex,__FUNCTION__);
            }
        }
        else if (offset <= 0)
        {
            // slides to the upper player
            scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
            _currentIndex--;
            self.downImageView.image = self.middleImageView.image;
            self.middleImageView.image = self.upperImageView.image;
            if (_currentIndex == 0) {
                _upperLive = [self.lives lastObject];
                
            }
            else if (_currentIndex == -1) {
                _upperLive = self.lives[self.lives.count - 2];
                _currentIndex = self.lives.count-1;
            }
            else {
                _upperLive = self.lives[_currentIndex - 1];
            }
            [self prepareForImageView:self.upperImageView withLive:_upperLive];
            if (_previousIndex == _currentIndex) {
                return;
            }
            if ([self.playerDelegate respondsToSelector:@selector(playerScrollView:currentPlayerIndex:)]) {
                [self.playerDelegate playerScrollView:self currentPlayerIndex:_currentIndex];
                _previousIndex = _currentIndex;
                NSLog(@"current index in delegate: %ld -%s",_currentIndex,__FUNCTION__);
            }
        }
    }
}

#pragma mark - layz
- (NSMutableArray *)lives {
    if (!_lives) {
        _lives = [NSMutableArray array];
    }
    return _lives;
}

@end
