#import "ViewControllerGraphResults.h"
#import "ConnectionToServer.h"
#import "Votazione.h"
#import "CPTPlotSpace.h"
#import "Font.h"
#import "Util.h"

@interface ViewControllerGraphResults ()

@end

@implementation ViewControllerGraphResults

@synthesize tiesPlot,notiesPlot,poll,optimalData,optimalNotiesData,selectedPlot;
@synthesize scrollView,grafico,dizionarioVotazioni,selectedIndex,plotArray,annotation,risposte,candidates;


- (void) viewDidLoad {
    
    selectedIndex = -1;
   
}

#pragma mark - UIViewController lifecycle methods

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    /* Inseriamo i primi  valori random in modo da tarare automaticamente il grafico su quei valori */
    [self inizializzaArrays];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(320,415)];
    
    /* Settaggio del grafico e visualizzazione */
    [self initPlot];
    
    [grafico sizeToFit];
    
    NSMutableArray *lettere=[[NSMutableArray alloc]init];
    [lettere addObject:@"A) "];
    [lettere addObject:@"B) "];
    [lettere addObject:@"C) "];
    [lettere addObject:@"D) "];
    [lettere addObject:@"E) "];
    
    NSMutableString* risposteLabel = [NSMutableString stringWithCapacity:500];
    
    for(int i=0;i<[candidates count];i++) {
        
        [risposteLabel appendFormat:@"%@", [lettere objectAtIndex:i ]];
        [risposteLabel appendFormat:@"%@\n\n", [candidates objectAtIndex:i ]];
    
    }
    
    risposte.text = risposteLabel;
    risposte.textColor = [UIColor blackColor];
    risposte.selectable = true;
    risposte.font = [UIFont fontWithName:FONT_CANDIDATES_NAME size:15];
    risposte.backgroundColor = [UIColor clearColor];
    risposte.textAlignment = NSTextAlignmentNatural;
    risposte.selectable = false;
    [risposte sizeToFit];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame;
    CGFloat currentY = 15;
    frame = grafico.frame;
    frame.origin.y = currentY;
    frame.origin.x -= 2;
    grafico.frame = frame;
    currentY += grafico.frame.size.height;
    
    if(screenHeight == IPHONE_5_5S_HEIGHT)
        currentY += GRAFICO_IPHONE_5_5S;
        
    else {
        
        if(screenHeight == IPHONE_6_HEIGHT)
            currentY += GRAFICO_IPHONE_6;
        
        else {
        
            if(screenHeight == IPHONE_6Plus_HEIGHT)
                currentY += GRAFICO_IPHONE_6Plus;
            
            else currentY += GRAFICO_IPHONE_4_4S;
        
        }
        
    }
    
    frame = risposte.frame;
    frame.origin.y = currentY;
    frame.origin.x += 15;
    risposte.frame = frame;
    currentY += risposte.frame.size.height;
    [scrollView setContentSize:CGSizeMake(320,currentY-15)];
    [scrollView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0];
    
}

#pragma mark - Chart behavior
- (void) initPlot {
    
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    
}

- (void) configureHost {
    
    CGFloat graficoWidth = grafico.bounds.size.width;
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:CGRectMake(0,0,graficoWidth,graficoWidth)];
    self.hostView.allowPinchScaling = YES;
    [self.grafico addSubview:self.hostView];
    
}

- (void) configureGraph {
    
    /* Create the graph */
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    
    /* Create and set text style */
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = GRAPH_TEXT;
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    /* Set padding forplot area */
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    /* Enable user interactions forplot space */
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
}

- (void) configurePlots {
    
    /* Get graph and plot space */
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    /* Create the three plots */
    plotSpace.delegate = self;
    tiesPlot = [[CPTScatterPlot alloc] init];
    tiesPlot.dataSource = self;
    tiesPlot.identifier =@"TIES";
    CPTColor *tiesColor = [CPTColor blackColor];
    [graph addPlot:tiesPlot toPlotSpace:plotSpace];
    notiesPlot = [[CPTScatterPlot alloc] init];
    notiesPlot.dataSource = self;
    notiesPlot.identifier = @"NOTIES";
    CPTColor *notiesColor = [CPTColor redColor];
    [graph addPlot:notiesPlot toPlotSpace:plotSpace];
    
    /* Setup plot space */
    plotArray=[NSArray arrayWithObjects:tiesPlot, notiesPlot, nil];
    [plotSpace scaleToFitPlots:plotArray];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.yRange = yRange;
    
    /* Create styles and symbols */
    CPTMutableLineStyle *tiesLineStyle = [tiesPlot.dataLineStyle mutableCopy];
    tiesLineStyle.lineWidth = 0.0;
    tiesLineStyle.lineColor = tiesColor;
    tiesPlot.dataLineStyle = tiesLineStyle;
    CPTMutableLineStyle *tiesSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    tiesSymbolLineStyle.lineColor = tiesColor;
   
    CPTMutableLineStyle *notiesSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    notiesSymbolLineStyle.lineColor = notiesColor;
    notiesSymbolLineStyle.lineWidth = 0.0;
    notiesPlot.dataLineStyle=notiesSymbolLineStyle;
    notiesPlot.plotSymbolMarginForHitDetection=6.0f;
    
    tiesPlot.plotSymbolMarginForHitDetection=6.0f;
    tiesPlot.delegate=self;
    notiesPlot.delegate=self;
    
}

