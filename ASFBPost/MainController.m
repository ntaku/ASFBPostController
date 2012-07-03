//
//  Copyright (c) 2012 AppStair LLC. All rights reserved.
//  http://appstair.com
//

#import "MainController.h"
#import "ASFBPostController.h"


@implementation MainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIButton *_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_btn setTitle:@"Open" forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(showFBPost) forControlEvents:UIControlEventTouchUpInside];
    [_btn setFrame:CGRectMake(10, 10, 140, 40)];
    [self.view addSubview:_btn];
}

- (void)showFBPost{
    ASFBPostController *c = [[ASFBPostController alloc] init];
    c.thumbnailImage = [UIImage imageNamed:@"sample_thumb.jpg"];    
    c.originalImage = [UIImage imageNamed:@"sample.jpg"];
    
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    n.modalPresentationStyle = UIModalPresentationFormSheet;
    [c release];
    [self presentModalViewController:n animated:YES];
    [n release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

@end
