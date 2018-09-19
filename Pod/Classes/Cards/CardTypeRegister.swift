//
//  CardTypeRegister.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/// A `CardTypeRegister` is used to maintain the range of accepted card types. You can provide different card type registers for different CardTextField's and customize the range of accepted card types individually.
open class CardTypeRegister {
    
    /**
     The default card type register, shared among all CardTextFields.
     */
    public static let sharedCardTypeRegister = CardTypeRegister(registeredCardTypes: CardTypeRegister.defaultCardTypes)
    
    /// An array of all registered card types. You can edit this array with `registerCardType`, `unregisterCardType` or `setRegisteredCardTypes`.
    open private(set) var registeredCardTypes: [CardType]
    
    /**
     Creates a new `CardTypeRegister` that accepts no card types.
     */
    public init() {
        registeredCardTypes = []
    }

    /**
     Creates a new `CardTypeRegister` with the given sequence of card types.
     
     - parameter registeredCardTypes: Any sequence of `CardType` that should be accepted by `self`.
     */
    public convenience init<T: Sequence>(registeredCardTypes: T) where T.Iterator.Element == CardType {
        self.init()
        setRegisteredCardTypes(registeredCardTypes)
    }

    /// An array with the default card types provided by Caishen.
    public static let defaultCardTypes: [CardType] = [
            AmericanExpress(),
            ChinaUnionPay(),
            DinersClub(),
            Discover(),
            JCB(),
            MasterCard(),
            Visa()
        ]
    
    /**
     Adds the provided card type to the array of registered card types.
     
     - parameter cardType: The card type that should be contained in this card type register.
     */
    open func register(cardType: CardType) {
        if registeredCardTypes.contains(where: { $0.isEqual(to: cardType) }) {
            return
        }

        registeredCardTypes.append(cardType)
    }
    
    /**
     Removes the provided card type from the array of registered card types.
     
     - parameter cardType: The card type that should be removed from this card type register.
     */
    open func unregister(cardType: CardType) {
        registeredCardTypes = registeredCardTypes.filter { !$0.isEqual(to: cardType) }
    }
    
    /**
     Replaces the range of registered card types.
     
     - parameter cardTypes: The new range of card types contained in this card type register.
     */
    open func setRegisteredCardTypes<T: Sequence>(_ cardTypes: T) where T.Iterator.Element == CardType {
        registeredCardTypes = [CardType]()
        registeredCardTypes.append(contentsOf: cardTypes)
    }
    
    /**
     Retreives a card type for a specific card number by parsing the Issuer Identification Numbers in the registered card types and matching them with the provided card number.
     
     - important: When creating custom card types, you should make sure, that there are no conflicts in the Issuer Identification Numbers you provide. For example, using [309] to detect a Diners Club card and using [3096] to detect a JCB card will not cause issues as IINs are parsed with the highest numbers first, i.e. the numbers that provide the most context possible, which will return a JCB card in this case. However, no two card types should provide the exact same number (like [309] to detect both a Diners Club card and a JCB card)!
     
     - parameter number: The card number whose CardType should be determined
     
     - returns: An instance of UnknownCardType, if no card type matches the Issuer Identification Number of the provided card number or any other card type that matches the card number.
     */
    open func cardType(for number: Number) -> CardType {
        for i in (0...min(number.length, 6)).reversed() {
            if let substring = number.rawValue[0,i], let substringAsNumber = Int(substring) {
                if let firstMatchingCardType = registeredCardTypes.filter({
                    $0.identifyingDigits.contains(substringAsNumber)
                }).first {
                    return firstMatchingCardType
                }
            }
        }
        
        return UnknownCardType()
    }

}
