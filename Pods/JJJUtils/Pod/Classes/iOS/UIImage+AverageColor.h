//
//  UIImage+AverageColor.h
//  Decktracker
//
//  Created by Jovit Royeca on 11/15/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AverageColor)

-(UIColor *) averageColor;

-(UIColor *) patternColor:(UIColor*) averageColor;

@end
