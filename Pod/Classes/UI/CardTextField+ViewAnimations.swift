//
//  CardTextField+ViewAnimations.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public extension CardTextField {
    // MARK: - View animations
    
    /**
     Moves the card number input field to the left outside of the screen with an animation of the duration `viewAnimationDuration`, so that only the last group of the card number is visible. At the same time, the card detail (expiration month and year and CVC) slide in from the right.
     */
    public func moveCardNumberOutAnimated() {
        UIView.animate(withDuration: viewAnimationDuration, animations: { [weak self] _ in
            self?.moveCardNumberOut()
            })
    }
    
    /**
     Moves the full card number input field to inside the screen with an animation of the duration `viewAnimationDuration`. At the same time, the card detail (expiration month and year and CVC) slide outside the view.
     */
    public func moveCardNumberInAnimated() {
        UIView.animate(withDuration: viewAnimationDuration, animations: { [weak self] _ in
            self?.moveCardNumberIn()
            })
    }
    
    /**
     Moves the card number input field to the left outside of the screen, so that only the last group of the card number is visible. At the same time, the card detail (expiration month and year and CVC) are displayed to its right.
     */
    public func moveCardNumberOut() {
        // If the card number is invalid, do not allow to move to the card detail
        if cardType?.validate(number: card.bankCardNumber) != .Valid {
            return
        }
        // If neither expiry nor cvc are required, also do not allow to move to the detail
        if hideExpiryTextFields && hideCVCTextField {
            return
        }
        // We will set numberInputTextField as first responder in the next step. This will trigger `editingDidBegin`
        // which in turn will cause the number field to move to full display. This can cause animation issues.
        // In order to tackle these animation issues, check if the cardInfoView was previously fully displayed (and should therefor not be moved with an animation).
        var shouldMoveAnimated: Bool = true
        if let transform = cardInfoView?.transform, transform.isIdentity {
            shouldMoveAnimated = false
        }
        UIView.performWithoutAnimation { [weak self] _ in
            self?.numberInputTextField?.becomeFirstResponder()
        }
        // Get the rect for the last group of digits
        if let rect = numberInputTextField?.rectForLastGroup() {
            // If on RTL language: hide the entire number except for the last group.
            // Else: Move the number out of range, except for the last group.
            if isRightToLeftLanguage {
                let shapeLayer = CAShapeLayer()
                let path = CGPath(rect: rect, transform: nil)
                shapeLayer.path = path
                numberInputTextField.layer.mask = shapeLayer
                numberInputTextField?.transform = CGAffineTransform.identity
            } else {
                if shouldMoveAnimated {
                    numberInputTextField?.transform =
                        CGAffineTransform(translationX: -rect.origin.x, y: 0)
                } else {
                    UIView.performWithoutAnimation { [weak self] _ in
                        self?.numberInputTextField?.transform =
                            CGAffineTransform(translationX: -rect.origin.x, y: 0)
                    }
                }
            }
        } else {
            numberInputTextField?.alpha = 0
        }
        // Reset the first responder status as it was before.
        UIView.performWithoutAnimation { [weak self] _ in
            self?.numberInputTextField?.resignFirstResponder()
        }
        if shouldMoveAnimated {
            cardInfoView?.transform = CGAffineTransform.identity
        } else {
            UIView.performWithoutAnimation { [weak self] _ in
                self?.cardInfoView?.transform = CGAffineTransform.identity
            }
        }
		monthTextField.becomeFirstResponder()
    }
    
    /**
     Moves the full card number input field to inside the screen. At the same time, the card detail (expiration month and year and CVC) are moved outside the view.
     */
    public func moveCardNumberIn() {
        let infoTextFields: [UITextField?] = [monthTextField, yearTextField, cvcTextField]
        
        translateCardNumberIn()
        
        // If card info view is moved with an animation, wait for it to finish before
        // showing the full card number to avoid overlapping on RTL language.
        if cardInfoView?.layer.animationKeys() != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(viewAnimationDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] _ in
                self?.numberInputTextField?.layer.mask = nil
            })

            // Let the number text field become first responder only after the animation has completed (left to right script)
            // or half way through the view animation (right to left script)
            let firstResponderDelay = isRightToLeftLanguage ? viewAnimationDuration / 2.0 : viewAnimationDuration
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(firstResponderDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                            infoTextFields.forEach({$0?.resignFirstResponder()})
                            self.numberInputTextField.becomeFirstResponder()
            })
        } else {
            numberInputTextField?.layer.mask = nil
            infoTextFields.forEach({$0?.resignFirstResponder()})
            numberInputTextField.becomeFirstResponder()
        }
    }
    
    internal func translateCardNumberIn() {
        if isRightToLeftLanguage {
            UIView.performWithoutAnimation {
                self.numberInputTextField?.alpha = 1
                self.numberInputTextField?.transform = CGAffineTransform.identity
            }
        } else {
            numberInputTextField?.alpha = 1
            numberInputTextField?.transform = CGAffineTransform.identity
        }
        
        // Move card info view
        let offset = isRightToLeftLanguage ? -bounds.width : bounds.width
        cardInfoView?.transform = CGAffineTransform(translationX: offset, y: 0)
    }
}
