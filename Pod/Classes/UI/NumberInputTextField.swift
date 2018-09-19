//
//  NumberInputTextField.Swift
//  Caishen
//
//  Created by Daniel Vancura on 2/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 This kind of text field only allows entering card numbers and provides means to customize the appearance of entered card numbers by changing the card number group separator.
 */
@IBDesignable
open class NumberInputTextField: StylizedTextField {

    // MARK: - Variables
    
    /**
     The card number that has been entered into this text field. 
     
     - note: This card number may be incomplete and invalid while the user is entering a card number. Be sure to validate it against a proper card type before assuming it is valid.
     */
    open var cardNumber: Number {
        let textFieldTextUnformatted = cardNumberFormatter.unformat(cardNumber: text ?? "")
        return Number(rawValue: textFieldTextUnformatted)
    }
    
    /**
     */
    @IBOutlet open weak var numberInputTextFieldDelegate: NumberInputTextFieldDelegate?
    
    /**
     The string that is used to separate different groups in a card number.
     */
    @IBInspectable open var cardNumberSeparator: String = "-"
    
    open override var accessibilityValue: String? {
        get {
            // In order to read digits of the card number one by one, return them as "4 1 1 ..." separated by single spaces and commas inbetween groups for pauses
            var singleDigits: [Character] = []
            var lastCharWasReplacedWithComma = false
            text?.forEach({
                if !$0.isNumeric() {
                    if !lastCharWasReplacedWithComma {
                        singleDigits.append(",")
                        lastCharWasReplacedWithComma = true
                    } else {
                        lastCharWasReplacedWithComma = false
                    }
                }
                singleDigits.append($0)
                singleDigits.append(" ")
            })
            return String(singleDigits)
                + ". "
                + Localization.CardType.localizedStringWithComment("Description for detected card type.")
                + ": "
                + cardTypeRegister.cardType(for: cardNumber).name
        }
        
        set {  }
    }
    
    /// Variable to store the text color of this text field. The actual property `textColor` (as inherited from UITextField) will change based on whether or not the entered card number was invalid and may be `invalidInputColor` in this case. In order to always set and retreive the actual text color for this text field, it is saved and retreived to and from this private property.
    private var _textColor: UIColor?
    override open var textColor: UIColor? {
        get {
            return _textColor
        }
        set {
            /// Just store the text color in `_textColor`. It will be set as soon as input has been entered by setting super.textColor = _textColor.
            /// This is to avoid overriding `textColor` with `invalidInputColor` when invalid input has been entered.
            _textColor = newValue
        }
    }

    /**
     The card type register that holds information about which card types are accepted and which ones are not.
     */
    open var cardTypeRegister: CardTypeRegister = CardTypeRegister.sharedCardTypeRegister
    
    /**
     A card number formatter used to format the input
     */
    private var cardNumberFormatter: CardNumberFormatter {
        return CardNumberFormatter(cardTypeRegister: cardTypeRegister, separator: cardNumberSeparator)
    }
    
    // MARK: - UITextFieldDelegate
    
    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Current text in text field, formatted and unformatted:
        let textFieldTextFormatted = NSString(string: textField.text ?? "")
        // Text in text field after applying changes, formatted and unformatted:
        let newTextFormatted = textFieldTextFormatted.replacingCharacters(in: range, with: string)
        let newTextUnformatted = cardNumberFormatter.unformat(cardNumber: newTextFormatted)
        
        // Set the text color to invalid - this will be changed to `validTextColor` later in this method if the input was valid
        super.textColor = invalidInputColor
        
        if !newTextUnformatted.isEmpty && !newTextUnformatted.isNumeric() {
            return false
        }

        let parsedCardNumber = Number(rawValue: newTextUnformatted)
        let oldValidation = cardTypeRegister.cardType(for: cardNumber).validate(number: cardNumber)
        let newValidation =
            cardTypeRegister.cardType(for: parsedCardNumber).validate(number: parsedCardNumber)

        if !newValidation.contains(.NumberTooLong) {
            cardNumberFormatter.format(range: range, inTextField: textField, andReplaceWith: string)
            numberInputTextFieldDelegate?.numberInputTextFieldDidChangeText(self)
        } else if oldValidation == .Valid {
            // If the card number is already valid, should call numberInputTextFieldDidComplete on delegate
            // then set the text color back to normal and return
            numberInputTextFieldDelegate?.numberInputTextFieldDidComplete(self)
            super.textColor = _textColor
            return false
        } else {
            notifyNumberInvalidity()
        }

