
#import "TableViewController.h"

#import "TableViewCell.h"

#import "FLAnimatedImage.h"

@interface TableViewController ()

@property (nonatomic, strong) NSCache *gifsCache;
@property (nonatomic, strong) NSArray *gifNamesArray;
@property (nonatomic, strong) dispatch_queue_t gifsQueue;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gifsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    self.gifNamesArray = @[@"1", @"2", @"3", @"4", @"5", @"6"];
        
    UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(actionReload:)];
    self.navigationItem.leftBarButtonItem = reloadBarButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self actionReload:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionReload:(UIBarButtonItem*)reloadBarButtonItem {
    
    self.gifsCache = [[NSCache alloc] init];
    self.gifsCache.countLimit = 2000;
    self.gifsCache.totalCostLimit = 120*1024*1024;
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.gifNamesArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];
    for (UIView *view in [cell subviews]){
        [view removeFromSuperview];
    }
    
    NSString *gifName = [self.gifNamesArray objectAtIndex:indexPath.row];
    
    dispatch_async(self.gifsQueue, ^{
        
        FLAnimatedImage *image = (FLAnimatedImage*)[self.gifsCache objectForKey:gifName];
        
        if (!image) {
            
            NSURL *imgPath = [[NSBundle mainBundle] URLForResource:gifName withExtension:@"gif"];
            NSString *stringPath = [imgPath absoluteString];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
            
            image = [FLAnimatedImage animatedImageWithGIFData:data];
            [self.gifsCache setObject:image forKey:gifName];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            imageView.frame = CGRectMake(0.0, 0.0, 300, 200);
            imageView.animatedImage = image;
            imageView.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
            
            [cell addSubview:imageView];
        });
        
    });
 
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 200;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
