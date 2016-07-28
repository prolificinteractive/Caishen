//
//  CardImageStore.swift
//  Pods
//
//  Created by Christopher Jones on 3/24/16.
//
//

import UIKit

/// Defines a store that will return an image for a specific card type.
public protocol CardTypeImageStore {

    /**
     Provides an image for a specific card type. These images will be shown in a `CardTextField` once the card type has been detected from the entered number.
     
     - parameter cardType: The card type whose image should be retreived.
     
     - returns: The image for the specified card type or nil, if no image was provided for this card type.
     */
    func imageFor(cardType: CardType) -> UIImage?
    
    /**
     Provides an image for the CVC of a specific card type. The position of a CVC on a card may vary based on the card issuer, so that different card types may provide different images to indicate the location of the CVC on the card. This image will be shown in a `CardTextField`'s image view once the user starts entering the CVC.
     
     - parameter cardType: The card type whose CVC image should be retreived.
     
     - returns: The image for the CVC of the specified card type or nil, if no image was provided for this card type.
     */
    func cvcImageFor(cardType: CardType) -> UIImage?

}

extension Bundle: CardTypeImageStore {
    
    public func imageFor(cardType: CardType) -> UIImage? {
        return UIImage(named: cardType.name, in: self, compatibleWith: nil)
    }

    public func cvcImageFor(cardType: CardType) -> UIImage? {
        let cvcImageName: String
        if cardType.isEqual(to: AmericanExpress()) {
            cvcImageName = "AmexCVC"
        } else {
            cvcImageName = "CVC"
        }
        
        return UIImage(named: cvcImageName, in: self, compatibleWith: nil)
    }

}
