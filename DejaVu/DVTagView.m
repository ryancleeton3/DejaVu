//
//  DVTagView.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVTagView.h"


@interface DVTagView ()

@property (nonatomic) UILabel* label;
@property (nonatomic) UIView* view;
@property (nonatomic) UIImageView* imageView;

@end

@implementation DVTagView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _label = [UILabel new];
    [_label setTextColor:[UIColor whiteColor]];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_label];
    
    _view = [UIView new];
    _view.backgroundColor = [UIColor orangeColor];
    [self addSubview:_view];
    
    UIImage* x = [UIImage imageNamed:@"X"];
    _imageView = [[UIImageView alloc] initWithImage:x];
    _imageView.backgroundColor = [UIColor clearColor];
    [_view addSubview:_imageView];
    
    
    self.layer.cornerRadius = 5.0f;
    [self setClipsToBounds:YES];
    self.backgroundColor = [UIColor darkGrayColor];
    
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    self.label.text = text;
    
    CGSize size =  [text sizeWithFont:[UIFont systemFontOfSize:14.0]
                             constrainedToSize:CGSizeMake(500, CGFLOAT_MAX)
                                 lineBreakMode:self.label.lineBreakMode];
    
    [self.label setFrame:CGRectMake(0, 0, abs(size.width) + 35, 35)];
    [self.view setFrame:CGRectMake(abs(size.width) + 35, 0, 33, 35)];
    [self.imageView setFrame:CGRectMake(3, 3, self.imageView.bounds.size.width, self.imageView.bounds.size.height)];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 33 + abs(size.width) + 35, 35)];
}


@end
