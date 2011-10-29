//
//  ViewController.m
//  VBColorPicker
//
//  Created by Volodymyr Boichentsov on 10/28/11.
//  Copyright (c) 2011 www.injoit.com. All rights reserved.
//

#import "ViewController.h"
#import "VBColorPicker.h"


@implementation ViewController

@synthesize rect=_rect;
@synthesize cPicker=_cPicker;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    if (self.cPicker == nil) {
        [self.view setBackgroundColor:[UIColor grayColor]];
        self.cPicker = [[VBColorPicker alloc] initWithFrame:CGRectMake(0, 0, 202, 202)];
        [_cPicker setCenter:self.view.center];
        [self.view addSubview:_cPicker];
        [_cPicker setDelegate:self];
        [_cPicker showPicker];
        
        // set default YES!
        [_cPicker setHideAfterSelection:NO];
    }
	
}

// set color from picker
- (void) pickedColor:(UIColor *)color {
    [_rect setBackgroundColor:color];
    [_cPicker hidePicker];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_cPicker isHidden]) {
        [_cPicker hidePicker];
    }
}

// show picker by double touch
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 2) {
        [_cPicker setCenter:[touch locationInView:self.view]];
        [_cPicker showPicker];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.cPicker removeFromSuperview];
    self.cPicker = nil;
}





- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
