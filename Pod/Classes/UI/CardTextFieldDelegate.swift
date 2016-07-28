//
//  CardTextFieldDelegate.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/28/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import Foundation

public protocol CardTextFieldDelegate {
    
    /**
     Callback for a CardTextField, which is called whenever the entered Card information has changed.
     
     - parameter CardTextField: The CardTextField which received an update to its card information.
     - parameter information: The Card information which has been entered in the CardTextField or nil, if one or more of the CardTextField's text fields are empty or incomplete.
     - parameter validationResult: The result for the card validation of `information` or nil, if one or more of the CardTextField's text fields are empty or incomplete.
     */
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult)
    
    /**
     Callback for a CardTextField, which is called to update the image for its accessory button.
     
     - parameter CardTextField: The card number text field requesting an image for its accessory button.
     - returns: An image for the CardTextField's accessory button.
     */
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage?
    
    /**
     Callback for a CardTextField, which is used to check whether an accessory button should be provided.
     You can provide an arbitrary function which will be assigned to the text field's accessory button or nil, if you do not need an accessory button.
     
     - parameter CardTextField: The text field requesting an action for its accessory button.
     - returns: Any action that is performed when the accessory button is tapped or nil, if no accessory button should be displayed in the text field.
     */
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())?
    
    /**
     Callback for a CardTextField, which is called to update the accessibility label of the accessory button
     
     - parameter cardTextField: The text field requesting a accessibility label for its accessory button.
     - returns: The accessibility label for its accessory button
     */
    func cardTextFieldShouldProvideAccessoryButtonAccessibilityLabel(_ cardTextField: CardTextField) -> String?
}

public extension CardTextFieldDelegate {
    public func cardTextFieldShouldProvideAccessoryButtonAccessibilityLabel(_ cardTextField: CardTextField) -> String? {
        return Localization.AccessoryButtonAccessibilityLabel.localizedStringWithComment("Accessibility label for accessory button")
    }
}
