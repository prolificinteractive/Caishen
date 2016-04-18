//
//  Discover.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

public struct Discover: CardType {

    public let name = "Discover"
    
    public let CVCLength = 3
    
    public let identifyingDigits = Set(644...649).union( Set([6011]) ).union(Set([65]))

    public init() {
        
    }
    
}
