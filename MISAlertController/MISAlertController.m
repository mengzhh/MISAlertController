//
//  MISAlertController.m
//
//  Created by Michael Schneider on 9/28/14.
//  Copyright (c) 2014 Michael Schneider. Licensed under the MIT license.
//

#import "MISAlertController.h"

#pragma mark - MISAlertAction

@interface MISAlertAction ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) UIAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(MISAlertAction *action);

@property (nonatomic, strong) UIAlertAction *alertAction;
@end

@implementation MISAlertAction

@synthesize enabled = _enabled;

#pragma mark Class

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(MISAlertAction *action))handler
{
    return [[MISAlertAction alloc] initWithTitle:title style:style handler:handler];
}


#pragma mark Lifecycle

- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(MISAlertAction *action))handler
{
    self = [super init];
    if (self == nil) { return nil; }
    
    _title = title;
    _style = style;
    _handler = handler;

    if (NSClassFromString(@"UIAlertController") != nil) {
        __weak typeof(self) weakSelf = self;
        self.alertAction = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *alertAction) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            if (handler) {
                handler(strongSelf);
            }
        }];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MISAlertAction *alertAction = [self.class new];
    alertAction.title = self.title;
    alertAction.style = self.style;
    alertAction.handler = self.handler;
    alertAction.alertAction = self.alertAction;
    return alertAction;
}


#pragma mark Setter

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (self.alertAction != nil) {
        self.alertAction.enabled = enabled;
    }
}

@end


#pragma mark - MISUIAlertController

@interface MISUIAlertController : UIAlertController
@property (nonatomic, copy) void (^didDisappearCallback)(void);
@end

@implementation MISUIAlertController

#pragma mark UIViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.didDisappearCallback) {
        self.didDisappearCallback();
    }
}

#pragma mark UIAlertController

- (void)addAction:(UIAlertAction *)action
{
    if ([action isKindOfClass:MISAlertAction.class]) {
        [super addAction:[(MISAlertAction *)action alertAction]];
        return;
    }
    
    [super addAction:action];
}

#pragma mark Show

- (void)showFromSourceView:(UIView *)sourceView inViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIPopoverPresentationController *popover = self.popoverPresentationController;
    if (popover) {
        // If we have a source view use this to layout the popover
        if (sourceView != nil) {
            popover.sourceView = sourceView;
            popover.sourceRect = sourceView.bounds;
        }
        else {
            // If no source view is available show the action sheet centered
            popover.sourceView = viewController.view;
            popover.sourceRect = viewController.view.bounds;
            popover.permittedArrowDirections = 0;
        }
    }
    
    [viewController presentViewController:self animated:animated completion:nil];
}

@end


#pragma mark - MISAlertControllerHelper

@interface MISAlertControllerHelper : NSObject
@property (nonatomic, assign) UIAlertControllerStyle preferredStyle;
@property (nonatomic, strong) NSMutableArray *internalActions;

- (void)addAction:(MISAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) void (^didDisappearCallback)(void);
- (void)configureControl:(id)control;

- (void)showFromSourceView:(UIView *)sourceView inViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface MISAlertControllerAlertViewHelper : MISAlertControllerHelper<UIAlertViewDelegate>
@property (strong, nonatomic) UIAlertView *alertView;
@end

@interface MISAlertControllerActionSheetHelper : MISAlertControllerHelper<UIActionSheetDelegate>
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation MISAlertControllerHelper

#pragma mark Class

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    MISAlertControllerHelper *helper = (preferredStyle == UIAlertControllerStyleActionSheet) ? MISAlertControllerActionSheetHelper.new : MISAlertControllerAlertViewHelper.new;
    helper.title = title;
    helper.message = message;
    helper.preferredStyle = preferredStyle;
    return helper;
}

#pragma mark Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self == nil) { return self; }
    _internalActions = [NSMutableArray array];
    return self;
}

#pragma mark Setter / Getter

- (id)control
{
    // Subclass should return either UIAlertView or UIActionSheet
    return nil;
}

- (void)setTitle:(NSString *)title
{
    id control = self.control;
    if ([control respondsToSelector:@selector(setTitle:)]) {
        [control setTitle:title];
    }
}

- (NSString *)title
{
    id control = self.control;
    if ([control respondsToSelector:@selector(title)]) {
        return [control title];
    }
    return nil;
}

- (void)setMessage:(NSString *)message
{
    id control = self.control;
    if ([control respondsToSelector:@selector(setMessage:)]) {
        [control setMessage:message];
    }
}

- (NSString *)message
{
    id control = self.control;
    if ([control respondsToSelector:@selector(message)]) {
        return [control message];
    }
    
    return nil;
}

#pragma mark Actions

- (void)addAction:(MISAlertAction *)action
{
    // Subclass needs to implement
}

- (NSArray *)actions
{
    return [self.internalActions copy];
}

#pragma mark TextFields

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler
{
    // Subclass needs to implement
}

- (NSArray *)textFields
{
    return @[];
}

#pragma mark Configuration

