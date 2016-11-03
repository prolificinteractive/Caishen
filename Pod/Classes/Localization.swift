//
//  Localization.swift
//  Pods
//
//  Created by Shiyuan Jiang on 4/7/16.
//
//

import Foundation

/**
 Enum to provide constants for localized strings in caishen, as well as convenience methods to localize the respective strings.
 */
internal enum Localization: String {
    case StringsFileName = "Localizable"
    case AccessoryButtonAccessibilityLabel = "ACCESSORY_BUTTON_ACCESSIBILITY_LABEL"
    case NumberInputTextFieldAccessibilityLabel = "NUMBER_INPUT_TEXTFIELD_ACCESSIBILITY_LABEL"
    case MonthInputTextFieldAccessibilityLabel = "MONTH_INPUT_TEXTFIELD_ACCESSIBILITY_LABEL"
    case YearInputTextFieldAccessibilityLabel = "YEAR_INPUT_TEXTFIELD_ACCESSIBILITY_LABEL"
    case CVCInputTextFieldAccessibilityLabel = "CVC_TEXTFIELD_ACCESSIBILITY_LABEL"
    case InvalidCardNumber = "INVALID_CARD_NUMBER"
    case InvalidExpirationDate = "INVALID_EXPIRATION_DATE"
    case CardType = "CARD_TYPE"
    
    /**
     - parameter textField: The text field whose accessibility label should be retreived.
     - parameter comment:   An optional comment for the localization.
     
     - returns: The accessibility label for the provided text field.
     */
    static func accessibilityLabel(for textField: UITextField, with comment: String? = nil) -> String? {
        switch textField {
        case is NumberInputTextField:
            return Localization.NumberInputTextFieldAccessibilityLabel.localizedStringWithComment(comment)
        case is CVCInputTextField:
            return Localization.CVCInputTextFieldAccessibilityLabel.localizedStringWithComment(comment)
        case is MonthInputTextField:
            return Localization.MonthInputTextFieldAccessibilityLabel.localizedStringWithComment(comment)
        case is YearInputTextField:
            return Localization.YearInputTextFieldAccessibilityLabel.localizedStringWithComment(comment)
        default:
            return nil
        }
    }
    
    /**
     - parameter comment: An optional comment for the localization.
     
     - returns: The localized string for the raw value of `self` in the Caishen bundle.
     */
    func localizedStringWithComment(_ comment: String?) -> String {
        return NSLocalizedString(self.rawValue,
                                 tableName: Localization.StringsFileName.rawValue,
                                 bundle: Bundle(for: CardTextField.self),
                                 comment: comment ?? "")
    }
}

