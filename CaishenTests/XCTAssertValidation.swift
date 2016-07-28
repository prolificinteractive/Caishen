//
//  XCTAssertValidation.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/3/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit
import XCTest
import Caishen

func XCTAssertValid(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult == CardValidationResult.Valid, "Expected the validation result to be true, but was \(validationResult.description)")
}

func XCTAssertInvalidCVC(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.InvalidCVC), "Expected an invalid CVC, but got \(validationResult.description)")
}

func XCTAssertIncompleteCVC(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.CVCIncomplete), "Expected an incomplete CVC, but got \(validationResult.description)")
}

func XCTAssertInvalidNumberForType(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.NumberTooLong), "Expected an invalid number for the credit card type, but got \(validationResult.description)")
}

func XCTAssertIncompleteNumber(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.NumberIncomplete), "Expected an incomplete number for the credit card type, but got \(validationResult.description)")
}

func XCTAssertCardNotExpired(_ validationResult: CardValidationResult) {
    XCTAssertFalse(validationResult.isSuperset(of: CardValidationResult.CardExpired), "Expected a not expired card, but got: \(validationResult.description)")
}

func XCTAssertCardExpired(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.CardExpired), "Expected an expired card, but got: \(validationResult.description)")
}

func XCTAssertLuhnTestFailed(_ validationResult: CardValidationResult) {
    XCTAssertTrue(validationResult.isSuperset(of: CardValidationResult.LuhnTestFailed), "Expected a Luhn test failure on validation, but got \(validationResult.description)")
}
