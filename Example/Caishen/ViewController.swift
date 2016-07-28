//
//  ViewController.swift
//  Caishen
//
//  Created by Daniel Vancura on 02/03/2016.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit
import Caishen

class ViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var buyButton: UIButton?
    @IBOutlet weak var cardNumberTextField: CardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.cardTextFieldDelegate = self
    }
    
    @IBAction func buy(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CardNumberTextField delegate methods
    
    // This method of `CardNumberTextFieldDelegate` will set the saveButton enabled or disabled, based on whether valid card information has been entered.
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
            buyButton?.isEnabled = validationResult == .Valid
    }
    
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "camera")
    }
    
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] _ in
            guard let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self) else {
                return
            }
            self?.present(cardIOViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Card.io delegate methods
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        cardNumberTextField.prefill(number: cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil)
    }

}

