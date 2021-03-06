//
//  CDDiscussionDetailVC.m
//  CheatDictionary
//
//  Created by zzy on 2018/7/16.
//  Copyright © 2018年 朱正毅. All rights reserved.
//

#import "CDDiscussionDetailVC.h"

#import "CDDiscussionDetailModel.h"
#import "CDDiscussionDetailCell.h"

#import "CDDiscussionDetailUpperModel.h"
#import "CDDiscussionDetailUpperCell.h"

#import "YZInputView.h"

#import "CDDiscussionDetailVM.h"

#define kTextViewHeight 35

@interface CDDiscussionDetailVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CDDiscussionDetailVM *viewModel;

@property (nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) YZInputView *textView;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation CDDiscussionDetailVC
@dynamic viewModel;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [CDDiscussionDetailVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel loadData];
    
    self.title = self.params[@"type"];

    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.textView];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(kTextViewHeight).priorityHigh();
        make.edges.equalTo(self.bottomBar).insets(UIEdgeInsetsMake(5, 10, 5, 100));
    }];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.maskView = [UIView new];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.maskView.hidden = YES;
    [self.view addSubview:self.maskView];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    @weakify(self);
    self.textView.yz_textHeightChangeBlock = ^(NSString *text, CGFloat textHeight){
        @strongify(self);
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textHeight);
        }];
    };
    
    self.viewModel.completeLoadDataBlock = ^(BOOL success) {
        @strongify(self)
        if (success) {
            [self.tableView reloadData];
        } else {
            [CDToast showBottomToast:@"出错了呀"];
        }
    };
}

- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGFloat bottomMargin = [UIScreen mainScreen].bounds.size.height - endFrame.origin.y;
    [UIView animateWithDuration:duration animations:^{
        self.maskView.hidden = (bottomMargin == 0);
    }];
    [self.view layoutIfNeeded];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

#pragma mark -

- (YZInputView *)textView {
    if (!_textView) {
        _textView = [[YZInputView alloc] initWithFrame:CGRectMake(10, 2, SCREEN_WIDTH - 100, kTextViewHeight)];
        _textView.placeholder = @"写下你的评论...";
        _textView.maxNumberOfLines = 4;
        _textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = RGB(23, 19, 13);
        _textView.layer.borderColor = RGB(97, 82, 63).CGColor;
        _textView.layer.borderWidth = 2;
        
        _textView.inputAccessoryView = [UIView new];    //空view 隐藏inputAccessoryView
    }
    return _textView;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTextViewHeight + 10)];
        _bottomBar.backgroundColor = TabBarColor;
    }
    return _bottomBar;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.viewModel.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDBaseCellModel *model = self.viewModel.objects[indexPath.row];
    CDBaseTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([model cellClass]) forIndexPath:indexPath];
    [cell installWithObject:model];
    return cell;
}

@end
