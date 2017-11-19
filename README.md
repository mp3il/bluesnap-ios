# BlueSnap iOS SDK overview
BlueSnap's iOS SDK enables you to easily accept credit card payments directly from your iOS app and then process the payments via BlueSnap's Payment API. Additionally, if you use the Standard Checkout Flow (described below), you can process Apple Pay and PayPal payments as well.
When you use this library, BlueSnap handles most of the PCI compliance burden for you, as the user's payment data is tokenized and sent directly to BlueSnap.

This document will cover the following topics: 
* [Checkout flow options](#checkout-flow-options)
* [Installation](#installation)
* [Usage](#usage)
* [Implementing Standard Checkout Flow](#implementing-standard-checkout-flow)
* [Implementing Custom Checkout Flow](#implementing-custom-checkout-flow)
* [Sending the payment for processing](#sending-the-payment-for-processing)
* [Demo app - explained](#demo-app---explained)
* [Reference](#reference)

# Checkout flow options
The BlueSnap iOS SDK provides two elegant checkout flows to choose from. 
## Standard Checkout Flow 
The Standard Checkout Flow allows you to get up and running quickly with our pre-built checkout UI, enabling you to accept credit cards, Apple Pay, and PayPal payments in your app.
 Some of the capabilities include:
* Specifying required user info, such as email or billing address.
* Specifying an existing/returning shopper, so we can pre-populate all the details and allow selecting from existing payment methods.
* Pre-populating checkout page.
* Launching checkout UI with simple start function.

To see an image of the Standard Checkout Flow, click [here](https://developers.bluesnap.com/v8976-Basics/docs/ios-sdk#standard-checkout-flow). 

## Custom Checkout Flow
The Custom Checkout Flow enables you to easily accept credit card payments using our flexible credit card UI component, allowing you to have full control over the look and feel of your checkout experience. 
Some of the capabilities include: 
* Flexible and customizable UI element with built-in validations and card-type detection.
* Helper classes to assist you in currency conversions, removing whitespace, and more.
* Simple function that submits sensitive card details directly to BlueSnap's server.

To see an image of the credit card UI component, click [here](https://developers.bluesnap.com/v8976-Basics/docs/ios-sdk#section-custom-checkout-flow). 

# Installation
> The SDK is written in Swift 3, using Xcode 8.

## Requirements
* CocoaPods 1.1.0+
* Xcode 8.3.3+
* [BlueSnap API credentials](https://support.bluesnap.com/docs/api-credentials) 

## CocoaPods (Optional, CocoaPods 1.1.0+)
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate BluesnapSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BluesnapSDK', '~> <git tag/branch name>' 
    pod 'BluesnapSDK/DataCollector', '~> <git tag/branch name>'

end
```

Then, run the following command:

```bash
$ pod install
```
> Use the .xcworkspace file to open your project in Xcode.

## Disable landscape mode
Landscape mode is not supported in our UI, so in order to make sure the screen does not rotate with the device, you need to add this code to your application's AppDelegate.swift file:

    // MARK: Prevent auto-rotate
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

## Objective C Applications
This SDK is written in Swift. If your application is written in Objective-C, you might need to embed a Swift runtime library. Please follow [Apple's documentation](https://developer.apple.com/library/content/qa/qa1881/_index.html) to set up your project accordingly.

## Apple Pay (optional)
In the Standard Checkout Flow, Apple Pay is available for you to offer in your app. You will need to create a new Apple Pay Certificate, Apple Merchant ID, and configure Apple Pay in Xcode. Detailed instructions are available in our [Apple Pay Guide](https://developers.bluesnap.com/docs/apple-pay#section-implementing-apple-pay-in-your-website-or-ios-app). 

## PayPal (optional)
In the Standard Checkout Flow, you have the option to accept PayPal payments in your app. Follow these steps: 

1. Make sure you have a PayPal Business or Premier account. If you do not yet have a PayPal account, you can sign up for one on the PayPal website.

2. Connect your PayPal account to BlueSnap. Detailed instructions are available [here](https://support.bluesnap.com/docs/connecting-paypal-and-bluesnap). 

# Usage
This section will cover the following topics: 
* [Generating a token for the transaction](#generating-a-token-for-the-transaction)
* [Initializing the SDK](#initializing-the-sdk-with-the-token)

## Generating a token for the transaction
For each transaction, you'll need to generate a Hosted Payment Fields token on your server and pass it to the SDK.

To do this, initiate a server to server POST request with your API credentials and send it to the relevant URL for the Sandbox or Production environment:
* **Sandbox:** `https://sandbox.bluesnap.com/services/2/payment-fields-tokens`
* **Production:** `https://ws.bluesnap.com/services/2/payment-fields-tokens`

The token is returned in the Location header in the response. For more information, see [Creating a Hosted Payment Fields Token](http://developers.bluesnap.com/v4.0/docs/create-hosted-payment-fields-token). 

For returning shopper flow, add a querystring parameter to the URL: ?shopperId=<the shopper ID>

## Initializing the SDK
Create a `BSToken` instance using your token and a boolean to indicate if you're working in production. For this example, we'll pass `false` to indicate sandbox. 

```swift
fileprivate var bsToken : BSToken?
bsToken = BSToken(tokenStr: "c3d011abe0ba877be0d903a2f0e4ca4ecc0376e042e07bdec2090610e92730b5_", isProduction: false)
```
Initialize the SDK by calling [`initBluesnap`](#initBluesnap) function of `BlueSnapSDK` class.
See all the information on the functions parameters below, in the section "Main functionality - BlueSnapSDK class".

→ If you're using the Standard Checkout Flow, then continue on to the next section. <br>
→ If you're using the Custom Checkout Flow, then jump down to [Implementing Custom Checkout Flow](#implementing-custom-checkout-flow). 

# Implementing Standard Checkout Flow
This section will cover the following topics: 
* [Defining your checkout settings & callback function](#defining-your-checkout-settings--callback-function)
* [Launching checkout UI](#launching-checkout-ui)

## Defining your checkout settings

The [`showCheckoutScreen`](#showcheckoutscreen) function of the `BlueSnapSDK` class is the main entry point for the SDK. When called, this function launches the checkout UI for the user based on the parameters you provide. For example, you can display tax amounts and subtotals, specify which fields to require from the user, and pre-populate the checkout page with information you've already collected.

This function takes the parameters listed below. We'll go over setting `sdkRequest` in this section. 

| Parameter | Description |
| ------------- | ------------- |
| `inNavigationController`  | Your `ViewController`'s `navigationController` (to be able to navigate back).  |
| `animated` | Boolean that indicates if page transitions are animated. If `true`, wipe transition is used. If `false`, no animation is used - pages replace one another at once. |
| `sdkRequest` | Object that holds price information, required checkout fields, and initial user data. |

See the [Reference](#showcheckoutscreen) section below for more information on `showCheckoutScreen`. 

### Defining sdkRequest
`sdkRequest` (an instance of `BSSdkRequest`) allows you to initialize your checkout settings, such as price details, required user fields, and user data you've already collected.

```swift
fileprivate var sdkRequest: BSSdkRequest! = BSSdkRequest(...)
```

BSSdkRequest constructor parameters:

| Parameter      | Description   |
| ------------- | ------------- |
| Specifying required checkout fields |
| `withEmail`   | Boolean that determines if email is required. Default value is `true` - email is required. |
| `fullBilling` | Boolean that determines if full billing details are required. If `true`, full billing details are required. Default value is `false` - Full billing details are not required. |
| `withShipping` | Boolean that determines if shipping details are required. If `true`, shipping details (i.e. name, address, etc.) are required. Default value is `false` - shipping details are not required. |
| Purchase amount and currency |
| `priceDetails` | an instance of class BSPriceDetails, holding the proce details (see more below) |
| Pre-populating the checkout page (if you have user's data that you've already collected) |
| `billingDetails` | An instance of `BSBillingAddressDetails` - see `Pre-populating the checkout page` below. |
| `shippingDetails` | An instance of `BSShippingAddressDetails` - see `Pre-populating the checkout page` below. |
| Callback functions: |
| `purchaseFunc` | See `Defining your purchase callback function` below. |
| `updateTaxFunc` | (optional) See `Handling tax updates` below. |


#### Defining priceDetails
`priceDetails` (an instance of `BSPriceDetails`) is a property of `sdkRequest` that contains properties for amount, tax amount, and [currency](https://developers.bluesnap.com/docs/currency-codes). Set these properties to intialize the price details of the checkout page. 

```swift
sdkRequest.priceDetails = BSPriceDetails(amount: 25.00, taxAmount: 1.52, currency: "USD")
```
> If you’re accepting PayPal payments, please note: PayPal will be available only if `currency` is set to a currency supported by your [PayPal configuration](https://support.bluesnap.com/docs/connecting-paypal-and-bluesnap#section-4-synchronize-your-currency-balances). 

#### Pre-populating the checkout page (optional)
The following properties of `sdkRequest` allow you to pass user's data that you've already collected in order to pre-populate the checkout page.

| Property      | Description   |
| ------------- | ------------- |
| `billingDetails` | An instance of `BSBillingAddressDetails` that contains properties for name, address, city, country, state, and email. |
| `shippingDetails` | An instance of `BSShippingAddressDetails` that contains properties for name, address, and so on. |

In ViewController.swift of the demo app, take a look at the `setInitialShopperDetails` function to see an example of setting these properties with user data.

#### Handling tax updates (optional)
If you choose to collect shipping details (i.e. `withShipping` is set to `true`), then you may want to update tax rates whenever the user changes their shipping location. Supply a callback function to handle tax updates to the `updateTaxFunc` property of `sdkRequest`. Your function will be called whenever the user changes their shipping country or state. 

To see an example, check out `updateTax` in the demo app. 

### Defining your purchase callback function
`purchaseFunc` is a member of `sdkRequest` that takes a callback function to be invoked after the user hits “Pay” and their data is successfully submitted to BlueSnap (and associated with your token). 

`purchaseFunc` will be invoked with one of the following class instances (if and only if data submission to BlueSnap was successful): 

* If the result is a `BSApplePaySdkResult` instance, it will contain details about the amount, tax, and currency. Note that billing/shipping info is not collected, as it’s not needed to complete the purchase.  

* If the result is a `BSCcSdkResult` or `BSExistingCcSdkResult` instance, it will contain details about the amount, tax, currency, shipping/billing information, and non-sensitive credit card details (card type, last 4 digits, issuing country). 

* If the result is a `BSPayPalSdkResult`, then the transaction has already been completed! There is no need to send the transaction for processing from your server. 

To see how to structure `purchaseFunc`, check out [Defining your callback function](#defining-your-callback-function). 

Within `purchaseFunc`, the following logic will apply: 
1. Detect the specific payment method the user selected. 

2. If the user selected PayPal, no further action is required - transaction is complete. Show success message.

3. If the user selected Apple Pay or credit card, update your server with the order details and the token.

4. From your server, [complete the purchase](#sending-the-payment-for-processing) with your token. 

5. After receiving BlueSnap's response, update the client and display an appropriate message to the user. 

The function `completePurchase` in the demo app shows this logic.
```swift
private func completePurchase(purchaseDetails: BSBaseSdkResult!) {

    if let paypalPurchaseDetails = purchaseDetails as? BSPayPalSdkResult {
        // user chose PayPal
        // show success message
        return // no need to complete purchase via BlueSnap API
    }
    if let applePayPurchaseDetails = purchaseDetails as? BSApplePaySdkResult {
        // user chose Apple Pay
        // send order details & bsToken to server...

        // ...receive response

    } else if let ccPurchaseDetails = purchaseDetails as? BSCcSdkResult {
        // user chose credit card 
        // send order details & bsToken to server...

        // ...receive response
    }
    // depending on response, show success/fail message
}
```

> **Notes**: 
> * `purchaseFunc` will be called only if the user's details were successfully submitted to BlueSnap; it will not be called in case of an error. 
>
> * It's very important to send the payment for processing from your server. 

## Launching checkout UI
Now that you've set `showCheckoutScreen`'s parameters, it's time to launch the checkout UI for the user. 
```swift
    BlueSnapSDK.showCheckoutScreen(
        inNavigationController: self.navigationController,
        animated: true,
        sdkRequest: sdkRequest
    )
```
And you're ready to go! Accepting Apple Pay, credit card, and PayPal payments will be a breeze.

# Implementing Custom Checkout Flow
This section will cover the following topics: 
* [Configuring BSCcInputLine](#configuring-bsccinputline)
* [Setting up BSCcInputLineDelegate](#setting-up-bsccinputlinedelegate)
* [Setting up your submit action](#setting-up-your-submit-action)

## Configuring BSCcInputLine
[`BSCcInputLine`](#bsccinputline) is a UIView that holds the user's sensitive credit card data - credit card number, expiration date, and CVV. In addition to supplying an elegant user experience, it handles input validations, and submits the secured data to BlueSnap. Simply place a UIView in your storyboard and set its class to `BSCcInputLine`.

> **Notes**: 
> * In addition to card details, be sure to collect the user information marked as **Required** on [this page](https://developers.bluesnap.com/v8976-JSON/docs/card-holder-info).
> * If you would like to build your own UI fields for credit card number, expiration date, and CVV, BlueSnap provides you with a function called [`submitCcDetails`](#submitccdetails) to submit the user's card data directly to BlueSnap. Visit the [Reference](#submitccdetails) section to learn more.

## Setting up BSCcInputLineDelegate
If you're using `BSCcInputLine` to collect the user's data, in your `ViewController` you'll need to implement `BSCcInputLineDelegate`, which has 6 methods:

| Method      | Description   |
| ------------- | ------------- |
| `startEditCreditCard()` | Called just before the user enters the open state of CC field to edit it (in the UI, BlueSnap uses this stage to hide other fields). |
| `endEditCreditCard()` | Called after the user exits the CC field and it is the closed state to show last 4 digits of CC number (in the UI, BlueSnap uses this stage to un-hide the other fields). |
| `willCheckCreditCard()` | Called just before submitting the CC number to BlueSnap for validation (this action is asynchronous; in the UI, BlueSnap does nothing at this stage). |
| `didCheckCreditCard(creditCard: BSCreditCard, error: BSErrors)` | Called when BlueSnap gets the CC number validation response; if the error is empty, you will get the CC type, issuing country, and last 4 digits of CC number inside `creditCard` (in the UI, BlueSnap uses this stage to change the icon for the credit card type). Errors are shown by the component, you do not need to handle them. |
| `didSubmitCreditCard(creditCard: BSCreditCard, error: BSErrors)`* | Called when the response for the token submission is received (in the UI, BlueSnap uses this stage to close the window and callback the success action) – errors are shown by the component, you need not handle them. |
| `showAlert(_ message: String)` | Called when there is an unexpected error (not a validation error). |

*Within `didSubmitCreditCard`, you'll do the following: 
1. Detect if the user's card data was successfully submitted to BlueSnap (i.e. error is `nil`). 


2. If error is `nil`, you'll get the CC type, issuing country, and last 4 digits of CC number within `creditCard`. Update your server. 

3. From your server, you'll [send the payment for processing](#sending-the-payment-for-processing) using your token.

4. After you receive BlueSnap's response, you'll update the client and display an appropriate message to your user (i.e. "Congratulations, your payment was successful!" or "Oops, please try again.").

## Setting up your submit action
On your submit action (i.e. when the user submits their payment during checkout), you should call `BSCcInputLine`'s `validate` function (which returns a boolean) to make sure the data is correct. 

If the validation was successful (i.e. `validate` returns `true`), then call `BSCcInputLine`'s `submitPaymentFields()` function, which will call the `didSubmitCreditCard` callback with the results of the submission. 

Another option is to call `checkCreditCard(ccn: String)` which first validates and then submits, calling the delegate `didSubmitCreditCard` after a successful submit.

Congratulations, you're ready to start accepting credit card payments! 

# Sending the payment for processing
For credit card and Apple Pay payments, you will use our Payment API with your token to send an [Auth Capture](https://developers.bluesnap.com/v8976-JSON/docs/auth-capture), [Auth Only](https://developers.bluesnap.com/v8976-JSON/docs/auth-only) or [subscription](https://developers.bluesnap.com/v8976-JSON/docs/create-subscription) request, or to attach the payment details to a [shopper](https://developers.bluesnap.com/v8976-JSON/docs/create-vaulted-shopper). 
Note that for a returning shopper CC transaction, all the payment data is already tokenized on the server, so in your API call you need only pass the token, amount and currency!

**Note**: The token must be associated with the user's payment details. In the Standard Checkout Flow, this is when `purchaseFunc` is called. In the Custom Checkout Flow, this is when `didSubmitCreditCard` is called (if you're using the `BSCcInputLine` field) or `completion` is called (if you're using your own input fields). 

> DemoTransactions.swift of demo app shows an example of an Auth Capture request. Please note that these calls are for demonstration purposes only - the transaction should be sent from your server.

### Auth Capture example - Apple Pay payments (Standard Checkout Flow)
For Apple Pay payments, send an HTTP POST request to `/services/2/transactions` of the BlueSnap sandbox or production environment. 

For example: 
```cURL
curl -v -X POST https://sandbox.bluesnap.com/services/2/transactions \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \ 
-H 'Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=' \
-d '
{
	"cardTransactionType": "AUTH_CAPTURE", 
	"recurringTransaction": "ECOMMERCE", 
	"softDescriptor": "Mobile SDK test", 
	"amount": 25.00, 
	"currency": "USD", 
	"pfToken": "ae76939fab7275cbfd657495eb8c4d0654e52e704c112170fa61f4127a34bf64_",
	"transactionFraudInfo": {"fraudSessionId": "B04C4B2B6BED427284ECE2F1F870466C"}
}'
```
If successful, the response HTTP status code is 200 OK. Visit our [API Reference](https://developers.bluesnap.com/v8976-JSON/docs/auth-capture) for more details. 

### Auth Capture example - Credit card payments (new CC / returning shopper with existing CC)
For credit card payments, send an HTTP POST request to `/services/2/transactions` of the BlueSnap sandbox or production environment. 

For example: 
```cURL
curl -v -X POST https://sandbox.bluesnap.com/services/2/transactions \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \ 
-H 'Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=' \
-d '
{
	"cardTransactionType": "AUTH_CAPTURE",
	"recurringTransaction": "ECOMMERCE",
	"softDescriptor": "Mobile SDK test",
	"amount": 25.00, 
	"currency": "USD",
	"pfToken": "812f6ee706e463d3276e3abeb21fa94072e40695ed423ddac244409b3b652eff_",
}'
```
If successful, the response HTTP status code is 200 OK. Visit our [API Reference](https://developers.bluesnap.com/v8976-JSON/docs/auth-capture) for more details. 

Note that all the shopper data (billing, shipping, CC details, fraud-session-id) has already been submitted except the amount and price.


# Demo app - explained
The demo app shows how to use the basic functionality of the Standard Checkout Flow, including the various stages you need to implement (everything is in class `ViewController`).

1. Get a token from BlueSnap's server. Please note that you need to do this in your server-side implementation, so you don't expose your BlueSnap API credentials in your app. In the demo app, we create a token from BlueSnap Sandbox environment with dummy credentials. Call `BlueSnapSDK.setBsToken` to initialize it in the SDK. Note that according to the toggle in the UI, we create a token with a shopper ID (for returning shopper flow) or without (for new shopper flow).

2. Call `BlueSnapSDK.initBluesnap` to initialize the SDK with your token, fraud detection, token expiration handling, and other settingas.

3. Initialize the input to the checkout flow by creating an instance of `BSSdkRequest` and filling the parts you may know already of the user (by setting `shippingDetails` & `billingDetails`), your callback functions for purchase and tax calculation, and the fields you wish to require from the user (by setting `withShipping`, `fullBilling`, & `withEmail`). 

4. Define your `purchaseFunc` callback to call your application's server to complete the purchase (see [Defining your callback function](#defining-your-callback-function) for the logic of this function).

5. Call `BlueSnapSDK.showCheckoutScreen` (#showcheckoutscreen) to launch the checkout UI for the user. 

> **Note**: The demo app shows how to take advantage of our currency screen, which allows the user to change the currency selection during checkout, by calling [`BlueSnapSDK.showCurrencyList`](#showcurrencylist) with its associated parameters. <br>
 > **Important**: All transaction calls are for demonstration purposes only. These calls should be made from your server. 

# Reference
This section will cover the following topics: 
* [Data structures](#data-structures)
* [Main functionality - BlueSnapSDK class](#main-functionality---bluesnapsdk-class)
* [Handling token expiration](#handling-token-expiration)
* [Helper classes](#helper-classes)
* [Custom UI controls](#custom-ui-controls)

## Data structures
In the BlueSnap iOS SDK project, the `Model` group contains the data structures used throughout.
 
### BSToken (in BSToken.swift)
`BSToken` is the simplest one. It contains the token you received from BlueSnap and a boolean to indicate production or sandbox.

    public class BSToken {
        internal var tokenStr: String! = ""
        internal var serverUrl: String! = ""
        public init(tokenStr : String!, isProduction : Bool) {
            self.tokenStr = tokenStr
            self.serverUrl = isProduction ? BSApiManager.BS_PRODUCTION_DOMAIN : BSApiManager.BS_SANDBOX_DOMAIN
        }
        public init(tokenStr : String!, serverUrl : String!) {
            self.tokenStr = tokenStr
            self.serverUrl = serverUrl
        }
        public func getTokenStr() -> String! {
            return self.tokenStr
        }    
        public func getServerUrl() -> String! {
            return self.serverUrl
        }
    }

The SDK holds a function for obtaining a token from our Sandbox environment for quick testing purposes.

### BSSdkRequest (in BSPurchaseModelData.swift)
This class allows you to initialize your checkout settings, such as price details, required user fields, and user data you've already collected.

For more information on the properties of `BSSdkRequest`, see [Defining sdkRequest](#defining-initialdata). 
 
	@objc public class BSSdkRequest : NSObject {
		public var withEmail: Bool = true
		public var withShipping: Bool = false
		public var fullBilling : Bool = false

		public var priceDetails: BSPriceDetails! = BSPriceDetails(amount: 0, taxAmount: 0, currency: nil)
		
		public var billingDetails : BSBillingAddressDetails?
		public var shippingDetails : BSShippingAddressDetails?
    		public var purchaseFunc: (BSBaseSdkResult!) -> Void
		public var updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?
		
		public init(
        		withEmail: Bool,
        		withShipping: Bool,
        		fullBilling: Bool,
        		priceDetails: BSPriceDetails!,
        		billingDetails: BSBillingAddressDetails?,
        		shippingDetails: BSShippingAddressDetails?,
        		purchaseFunc: @escaping (BSBaseSdkResult!) -> Void,
        		updateTaxFunc: ((_ shippingCountry: String, _ shippingState: String?, _ priceDetails: BSPriceDetails) -> Void)?) {
				...
		}
	}

### BSPriceDetails (in BSPurchaseDataModel.swift)
This class contains the price details that are both input and output for the purchase, such as amount, tax amount, and currency. 

	@objc public class BSPriceDetails : NSObject, NSCopying {
		
		public var amount : Double! = 0.0
		public var taxAmount : Double! = 0.0
		public var currency : String! = "USD"
		
		public init(amount : Double!, taxAmount : Double!, currency : String?) {
			super.init()
			self.amount = amount
			self.taxAmount = taxAmount
			self.currency = currency ?? "USD"
		}
		
		public func copy(with zone: NSZone? = nil) -> Any {
			let copy = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
			return copy
		}
		
		public func changeCurrencyAndConvertAmounts(newCurrency: BSCurrency!) {
			...
		}
	}

### BSBaseAddressDetails, BSBillingAddressDetails, BSShippingAddressDetails (in BSAddress.swift)

These classes hold the user's bill and shipping details. 
Optional/Mandatory:
* Email will be collected only if `withEmail` is set to `true` in `BSInitialData`. 
* State is mandatory only if the country has state (USA, Canada and Brazil).
* Zip is always mandatory except for countries that have no postal/zip code.
* If you choose not to use the full billing option, name, country and zip are required, and email is optional.
* For full billing details, everything is mandatory. 
* For shipping details, all fields are mandatory except phone which is optional.

```
public class BSBaseAddressDetails {

	public init() {}

	public var name : String! = ""
	public var address : String?
	public var city : String?
	public var zip : String?
	public var country : String?
	public var state : String?

	public func getSplitName() -> (firstName: String, lastName: String)? {
		return BSStringUtils.splitName(name)
	}
}

public class BSBillingAddressDetails : BSBaseAddressDetails {

	public override init() { super.init() }
	public var email : String?
}

public class BSShippingAddressDetails : BSBaseAddressDetails {

	public override init() { super.init() }
	public var phone : String?
}
```

### BSPaymentType (in BSPurchaseDataModel.swift)
This enum differentiates between the payment method the user chose. It will contain cases for credit card, Apple Pay, and PayPal. 
```
public enum BSPaymentType {
	case CreditCard = "CC"
	case ApplePay = "APPLE_PAY"
	case PayPal = "PAYPAL"
}
```
### BSBaseSdkResult (in BSPurchaseDataModel.swift)
The central data structure is this class (and its derived classes), which holds user data that is the purchase details collected by the SDK. This is an abbreviated version of the class:

    public class BSBaseSdkResult : NSObject {
        
        var fraudSessionId: String?
        var priceDetails: BSPriceDetails!
            
        internal init(sdkRequest: BSSdkRequest) {
            ...
        }
	
	// Returns the fraud session ID used in KountInit()
    	public func getFraudSessionId() -> String? {
        	return fraudSessionId;
    	}
        
        /*
        Set amounts will reset the currency and amounts, including the original amounts.
        */
        public func setAmountsAndCurrency(amount: Double!, taxAmount: Double?, currency: String) {
        ...
        }
         
        // MARK: getters and setters
        
        public func getAmount() -> Double! {
            return priceDetails.amount
        }
        
        public func getTaxAmount() -> Double! {
            return priceDetails.taxAmount
        }
        
        public func getCurrency() -> String! {
            return priceDetails.currency
        }
    }

### BSCcSdkResult (in BSCcPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the flow for a new Credit Card.

    public class BSCcSdkResult : BSBaseSdkResult {
        
        public var creditCard: BSCreditCard = BSCreditCard()
        public var billingDetails : BSBillingAddressDetails! = BSBillingAddressDetails()
        public var shippingDetails : BSShippingAddressDetails?
        
        public override init(sdkRequest: BSSdkRequest) {
            ...
        }
    ...
    }

### BSExistingCcSdkResult (in BSCcPayment.swift)
This class inherits from `BSCcSdkResult`, and it holds the data collected in the flow, when a returning shopper chosoes an existing credit card. The data it holds is the same as the parent class.

	public class BSExistingCcPaymentRequest : BSCcPaymentRequest, NSCopying {
    		
		...
	}
    
### BSCreditCard (in BSCcPayment.swift)
This class contains the user's non-sensitive CC details for the purchase, including CC type, last four digits of CC number, and issuing country. 

	@objc public class BSCreditCard : NSObject, NSCopying {
		
		// these fields are output - result of submitting the CC details to BlueSnap
		public var ccType : String?
		public var last4Digits : String?
		public var ccIssuingCountry : String?
    		public var expirationMonth: String?
    		public var expirationYear: String?
		...
	}

### BSApplePaySdkResult (in BSApplePayPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the ApplePay flow (which is currently nothing).

    public class BSApplePaySdkResult: BSBaseSdkResult {
        
        public override init(sdkRequest: sdkRequest) {
            ...
        }
    }

### BSPayPalSdkResult (in BSPayPalPayment.swift)
This class inherits from `BSBaseSdkResult`, and it holds the data collected in the PayPal flow, which is only the invoice ID.

    public class BSPayPalSdkResult: BSBaseSdkResult {
        
        public var payPalInvoiceId : String?
        
        override public init(sdkRequest: sdkRequest) {
        ...
        }
    }

## Main functionality - BlueSnapSDK class
The class BlueSnapSDK holds main the functions that you'll utilize. In this section, we'll go through each function contained in this class. 

### initBluesnap
This is the first function you need to call before using any other. Signature:
	open class func initBluesnap(
        	bsToken : BSToken!,
        	generateTokenFunc: @escaping (_ completion: @escaping (BSToken?, BSErrors?) -> Void) -> Void,
        	initKount: Bool,
        	fraudSessionId: String?,
        	applePayMerchantIdentifier: String?,
		merchantStoreCurrency : String?,
        	completion: @escaping (BSErrors?)->Void) {


| Parameter | Description |
| ------------- | ------------- |
| `bsToken`  | the `BSToken` you created.  |
| `generateTokenFunc` | This function sets the callback function that creates a new token when the current one is expired. For more information, see [Handling token expiration](#handling-token-expiration).  |
| `initKount` | True if you want to initialize the Kount device data collection for fraud (recommended: True). |
| `fraudSessionId` | a unique ID (up to 32 characters) for the shopper session - optional (if empty, a new one is generated). |
| `applePayMerchantIdentifier` | optional identifier for ApplePay |
| `merchantStoreCurrency` | base currency code for currency rate calculations |
| completion | callback; will be called when the init process is done. Only then can you proceed to call other functions in the SDK |

> **Note**: Tokens expire after 60 minutes or after using the token to process a payment, whichever comes first. Therefore, you'll need to generate a new one for each purchase.<br> This will be handled automatically for you when you supply the callback function in parameter generateTokenFunc. See [Handling token expiration](#handling-token-expiration)<br>
> **Initializing fraud prevention**: by passing `initKount: true` when calling initBluesnap, you initialize the fraud prevention capabilities of the SDK, which collects data about the user's device for fraud profiling. You may pass the fraud-session-id if you have one; if you pass nil (empty), we generate a unique ID for you. See the [Developer Docs](https://developers.bluesnap.com/docs/fraud-prevention#section-device-data-checks) for more info.<br>
> **Configuring Apple Pay (optional)**: Set your [Apple Pay Merchant ID](#apple-pay-optional) by passing the parameter applePayMerchantIdentifier when calling initBluesnap<br>
> **Note**: The initBluesnap function is asynchronous and may take a few seconds; its `completion` parameter is a callback function you supply, which will be called when the init is done. Make sure you do not start the checkout flow before this happens.<br>


### showCheckoutScreen
This is the main function for the Standard Checkout Flow (you'll call it after calling `initBluesnap` has completed). Once you call `showCheckoutScreen`, the SDK starts the checkout flow of choosing the payment method and collecting the user's details.

Signature:

    open class func showCheckoutScreen(
        inNavigationController: UINavigationController!,
        animated: Bool,
        sdkRequest : BSSdkRequest!)

Parameters:

| Parameter | Description |
| ------------- | ------------- |
| `inNavigationController`  | Your `ViewController`'s `navigationController` (to be able to navigate back).  |
| `animated` | Boolean that indicates if page transitions are animated. If `true`, wipe transition is used. If `false`, no animation is used - pages replace one another at once. |
| `sdkRequest` | Object that holds price information, required checkout fields, and initial user data. |


### submitCcDetails
This function is relevant if you're collecting the user's card data using your own input fields. 
When called, `submitCcDetails` submits the user's card data to BlueSnap, where it will be associated with your token. 
> **Note**: Do not send raw credit card data to your server. Use this function from the client-side to submit sensitive data directly to BlueSnap.  

Signature:

    open class func submitCcDetails(ccNumber: String, expDate: String, cvv: String, purchaseDetails: BSCcSdkResult?, completion : @escaping (BSCcDetails, BSErrors?)->Void)
    
Parameter: 

| Parameter      | Description   |
| ------------- | ------------- |
| `ccNumber` | CC number |
| `expDate` | CC expiration date in the format MM/YYYY |
| `cvv` | CC security code (CVV) |
| `purchaseDetails` | optional shopper details you want to tokenize (billing/shipping address) |
| `completion` | Callback function that is invoked with non-sensitive credit card details (if submission was a success), or error details (if submission errored). |

*Your `completion` callback should do the following: 
1. Detect if the user's card data was successfully submitted to BlueSnap (if `BSErrors` is `nil`). 
2. If submission was successful, you'll update your server with the transaction details. 
3. From your server, you'll [Send the payment for processing](#sending-the-payment-for-processing) using your token. 
4. After receiving BlueSnap's response, you'll update the client and display an appropriate message to the user. 

### createSandboxTestToken
Returns a token for BlueSnap Sandbox environment; useful for tests.
In your real app, the token should be generated on the server side and passed to the app, so that the app will not expose your API credentials.
The completion function will be called once we get a result from the server; it will receive either a token or an error.

Signature:

    open class func createSandboxTestToken(completion: @escaping (BSToken?, BSErrors?) -> Void)
    
### createSandboxTestTokenWithShopperId
Same as `createSandboxTestToken`, only here you may supply a returning shopper ID, to enable returning shopper flow.
Signature:

    open class func createSandboxTestTokenWithShopperId(shopperId: Int?, completion: @escaping (BSToken?, BSErrors?) -> Void) 

## Handling token expiration
To handle token expiration, supply the `BlueSnapSDK` class with a function for it to call when the token expires (as part of the initBluesnap function call).

Your callback function should have the following signature. In the demo app, this function is called `generateAndSetBsToken`. 

    func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?)->Void)

Your function should do the following to resolve the token expiration. 
1. Call your server to generate a new BlueSnap token.
2. Initialize the token in the SDK by calling `BlueSnapSDK.setBsToken`.
3. Call the completion function passed as a parameter. If this is not done, the original action will not be able to complete successfully with the new token.


## Helper Classes
These helper classes provide additional functionality you can take advantage of, such as string valiations and currency conversions. 
 
### String Utils and Validations
#### BSStringUtils (in BSStringUtils.swift)
This string provide string helper functions like removeWhitespaces, removeNoneDigits, etc. 

#### BSValidator (in BSValidator.swift)
This class provides validation functions like isValidEmail, getCcLengthByCardType, formatCCN, getCCTypeByRegex, etc. to help you format credit card information, and validate user details. 

### Handling currencies and rates
These currency structures and methods assist you in performing currency conversions during checkout. Use BSPriceDetails function `changeCurrencyAndConvertAmounts`.

#### Currency Data Structures
We have 2 data structures (see BSCurrencyModel.swift): 	`BSCurrency` holds a single currency and  `BSCurrencies` holds all the currencies.

```
public class BSCurrency {
	internal var name : String!
	internal var code : String!
	internal var rate: Double!
	...
	public func getName() -> String! {
		return self.name
	}
	public func getCode() -> String! {
		return self.code
	}
	public func getRate() -> Double! {
		return self.rate
	}
}

public class BSCurrencies {
	...
	public func getCurrencyByCode(code : String!) -> BSCurrency? {
		...
	}
	public func getCurrencyIndex(code : String) -> Int? {
		...
	}
	public func getCurrencyRateByCurrencyCode(code : String!) -> Double? {
		...
	}
}
```
#### Currency Functionality (in BlueSnapSDK class):
##### getCurrencyRates
This function returns a list of currencies and their rates. The values are fetched when calling BlueSnapSDK.initBlesnap().

Signature:

    open class func getCurrencyRates() -> BSCurrencies?
 
##### showCurrencyList
If you're using the Standard Checkout Flow, you can use this function to take advantage of our currency selection screen, allowing the user to select a new currency to pay in. To see an example of calling this function, see ViewController.swift of the demo app. 

Signature:

    open class func showCurrencyList(
        inNavigationController: UINavigationController!,
        animated: Bool,
        selectedCurrencyCode : String!,
        updateFunc: @escaping (BSCurrency?, BSCurrency?)->Void,
        errorFunc: @escaping()->Void
    )

Parameters:

| Parameter      | Description   |
| ------------- | ------------- |
| `inNavigationController` | Your ViewController's navigationController (to be able to navigate back). |
| `animated` | Determines how to navigate to new screen. If `true`, then transition is animated.  |
| `selectedCurrencyCode` | 3 character [currency code](https://developers.bluesnap.com/docs/currency-codes) |
| `updateFunc` | Callback function that will be invoked each time a new value is selected. <br> See the function `updateViewWithNewCurrency` from demo app to see how to update checkout details according to new currency. |
| `errorFunc` | Callback function that will be invoked if we fail to get the currencies. |
  
## Custom UI Controls
If you want to build your own UI, you may find our custom controls useful, in themselves or to inherit from them and adjust to your own functionality.

There are a lot of comments inside the code, explaining how to use them and what each function does.

All 3 are @IBDesignable UIViews, so you can easily check them out: simply drag a UIView into your Storyboard, change the class name to one of these below, and start playing with the inspectable properties.

### BSBaseTextInput
BSBaseTextInput is a UIView that holds a text field and optional image; you can customize almost every part of it. It is less useful in itself, seeing it?s a base class for the following 2 controls.

### BSInputLine
BSInputLine is a UIView that holds a label, text field and optional image; you can customize almost every part of it.

### BSCcInputLine
BSCcInputLine is a UIView that holds the credit card fields (Cc number, expiration date and CVV). Besides a cool look and feel, it also handles its own validations and submits the secured data to the BlueSnap, so that your application does not have to handle it.
