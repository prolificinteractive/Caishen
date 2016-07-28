//
//  CardType.swift
//  Caishen
//
//  Created by Sagar Natekar on 11/23/15.
//  Copyright © 2015 Prolific Interactive. All rights reserved.
//

import Foundation

/**
 A `CardType` is a predefined type for different bank cards. Examples include "Visa" or "American Express", each of which have slightly different formats for their payment card information. Card types are determined by the Issuer Identification Number (IIN) of a card number, which is equal to the first six digits of a card number.
 */
public protocol CardType {
    
    /**
     - returns: The card type name (e.g.: Visa, MasterCard, ...)
     */
    var name: String { get }
    
    /**
     - returns: The number of digits expected in the Card Validation Code.
     */
    var CVCLength: Int { get }
    
    /**
     The card number grouping is used to format the card number when typing in the card number text field.
     For Visa Card types for example, this grouping would be [4,4,4,4], resulting in a card number format like
     0000-0000-0000-0000.
     - returns: The grouping of digits in the card number.
     */
    var numberGrouping: [Int] { get }
    
    /**
     Card types are typically identified by their first n digits. In compliance to ISO/IEC 7812, the first digit is the *Major industry identifier*, which is equal to:
        - 1, 2 for airlines
        - 3 for Travel & Entertainment (non-banks like American Express, DinersClub, ...)
        - 4, 5 for banking and financial institutions
        - 6 for merchandising and banking/financial (Discover Card, Laser, China UnionPay, ...)
        - 7 for petroleum and other future industry assignments
        - 8 for healthcare, telecommunications and other future industry assignments
        - 9 for assignment by national standards bodies
     The first 6 digits also are the *Issuer Identification Number*, indicating the issuer of the card. 
     
     In order to identify the card issuer, this function returns a Set of integers which indicate the card issuer. In case of Discover for example, this is the set of [(644...649),(622126...622925),(6011)], which contains different Issuer Identification Number ranges which are reserved for Discover.
     
     - important: When creating custom card types, you should make sure, that there are no conflicts in the Issuer Identification Numbers you provide. For example, using [309] to detect a Diners Club card and using [3096] to detect a JCB card will not cause issues as IINs are parsed with the highest numbers first, i.e. the numbers that provide the most context possible, which will return a JCB card in this case. However, no two card types should provide the exact same number (like [309] to detect both a Diners Club card and a JCB card)!
     
     - returns: A set of numbers which, when being found in the first digits of the card number, indicate the card issuer.
     */
    var identifyingDigits: Set<Int> { get }

    /**
     Validates the card verification code.
     
     - important: This validation does not mean that the CVC will be accepted by the card issuer! In order to validate the card with the card issuer, you should opt for the integration of a [Payment Gateway](https://en.wikipedia.org/wiki/Payment_gateway) to confirm the authenticity of the entered CVC.
     
     - parameter cvc: The card verification code as indicated on the payment card.
     
     - returns: The validation result for the CVC, taking the current card type into account, as different card issuers can provide CVCs in different formats.
     */
    func validate(cvc: CVC) -> CardValidationResult

    
    /** 
     A boolean flag that indicates whether CVC validation is required for this card type or not.
     Setting this value to false will hide the CVC text field from the `CardTextField` and remove the required validation routine.
     */
    var requiresCVC: Bool { get }

    /**
     A boolean flag that indicates whether expiry validation is required for this card type or not.
     Setting this value to false will hide the month and year text field from the `CardTextField` and remove the required
     validation routine.
     */
    var requiresExpiry: Bool { get }

    /**
     Validates the card number.
     
     - important: This validation incorporates the validation of the card number length, a test for the [Luhn algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm) and a check, whether or not the card number only contains numeric digits. Within *Caishen*, no validation with a card issuer takes place and you should opt for the integration of a [Payment Gateway](https://en.wikipedia.org/wiki/Payment_gateway) to confirm the authenticity of the entered card number.
     
     - parameter number: The card number.
     
     - returns: The result of the card number validation.
     */
    func validate(number: Number) -> CardValidationResult

    /**
     Validates the card's expiry date, checking whether the card has expired or not.
     
     - parameter expiry: The card's expiry.
     
     - returns: The result of the card expiration date validation.
     */
    func validate(expiry: Expiry) -> CardValidationResult

    /**
     Returns whether or not `self` is equal to another `CardType`.
     
     - parameter cardType: Another card type to check equality with.
     
     - returns: Whether or not `self` is equal to the provided `cardType`.
     */
    func isEqual(to cardType: CardType) -> Bool
}

extension CardType {
    
    public func isEqual(to cardType: CardType) -> Bool {
        return cardType.name == self.name
    }
    
    public var requiresExpiry: Bool {
        return true
    }
    
    public var requiresCVC: Bool {
        return true
    }

    public var numberGrouping: [Int] {
        return [4, 4, 4, 4]
    }

    public var maxLength: Int {
        return numberGrouping.reduce(0) { $0 + $1 }
    }

