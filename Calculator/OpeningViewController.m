//
//  OpeningViewController.m
//  Calculator
//
//  Created by wang on 13-10-15.
//  Copyright (c) 2013年 wang. All rights reserved.
//
#import "OpeningViewController.h"

@interface OpeningViewController ()

@end

@implementation OpeningViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)gotoMainView:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [self.gotoMainViewBtn setHidden:YES];
    [UIView beginAnimations:@"open" context:nil];
    [UIView setAnimationDuration:1];
    UIStoryboard * storyboard = [ UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *main = [storyboard instantiateInitialViewController];
    [self presentViewController:main animated:YES completion:NULL];
    [UIView commitAnimations];
    
}


@end
