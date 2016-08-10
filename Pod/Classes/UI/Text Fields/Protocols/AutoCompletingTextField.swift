//
//  AutoCompletingTextField.swift
//  Pods
//
//  Created by Daniel Vancura on 3/29/16.
//
//

import Foundation

/**
 A protocol to provide auto completion behavior of text.
 */
protocol AutoCompletingTextField {
    
    /**
     Returns the auto-completed text for the new text
     E.g. if user input a "4" in a monthInputTextField, it should show a string of "04" instead.
     This makes the input process easier for users
     
     - note: This can be overridden by subclasses to provide auto completion behavior.
     
     - returns: Auto-completed string.
     */
    func autocomplete(_ text: String) -> String
}
