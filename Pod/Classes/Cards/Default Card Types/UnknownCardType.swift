//
//  UnknownCardType.swift
//  Pods
//
//  Created by Christopher Jones on 3/24/16.
//
//

internal struct UnknownCardType: CardType {

    let name = "Unknown"
    let CVCLength = 0
    let identifyingDigits: Set<Int> = []

    func validateNumber(cardNumber: Number) -> CardValidationResult {
        return CardValidationResult.UnknownType
            .union(lengthMatchesType(cardNumber.length))
            .union(numberIsNumeric(cardNumber))
            .union(numberIsValidLuhn(cardNumber))
    }

    func validateCVC(cvc: CVC) -> CardValidationResult {
        return .UnknownType
    }

    func validateExpiry(expiry: Expiry) -> CardValidationResult {
        return .UnknownType
    }

}
