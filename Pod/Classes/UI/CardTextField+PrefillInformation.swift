//
//  CardTextField+PrefillInformation.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

extension CardTextField {
    
    /**
     Fills all form fields of this card text field with the information provided and moves to card detail, if the provided card number was valid.
     
     - parameter cardNumber: The card number which should be shown in the number input field.
     - parameter month:      The month that should be shown in the month input field.
     - parameter year:       The year that should be shown in the year input field.
     - parameter cvc:        The CVC that should be shown in the CVC input field.
     */
    open func prefill(_ number: String?, month: Int?, year: Int?, cvc: String?) {
        if let year = year {
            var trimmedYear = year
            if year > 100 {
                trimmedYear = year % 100
            }
            
            yearTextField?.prefill(String(format: "%02i", arguments: [trimmedYear]))
        }
        
        if let month = month {
            monthTextField?.prefill(String(format: "%02i", arguments: [month]))
        }
        
        if let cardNumber = number, let numberInputTextField = numberInputTextField {
            numberInputTextField.prefill(cardNumber)
            
            // With a new card number comes a new card type - pass this card type to `cvcTextField`
            cvcTextField?.cardType = cardType
        }
        
        if let cvc = cvc {
            cvcTextField?.prefill(cvc)
        }

        moveCardNumberOutAnimated(remainFirstResponder: isChildFirstResponder)
        
        notifyDelegate()
    }
}
