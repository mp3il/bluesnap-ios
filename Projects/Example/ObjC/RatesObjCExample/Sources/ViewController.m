//
//  ViewController.m
//  RatesObjCExample
//

#import "ViewController.h"

@import SwiftRates;

@interface ViewController () <UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *currencyButton;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIButton *convertButton;

@end

@implementation ViewController

#pragma mark - UIViewController's methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	
	[self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Dismiss keyboard

- (void)dismissKeyboard
{
	[_valueTextField resignFirstResponder];
}

#pragma mark - Actions

- (IBAction)convertButtonAction:(UIButton *)sender
{
	CGFloat rawValue = [_valueTextField.text floatValue];
	
	[SwiftRates showSummaryScreen:rawValue toCurrency:_currencyButton.titleLabel.text inNavigationController:self.navigationController animated:YES];
}

- (IBAction)currencyButtonAction:(UIButton *)sender
{
	[SwiftRates showCurrencyList:sender inViewController:self animated:YES];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
	return UIModalPresentationNone;
}

@end
