//
//  Mobile_Validation.m
//  Mobile_Validation
//
//  Created by James Kovacs on 5/15/13.
//  Copyright (c) 2013 James Kovacs. All rights reserved.
//

#import "Mobile_Validation.h"

@interface Mobile_Validation()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation Mobile_Validation
@synthesize programStack = _programStack;

-(NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}
-(void)setProgramStack: (NSMutableArray *)programStack
{
    _programStack = programStack;
}

@end