- (void)configureControl:(id)control
{
    // Add all actions to the control
    [self.internalActions enumerateObjectsUsingBlock:^(MISAlertAction *action, NSUInteger idx, BOOL *stop) {
        NSInteger buttonIdx = [control addButtonWithTitle:action.title];
        if (action.style == UIAlertActionStyleCancel) {
            if ([control respondsToSelector:@selector(setCancelButtonIndex:)]) {
                [control setCancelButtonIndex:buttonIdx];
            }
        }
        else if (action.style == UIAlertActionStyleDestructive) {
            if ([control respondsToSelector:@selector(setDestructiveButtonIndex:)]) {
                [control setDestructiveButtonIndex:buttonIdx];
            }
        }
    }];
}

#pragma mark UIActionSheet / UIAlertView Delegate helper

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MISAlertAction *alertAction = self.internalActions[buttonIndex];
    void (^callback)(MISAlertAction *action) = alertAction.handler;
    if (callback) {
        callback(self.actions[buttonIndex]);
    }
}

- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.didDisappearCallback) {
        self.didDisappearCallback();
    }
}

#pragma mark Show

- (void)showFromSourceView:(UIView *)sourceView inViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Show alert view or action sheet
    id control = self.control;
    
    [self configureControl:control];
    
    if (sourceView != nil && [control respondsToSelector:@selector(showFromRect:inView:animated:)]) {
        [control showFromRect:sourceView.bounds inView:sourceView animated:animated];
    }
    else if ([control respondsToSelector:@selector(showInView:)]) {
        [control showInView:viewController.view];
    }
    else if ([control respondsToSelector:@selector(show)]) {
        [control show];
    }
}

#pragma mark Hide

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    id control = self.control;
    
    if ([control respondsToSelector:@selector(dismissWithClickedButtonIndex:animated:)] &&
        [control respondsToSelector:@selector(isVisible)] && [control isVisible]) {
        [control dismissWithClickedButtonIndex:-1 animated:YES];
    }
    
    if (completion) {
        completion();
    }
}

@end


#pragma mark - MISAlertControllerAlertViewHelper

@implementation MISAlertControllerAlertViewHelper

#pragma mark Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self == nil) { return self; }
    _alertView = [[UIAlertView alloc] init];
    _alertView.delegate = self;
    return self;
}

#pragma mark MISAlertControllerHelper

- (id)control
{
    return self.alertView;
}

- (void)addAction:(MISAlertAction *)action
{
    [self.internalActions addObject:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler
{
    // Add text field to alert view and return the text field to the configuration handler
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    configurationHandler([self.alertView textFieldAtIndex:0]);
}

- (NSArray *)textFields
{
    if (self.alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        return @[[self.alertView textFieldAtIndex:0]];
    }
    
    return [super textFields];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self clickedButtonAtIndex:buttonIndex];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self didDismissWithButtonIndex:buttonIndex];
}

@end


#pragma mark - MISAlertControllerActionSheetHelper

@implementation MISAlertControllerActionSheetHelper

- (instancetype)init
{
    self = [super init];
    if (self == nil) { return self; }
    _actionSheet = [[UIActionSheet alloc] init];
    _actionSheet.delegate = self;
    return self;
}


#pragma mark MISAlertControllerHelper

- (id)control
{
    return self.actionSheet;
}

- (void)addAction:(MISAlertAction *)action
{
    [self.internalActions insertObject:action atIndex:0];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler
{
    NSAssert(NO, @"MISAlertControllerStyleActionSheet does not support text fields");
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self clickedButtonAtIndex:buttonIndex];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self didDismissWithButtonIndex:buttonIndex];
}

@end


#pragma mark - MISAlertController

@interface MISAlertController () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) id alertController;
@end

@implementation MISAlertController

#pragma mark Class

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [[MISAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

#pragma mark Lifecycle

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    self = [super init];
    if (self == nil) { return self; }
    [self configureControllerWithTitle:title message:message preferredStyle:preferredStyle];
    return self;
}

#pragma mark Control

- (void)configureControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    if (NSClassFromString(@"UIAlertController") != nil) {
        self.alertController = [MISUIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    } else {
        self.alertController = [MISAlertControllerHelper alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    }
}

#pragma mark Show Alert Controller

- (void)showInViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self showFromSourceView:nil inViewController:viewController animated:animated];
}

- (void)showFromSourceView:(UIView *)sourceView inViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Show alert view or action sheet
    id alertController = self.alertController;

    // Use __block in this case so self is not dealloced before the control disappeared
    __block MISAlertController *blockSelf = self;
    [alertController setDidDisappearCallback:^{
        // Push it to the next run loop so we dealloc self after the action was fired
        dispatch_async(dispatch_get_main_queue(), ^{
            blockSelf.alertController = nil;
            blockSelf = nil;
        });
    }];
    
    [alertController showFromSourceView:sourceView inViewController:viewController animated:animated];
}

#pragma mark Hide Alert Controller

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.alertController) {
        [self.alertController dismissViewControllerAnimated:flag completion:completion];
    } else {
        // If alertController is already dismissed just call completion block
        if (completion) {
            completion();
        }
    }
}

#pragma mark Forwarding

- (id)forwardingTargetForSelector:(SEL)selector
{
    // Dispatch all messages from the Proxy category to the alert controller
    if ([self.alertController respondsToSelector:selector]) {
        return self.alertController;
    }
    
    return [super forwardingTargetForSelector:selector];
}

@end
