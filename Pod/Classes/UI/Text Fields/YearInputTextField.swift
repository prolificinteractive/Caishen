//
//  YearInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/// A text field which can be used to enter years and provides validation.
public class YearInputTextField: DetailInputTextField {
    
    /**
     Checks the validity of the entered year.
     
     - returns: True, if the year is valid.
     */
    internal override func isInputValid(_ year: String, partiallyValid: Bool) -> Bool {
        if partiallyValid && year.characters.count == 0 {
            return true
        }
        
        guard let yearInt = UInt(year) else {
            return false
        }
        
        return yearInt >= 0 &&
            yearInt < 100 &&
            (partiallyValid || year.characters.count == 2)
    }
}
