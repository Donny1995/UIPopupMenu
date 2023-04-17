//
//  NSObject+LoadStarter.h
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 12.04.2023.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyboardListener : NSObject

+ (void)load;
@property (class, nonatomic, readonly) CGRect keyboardRect;

@end

NS_ASSUME_NONNULL_END

