//
//  DetailInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A text field subclass that validates any input for card detail before changing the text attribute.
 You can subclass `DetailInputTextField` and override `isInputValid` to specify the validation routine.
 The default implementation accepts any input.
 */
public class DetailInputTextField: StylizedTextField {
    
    public var cardInfoTextFieldDelegate: CardInfoTextFieldDelegate?
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            textField.text = UITextField.emptyTextFieldCharacter
        }
    }
    
    public override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: (textField.text ?? "")).replacingCharacters(in: range, with: string).replacingOccurrences(of: UITextField.emptyTextFieldCharacter, with: "")
        
        let deletingLastCharacter = !(textField.text ?? "").isEmpty && textField.text != UITextField.emptyTextFieldCharacter && newText.isEmpty
        if deletingLastCharacter {
            textField.text = UITextField.emptyTextFieldCharacter
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: newText)
            return false
        }
        
        let autoCompletedNewText = autocomplete(newText)
        
        let (currentTextFieldText, overflowTextFieldText) = split(autoCompletedNewText)
        
        if isInputValid(currentTextFieldText, partiallyValid: true) {
            textField.text = currentTextFieldText
            if isInputValid(currentTextFieldText, partiallyValid: false) {
                cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: currentTextFieldText)
            } else {
                cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: currentTextFieldText)
            }
        }
        
        if !overflowTextFieldText.characters.isEmpty {
            cardInfoTextFieldDelegate?.textField(self, didEnterOverflowInfo: overflowTextFieldText)
        }
        
        return false
    }
    
    public func prefill(_ text: String) {
        if isInputValid(text, partiallyValid: false) {
            cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: text)
        } else if isInputValid(text, partiallyValid: true) {
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: text)
        }
    }
    
    private func split(_ text: String) -> (currentText: String, overflowText: String) {
        let hasOverflow = text.characters.count > expectedInputLength
        let index = (hasOverflow) ?
            text.characters.index(text.startIndex, offsetBy: expectedInputLength) :
            text.characters.index(text.startIndex, offsetBy: text.characters.count)
        return (text.substring(to: index), text.substring(from: index))
    }
}

extension DetailInputTextField: AutoCompletingTextField {

    func autocomplete(_ text: String) -> String {
        return text
    }
}

extension DetailInputTextField: TextFieldValidation {
    /**
     Default number of expected digits for MonthInputTextField and YearInputTextField
     */
    var expectedInputLength: Int {
        return 2
    }

    func isInputValid(_ input: String, partiallyValid: Bool) -> Bool {
        return true
    }
}
