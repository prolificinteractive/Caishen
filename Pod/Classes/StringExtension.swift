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
    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
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
    func NSRangeFromRange(_ range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distance(to: from), from.distance(to: to))
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
        return self.substring(with: (self.characters.index(self.startIndex, offsetBy: fromInclusively)..<self.characters.index(self.startIndex, offsetBy: toExclusively)))
    }
    
    /**
     - returns: True if this string contains only digits.
     */
    func isNumeric() -> Bool {
        return characters.reduce(true, combine: { (result, value) in
            let string = String(value)
            guard let firstChar = string.utf16.first else {
                return result
            }
            return result && CharacterSet.decimalDigits.contains(UnicodeScalar(firstChar))}
        )
    }
}
