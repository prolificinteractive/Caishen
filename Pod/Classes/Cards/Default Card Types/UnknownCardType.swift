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

    public func validateNumber(cardNumber: Number) -> CardValidationResult {
        return CardValidationResult.UnknownType
            .union(lengthMatchesType(cardNumber.length))
            .union(numberIsNumeric(cardNumber))
            .union(numberIsValidLuhn(cardNumber))
    }

    public func validateCVC(cvc: CVC) -> CardValidationResult {
        return .UnknownType
    }

    public func validateExpiry(expiry: Expiry) -> CardValidationResult {
        return .UnknownType
    }

    public init() {
        
    }

}
