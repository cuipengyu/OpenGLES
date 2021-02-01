//
//  RTHomeViewController.m
//  RTFilter002
//
//  Created by CuiPengyu on 2021/1/27.
//

#import "RTHomeViewController.h"
#import "RTPresent.h"
#import "RTTableViewDataSource.h"
#import "RTEditViewController.h"

@interface RTHomeViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) RTTableViewDataSource *dataSource;
@property (nonatomic, strong) RTPresent *present;
@end

@implementation RTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    __weak typeof(self)weakSelf = self;
    self.dataSource = [[RTTableViewDataSource alloc] initWithCellIdentifier:[RTTableViewCell reuseID] preConfig:^(UITableViewCell * _Nonnull cell, RTModel *model, NSIndexPath * _Nonnull indexPath) {
        cell.textLabel.text = model.title;
    } click:^(RTModel *model, NSIndexPath * _Nonnull indexPath) {
        if (!weakSelf) {
            return;
        }
      
        
        if (model.className && model.className.length > 0) {
            Class cls = NSClassFromString(model.className);
            if (cls && [cls isSubclassOfClass:[UIViewController class]]) {
                UIViewController *vc = [cls new];
                vc.title = model.title;
                [weakSelf pushVC:vc];
            }
            return;
        }
        RTEditViewController *editVC = [[RTEditViewController alloc] init];
        editVC.shaderNames = model.shaderNames;
        editVC.segmentTitles = model.segmentTitles;
        editVC.title = model.title;
        editVC.isActive = model.isActive;
        [weakSelf pushVC:editVC];
        
    }];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    [self.view addSubview:self.tableView];
    
    self.present = [[RTPresent alloc] init];
    [self.present loadData];
    [self refreshUI];
}

- (void)pushVC:(UIViewController *)vc{
    
    RTPickerPhotoManager *picker = [RTPickerPhotoManager shareManager];
    if (picker.lastSelectedImage) {
        [vc setValue:picker.lastSelectedImage forKey:@"image"];
        [self.navigationController pushViewController:vc animated:true];
        return;
    }

    picker.selectedPhotoBlock = ^(UIImage * _Nonnull image) {
        [vc setValue:image forKey:@"image"];
        [self.navigationController pushViewController:vc animated:true];
        [RTPickerPhotoManager shareManager].selectedPhotoBlock = NULL;
    };
    [picker showPickerFrom:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.clearBtn.enabled = [RTPickerPhotoManager shareManager].lastSelectedImage ? true : false;
}

- (void)refreshUI{
    
    [self.dataSource.dataArray addObjectsFromArray:self.present.dataArray];
    
    [self.tableView reloadData];
}

- (void)clearSelectedImage{
    [RTPickerPhotoManager shareManager].lastSelectedImage = nil;
    self.clearBtn.enabled = false;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[RTTableViewCell class] forCellReuseIdentifier:[RTTableViewCell reuseID]];
      
        [_tableView setTableFooterView:self.clearBtn];
    }
    return _tableView;
}
-(UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_clearBtn setTitle:@"清空已选图片" forState:UIControlStateNormal];
        _clearBtn.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
        [_clearBtn addTarget:self action:@selector(clearSelectedImage) forControlEvents:UIControlEventTouchUpInside];
        [_clearBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_clearBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    return _clearBtn;
}
@end
