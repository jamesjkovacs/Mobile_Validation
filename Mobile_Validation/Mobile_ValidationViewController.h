//
//  Mobile_ValidationViewController.h
//  Mobile_Validation
//
//  Created by James Kovacs on 5/15/13.
//  Copyright (c) 2013 James Kovacs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *FACILITY_NUMBER;

@interface Mobile_ValidationViewController : UIViewController
    // ADD: delegate protocol
    < ZBarReaderDelegate >
{
    IBOutlet UITextView *resultText;
    IBOutlet UIImageView *resultImage;
}
@property (weak, nonatomic) IBOutlet UILabel *hostcomResult;
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
- (IBAction) scanButtonTapped;
- (IBAction) alert;
- (NSData*)encodeDictionary:(NSDictionary*)dictionary;
- (IBAction)sendButtonTapped:(UIButton *)sender;

@end
