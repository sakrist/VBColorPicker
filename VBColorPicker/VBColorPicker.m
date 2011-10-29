//
//  VBColorPicker.m
//  VBColorPicker
//
//  Created by Volodymyr Boichentsov on 10/28/11.
//  Copyright (c) 2011 www.injoit.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VBColorPicker.h"

@implementation VBColorPicker

@synthesize lastSelectedColor=_lastSelectedColor;
@synthesize delegate=_delegate;

@synthesize hideAfterSelection=_hideAfterSelection;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"colorWheel"]];
        [self setUserInteractionEnabled:YES];
        [self setHidden:YES];
        self.hideAfterSelection = YES;
    }
    return self;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
	// per component. Regardless of what the source image format is 
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}


- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
    
    
	CGImageRef inImage = [[self image] CGImage];
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage); 
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	if (data != NULL && data != 0) {
		//offset locates the pixel in the data from x,y. 
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset]; 
		int red = data[offset+1]; 
		int green = data[offset+2]; 
		int blue = data[offset+3]; 
		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
	
	// When finished, release the context
	CGContextRelease(cgctx); 
	// Free image data memory for the context
	if (data) { free(data); }
	
	return color;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (self.hidden == YES || self.alpha == 0) {
		//color wheel is hidden, so don't handle  this as a color wheel event.
		[[self nextResponder] touchesBegan:touches withEvent:event];
		return;
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { 
    if (self.hidden == YES || self.alpha == 0) {
		//color wheel is hidden, so don't handle  this as a color wheel event.
		[[self nextResponder] touchesMoved:touches withEvent:event];
		return;
	}
}


- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (self.hidden == YES || self.alpha == 0) {
		//color wheel is hidden, so don't handle  this as a color wheel event.
		[[self nextResponder] touchesEnded:touches withEvent:event];
		return;
	}
	
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self]; //where image was tapped
    
    CGRect r = self.frame;
    r.origin = CGPointZero;
    
    if (CGRectContainsPoint(r, point)) {
        UIColor *color = [self getPixelColorAtLocation:point]; 
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        if (components[3] != 0) {
            _lastSelectedColor = color;   
        }
    }
    
    if ([_delegate respondsToSelector:@selector(pickedColor:)]) {
        [_delegate performSelector:@selector(pickedColor:) withObject:_lastSelectedColor];
    }
    
    if (_hideAfterSelection) {
        [self hidePicker];
    }
}


- (void) animateColorWheelToShow:(BOOL)show duration:(float)duration {
	
    if ([self.layer.animationKeys count] > 0) {
        return;
    }
    
    int x;
	float angle;
	float scale;
    
	if (show) { 
		x = 0;
		angle = 0;
		scale = 1;
		[self setNeedsDisplay];
		self.hidden = NO;
	} else {
        x = -320;
		angle = -3.12;
		scale = 0.001;
	}
    
    CATransform3D transform = CATransform3DMakeTranslation(0,0,0);
    transform = CATransform3DScale(transform, scale, scale, 1);
    
    [UIView animateWithDuration:duration 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{
                         self.transform = CATransform3DGetAffineTransform(transform);
                         self.layer.transform = transform;
                     } 
                     completion:^(BOOL finished) {
                         if (show == NO) {
                             [self setHidden:YES];
                         }
                     }];
}

- (void) showPicker {
    [self showPickerWithDuration:0.3f];
}

- (void) hidePicker {
    [self hidePickerWithDuration:0.3f];
}


- (void) showPickerWithDuration:(float)duration  {
    [self animateColorWheelToShow:YES duration:duration];
}

- (void) hidePickerWithDuration:(float)duration {
    [self animateColorWheelToShow:NO duration:duration];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
