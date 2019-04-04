//
//  CardTextField+UITextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

extension CardTextField: CardInfoTextFieldDelegate {

    open func textField(_ textField: UITextField, didEnterValidInfo: String) {
        updateNumberColor()
        notifyDelegate()
        if expirationDateIsValid() {
            select(textField, prefillText: nil)
        }
    }
    
    open func textField(_ textField: UITextField, didEnterPartiallyValidInfo: String) {
        updateNumberColor()
        notifyDelegate()
    }
    
    open func textField(_ textField: UITextField, didEnterOverflowInfo overFlowDigits: String) {
        updateNumberColor()
        select(textField, prefillText: overFlowDigits)
    }

    private func select(_ textField: UITextField, prefillText: String?) {
        var nextTextField: UITextField?
        if textField == monthTextField {
            if hideExpiryTextFields {
                select(yearTextField, prefillText: prefillText)
            } else {
                nextTextField = yearTextField
            }
        } else if textField == yearTextField {
            if !hideCVCTextField {
                nextTextField = cvcTextField
            }
        }

        // Let the next text field become first responder if one of the contained text fields
        // already is first responder.
        if isChildFirstResponder {
            nextTextField?.becomeFirstResponder()
        }

        guard let prefillText = prefillText else {
            return
        }
        
        _ = nextTextField?.delegate?.textField?(nextTextField!, shouldChangeCharactersIn: NSMakeRange(0, (nextTextField?.text ?? "").count), replacementString: prefillText)
    }
    
    /**
     Updates the color of month and year text field based on whether or not the input into those text fields is valid or not.
     */
    private func updateNumberColor() {
        // if the expiration date is not valid, set the text color for the date to `invalidNumberColor`
        if !expirationDateIsValid() {
            let invalidInputColor = self.invalidInputColor ?? UIColor.red
            // if the expiration date text fields haven't been assigned invalid input color
            if monthTextField?.textColor != invalidInputColor && yearTextField?.textColor != invalidInputColor {
                monthTextField?.textColor = invalidInputColor
                yearTextField?.textColor = invalidInputColor

                addDateInvalidityObserver()
            }
        } else {
            monthTextField?.textColor = numberInputTextField?.textColor ?? UIColor.black
            yearTextField?.textColor = numberInputTextField?.textColor ?? UIColor.black
        }
    }

    /**
     Return the validity of the entered expiration date.

     If the expiration date is Expiry.invalid, it means that no real date is calculated yet,
     then return true because we do not know if the expiration date is valid or not.

     If the expiration date is fully entered (and then calculated automatically) and is a time in the future,
     then return true because we know that it is a valid expiration date

     Otherwise, return false

     - returns: The validity of the entered expiration date.
     */
    private func expirationDateIsValid() -> Bool {
        return card.expiryDate == Expiry.invalid || card.expiryDate.rawValue.timeIntervalSinceNow > 0
    }

    // MARK: Accessibility

    /**
     Add an observer to listen to the event of UIAccessibilityAnnouncementDidFinishNotification, and then post an accessibility
     notification to user that the entered expiration date has already expired.

     The reason why can't we just post an accessbility notification is that only the last accessibility notification would be read to users.
     As each time users input something there will be an accessibility notification from the system which will always replace what we have
     posted here. Thus we need to listen to the notification from the system first, wait until it is finished, and post ours afterwards.
     */
    private func addDateInvalidityObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notifyExpiryInvalidity),
                                               name: UIAccessibility.announcementDidFinishNotification,
                                               object: nil)
    }

    /**
     Notify user the entered expiration date has already expired when accessibility is turned on
     */
    @objc private func notifyExpiryInvalidity() {
        let localizedString = Localization.InvalidExpirationDate.localizedStringWithComment("The expiration date entered is not valid")
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: localizedString)
        NotificationCenter.default.removeObserver(self)
    }
}
