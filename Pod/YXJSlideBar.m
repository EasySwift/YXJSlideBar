//
//  YXJSlideBar.m
//  YXJSlideBarDemo
//
//  Created by YXJ on 15/6/4.
//  Copyright (c) 2015年 YXJ. All rights reserved.
//

#import "YXJSlideBar.h"
#import "YXJSlideBarItem.h"

#define DEVICE_WIDTH            CGRectGetWidth([UIScreen mainScreen].bounds)
#define DEFAULT_SLIDER_COLOR    [UIColor orangeColor]
#define SLIDER_VIEW_HEIGHT      2

@interface YXJSlideBar () <YXJSlideBarItemDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) UIView *sliderView;

@property (strong, nonatomic) YXJSlideBarItem *selectedItem;
@property (strong, nonatomic) YXJSlideBarItemSelectedCallback callback;

//每个item的宽度 , 如果想宽度自适应，必须指定宽度为0
@property (assign, nonatomic) NSInteger itemsWidth;

@end

@implementation YXJSlideBar

-(instancetype)initWithItemWidth:(CGFloat)itemWidth barHeight:(CGFloat)barHeight{
    self.itemsWidth = itemWidth ;
    CGRect frame = CGRectMake(0, 0, DEVICE_WIDTH, barHeight);
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _items = [NSMutableArray array];
        [self initScrollView];
        [self initSliderView];
    }
    return self;
}

#pragma - mark Custom Accessors
- (void)setItemsTitle:(NSArray *)itemsTitle {
    _itemsTitle = itemsTitle;
    [self setupItems];
}

- (void)setItemColor:(UIColor *)itemColor {
    for (YXJSlideBarItem *item in _items) {
        [item setItemTitleColor:itemColor];
    }
}

- (void)setItemSelectedColor:(UIColor *)itemSelectedColor {
    for (YXJSlideBarItem *item in _items) {
        [item setItemSelectedTitleColor:itemSelectedColor];
    }
}

- (void)setSliderColor:(UIColor *)sliderColor {
    _sliderColor = sliderColor;
    self.sliderView.backgroundColor = _sliderColor;
}

- (void)setSelectedItem:(YXJSlideBarItem *)selectedItem {
    _selectedItem.selected = NO;
    _selectedItem = selectedItem;
}


#pragma - mark Private

- (void)initScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
}

- (void)initSliderView {
    _sliderView = [[UIView alloc] init];
    _sliderColor = DEFAULT_SLIDER_COLOR;
    _sliderView.backgroundColor = _sliderColor;
    [_scrollView addSubview:_sliderView];
}

- (void)setupItems {
    CGFloat itemX = 0;
    for (NSString *title in _itemsTitle) {
        YXJSlideBarItem *item = [[YXJSlideBarItem alloc] init];
        item.delegate = self;
        
        // Init the current item's frame
        CGFloat itemW = [YXJSlideBarItem widthForTitle:title];
        
        
        if (self.itemsWidth == 0) {
            item.frame = CGRectMake(itemX, 0, itemW, CGRectGetHeight(_scrollView.frame));
        }else{
            item.frame = CGRectMake(itemX, 0, self.itemsWidth, CGRectGetHeight(_scrollView.frame));
        }
        
        [item setItemTitle:title];
        [_items addObject:item];
        
        [_scrollView addSubview:item];
        
        // Caculate the origin.x of the next item
        itemX = CGRectGetMaxX(item.frame);
    }
    
    // Cculate the scrollView 's contentSize by all the items
    _scrollView.contentSize = CGSizeMake(itemX, CGRectGetHeight(_scrollView.frame));
    
    // Set the default selected item, the first item
    YXJSlideBarItem *firstItem = [self.items firstObject];
    firstItem.selected = YES;
    _selectedItem = firstItem;
    
    // Set the frame of sliderView by the selected item
    _sliderView.frame = CGRectMake(0, self.frame.size.height - SLIDER_VIEW_HEIGHT, firstItem.frame.size.width, SLIDER_VIEW_HEIGHT);
}


