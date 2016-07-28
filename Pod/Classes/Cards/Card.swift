//
//  Card.swift
//  Caishen
//
//  Created by Sagar Natekar on 11/25/15.
//  Copyright © 2015 Prolific Interactive. All rights reserved.
//

import Foundation

/**
 A card represents a physical bank card with all its associated attributes.
*/
public struct Card {

    /// The card number that is shown on the user's card.
    public let bankCardNumber: Number
    
    /**
     The card verification code for the user's card.
     
     - important: You should never save and/or autofill a user's card verification code in your app, as this will void the CVC's purpose as a security feature.
     - important: CVCs that are validated by *Caishen* as `CardValidationResult.Valid` are not necessarily validated by the card issuer as well. In order to validate the CVC, you should opt for the integration of a [Payment Gateway](https://en.wikipedia.org/wiki/Payment_gateway) to validate the authenticity of the entered CVC.
     */
    public let cardVerificationCode: CVC
    
    /**
     The card's expiry date as indicated on the payment card.
     
     - note: *Caishen* will use the current date (as returned by `NSDate()`) to determine, whether a card has expired or not.
     */
    public let expiryDate: Expiry

    /**
     Factory method to create a card from string arguments as provided by a UITextField.
     
     - parameter number: The string value of the card number.
     - parameter cvc: The string value of the card verification code.
     - parameter expiry: the string value of the expiry date (example: 09/2018)
     
     - returns: A card with the provided parameters.
     */
    public static func create(number: String, cvc: String, expiry: String) throws -> Card {
        // Create card number, cvc and expiry with the arguments provided
        let cardNumber = Number(rawValue: number)
        let cardCVC = CVC(rawValue: cvc)
        let cardExpiry = Expiry(string: expiry) ?? Expiry.invalid

        return Card(number: cardNumber, cvc: cardCVC, expiry: cardExpiry)
    }

    /**
     Creates a `Card` with given card number, verification code and expiry date.
     
     - parameter bankCardNumber: The card number as indicated on the user's payment card.
     - parameter cardVerificationCode: The card verification code as indicated on the user's payment card.
     - parameter expiryDate: The expiration date as indicated on the user's payment card
    */
    public init(number: Number, cvc: CVC, expiry: Expiry) {
        self.bankCardNumber = number
        self.cardVerificationCode = cvc
        self.expiryDate = expiry
    }

}