        let newLengthComplete =
            parsedCardNumber.length == cardTypeRegister.cardType(for: parsedCardNumber).maxLength

        if newLengthComplete && newValidation != .Valid {
            addNumberInvalidityObserver()
        } else if newValidation == .Valid {
            numberInputTextFieldDelegate?.numberInputTextFieldDidComplete(self)
        }
        
        /// If the number is incomplete or valid, assume it's valid and show it in `textColor`
        /// Also, if the number is of unknown type and the full IIN has not been entered yet, assume it's valid.
        if (newValidation.contains(.UnknownType) && newTextUnformatted.count <= 6) || newValidation.contains(.NumberIncomplete) || newValidation == .Valid {
            super.textColor = _textColor
        }

        return false
    }
    
    /**
     Prefills the card number. The entered card number will only be prefilled if it is at least partially valid and will be displayed formatted.
     
     - parameter text: The card number which should be displayed in `self`.
     */
    open func prefill(_ text: String) {
        let unformattedCardNumber = String(text.filter({$0.isNumeric()}))
        let cardNumber = Number(rawValue: unformattedCardNumber)
        let type = cardTypeRegister.cardType(for: cardNumber)
        let numberPartiallyValid = type.checkCardNumberPartiallyValid(cardNumber) == .Valid
        
        if numberPartiallyValid {
            // Set text and apply text color changes if the prefilled card type is unknown
            self.text = text

            _ = textField(self,
                          shouldChangeCharactersIn: NSRange(location: 0, length: text.count),
                          replacementString: cardNumber.rawValue)
        }
    }
    
    // MARK: - Helper functions
    
    /**
     Computes the rect that contains the specified text range within the text field.
     
     - precondition: This function will only work, when `textField` is the first responder. If `textField` is not first responder, `textField.beginningOfDocument` will not be initialized and this function will return nil.
     
     - parameter range: The range of the text in the text field whose bounds should be detected.
     - parameter textField: The text field containing the text.
     
     - returns: A rect indicating the location and bounds of the text within the text field, or nil, if an invalid range has been entered.
     */
    private func rectFor(range: NSRange, in textField: UITextField) -> CGRect? {
        guard let rangeStart = textField.position(from: textField.beginningOfDocument, offset: range.location) else {
            return nil
        }
        guard let rangeEnd = textField.position(from: rangeStart, offset: range.length) else {
            return nil
        }
        guard let textRange = textField.textRange(from: rangeStart, to: rangeEnd) else {
            return nil
        }
        
        return textField.firstRect(for: textRange)
    }
    
    /**
     - precondition: This function will only work, when `self` is the first responder. If `self` is not first responder, `self.beginningOfDocument` will not be initialized and this function will return nil.
     
     - returns: The CGRect in `self` that contains the last group of the card number.
     */
    open func rectForLastGroup() -> CGRect? {
        guard let lastGroupLength = text?.components(separatedBy: cardNumberFormatter.separator).last?.count else {
            return nil
        }
        guard let textLength = text?.count else {
            return nil
        }
        
        return rectFor(range: NSMakeRange(textLength - lastGroupLength, lastGroupLength), in: self)
    }
    
    // MARK: Accessibility
    
    /**
     Add an observer to listen to the event of UIAccessibilityAnnouncementDidFinishNotification, and then post an accessibility
     notification to user that the entered card number is not valid.
     
     The reason why can't we just post an accessbility notification is that only the last accessibility notification would be read to users.
     As each time users input something there will be an accessibility notification from the system which will always replace what we have
     posted here. Thus we need to listen to the notification from the system first, wait until it is finished, and post ours afterwards.
     */
    private func addNumberInvalidityObserver() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(notifyNumberInvalidity),
                                                         name: UIAccessibility.announcementDidFinishNotification,
                                                         object: nil)
    }
    
    /**
     Notify user the entered card number is invalid when accessibility is turned on
     */
    @objc private func notifyNumberInvalidity() {
        let localizedString = Localization.InvalidCardNumber.localizedStringWithComment("The expiration date entered is not valid")
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: localizedString)
        NotificationCenter.default.removeObserver(self)
    }
}
