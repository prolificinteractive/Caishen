//
//  Franchise.swift
//  Caishen
//
//  Created by Andres Silva Gomez on 8/8/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import Foundation

public enum Franchise: String {
    
    case Visa = "Visa"
    case Amex = "Amex"
    case CUP = "China UnionPay"
    case Diners = "Diners Club"
    case Discover = "Discover"
    case JCB = "JCB"
    case MasterCard = "MasterCard"
    case Unknown = "Unknown"
    
    public init(rawValue: String) {
        switch rawValue {
        case "Visa": self = .Visa
        case "Amex": self = .Amex
        case "China UnionPay": self = .CUP
        case "Diners Club": self = .Diners
        case "Discover": self = .Discover
        case "JCB": self = .JCB
        case "MasterCard": self = .MasterCard
        default: self = .Unknown
        }
    }
    
}