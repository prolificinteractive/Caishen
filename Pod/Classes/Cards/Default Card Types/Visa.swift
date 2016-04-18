//
//  Visa.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public struct Visa: CardType {
    
    public let name = "Visa"
    
    public let CVCLength = 3
    
    public let identifyingDigits = Set([4])

    public init() {
        
    }

}
