//
//  MISAlertController.h
//
//  Created by Michael Schneider on 9/28/14.
//  Copyright (c) 2014 Michael Schneider. Licensed under the MIT license.
//

#import <UIKit/UIKit.h>

@interface MISAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(MISAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end


@interface MISAlertController : NSObject

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle;

- (void)showInViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)showFromSourceView:(UIView *)sourceView inViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end


@interface MISAlertController (Proxy)

- (void)addAction:(MISAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) UIAlertControllerStyle preferredStyle;

@end
