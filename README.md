![Caishen](caishen.jpg)

[![Travis build status](https://img.shields.io/travis/prolificinteractive/Caishen.svg?style=flat-square)](https://travis-ci.org/prolificinteractive/Caishen)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Caishen.svg?style=flat-square)](https://img.shields.io/cocoapods/v/Caishen.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Caishen.svg?style=flat-square)](http://cocoadocs.org/docsets/Caishen)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/Caishen.svg?style=flat-square)](http://cocoadocs.org/docsets/Caishen)

## Description

Caishen provides an easy-to-use text field to ask users for payment card information and to validate the input. It serves a similar purpose as [PaymentKit](https://github.com/stripe/PaymentKit), but is developed as a standalone framework entirely written in Swift. Caishen also allows an easy integration with other third-party frameworks, such as [CardIO](https://www.card.io).

<center> ![Caishen example](caishen_example.gif) </center>

## Requirements

* iOS 8.0+
* Xcode 7.3+

## Installation

### CocoaPods

Caishen is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Caishen"
```

### Carthage

Caishen is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```
github "prolificinteractive/Caishen"
```

## Usage

### Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

---

### Inside your project

To add a text field for entering card information to a view, either ...

- ... add a UITextField to your view in InterfaceBuilder and change its class to *CardTextField* (when using InterfaceBuilder)
- ... or initiate a *CardTextField* with one of its initializers (when instantiating from code): 
	- init?(coder: aDecoder: NSCoder)
	- init(frame: CGRect)

To get updates about entered card information on your view controller, confirm to the protocol *CardTextFieldDelegate* set the view controller as *cardTextFieldDelegate* for the text field:

```swift
class MyViewController: UIViewController, CardTextFieldDelegate {
	
	@IBOutlet weak var cardTextField: CardTextField?
	
	override func viewDidLoad() {
		cardTextField?.cardTextFieldDelegate = self
		
		...
	}
	
	func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        // A valid card has been entered, if validationResult == CardValidationResult.Valid
    }
    
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        // You can return an image which will be used on cardTextField's accessory button
		 // If you return nil but provide an accessory button action, the unicode character "⇤" is displayed instead of an image to indicate an action that affects the text field.
    }
    
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
		 // You can return a callback function which will be called if a user tapped on cardTextField's accessory button
		 // If you return nil, cardTextField won't display an accessory button at all.
    }
	
	...
```

---

### Customizing the text field appearance

CardTextField is mostly customizable like every other UITextField. Setting any of the following standard attributes for a CardTextField (either from code or from interface builder) will affect the text field just like it affects any other UITextField:

| Property           | Type                 | Description                                                                                                            |
|:-------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------------------|
| placeholder        | String?              | The card number place holder. This will be automatically formatted at runtime to look like an actual Visa card number. |
| textColor          | UIColor?             | The color of text entered into the CardTextField.                                                                |
| backgroundColor    | UIColor?             | The background color of the text field.                                                                                |
| font               | UIFont?              | The font of the entered text.                                                                                          |
| secureTextEntry    | Bool                 | When set to true, any input in the text field will be secure (i.e. masked with "•" characters).                        |
| keyboardAppearance | UIKeyboardAppearance | The keyboard appearance when editing text in the text field.                                                           |
| borderStyle        | UITextBorderStyle    | The border style for the text field.                                                                                   |

Additionally, CardTextField offers attributes tailored to its purpose (accessible from interface builder as well):

| Property           | Type                 | Description                                                                                                            |
|:-------------------|:---------------------|:-----------------------------------------------------------------------------------------------------------------------|
| cardNumberSeparator| String?              | A string that is used to separate the groups in a card number. Defaults to " - ".                                      |
| viewAnimationDuration | Double?           | The duration for a view animation in seconds when switching between the card number text field and details (month, view and cvc text fields). |
| invalidInputColor  | UIColor?             | The text color for invalid input. When entering an invalid card number, the text will flash in this color and in case of an expired card, the expiry will be displayed in this color as well. |

---

### CardIO

CardIO might be among the most powerful tools to let users enter their payment card information. It uses the camera and lets the user scan his or her credit card. However, you might still want to provide users with a visually appealing text field to enter their payment card information, since users might want to restrict access to their camera or simply want to enter this information manually.

In order to provide users with a link to CardIO, you can use a CardTextField's `prefillCardInformation` method alongside the previously mentioned accessory button:

```swift
// 1. Let your view controller confirm to the CardTextFieldDelegate and CardIOPaymentViewControllerDelegate protocol:
class ViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {
	...
	
	// MARK: - CardTextFieldDelegate
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        if validationResult == .Valid {
        	// A valid payment card has been manually entered or CardIO was used to scan one.
        }
    }
    
    // 2. Optionally provide an image for the CardIO button
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "cardIOIcon")
    }
    
    // 3. Set the action for the accessoryButton to open CardIO:
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] _ in
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self)
            self?.presentViewController(cardIOViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - CardIOPaymentViewControllerDelegate
    
    // 4. When receiving payment card information from CardIO, prefill the text field with that information:
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        cardTextField.prefillCardInformation(
        	cardInfo.cardNumber, 
        	month: Int(cardInfo.expiryMonth), 
        	year: Int(cardInfo.expiryYear), 
        	cvc: cardInfo.cvv)
        	
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
```

---

### Specifying your own card types

CardTextField further contains a *CardTypeRegister* which maintains a set of different card types that are accepted by this text field.
You can create your own card types and add or remove them to or from card number text fields:

```swift
struct MyCardType: CardType {
    
	// MARK: - Required
	
	// The name of your specified card type:
    public let name = "My Card Type"
    
    // Note: The image that will be displayed in the card number text field's image view when this card type has been detected will load from an asset with the name `cardType.name`.
	
	// If the Issuer Identification Number (the first six digits of the entered card number) of a card number 
	// starts with anything from 1000 to 1111, the card is identified as being of type "MyCardType":
    public let identifyingDigits = Set(1000...1111)
	
	// MARK: - Optional
	
	// Not specifying this will assert a three digits long cvc:
	public let CVCLength = 4
	
	// Not specifying this will load a default cvc image:
    public let cvcImage: UIImage? = UIImage(named: "MyCardTypeCVCImage")
	
	// Not specifying this will result in a 16 digit number, separated into 4 groups of 4 digits.
	// The grouping of your card number type. The following results in a card number format
	// like "100 - 0000 - 00000 - 000000":
	public let numberGrouping = [3, 4, 5, 6]
	
    public init() {
		
    }
}

...

class MyViewController: UIViewController, CardTextFieldDelegate {
	
	@IBOutlet weak var cardTextField: CardTextField?
	...
	
	func viewDidLoad() {
		cardTextField?.cardTypeRegister.registerCardType(MyCardType())
	}
	
	...
}
```

---

### Using the different components of the text field separately

Instead of entering the card number, expiry and CVC in a single text field, it is possible to use single text fields to enter this information separately.

```swift
class ViewController: UIViewController, NumberInputTextFieldDelegate, CardInfoTextFieldDelegate {
    
    @IBOutlet weak var cardNumberTextField: NumberInputTextField!
    @IBOutlet weak var monthInputTextField: MonthInputTextField!
    @IBOutlet weak var yearInputTextField: YearInputTextField!
    @IBOutlet weak var cvcInputTextField: CVCInputTextField!
        
    // A card that is not nil when valid information has been entered in the text fields:
    var card: Card? {
        let number = cardNumberTextField.cardNumber
        let cvc = CVC(rawValue: cvcInputTextField.text ?? "")
        let expiry = Expiry(month: monthInputTextField.text ?? "", year: yearInputTextField.text ?? "")
                        ?? Expiry.invalid
        
        let cardType = cardNumberTextField.cardTypeRegister.cardTypeFor(number: cardNumberTextField.cardNumber)
        if cardType.validate(cvc: cvc).union(cardType.validate(expiry: expiry)).union(cardType.validate(number: number)) == .Valid {
            return Card(number: number, cvc: cvc, expiry: expiry)
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.numberInputTextFieldDelegate = self
        monthInputTextField.cardInfoTextFieldDelegate = self
        yearInputTextField.cardInfoTextFieldDelegate = self
        cvcInputTextField.cardInfoTextFieldDelegate = self
        
        // Set the `deleteBackwardCallbacks` - closures which are called whenever a user hits
        // backspace on an empty text field.
        monthInputTextField.deleteBackwardCallback = { _ in self.cardNumberTextField.becomeFirstResponder() }
        yearInputTextField.deleteBackwardCallback = { _ in self.monthInputTextField.becomeFirstResponder() }
        cvcInputTextField.deleteBackwardCallback = { _ in self.yearInputTextField.becomeFirstResponder() }
    }
    
    func numberInputTextFieldDidComplete(_ numberInputTextField: NumberInputTextField) {
        cvcInputTextField.cardType = numberInputTextField.cardTypeRegister.cardTypeFor(number: numberInputTextField.cardNumber)
        print("Card number: \(numberInputTextField.cardNumber)")
        print(card)
        monthInputTextField.becomeFirstResponder()
    }
    
    func numberInputTextFieldDidChangeText(_ numberInputTextField: NumberInputTextField) {
        
    }
    
    func textField(_ textField: UITextField, didEnterValidInfo: String) {
        switch textField {
        case is MonthInputTextField:
            print("Month: \(didEnterValidInfo)")
            yearInputTextField.becomeFirstResponder()
        case is YearInputTextField:
            print("Year: \(didEnterValidInfo)")
            cvcInputTextField.becomeFirstResponder()
        case is CVCInputTextField:
            print("CVC: \(didEnterValidInfo)")
        default:
            break
        }
        print(card)
    }
    
    func textField(_ textField: UITextField, didEnterPartiallyValidInfo: String) {
        // The user entered information that is not valid but might become valid on further input.
        // Example: Entering "1" for the CVC is partially valid, while entering "a" is not.
    }
    
    func textField(_ textField: UITextField, didEnterOverflowInfo overFlowDigits: String) {
        // This function is used in a CardTextField to carry digits to the next text field.
        // Example: A user entered "02/20" as expiry and now tries to append "5" to the month.
        //          On a card text field, the year will be replaced with "5" - the overflow digit.
    }
    
    // ...
}
```

## Contributing to Caishen

To report a bug or enhancement request, feel free to file an issue under the respective heading.

If you wish to contribute to the project, fork this repo and submit a pull request. Code contributions should follow the standards specified in the [Prolific Swift Style Guide](https://github.com/prolificinteractive/swift-style-guide).

## License

Caishen is Copyright (c) 2016 Prolific Interactive. It may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## Maintainers

![prolific](https://s3.amazonaws.com/prolificsitestaging/logos/Prolific_Logo_Full_Color.png)

Caishen is maintained and funded by Prolific Interactive. The names and logos are trademarks of Prolific Interactive.
