//
//  UnknownCardType.swift
//  Pods
//
//  Created by Christopher Jones on 3/24/16.
//
//

/**
 *  The undefined card type
 */
public struct UnknownCardType: CardType {

    public let name = "Unknown"
    public let CVCLength = 0
    public let identifyingDigits: Set<Int> = []

    public func validateNumber(_ cardNumber: Number) -> CardValidationResult {
        return CardValidationResult.UnknownType
            .union(lengthMatchesType(cardNumber.length))
            .union(numberIsNumeric(cardNumber))
            .union(numberIsValidLuhn(cardNumber))
    }

    public func validateCVC(_ cvc: CVC) -> CardValidationResult {
        return .UnknownType
    }

    public func validateExpiry(_ expiry: Expiry) -> CardValidationResult {
        return .UnknownType
    }

}
