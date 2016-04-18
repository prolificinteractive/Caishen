//
//  DinersClub.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public struct DinersClub: CardType {
    
    public let name = "Diners Club"
    
    public let CVCLength = 3

    public let numberGrouping = [4, 6, 4]
    
    public let identifyingDigits = Set(300...305).union( Set([36, 38, 39, 309, 2014, 2149]) )

    public init() {

    }

}