- (void)scrollToVisibleItem:(YXJSlideBarItem *)item {
    NSInteger selectedItemIndex = [self.items indexOfObject:_selectedItem];
    NSInteger visibleItemIndex = [self.items indexOfObject:item];
    
    // If the selected item is same to the item to be visible, nothing to do
    if (selectedItemIndex == visibleItemIndex) {
        return;
    }
    
    CGPoint offset = _scrollView.contentOffset;
    
    // If the item to be visible is in the screen, nothing to do
    if (CGRectGetMinX(item.frame) >= offset.x && CGRectGetMaxX(item.frame) <= (offset.x + CGRectGetWidth(_scrollView.frame))) {
        return;
    }
    
    // Update the scrollView's contentOffset according to different situation
    if (selectedItemIndex < visibleItemIndex) {
        // The item to be visible is on the right of the selected item and the selected item is out of screeen by the left, also the opposite case, set the offset respectively
        if (CGRectGetMaxX(_selectedItem.frame) < offset.x) {
            offset.x = CGRectGetMinX(item.frame);
        } else {
            offset.x = CGRectGetMaxX(item.frame) - CGRectGetWidth(_scrollView.frame);
        }
    } else {
        // The item to be visible is on the left of the selected item and the selected item is out of screeen by the right, also the opposite case, set the offset respectively
        if (CGRectGetMinX(_selectedItem.frame) > (offset.x + CGRectGetWidth(_scrollView.frame))) {
            offset.x = CGRectGetMaxX(item.frame) - CGRectGetWidth(_scrollView.frame);
        } else {
            offset.x = CGRectGetMinX(item.frame);
        }
    }
    _scrollView.contentOffset = offset;
}

- (void)addAnimationWithSelectedItem:(YXJSlideBarItem *)item {
    // Caculate the distance of translation
    CGFloat dx = CGRectGetMidX(item.frame) - CGRectGetMidX(_selectedItem.frame);
    
    // Add the animation about translation
    CABasicAnimation *positionAnimation = [CABasicAnimation animation];
    positionAnimation.keyPath = @"position.x";
    positionAnimation.fromValue = @(_sliderView.layer.position.x);
    positionAnimation.toValue = @(_sliderView.layer.position.x + dx);
    
    // Add the animation about size
    CABasicAnimation *boundsAnimation = [CABasicAnimation animation];
    boundsAnimation.keyPath = @"bounds.size.width";
    boundsAnimation.fromValue = @(CGRectGetWidth(_sliderView.layer.bounds));
    boundsAnimation.toValue = @(CGRectGetWidth(item.frame));
    
    // Combine all the animations to a group
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[positionAnimation, boundsAnimation];
    animationGroup.duration = 0.2;
    [_sliderView.layer addAnimation:animationGroup forKey:@"basic"];
    
    // Keep the state after animating
    _sliderView.layer.position = CGPointMake(_sliderView.layer.position.x + dx, _sliderView.layer.position.y);
    CGRect rect = _sliderView.layer.bounds;
    rect.size.width = CGRectGetWidth(item.frame);
    _sliderView.layer.bounds = rect;
}

#pragma mark - Public

- (void)slideBarItemSelectedCallback:(YXJSlideBarItemSelectedCallback)callback {
    _callback = callback;
}

- (void)selectSlideBarItemAtIndex:(NSUInteger)index {
    YXJSlideBarItem *item = [self.items objectAtIndex:index];
    if (item == _selectedItem) {
        return;
    }
    
    item.selected = YES;
    [self scrollToVisibleItem:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
}

#pragma mark - YXJSlideBarItemDelegate

- (void)slideBarItemSelected:(YXJSlideBarItem *)item {
    if (item == _selectedItem) {
        return;
    }
    
    [self scrollToVisibleItem:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
    _callback([self.items indexOfObject:item]);
}

@end
