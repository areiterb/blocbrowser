//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by ALEJANDRO REITER B on 9/10/14.
//  Copyright (c) 2014 Alejandro Reiter. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"


@interface BLCAwesomeFloatingToolbar () {
    CGFloat toolbarScale;
    NSInteger colorIndex;
}

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        toolbarScale = 1.0;
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        colorIndex = 0;
  
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
        // self.dimButtons = [UIButton buttonWithType:UIButtonTypeSystem];
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePincheGesture:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressDuration:)];
        [self addGestureRecognizer:self.longGesture];
        self.longGesture.minimumPressDuration = 1.0;
        [self addGestureRecognizer:_longGesture];
        
    }
    
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        // Review this part
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

- (UILabel *) labelFromTouches: (NSSet *)touches withEvent:(UIEvent *) event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}


- (void) tapFired: (UITapGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateRecognized) {
        return;
    }
    CGPoint location = [recognizer locationInView:self];
    UIView *tappedView = [self hitTest:location withEvent:nil];
        
    if ([self.labels containsObject:tappedView]) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
    
}

- (void) handlePincheGesture: (UIPinchGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateBegan == _pinchGesture.state ||
        UIGestureRecognizerStateChanged == _pinchGesture.state) {
        
        CGFloat deltaScale = _pinchGesture.scale;
        
        toolbarScale = deltaScale;
        
        CGAffineTransform zoomTransform = CGAffineTransformScale(_pinchGesture.view.transform, deltaScale, deltaScale);
        _pinchGesture.view.transform = zoomTransform;
        
        _pinchGesture.scale = 1;
        
    }
}

- (void) handleLongPressDuration: (UILongPressGestureRecognizer *)recognizer {
    // Alpha {0000 0000} Red {0000 0000} Green {0000 0000} Blue {0000 0000}
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        /*
        NSMutableArray *newLabelArray;
        
        for (int i = 0; i < self.colors.count; i++) {
            UILabel *label = self.labels[i];
            label.textColor = self.colors[i];
            [newLabelArray addObject:label];
        }
         */
        /*[self.colors enumerateObjectsUsingBlock:^(UIColor *obj, NSUInteger idx, BOOL *stop) {
            // loops through colors 0->3
        }];*/
        [self.labels enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
            if (colorIndex == 0) {

            }
                
        }];
        
        
        // before long press
        // label 1 = color 1
        // label 2 = color 2
        // label 3 = color 3
        // label 4 = color 4
        
        // after first long press
        // label 1 = color 2
        // label 2 = color 3
        // label 3 = color 4
        // label 4 = color 1
        
        // after fourth long press
        // label 1 = color 1
        // label 2 = color 2
        // label 3 = color 3
        // label 4 = color 4
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}




@end

