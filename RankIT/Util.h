#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef UTIL_H

#define UTIL_H

/* Altezza della cella */
#define CELL_HEIGHT 75

/* Utile per convertire un colore da esadecimale a "colore Obj-C" */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif

@interface Util : NSObject

/* Stringa per la search bar */
FOUNDATION_EXPORT NSString *NO_RESULTS;

/* Stringhe per messaggi da stampare a video */
FOUNDATION_EXPORT NSString *EMPTY_POLLS_LIST;
FOUNDATION_EXPORT NSString *EMPTY_VOTED_POLLS_LIST;
FOUNDATION_EXPORT NSString *EMPTY_MY_POLLS_LIST;
FOUNDATION_EXPORT NSString *NO_RANKING;

/* Stringhe per il pulsante di ritorno schermata */
FOUNDATION_EXPORT NSString *SEARCH;
FOUNDATION_EXPORT NSString *BACK;
FOUNDATION_EXPORT NSString *BACK_TO_HOME;
FOUNDATION_EXPORT NSString *BACK_TO_VOTED;
FOUNDATION_EXPORT NSString *BACK_TO_MY_POLL;
FOUNDATION_EXPORT NSString *BACK_TO_RANKING;

/* Spaziatura voti per diversi IPhone */
FOUNDATION_EXPORT int IPHONE_4_4S_5_5S;
FOUNDATION_EXPORT int IPHONE_6;
FOUNDATION_EXPORT int IPHONE_6Plus;
FOUNDATION_EXPORT int X_FOR_VOTES;

/* Larghezza degli schermi di IPhone6,6+ */
FOUNDATION_EXPORT float IPHONE_6_WIDTH;
FOUNDATION_EXPORT float IPHONE_6Plus_WIDTH;

/* Spaziatura grafico per diversi IPhone */
FOUNDATION_EXPORT int GRAFICO_IPHONE_4_4S;
FOUNDATION_EXPORT int GRAFICO_IPHONE_5_5S;
FOUNDATION_EXPORT int GRAFICO_IPHONE_6;
FOUNDATION_EXPORT int GRAFICO_IPHONE_6Plus;

/* Lunghezza degli schermi di tutti di IPhone5,5S,6,6+ */
FOUNDATION_EXPORT float IPHONE_5_5S_HEIGHT;
FOUNDATION_EXPORT float IPHONE_6_HEIGHT;
FOUNDATION_EXPORT float IPHONE_6Plus_HEIGHT;

+ (NSDateFormatter*) getDateFormatter;
+ (int) compareDate:(NSDate *)first WithDate:(NSDate *)second;
+ (NSString *) toStringUserFriendlyDate:(NSString *) data;

@end