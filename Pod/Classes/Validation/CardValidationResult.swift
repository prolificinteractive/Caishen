//
//  CardValidationResult.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/2/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A CardValidationResult is an `OptionSetType`. This means, it can be 
 combined with other CardValidationResult. This allows to have multiple 
 validation results in a single object, like having a card number that 
 does not match the card type and an expired card at the same time.
 
 **Example:**
 ````
 let result = CardValidationResult.NumberDoesNotMatchType.union(CardValidationResult.CardExpired)
*/
public struct CardValidationResult: OptionSet {
    public let rawValue: UInt64
    
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    // MARK: - Default declarations
    public static let Valid                   = CardValidationResult(rawValue: 0)
    
    /** 
     Card number does not match the specified type or is too long.
     */
    public static let NumberDoesNotMatchType  = CardValidationResult(rawValue: 1 << 0)
    
    /**
     Card number does match the specified type but is too short.
     - note: This result will be returned for an incompleted card number.
     */
    public static let NumberIncomplete        = CardValidationResult(rawValue: 1 << 1)
    
    /**
     Invalid Card Verificaiton Code.
     */
    public static let InvalidCVC              = CardValidationResult(rawValue: 1 << 2)
    
    /**
     The Card Verification Code is too short.
     */
    public static let CVCIncomplete           = CardValidationResult(rawValue: 1 << 3)
    
    /**
     The card has already expired.
     */
    public static let CardExpired             = CardValidationResult(rawValue: 1 << 4)
    
    /**
     Card number does not match the specified type or is too long.
     */
    public static let NumberIsNotNumeric      = CardValidationResult(rawValue: 1 << 5)
    
    /**
     The Luhn test failed for the credit card number.
     - note: This result might be returned for an incompleted card number.
     */
    public static let LuhnTestFailed          = CardValidationResult(rawValue: 1 << 6)

    /// Indicates that the type of card could not be inferred.
    public static let UnknownType             = CardValidationResult(rawValue: 1 << 7)

    /// Indicates that the expiry is invalid
    public static let InvalidExpiry           = CardValidationResult(rawValue: 1 << 8)

    /// Indicates that the card number is too long.
    public static let NumberTooLong           = CardValidationResult(rawValue: 1 << 9)

}

extension CardValidationResult: CustomStringConvertible {

    /**
     - returns: An array of strings which contain textual descriptions of the validation result in `self`.
     */
    public func toString() -> [String] {
        var strings: [String] = []
        if self == .Valid {
            strings.append("Valid")
        }

        if isSuperset(of: .NumberDoesNotMatchType) {
            strings.append("Number does not match type")
        }

        if isSuperset(of: .CVCIncomplete) {
            strings.append("CVC is too short")
        }

        if isSuperset(of: .InvalidCVC) {
            strings.append("CVC is invalid")
        }

        if isSuperset(of: .CardExpired) {
            strings.append("Card has expired")
        }

        if isSuperset(of: .InvalidExpiry) {
            strings.append("Expiration date is not valid")
        }

        if isSuperset(of: .NumberIsNotNumeric) {
            strings.append("Card number is not numeric")
        }

        if isSuperset(of: .LuhnTestFailed) {
            strings.append("Luhn test failed for card number")
        }

        if isSuperset(of: .NumberIncomplete) {
            strings.append("Card number seems to be incomplete")
        }

        if isSuperset(of: .UnknownType) {
            strings.append("Card type could not be inferred")
        }

        if isSuperset(of: .NumberTooLong) {
            strings.append("Card number is too long")
        }

        return strings
    }

    public var description: String {
        return toString().reduce("") { (current, next) in
            return "\(current)\n\(next)"
        }
    }

}
