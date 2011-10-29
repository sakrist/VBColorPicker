//
//  VBColorPicker.h
//  VBColorPicker
//
//  Created by Volodymyr Boichentsov on 10/28/11.
//  Copyright (c) 2011 www.injoit.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBColorPicker : UIImageView

@property BOOL hideAfterSelection; // default YES
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly, retain) UIColor* lastSelectedColor;


- (void) showPicker;
- (void) hidePicker;
- (void) showPickerWithDuration:(float)duration;
- (void) hidePickerWithDuration:(float)duration;
- (void) animateColorWheelToShow:(BOOL)show duration:(float)duration;

@end


@protocol VBColorPickerDelegate <NSObject>

- (void) pickedColor:(UIColor *)color;


@end