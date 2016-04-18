//
//  CardTypeRegister.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public class CardTypeRegister {
    
    public static let sharedCardTypeRegister = CardTypeRegister()
    
    public private(set) var registeredCardTypes: [CardType]
    
    init() {
        registeredCardTypes = [
            AmericanExpress(),
            DinersClub(),
            Discover(),
            JCB(),
            MasterCard(),
            Visa()
        ]
    }
    
    public func registerCardType(cardType: CardType) {
        if registeredCardTypes.contains({ $0.isEqualTo(cardType) }) {
            return
        }

        registeredCardTypes.append(cardType)
    }
    
    public func unregisterCardType(cardType: CardType) {
        registeredCardTypes = registeredCardTypes.filter { !$0.isEqualTo(cardType) }
    }
    
    public func setRegisteredCardTypes<T: SequenceType where T.Generator.Element == CardType>(cardTypes: T) {
        registeredCardTypes = [CardType]()
        registeredCardTypes.appendContentsOf(cardTypes)
    }
    
    public func cardTypeForNumber(cardNumber: Number) -> CardType {
        for i in (0...min(cardNumber.length, 6)).reverse() {
            if let substring = cardNumber.rawValue[0,i], let substringAsNumber = Int(substring) {
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