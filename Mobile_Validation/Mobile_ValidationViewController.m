//
//  Mobile_ValidationViewController.m
//  Mobile_Validation
//
//  Created by James Kovacs on 5/15/13.
//  Copyright (c) 2013 James Kovacs. All rights reserved.
//

#import "Mobile_ValidationViewController.h"
#import "Mobile_Validation.h"

NSString *FACILITY_NUMBER = @"17040633";

@interface Mobile_ValidationViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic)BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) Mobile_Validation *validation;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *ticket;
@property (nonatomic, strong) NSString *serial_num;
@property (nonatomic, strong) ZBarSymbol *symbol;
@end

@implementation Mobile_ValidationViewController

@synthesize hostcomResult = _hostcomResult;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize validation = _validation;
@synthesize responseData = _responseData;
@synthesize resultImage, resultText;
@synthesize username = _username;
@synthesize password = _password;
@synthesize ticket = _ticket;
@synthesize serial_num = _serial_num;
@synthesize symbol = _symbol;

- (IBAction) alert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In" message:@"Please enter your Username and Password" delegate:self cancelButtonTitle:@"Log In" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
 //   [alert addTextFieldWithValue:@"" label:@"Username"];
 //   [alert addTextFieldWithValue:@"" label:@"Password"];
    [alert show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *tf_username = [alertView textFieldAtIndex:0];
    UITextField *tf_password = [alertView textFieldAtIndex:1];
    resultText.text = tf_username.text;
    self.username = tf_username.text;
    self.password = tf_password.text;
    NSLog(@"username = %@", tf_username.text);
    NSLog(@"password = %@", tf_password.text);
    
}


- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    //[reader release];
}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (IBAction)sendButtonTapped:(UIButton *)sender {
    
    //sender.backgroundColor = [UIColor: ];
    NSString *urlString = [NSString stringWithFormat:@"https://107.23.8.47:5000/mobile_validation?user=%@&password=%@&key=%@", self.username, self.password, self.symbol.data];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"merapi", @"user",
                              @"parking654", @"password", self.serial_num, @"key", nil];
//    NSData *postData = [self encodeDictionary:postDict];
    NSError *myError = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:(id)postDict options:0 error:&myError];
    NSString* jsonMessage = [[NSString alloc] initWithData:postData
                                              encoding:NSUTF8StringEncoding] ;
    //NSString* jsonMessage = [NSString stringWithUTF8String:postData];
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    //    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //    NSString *postString = @"user=merapi&password=parking123&key=12345678";
    //   [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setHTTPBody:postData];
//    NSString *jsonMessage = [postDict JSONRepresentation];
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [jsonMessage length]];
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData] ;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    /*    NSURLRequest *request = [NSURLRequest requestWithURL:
     [NSURL URLWithString:@"https://107.23.8.47:5000/example.json"]];
     [[NSURLConnection alloc] initWithRequest:request delegate:self];
     */
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    self.symbol = nil;
    for(_symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    //resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
//    resultImage.image =
//    [info objectForKey: UIImagePickerControllerOriginalImage];

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSDate *barcode_starting_date = [dateFormatter dateFromString:@"2002-01-01 at 00:00"];
    NSDate *ticket_starting_date = [dateFormatter dateFromString:@"1994-01-01 at 00:00"];

    int barcode_secs_from_start = [[self.symbol.data substringWithRange: NSMakeRange(7, 7)] intValue] * 60;
    int barcode_hours_from_start = [[self.symbol.data substringWithRange: NSMakeRange(7, 7)] intValue] / 60;
    //int barcode_days_from_start = barcode_hours_from_start / 24;
    NSDate *ticket_date = [barcode_starting_date dateByAddingTimeInterval:barcode_secs_from_start];
    NSTimeInterval ticket_days_from_start = ((([ticket_date timeIntervalSinceDate:ticket_starting_date])/60)/60)/24;

    int ticket_hour_issued = ([[self.symbol.data substringWithRange: NSMakeRange(7, 7)] intValue] / 60) % 24;
    int ticket_minute_issued = [[self.symbol.data substringWithRange: NSMakeRange(7, 7)] intValue] % 60;
    NSString *ticket_time_in_minutes = [NSString stringWithFormat:@"%04i", (ticket_hour_issued * 60) + ticket_minute_issued];
    
    NSString *car_park_num = [self.symbol.data substringWithRange: NSMakeRange(5, 2)];
    NSString *ticket_num = [self.symbol.data substringWithRange: NSMakeRange(14, 6)];

    self.serial_num = [NSString stringWithFormat:@"%@%i%@%@%@", ticket_time_in_minutes, (int)ticket_days_from_start, FACILITY_NUMBER, car_park_num, ticket_num];
    
    resultText.text = self.serial_num;
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

- (void) dealloc
{
    self.resultImage = nil;
    self.resultText = nil;
    //[super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return(YES);
}

- (Mobile_Validation *)validation
{
    if (!_validation) _validation = [[Mobile_Validation alloc] init];
    return _validation;
}

- (IBAction)sendRequest:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    NSLog(@"digit pressed = %@", digit);
    //UILabel *myDisplay = self.hostcomResult;
    //NSString *currentText = myDisplay.text; //[myDisplay text];
    //NSString *newText = [currentText stringByAppendingString:digit];
    //myDisplay.text = newText;
    //self.hostcomResult.text = [self.hostcomResult.text stringByAppendingString:digit];
    if (self.userIsInTheMiddleOfEnteringANumber)
    {    
        self.hostcomResult.text = [self.hostcomResult.text stringByAppendingFormat:@"%@ %@",@" ",[sender currentTitle]];
    }
    else
    {
        self.hostcomResult.text = [sender currentTitle];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewdidload");
    self.responseData = [NSMutableData data];
/*    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"https://107.23.8.47:5000/example.json"]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];*/
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    BOOL trusted = YES;
/*    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"trusted" ofType:@"der"];
        NSData *certData = [[NSData alloc] initWithContentsOfFile:thePath];
        CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
        SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
        SecPolicyRef policyRef = SecPolicyCreateBasicX509();
        SecCertificateRef certArray[1] = { cert };
        CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
        SecTrustResultType trustResult;
        SecTrustEvaluate(serverTrust, &trustResult);
        trusted = (trustResult == kSecTrustResultUnspecified);
        CFRelease(certArrayRef);
        CFRelease(policyRef);
        CFRelease(cert);
        CFRelease(certDataRef);
    }*/
    if (trusted) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
//    else {
//        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
//    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    NSLog(@"data contents: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    for(id key in res) {
        
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
        if ([keyAsString isEqualToString:@"results"]) {
            resultText.text = valueAsString;
        }
    }
    
    // extract specific value...
//    NSArray *results = [res objectForKey:@"results"];
    
/*    for (NSDictionary *result in results) {
        NSString *icon = [result objectForKey:@"icon"];
        NSLog(@"icon: %@", icon);
    }*/
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