    public func validate(cvc: CVC) -> CardValidationResult {

        guard requiresCVC else {
            return .Valid
        }

        guard let _ = cvc.toInt() else {
            return .InvalidCVC
        }

        if cvc.length > CVCLength {
            return .InvalidCVC
        } else if cvc.length < CVCLength {
            return .CVCIncomplete
        }

        return .Valid
    }

    public func validate(number: Number) -> CardValidationResult {
        return lengthMatchesType(number.length)
            .union(numberIsNumeric(number))
            .union(numberIsValidLuhn(number))
    }

    public func validate(expiry: Expiry) -> CardValidationResult {
        guard requiresExpiry else {
            return .Valid
        }
        
        guard expiry != Expiry.invalid else {
            return .InvalidExpiry
        }

        let currentDate = Date()
        let expiryDate = expiry.rawValue

        if expiryDate.timeIntervalSince1970 < currentDate.timeIntervalSince1970 {
            return CardValidationResult.CardExpired
        } else {
            return CardValidationResult.Valid
        }
    }

    /**
     You can implicitly set this property by providing `numberGrouping` when implementing this protocol.
     
     - returns: The number of digits that are contained in a card number of card type `self`.
     */
    public func expectedCardNumberLength() -> Int {
        return numberGrouping.reduce(0, combine: {$0 + $1})
    }

    /**
     - parameter number: A card number which should be checked for compliance to the [Luhn algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm).
     
     - returns: True if the card number complies to the Luhn algorithm. False if it does not.
     */
    public func numberIsValidLuhn(_ number: Number) -> CardValidationResult {
        var odd = true
        var sum = 0
        let digits = NSMutableArray(capacity: number.length)
        for i in 0..<number.length {
            // If the number is not long enough, fail the Luhn test
            guard let digit = number.description[i,i+1] else {
                return CardValidationResult.LuhnTestFailed
            }
            digits.add(NSString(string: digit))
        }
        for obj in digits.reverseObjectEnumerator() {
            let digitString = obj as! NSString
            var digit = digitString.integerValue
            odd = !odd
            if odd {
                digit = digit * 2
            }
            if digit > 9 {3
                digit = digit - 9
            }
            sum += digit
        }

        if sum % 10 == 0 {
            return CardValidationResult.Valid
        } else {
            return CardValidationResult.LuhnTestFailed
        }
    }

    /**
     Checks whether or not a card number is partially valid.
     
     - parameter cardNumber: The card number which should be checked for partial validity.
     
     - returns: Valid, if 
        - the card validation succeeded 
        - or the card validation failed because of the Luhn test or insufficient card number length (both of which are irrelevant for incomplete card numbers).
     */
    public func checkCardNumberPartiallyValid(_ cardNumber: Number) -> CardValidationResult {
        let validationResult = validate(number: cardNumber)
        let completeNumberButLuhnTestFailed = !validationResult.isSuperset(of: CardValidationResult.NumberIncomplete) && validationResult.isSuperset(of: CardValidationResult.LuhnTestFailed)

        if completeNumberButLuhnTestFailed {
            return validationResult
        } else {
            return
                self.validate(number: cardNumber)
                    .subtracting(.NumberIncomplete)
                    .subtracting(.LuhnTestFailed)
        }
    }

    /**
     Helper method for `lengthMatchesType` to check the actual length of a card number against the expected length.
     
     - parameter actualLength: The length of a card number that is to be validated.
     - parameter expectedLength: The expected length for the card number's card type.
     
     - returns: CardValidationResult.Valid if the lengths match, CardValidationResult.NumberDoesNotMatchType otherwise.
     */
    private func testLength(_ actualLength: Int, assumingLength expectedLength: Int) -> CardValidationResult {
        if actualLength == expectedLength {
            return .Valid
        } else if actualLength < expectedLength {
            return .NumberIncomplete
        } else if actualLength > maxLength {
            return .NumberTooLong
        } else {
            return .NumberDoesNotMatchType
        }
    }

    /**
     Checks the length of a card number against `self`.
     
     - parameter length: The count of the card number's digits.
     
     - returns: `CardValidationResult.Valid` if the card number has the right amount of digits for `self`
        - `.NumberIncomplete`:          The card number is too short
        - `.NumberTooLong`:             The card number is too long
        - `.NumberDoesNotMatchType`:    The card number's Issuer Identification Number does not match `self`
     */
    public func lengthMatchesType(_ length: Int) -> CardValidationResult {
        return testLength(length, assumingLength: expectedCardNumberLength())
    }

    /**
     Checks whether or not the card number only contains numeric digits.
     
     - parameter number: The card number.
     
     - returns: `CardValidationResult.Valid` if the card number contains only numeric characters.
        - `.NumberIsNotNumeric`:        Otherwise.
     */
    public func numberIsNumeric(_ number: Number) -> CardValidationResult {
        for c in number.description.characters {
            if !["0","1","2","3","4","5","6","7","8","9"].contains(c) {
                return CardValidationResult.NumberIsNotNumeric
            }
        }

        return CardValidationResult.Valid
    }

}
