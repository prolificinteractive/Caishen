//
//  NumberInputTextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/24/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

/**
 The delegate protocol for a `NumberInputTextField`. The delegate gets notified about changes to the text, as well as an update, if a valid card number has been entered.
 */
@objc
public protocol NumberInputTextFieldDelegate {
    /**
     Called when the user entered a valid card number.
     
     - parameter numberInputTextField: The `NumberInputTextField` that was used to enter a card number.
     */
    func numberInputTextFieldDidComplete(_ numberInputTextField: NumberInputTextField)
    
    /**
     Called when the user changed the text in the `NumberInputTextField`.
     
     - parameter numberInputTextField: The `NumberInputTextField` whose text was changed.
     */
    func numberInputTextFieldDidChangeText(_ numberInputTextField: NumberInputTextField)
}
