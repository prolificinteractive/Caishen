//
//  MonthInputTextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A protocol for the delegate of a `DetailInputTextField`.
 */
public protocol CardInfoTextFieldDelegate {
    
    /**
     Called whenever valid information was entered into `textField`.
     
     - parameter textField:         The text field whose information was updated and is valid.
     - parameter didEnterValidInfo: The valid information that was entered into `textField`.
     */
    func textField(_ textField: UITextField, didEnterValidInfo: String)
    
    /**
     Called whenever partially valid information was entered into `textField`.
     
     - parameter textField:                  The text field whose information was updated and is partially valid.
     - parameter didEnterPartiallyValidInfo: The partially valid information that was entered.
     */
    func textField(_ textField: UITextField, didEnterPartiallyValidInfo: String)
    
    /**
     Called whenever more text was entered into `textField` than necessary. This can be used to provide this overflow as text in the next text field in the responder chain.
     
     - parameter textField:      The text field which received more information than required.
     - parameter overFlowDigits: The overflow of text which does not fit into `textField` and might be entered into the next receiver in the responder chain.
     */
    func textField(_ textField: UITextField, didEnterOverflowInfo overFlowDigits: String)
}
