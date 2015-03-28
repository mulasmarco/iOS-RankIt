#import "TableViewController.h"
#import "ConnectionToServer.h"
#import "APIurls.h"

/* Costante per i nomi dei poll pubblici */
NSInteger POLL_NAME = 9;

/* Stringa per la search bar */
NSString *NO_RESULTS = @"Nessun risultato trovato";

@interface TableViewController ()

@end

@implementation TableViewController {
    
    /* Oggetto per la connessione al server */
    ConnectionToServer *Connection;
    
    /* Dizionario dei poll pubblici */
    NSMutableDictionary *allPublicPolls;
    
    /* Array dei nomi dei poll pubblici che verranno visualizzati */
    NSMutableArray *pollName;
    
    /* Array per i risultati di ricerca */
    NSArray *searchResults;
    
    /* Oggetto per il refresh da TableView */
    UIRefreshControl *refreshControl;
    
    /* Variabile che conterrà la subview da rimuovere */
    UIView *subView;
    
    /* Messaggio nella schermata Home */
    UILabel *messageLabel;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /* Permette alle table view di non stampare celle vuote che vanno oltre quelle dei risultati */
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* Download iniziale di tutti i poll pubblici */
    [self DownloadPolls];
    
    /* Se non c'è connessione o non ci sono poll pubblici, il background della TableView è senza linee */
    if (allPublicPolls==nil || [allPublicPolls count] == 0)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* Altrimenti prende i nomi dei poll pubblici da visualizzare */
    else [self NamePolls];
    
    searchResults = [[NSArray alloc]init];
    
    /* Dichiarazione della label da mostrare in caso di non connessione o assenza di poll */
    messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.tag = 1;
    [messageLabel setFrame:CGRectOffset(messageLabel.bounds, CGRectGetMidX(self.tableView.frame) - CGRectGetWidth(self.tableView.bounds)/2, CGRectGetMidY(self.tableView.frame) - CGRectGetHeight(self.tableView.bounds)/1.5)];
    
    /* Questa è la parte di codice che definisce il refresh da parte della TableView */
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(DownloadPolls) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 0;
    [self.tableView addSubview:refreshControl];
    
    /* Visualizza i poll pubblici nella Home */
    [self HomePolls];
    
}

/* Download poll pubblici dal server */
- (void)DownloadPolls {
    
     Connection = [[ConnectionToServer alloc]init];
     [Connection scaricaPollsWithPollId:@"" andUserId:@"" andStart:@""];
     allPublicPolls = Connection.getDizionarioPolls;
     
     if (allPublicPolls!=nil && [allPublicPolls count] != 0) {
     
        [self NamePolls];
        [self.tableView reloadData];
     
     }
     
     [self HomePolls];
    
}

/* Estrapolazione dei nomi dei poll pubblici ritornati dal server */
- (void)NamePolls {
    
    NSString *value;
    NSString *str;
    NSArray *split;
    NSString *sep = @"=;";
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
    pollName = [[NSMutableArray alloc]init];
    
    /* Scorre il dizionario e splitta in base all'insieme di caratteri set */
    for(id key in allPublicPolls) {
        
        value = [allPublicPolls objectForKey:key];
        str = [NSString stringWithFormat:@"%@",value];
        split = [str componentsSeparatedByCharactersInSet:set];
        [pollName addObject:split[POLL_NAME]];
        
    }
    
}

/* Visualizzazione poll pubblici nella Home */
- (void)HomePolls {
    
    if (allPublicPolls!=nil) {
        
        if([allPublicPolls count] != 0) {
            
            /* Rimuoviamo la subview aggiunta per il messaggio d'errore */
            subView  = [self.tableView viewWithTag:1];
            [subView removeFromSuperview];
            
            /* Background con linee */
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
        }
        
        else {
            
            /* Rimuove tutte le celle dei poll per mostrare il messaggio di assenza poll */
            [pollName removeAllObjects];
            [self.tableView reloadData];
            
            /* Stampa del messaggio di notifica */
            [self printMessaggeError];
            
        }
        
    }
    
    /* Internet assente */
    else {
        
        /* Rimuove tutte le celle dei poll per mostrare il messaggio di assenza connessione */
        [pollName removeAllObjects];
        [self.tableView reloadData];
        
        /* Stampa del messaggio di notifica */
        [self printMessaggeError];
        
    }
    
    /* Conclude il refresh (Sparisce l'animazione) */
    [refreshControl endRefreshing];
    
}

/* Funzione per la visualizzazione del messaggio di notifica di assenza connessione o assenza poll pubblici */
- (void)printMessaggeError {
    
    /* Background senza linee e definizione del messaggio di assenza poll pubblici o assenza connessione */
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* Assegna il messaggio a seconda dei casi */
    if(allPublicPolls!=nil)
        messageLabel.text = EMPTY_POLLS_LIST;
    
    else messageLabel.text = SERVER_UNREACHABLE;
    
    /* Aggiunge la SubView con il messaggio da visualizzare */
    [self.tableView addSubview:messageLabel];
    [self.tableView sendSubviewToBack:messageLabel];
    
}

/* Regola l'altezza delle celle nella Home */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 75;
}

/* Funzioni che permettono di visualizzare i nomi dei poll pubblici nelle celle della Home o i risultati di ricerca */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        if([searchResults count] == 0) {
            
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
            
            for (UIView *view in self.searchDisplayController.searchResultsTableView.subviews) {
                
                if ([view isKindOfClass:[UILabel class]]) {
                    
                    ((UILabel *)view).font = [UIFont fontWithName:@"Helvetica" size:20];
                    ((UILabel *)view).textColor = [UIColor darkGrayColor];
                    ((UILabel *)view).text = NO_RESULTS;

                }
            }
        
        }
    
        else [self.searchDisplayController.searchResultsTableView setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
        
        return [searchResults count];
        
    }
    
    else return [pollName count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"PollCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        cell.accessoryType = cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
        
    }
    
    else cell.textLabel.text = [pollName objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains %@",searchText];
    searchResults = [pollName filteredArrayUsingPredicate:resultPredicate];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
    
}

@end