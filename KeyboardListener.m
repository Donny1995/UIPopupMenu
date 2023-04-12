//
//  NSObject+LoadStarter.m
//  UIPopupMenu
//
//  Created by Alexandr Sivash on 12.04.2023.
//

#import "KeyboardListener.h"

@implementation KeyboardListener

static CGRect _keyboardRect;

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

+ (void)keyboardWillShow:(NSNotification *)notification {
    _keyboardRect = [self keyboardFrameFromNotification: notification];
}

+ (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardRect = CGRectNull;
}

+ (void)keyboardWillChange:(NSNotification *)notification {
    _keyboardRect = [self keyboardFrameFromNotification: notification];
}

+ (CGRect)keyboardRect {
    return _keyboardRect;
}

+ (CGRect)keyboardFrameFromNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    return [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end