- (void) configureAxes {
    
    /* Create styles */
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor lightGrayColor];
    axisTitleStyle.fontName = GRAPH_AXIS_NAME;
    
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor=[CPTColor lightGrayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor lightGrayColor];
    axisTextStyle.fontName = GRAPH_AXIS_NAME;
    axisTextStyle.fontSize = 12.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor lightGrayColor];
    tickLineStyle.lineWidth = 0.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor lightGrayColor];
    tickLineStyle.lineWidth = 0.0f;
    
    /* Get axis set */
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    /* Configure y-axis */
    CPTXYAxis *x = axisSet.xAxis;
    x.title = @"mu";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -28.0f;
    x.axisLineStyle = axisLineStyle;

    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.labelTextStyle = axisTextStyle;
    x.labelOffset = -22.0f;
    
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.minorTickLength = 2.0f;
    x.tickDirection = CPTSignPositive;
 
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xMajorLocations = [NSMutableSet set];
    NSMutableSet *xMinorLocations = [NSMutableSet set];
    x.axisLabels = xLabels;
    x.majorTickLocations = xMajorLocations;
    x.minorTickLocations = xMinorLocations;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    x.majorIntervalLength=[[NSNumber numberWithDouble:0.5]decimalValue];
 
    /* Configure y-axis */
    CPTXYAxis *y = axisSet.yAxis;
    y.title = @"sigma";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -36.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    
    y.majorIntervalLength=[[NSNumber numberWithDouble:0.5]decimalValue];
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = -25.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    y.labelingPolicy=CPTAxisLabelingPolicyAutomatic;
   
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];

    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;

    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];

}

#pragma mark - Rotation
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);

}

#pragma mark - CPTPlotDataSource methods
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    
    if([plot.identifier isEqual:@"TIES"] == YES)
        return [self.optimalData count];
    
    if([plot.identifier isEqual:@"NOTIES"] == YES)
         return [self.optimalNotiesData count];
    
    return 0;
    
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    switch (fieldEnum) {
            
        case CPTScatterPlotFieldX:
            
            if([plot.identifier isEqual:@"TIES"] == YES)
                return [NSNumber numberWithFloat:[[self.optimalData objectAtIndex:index]mu]];
            
            if([plot.identifier isEqual:@"NOTIES"] == YES)
                return [NSNumber numberWithFloat:[[self.optimalNotiesData objectAtIndex:index]mu]];
            
        break;
            
        case CPTScatterPlotFieldY:
            
            if([plot.identifier isEqual:@"TIES"] == YES)
                return [NSNumber numberWithFloat:[[self.optimalData objectAtIndex:index]sigma]];
            
            if([plot.identifier isEqual:@"NOTIES"] == YES)
                return [NSNumber numberWithFloat:[[self.optimalNotiesData objectAtIndex:index]sigma]];
            
    }
    
    return NULL;
    
}

- (void) scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index {
    
    selectedIndex=index;
    Votazione *votazione;
    
    CPTColor *color;
    
    if(annotation!=nil)
     [self.hostView.hostedGraph.plotAreaFrame.plotArea removeAnnotation:annotation];
    
    if([plot.identifier isEqual:@"TIES"] == YES) {
        
        votazione=[optimalData objectAtIndex:index];
        selectedPlot=[NSMutableString stringWithFormat:@"TIES"];
        color=[CPTColor redColor];
         
    }
    
    if([plot.identifier isEqual:@"NOTIES"] == YES) {
        
       votazione=[optimalNotiesData objectAtIndex:index];
       selectedPlot=[NSMutableString stringWithFormat:@"NOTIES"];
       color=[CPTColor purpleColor];
    
    }
    
    NSNumber *x = [ NSNumber numberWithFloat:[votazione mu]];
    NSNumber *y = [ NSNumber numberWithFloat:[votazione sigma]];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    NSString *label=[NSString stringWithFormat:@"%@ \n(%.3f,%.3f)",[votazione pattern],[votazione mu],[votazione sigma]];
    CPTMutableTextStyle *style=[[CPTMutableTextStyle alloc]init];
    style.color=color;
    style.fontSize=7.0;
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:label style:style];
    annotation.contentLayer = textLayer;
    annotation.displacement = CGPointMake(-10.0f, -20.0f);
    [self.hostView.hostedGraph.plotAreaFrame.plotArea addAnnotation:annotation];
    [self symbolForScatterPlot:plot recordIndex:index];
    [tiesPlot reloadData];
    [notiesPlot reloadData];

}

