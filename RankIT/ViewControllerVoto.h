#import <UIKit/UIKit.h>
#import "Candidate.h"
#import "Poll.h"

@interface ViewControllerVoto : UIViewController <UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *candidateNames;
@property (strong,nonatomic) NSMutableArray *candidateChars;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) Poll *poll;
@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) IBOutlet UILabel *fourth;
@property (weak,nonatomic) IBOutlet UILabel *fifth;

- (IBAction) vota:(id)sender;

@end