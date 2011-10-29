//
//  ViewController.h
//  VBColorPicker
//
//  Created by Volodymyr Boichentsov on 10/28/11.
//  Copyright (c) 2011 www.injoit.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBColorPicker.h"

@interface ViewController : UIViewController <VBColorPickerDelegate>

@property (nonatomic, strong) IBOutlet UIView *rect;
@property (nonatomic, strong) VBColorPicker *cPicker;

@end