- (CPTPlotSymbol *) symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index {
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    
    if([plot.identifier isEqual:@"TIES"] == YES&&index==selectedIndex&&[selectedPlot isEqualToString:@"TIES"]) {
        
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol diamondPlotSymbol];
        plotSymbol.size = CGSizeMake(12.0f, 12.0f);
        plotSymbol.fill=[CPTFill fillWithColor:[CPTColor redColor]];
        plotSymbol.lineStyle=lineStyle;
        plot.plotSymbol=plotSymbol;
        return plotSymbol;
       
    }
    
    else if([plot.identifier isEqual:@"TIES"] == YES&&index!=selectedIndex) {
        
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol diamondPlotSymbol];
        plotSymbol.size = CGSizeMake(6.0f, 6.0f);
        plotSymbol.fill=[CPTFill fillWithColor:[CPTColor redColor]];
        plotSymbol.lineStyle=lineStyle;
        plot.plotSymbol=plotSymbol;
        return plotSymbol;
    }
    
    else if([plot.identifier isEqual:@"NOTIES"] == YES&&index==selectedIndex&&[selectedPlot isEqualToString:@"NOTIES"]) {
        
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.size = CGSizeMake(12.0f, 12.0f);
        plotSymbol.fill=[CPTFill fillWithColor:[CPTColor purpleColor]];
        plotSymbol.lineStyle=lineStyle;
        plot.plotSymbol=plotSymbol;
        return plotSymbol;
        
    }
    
    else if([plot.identifier isEqual:@"NOTIES"] == YES&&index!=selectedIndex) {
    
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.size = CGSizeMake(6.0f, 6.0f);
        plotSymbol.fill=[CPTFill fillWithColor:[CPTColor purpleColor]];
        plotSymbol.lineStyle=lineStyle;
        plot.plotSymbol=plotSymbol;
        return plotSymbol;
    
    }
    
    return nil;

}

- (void) configureLegend {

    CPTGraph *graph =self.hostView.hostedGraph;
    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfColumns=1;
    graph.legend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    graph.legend.cornerRadius = 5.0;
    graph.legendAnchor = CPTRectAnchorBottom;
    graph.legendDisplacement = CGPointMake(105.0, 255.0);

}

- (void) inizializzaArrays {
    
    optimalData = [[NSMutableArray alloc] init];
    optimalNotiesData = [[NSMutableArray alloc] init];
    dizionarioVotazioni=[[NSMutableDictionary alloc]init];
    ConnectionToServer *connection=[[ConnectionToServer alloc]init];
    candidates=[connection getCandidatesWithPollId:[NSString stringWithFormat:@"%d",[poll pollId]]];
    NSMutableDictionary* results=[connection getResultsOfPoll:poll];
    NSMutableDictionary * optimalNotiesclassifiche=[results valueForKey:@"optimalnotiesdata"];
    NSMutableDictionary * optimalclassifiche=[results valueForKey:@"optimaldata"];
    
    for(id key in optimalclassifiche ) {
        
        Votazione *votazione=[[Votazione alloc] initWithPattern:[key valueForKey:@"pattern"] AndMu:[[key valueForKey:@"mu"]floatValue]AndSigma:[[key valueForKey:@"sigma"]floatValue] AndVotedBy:[[key valueForKey:@"votedby"]floatValue]];
        [optimalData addObject:votazione];
      
    }
    
    for(id key in optimalNotiesclassifiche ) {
        
        Votazione *votazione=[[Votazione alloc] initWithPattern:[key valueForKey:@"pattern"] AndMu:[[key valueForKey:@"mu"]floatValue]AndSigma:[[key valueForKey:@"sigma"]floatValue] AndVotedBy:[[key valueForKey:@"votedby"]floatValue]];
        [optimalNotiesData addObject:votazione];
        CGPoint punto= CGPointMake([votazione mu], [votazione sigma]);
        [dizionarioVotazioni setObject:votazione forKey:[NSString stringWithFormat:@"%f;%f",punto.x,punto.y]];
    
    }
    
}

@end