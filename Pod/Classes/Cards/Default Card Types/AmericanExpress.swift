//
//  Amex.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public struct AmericanExpress: CardType {
    
   public let name = "Amex"
    
    public let CVCLength = 4

    public let numberGrouping = [4, 6, 5]

    public let identifyingDigits = Set([34, 37])

    public init() {

    }

}
