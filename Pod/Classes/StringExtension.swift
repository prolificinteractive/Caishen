//
//  StringExtension.swift
//  Caishen
//
//  Created by Sagar Natekar on 11/23/15.
//  Copyright © 2015 Prolific Interactive. All rights reserved.
//

import Foundation

extension String {

    //http://stackoverflow.com/a/30404532/1565974
    
    /**
     Converts an NSRange object for characters in `self` to a Range<String.Index> for use in methods expecting a Range.
     
     - parameter nsRange: The NSRange object that should be converted to Range.
     
     - returns: `nsRange` converted to Range<String.Index> or nil, if its start and/or end location are not within `self`.
     */
    func rangeFrom(_ nsRange: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex) else {
            return nil
        }
        guard let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex) else {
            return nil
        }
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }

    /**
     Converts a Range<String.Index> object in `self` to an NSRange object for use in methods expecting an NSRange.
     
     - parameter range: The Range object that should be converted to NSRange.
     
     - returns: An NSRange object that is equivalent to `range`.
     */
    func NSRangeFrom(_ range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    /**
     Convenience method to retreive a substring of `self`.
     
     - parameter fromInclusively: The index of the first character that should be included in the substring.
     - parameter toExclusively: The index of the last character that should no longer be included in the substring.
     
     - returns: Substring starting with the character at index `fromInclusiveley` and ending before the character at index `toExclusively`.
    */
    subscript(fromInclusively: Int, toExclusively: Int) -> String? {
        if characters.count < toExclusively || fromInclusively >= toExclusively {
            return nil
        }
/**
         let hasOverflow = text.characters.count > expectedInputLength
         let index = (hasOverflow) ?
         text.characters.index(text.startIndex, offsetBy: expectedInputLength) :
         text.characters.index(text.startIndex, offsetBy: text.characters.count)
         let first = String(text[..<index])
         let second = String(text.suffix(from: index))
         return (first, second)
 */
        let index = self.characters.index(self.startIndex, offsetBy: fromInclusively)..<self.characters.index(self.startIndex, offsetBy: toExclusively)
        return String(self[index])
    }
    
    /**
     - returns: True if this string contains only digits.
     */
    func isNumeric() -> Bool {
        return characters.reduce(true, { (result, value) in
            let string = String(value)
            guard let firstChar = string.utf16.first else {
                return result
            }
            return result && CharacterSet.decimalDigits.contains(UnicodeScalar(firstChar)!)}
        )
    }
}
