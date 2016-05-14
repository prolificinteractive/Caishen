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
        UIView.animateWithDuration(viewAnimationDuration, animations: { [weak self] _ in
            self?.moveCardNumberOut()
            })
    }
    
    /**
     Moves the full card number input field to inside the screen with an animation of the duration `viewAnimationDuration`. At the same time, the card detail (expiration month and year and CVC) slide outside the view.
     */
    public func moveCardNumberInAnimated() {
        UIView.animateWithDuration(viewAnimationDuration, animations: { [weak self] _ in
            self?.moveCardNumberIn()
            })
    }
    
    /**
     Moves the card number input field to the left outside of the screen, so that only the last group of the card number is visible. At the same time, the card detail (expiration month and year and CVC) are displayed to its right.
     */
    public func moveCardNumberOut() {
        // If the card number is invalid, do not allow to move to the card detail
        if cardType?.validateNumber(card.bankCardNumber) != .Valid {
            return
        }
        // We will set numberInputTextField as first responder in the next step. This will trigger `editingDidBegin`
        // which in turn will cause the number field to move to full display. This can cause animation issues.
        // In order to tackle these animation issues, check if the cardInfoView was previously fully displayed (and should therefor not be moved with an animation).
        var shouldMoveAnimated: Bool = true
        if let transform = cardInfoView?.transform where CGAffineTransformIsIdentity(transform) {
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
                let path = CGPathCreateWithRect(rect, nil)
                shapeLayer.path = path
                numberInputTextField.layer.mask = shapeLayer
                numberInputTextField?.transform = CGAffineTransformIdentity
            } else {
                if shouldMoveAnimated {
                    numberInputTextField?.transform =
                        CGAffineTransformMakeTranslation(-rect.origin.x, 0)
                } else {
                    UIView.performWithoutAnimation { [weak self] _ in
                        self?.numberInputTextField?.transform =
                            CGAffineTransformMakeTranslation(-rect.origin.x, 0)
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
            cardInfoView?.transform = CGAffineTransformIdentity
        } else {
            UIView.performWithoutAnimation { [weak self] _ in
                self?.cardInfoView?.transform = CGAffineTransformIdentity
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
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(viewAnimationDuration * Double(NSEC_PER_SEC))),
                           dispatch_get_main_queue()) { [weak self] _ in
                self?.numberInputTextField?.layer.mask = nil
            }
            
            // Let the number text field become first responder only after the animation has completed (left to right script)
            // or half way through the view animation (right to left script)
            let firstResponderDelay = isRightToLeftLanguage ? viewAnimationDuration / 2.0 : viewAnimationDuration
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(firstResponderDelay * Double(NSEC_PER_SEC))),
                           dispatch_get_main_queue()) {
                            infoTextFields.forEach({$0?.resignFirstResponder()})
                            self.numberInputTextField.becomeFirstResponder()
            }
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
                self.numberInputTextField?.transform = CGAffineTransformIdentity
            }
        } else {
            numberInputTextField?.alpha = 1
            numberInputTextField?.transform = CGAffineTransformIdentity
        }
        
        // Move card info view
        let offset = isRightToLeftLanguage ? -superview!.bounds.width : superview!.bounds.width
        cardInfoView?.transform = CGAffineTransformMakeTranslation(offset, 0)
    }
}