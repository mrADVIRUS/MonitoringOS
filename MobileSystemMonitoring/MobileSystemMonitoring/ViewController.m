//
//  ViewController.m
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 14.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import "ViewController.h"
#import "Macroses.h"
#import "Types.h"

NSString * const HCdidChangeDefaultLogFolderNotification = @"HCdidChangeDefaultLogFolderNotification";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *vSettings;
@property (weak, nonatomic) IBOutlet UIView *vDetails;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segFolders;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UITextField *tfTimeInterval;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcSettingsTopOffset;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL appRunFirstTime = [userDef boolForKey:k_appFirstTime];
    self.vSettings.hidden = appRunFirstTime;
    
    self.vDetails.hidden = !appRunFirstTime;
    [self updateDescription];
    [self subscribeNotifications];
}

- (void)dealloc
{
    [self unsubscribeNotifications];
}

#pragma mark - Private

- (void) configureUI
{
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(onBtnDoneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.tfTimeInterval.inputAccessoryView = keyboardDoneButtonView;
    
    self.btnSave.layer.borderColor = [UIColor colorWithRed:0.27 green:0.84 blue:0.58 alpha:1.0].CGColor;
    self.vSettings.layer.borderWidth = 1.0f;
    self.vSettings.layer.cornerRadius = 10.0f;
    self.vSettings.layer.borderColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0].CGColor;
}

- (void) subscribeNotifications
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) unsubscribeNotifications
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) updateDescription
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    CGFloat timeInterval = [userDef doubleForKey:k_userTimeInterval];
    EMonitoringFolderType folderType = [userDef integerForKey:k_typeFolder];
    
    NSString *folderName = (folderType == EMonitoringFolderTypeDocuments) ? @"Documents" : ((folderType == EMonitoringFolderTypeLibrary) ? @"Library" : @"Temp");
    self.lblDescription.text = [NSString stringWithFormat:@"Monitoring starts only when app in background and all logs saves in folder '%@' every %.2f sec.", folderName, timeInterval];
}

- (BOOL)checkTimeInterval
{
    CGFloat timeInterval = [self.tfTimeInterval.text doubleValue];
    if (timeInterval <= 0) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Alert"
                                     message:@"Time interval must be more than 0."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* okBtn = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:nil];
        
        [alert addAction:okBtn];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)onBtnDoneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    
    if ([self checkTimeInterval]) {
        [self.view endEditing:YES];
    }
}

- (IBAction)onBtnSave:(id)sender
{
    if (![self checkTimeInterval]) {
        return;
    }
    
    EMonitoringFolderType folderType = self.segFolders.selectedSegmentIndex;
//    NSLog(@"Index = %lu", (unsigned long)folderType);

    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setDouble:[self.tfTimeInterval.text doubleValue] forKey:k_userTimeInterval];
    [userDef setInteger:folderType forKey:k_typeFolder];
    [userDef setBool:YES forKey:k_appFirstTime];
    [userDef synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HCdidChangeDefaultLogFolderNotification
                                                        object:self
                                                      userInfo:@{@"folderType":@(folderType)}];
    
    WEAKSELF_DECLARATION
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF_DECLARATION
        [strongSelf.vSettings setAlpha:0.0f];
    } completion:^(BOOL finished) {
        STRONGSELF_DECLARATION
        [strongSelf.vSettings setHidden:YES];
        [strongSelf.vDetails setHidden:NO];
        
        [strongSelf updateDescription];
    }];
}

- (IBAction)onBtnOpenSettings:(id)sender
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    CGFloat timeInterval = [userDef doubleForKey:k_userTimeInterval];
    EMonitoringFolderType folderType = [userDef integerForKey:k_typeFolder];
    
    self.segFolders.selectedSegmentIndex = folderType;
    self.tfTimeInterval.text = [NSString stringWithFormat:@"%.1f", timeInterval];
    
    [self.vSettings setHidden:NO];

    WEAKSELF_DECLARATION
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF_DECLARATION
        strongSelf.vSettings.alpha = 1.0f;
    } completion:nil];
}

#pragma mark - NSNotifications

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSTimeInterval duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.lcSettingsTopOffset.constant = 0.0;
    
    WEAKSELF_DECLARATION
    [UIView animateWithDuration:duration
                     animations:^{
                         STRONGSELF_DECLARATION
                         [strongSelf.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSTimeInterval duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.lcSettingsTopOffset.constant = 100.0;

    WEAKSELF_DECLARATION
    [UIView animateWithDuration:duration
                     animations:^{
                         STRONGSELF_DECLARATION
                         [strongSelf.view layoutIfNeeded];
                     }];
}

@end
