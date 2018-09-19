//
//  StylizedTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/10/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/// A text field that provides additional UI customization.
@IBDesignable
open class StylizedTextField: UITextField, UITextFieldDelegate {
    
    /**
     Changes to this parameter draw the border of `self` in the given width.
     */
    @IBInspectable
    open var borderWidth: CGFloat = 0 {
        didSet {
            if borderWidth >= 0 {
                self.borderStyle = .none
                self.layer.borderWidth = CGFloat(borderWidth)
            } else {
                self.borderStyle = .roundedRect
                self.layer.borderWidth = 0
            }
        }
    }
    
    /**
     If `borderWidth` has been set, changes to this parameter round the corners of `self` in the given corner radius.
     */
    @IBInspectable
    open var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius >= 0 {
                self.layer.cornerRadius = cornerRadius
            }
        }
    }
    
    /**
     If `borderWidth` has been set, changes to this parameter change the color of the border of `self`.
     */
    @IBInspectable
    open var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
    /**
     A method which will be called, when the delete key has been pressed for an empty text field.
     */
    open var deleteBackwardCallback: ((UITextField) -> Void)?
    
    open override var text: String? {
        didSet {
            if (text ?? "").isEmpty {
                deleteBackwardCallback?(self)
            } else if text == UITextField.emptyTextFieldCharacter {
                drawPlaceholder(in: textInputView.bounds)
            }
            setNeedsDisplay()
        }
    }
    
    /**
     The color in which text flashes, when the user is about to enter an invalid card number.
     */
    @IBInspectable open var invalidInputColor: UIColor = UIColor.red
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    // MARK: - Override functions

    open override var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: self)
        return super.becomeFirstResponder()
    }
    
    open override func draw(_ rect: CGRect) {
        if text == "" || text == UITextField.emptyTextFieldCharacter {
            super.drawPlaceholder(in: rect)
        } else {
            super.draw(rect)
        }
    }
    
    open override func drawPlaceholder(in rect: CGRect) {
        
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
