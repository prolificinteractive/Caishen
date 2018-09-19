//
//  CardNumberFormatter.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A `CardNumberFormatter` provides the formatting of card numbers based on their card type.
 */
public final class CardNumberFormatter {

    /// The separator which is used to separate different groups of a card number.
    public let separator: String
    
    /// The card type register which is used to access accepted card types. Formatting will only take place for card numbers whose card type can be found in this property.
    private var cardTypeRegister: CardTypeRegister
    
    /**
     Creates a `CardNumberFormatter` with the provided separator for formatting.
     
     - parameter separator: The separator that is used for grouping the card number.
     */
    public init(cardTypeRegister: CardTypeRegister, separator: String = " ") {
        self.separator = separator
        self.cardTypeRegister = cardTypeRegister
    }
    
    /**
     This function removes the format of a card number string that has been formatted with the same instance of a `CardNumberFormatter`.
     
     - parameter cardNumberString: The card number string representation that has previously been formatted with `self`.
     
     - returns: The unformatted card number string representation.
     */
    public func unformat(cardNumber: String) -> String {
        return cardNumber.replacingOccurrences(of: self.separator, with: "")
    }

    /**
     Formats the given card number string based on the detected card type.
     
     - parameter cardNumberString: The card number's unformatted string representation.
     
     - returns: Formatted card number string.
     */
    public func format(cardNumber: String) -> String {
        let regex: NSRegularExpression

        let cardType = cardTypeRegister.cardType(for: Number(rawValue: cardNumber))
        do {
            let groups = cardType.numberGrouping
            var pattern = ""
            var first = true
            for group in groups {
                pattern += "(\\d{1,\(group)})"
                if !first {
                    pattern += "?"
                }
                first = false
            }
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        } catch {
            fatalError("Error when creating regular expression: \(error)")
        }
        
        return NSArray(array: split(string: cardNumber, with: regex)).componentsJoined(by: self.separator)
    }
    
    /**
     Computes the index of the cursor position after unformatting the textField's content.
     
     - parameter textField: The textField containing a formatted string.
     
     - returns: The index of the cursor position or nil, if no selected text was found.
     */
    public func cursorPositionAfterUnformatting(_ text: String, in textField: UITextField) -> Int? {
        guard let selectedRange = textField.selectedTextRange else {
            return nil
        }

        let addedCharacters = text.count - (textField.text ?? "").count
        let position = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start) + addedCharacters
        let components = text.components(separatedBy: self.separator)
        
        // Find the component that contains the cursor
        var componentContainingCursor = 0
        var stringParsingIndex = 0
        for i in 0..<components.count {
            stringParsingIndex += components[i].count
            if position <= stringParsingIndex {
                componentContainingCursor = i
                break
            }
            stringParsingIndex += self.separator.count
        }
        
        return position - componentContainingCursor * self.separator.count
    }
    
    /**
     Computes the index of a character in an unformatted string that is equivalent to `index` in `formattedString`.
     
     **Example:** Index **7** in *"0123 - 4"* (pointing at *"4"*) is equal to index **4** in the unformatted string *"01234"*.
     
     - parameter index:           The index in the formatted string whose equivalent in the unformatted string should be determined.
     - parameter formattedString: The formatted string.
     
     - returns: The index in an unformatted string that is equivalent to `index` in `formattedString`.
     */
    private func indexInUnformattedString(_ indexInFormattedString: Int, formattedString: String) -> Int {
        var componentWithIndex = 0
        var charCount = 0
        for component in formattedString.components(separatedBy: self.separator) {
            charCount += component.count
            if charCount >= indexInFormattedString {
                break
            } else {
                componentWithIndex += 1
                charCount += self.separator.count
            }
        }
        
        return indexInFormattedString - componentWithIndex * self.separator.count
    }
    
    /**
     Computes the index of a character in a formatted string that is equivalent to `index` in `unformattedString`.
     
     **Example:** Index **4** in *"01234"* (pointing at *"4"*) is equal to index **7** in the formatted string *"0123 - 4"*.
     
     - parameter index:           The index in the unformatted string whose equivalent in the formatted string should be determined.
     - parameter unformattedString: The unformatted string.
     
     - returns: The index in a formatted string that is equivalent to `index` in `unformattedString`.
     */
    private func indexInFormattedString(_ index: Int, unformattedString: String) -> Int {
        var charIdx = 0
        let formattedString = self.format(cardNumber: unformattedString)
        
        let groups = formattedString.components(separatedBy: self.separator)
        
        for i in 0..<groups.count {
            let groupChars = groups[i].count
            
            charIdx += groupChars
            if charIdx >= index {
                return min(index + i * self.separator.count, formattedString.count)
            }
        }
        
        return 0
    }
    
    /**
     Replaces the specified range of text in the provided text field with the given string and makes sure that the result is formatted.
     
     - parameter range:     The range of text which should be replaced.
     - parameter textField: The text field whose text should be changed.
     - parameter string:    The new string. This might be unformatted or badly formatted and will be formatted properly before being inserted into `textField`.
     */
    public func format(range: NSRange, inTextField textField: UITextField, andReplaceWith string: String) {
        let newValueUnformatted = unformat(cardNumber: NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string))
        let oldValueUnformatted = unformat(cardNumber: textField.text ?? "")

        let newValue = format(cardNumber: newValueUnformatted)
        let oldValue = textField.text ?? ""
        
        var position: UITextPosition?
        if let start = textField.selectedTextRange?.start {
            let oldCursorPosition = textField.offset(from: textField.beginningOfDocument, to: start)
            let oldCursorPositionUnformatted = indexInUnformattedString(oldCursorPosition, formattedString: oldValue)
            let newCursorPositionUnformatted = oldCursorPositionUnformatted + (newValueUnformatted.count - oldValueUnformatted.count)
            let newCursorPositionFormatted = indexInFormattedString(newCursorPositionUnformatted, unformattedString: newValueUnformatted)
            
            position = textField.position(from: textField.beginningOfDocument, offset: newCursorPositionFormatted)
        }
        
        textField.text = newValue
        if let position = position {
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }
    
    /**
     Splits a string with a given regular expression and returns all matches in an array of separate strings.
     
     - parameter string: The string that is to be split.
     - parameter regex: The regular expression that is used to search for matches in `string`.
     
     - returns: An array of all matches found in string for `regex`.
     */
    private func split(string: String, with regex: NSRegularExpression) -> [String] {
        let matches = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, string.count))
        var result = [String]()
        
        matches.forEach {
            for i in 1..<$0.numberOfRanges {
                let range = $0.range(at: i)
                
                if range.length > 0 {
                    result.append(NSString(string: string).substring(with: range))
                }
            }
        }
        
        return result
    }
}
