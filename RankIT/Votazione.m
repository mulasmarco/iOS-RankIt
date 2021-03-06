#import "Votazione.h"

@implementation Votazione

- (id) initWithPattern:(NSString*)pattern AndMu:(float)mu AndSigma:(float)sigma AndVotedBy:(float)votedBy {
    
    self = [super init];
    
    if(self) {
        
        self.pattern=pattern;
        self.mu=mu;
        self.sigma=sigma;
        self.votedby=votedBy;
        
    }
    
    return self;
    
}

- (NSString *) description {
    
    return [NSString stringWithFormat:@"%@ %f %f",self.pattern,self.mu,self.sigma];

}

@end