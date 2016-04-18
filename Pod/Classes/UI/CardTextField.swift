//
//  CardTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/12/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 This kind of text field serves as a container for subviews, which allow a user to enter card information.
 
 The typical structure of a `CardTextField`'s subviews is as follows:
 - _: UIView (in most cases with a transparent background in order to not hide the CardTextField)
    - cardImageView: UIImageView
    - CardNumberInputTextField (for entering a card number)
    - cardInfoView: UIView (container for other views to enter additional information after entering a valid card number) with subviews ordered from left to right:
        - monthTextField: StylizedTextField
        - yearTextField: StylizedTextField
        - cvcTextField: StylizedTextField
 
 In order to create a custom CardTextField, you can create a subclass which overrides `getNibName()` and `getNibBundle()` in order to load a nib from a specific bundle, which follows this structure
 */
@IBDesignable
public class CardTextField: UITextField, NumberInputTextFieldDelegate {
    
    // MARK: - Public variables
    
    /**
    The image view which is used to display the detected card type.
    */
    @IBOutlet public weak var cardImageView: UIImageView?
    
    /**
     A but which is shown only when the delegate's
     */
    @IBOutlet public weak var accessoryButton: UIButton?
    
    /**
     The formatted text field which is used to enter the card number.
     */
    @IBOutlet public weak var numberInputTextField: NumberInputTextField!
    
    /**
     The text field which is used to enter the card validation code.
     */
    @IBOutlet public weak var cvcTextField: CVCInputTextField!
    
    /**
     The text field which is used to enter the month of the expiry date.
     */
    @IBOutlet public weak var monthTextField: MonthInputTextField!
    
    /**
     The text field which is used to enter the year of the expiry date.
     */
    @IBOutlet public weak var yearTextField: YearInputTextField!
    
    /**
     The view which is slided in from the right after a valid card number has been entered.
     */
    @IBOutlet public weak var cardInfoView: UIView?

    /// The image store for the card number text field.
    public var cardTypeImageStore: CardTypeImageStore = NSBundle(forClass: CardTextField.self)

    public var cardTextFieldDelegate: CardTextFieldDelegate? {
        didSet {
            setupAccessoryButton()
        }
    }
    
    /**
     The string value that is used to separate the different groups of a card number in the text field.
     */
    @IBInspectable public var cardNumberSeparator: String? = " - " {
        didSet {
            numberInputTextField?.cardNumberSeparator = cardNumberSeparator ?? " - "
        }
    }
    
    /**
     The duration of the view animation when switching from number input to detail.
     */
    @IBInspectable public var viewAnimationDuration: Double? = 0.3
    
    /**
     The text color for invalid input in a text field.
     */
    @IBInspectable public var invalidInputColor: UIColor? {
        didSet {
            guard let invalidInputColor = invalidInputColor else {
                return
            }
            let textFields: [StylizedTextField?] = [numberInputTextField, monthTextField, yearTextField, cvcTextField]
            textFields.forEach({$0?.invalidInputColor = invalidInputColor})
        }
    }
    
    @IBOutlet weak var slashLabel: UILabel!
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint?
    
    /**
     Inset before the card type image view. Defaults to 1.0.
     */
    @IBInspectable public var imageViewLeadingInset: CGFloat = 1.0 {
        didSet {
            imageViewLeadingConstraint?.constant = imageViewLeadingInset
        }
    }
    
    /**
     Inset after the card type image view. Defaults to 4.0.
     */
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint?
    @IBInspectable public var imageViewTrailingInset: CGFloat = 4.0 {
        didSet {
            imageViewTrailingConstraint?.constant = imageViewTrailingInset
        }
    }
    
    /**
     Inset before the accessory button. Defaults to 4.0.
     */
    @IBOutlet weak var accessoryButtonLeadingConstraint: NSLayoutConstraint?
    @IBInspectable public var accessoryButtonLeadingInset: CGFloat = 4.0 {
        didSet {
            accessoryButtonLeadingConstraint?.constant = accessoryButtonLeadingInset
        }
    }
    
    /**
     Inset after the card type image view. Defaults to 5.0.
     */
    @IBOutlet weak var accessoryButtonTrailingConstraint: NSLayoutConstraint?
    @IBInspectable public var accessoryButtonTrailingInset: CGFloat = 5.0 {
        didSet {
            accessoryButtonTrailingConstraint?.constant = accessoryButtonTrailingInset
        }
    }
    
    /**
     The currently entered card values. Note that the values are not guaranteed to be valid.
     */
    public var card: Card {
        get {
            let cardNumber = numberInputTextField.cardNumber
            let cardCVC = CVC(rawValue: cvcTextField.text ?? "")
            let cardExpiry =
                Expiry(month: monthTextField.text ?? "", year: yearTextField.text ?? "")
                    ?? Expiry.invalid

            return Card(bankCardNumber: cardNumber, cardVerificationCode: cardCVC, expiryDate: cardExpiry)
        }
    }
    
    /**
     This card type register contains a list of all valid card types. You can provide separate card type registers for different card number text fields.
     By default, CardTypeRegister.sharedCardTypeRegister is used.
     */
    public var cardTypeRegister: CardTypeRegister = CardTypeRegister.sharedCardTypeRegister

    #if !TARGET_INTERFACE_BUILDER
    public override var placeholder: String? {
        didSet {
            numberInputTextField?.placeholder = placeholder
            super.placeholder = nil
        }
    }
    #endif
    
    public override var attributedPlaceholder: NSAttributedString? {
        didSet {
            numberInputTextField?.attributedPlaceholder = attributedPlaceholder
            super.attributedPlaceholder = nil
        }
    }
    
    /**
     The card type for the entered card number or nil, if no card type has been detected with the given input.
     */
    public final var cardType: CardType? {
        guard let number = numberInputTextField?.cardNumber else {
            return nil
        }
        
        return cardTypeRegister.cardTypeForNumber(number)
    }
    
    // MARK: - Initializers & view setup
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        #if !TARGET_INTERFACE_BUILDER
            setupView()
        #endif
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        #if !TARGET_INTERFACE_BUILDER
            setupView()
        #endif
    }
    
    /**
     Sets up the view by loading subviews from the given Nib in the specified bundle.
     */
    private func setupView() {
        guard let nib = getNibBundle().loadNibNamed(getNibName(), owner: self, options: nil), let firstObjectInNib = nib.first as? UIView else {
            fatalError("The nib is expected to contain a UIView as root element.")
        }
        
        numberInputTextField.contentMode = UIViewContentMode.Redraw
        
        clipsToBounds = true
        
        firstObjectInNib.autoresizesSubviews = true
        firstObjectInNib.translatesAutoresizingMaskIntoConstraints = true
        firstObjectInNib.frame = bounds
        addSubview(firstObjectInNib)
        
        cardImageView?.image = cardTypeImageStore.imageForCardType(UnknownCardType())
        cardImageView?.backgroundColor = backgroundColor ?? UIColor.whiteColor()
        cardImageView?.layer.cornerRadius = 5.0
        cardImageView?.layer.shadowColor = UIColor.blackColor().CGColor
        cardImageView?.layer.shadowRadius = 2
        cardImageView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardImageView?.layer.shadowOpacity = 0.2
        
        imageViewLeadingConstraint?.constant = imageViewLeadingInset
        imageViewTrailingConstraint?.constant = imageViewTrailingInset
        accessoryButtonLeadingConstraint?.constant = accessoryButtonLeadingInset
        accessoryButtonTrailingConstraint?.constant = accessoryButtonTrailingInset
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(moveNumberFieldLeftAnimated))
        leftSwipeGestureRecognizer.direction = .Left
        firstObjectInNib.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        [firstObjectInNib, cardInfoView].forEach({
            let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(moveNumberFieldRightAnimated))
            rightSwipeGestureRecognizer.direction = .Right
            $0?.addGestureRecognizer(rightSwipeGestureRecognizer)
        })
        
        setupTextFieldDelegates()
        setupTextFieldAttributes()
        setupTargetsForEditinBegin()
        setupAccessoryButton()
    }
    
    private func setupTextFieldDelegates() {
        numberInputTextField?.numberInputTextFieldDelegate = self
        monthTextField?.cardInfoTextFieldDelegate = self
        yearTextField?.cardInfoTextFieldDelegate = self
        cvcTextField?.cardInfoTextFieldDelegate = self
    }
    
    /**
     Customizes text field attributes of subviews so that the appearance matches the appearance of `self`.
     */
    private func setupTextFieldAttributes() {
        numberInputTextField?.cardNumberSeparator = cardNumberSeparator ?? " - "
        numberInputTextField?.placeholder = placeholder
        
        cvcTextField?.deleteBackwardCallback = {_ -> Void in self.yearTextField?.becomeFirstResponder()}
        monthTextField?.deleteBackwardCallback = {_ -> Void in self.numberInputTextField?.becomeFirstResponder()}
        yearTextField?.deleteBackwardCallback = {_ -> Void in self.monthTextField?.becomeFirstResponder()}
        
        let textFields: [UITextField?] = [numberInputTextField,cvcTextField,monthTextField,yearTextField]
        textFields.forEach({
            $0?.keyboardType = .NumberPad
            $0?.textColor = textColor
            $0?.font = font
            $0?.keyboardAppearance = keyboardAppearance
            $0?.secureTextEntry = secureTextEntry
        })
        
        super.textColor = UIColor.clearColor()
        super.placeholder = nil
    }
    
    private func setupTargetsForEditinBegin() {
        // Show the full number text field, if editing began on it
        numberInputTextField?.addTarget(self, action: #selector(moveNumberFieldRightAnimated), forControlEvents: UIControlEvents.EditingDidBegin)
        
        // Show CVC image if the cvcTextField is selected, show card image otherwise
        let nonCVCTextFields: [UITextField?] = [numberInputTextField, monthTextField, yearTextField]
        nonCVCTextFields.forEach({$0?.addTarget(self, action: #selector(showCardImage), forControlEvents: .EditingDidBegin)})
        cvcTextField?.addTarget(self, action: #selector(showCVCImage), forControlEvents: .EditingDidBegin)
    }
    
    internal func buttonReceivedAction() {
        cardTextFieldDelegate?.cardTextFieldShouldProvideAccessoryAction(self)?()
    }
    
    private func setupAccessoryButton() {
        guard let _ = cardTextFieldDelegate?.cardTextFieldShouldProvideAccessoryAction(self) else {
            accessoryButton?.alpha = 0
            return
        }
        accessoryButton?.addTarget(self, action: #selector(buttonReceivedAction), forControlEvents: .TouchUpInside)
        accessoryButton?.alpha = 1.0
        accessoryButton?.imageView?.contentMode = .ScaleAspectFit
        
        if let buttonImage = cardTextFieldDelegate?.cardTextFieldShouldShowAccessoryImage(self) {
            let scaledImage = buttonImage.resizableImageWithCapInsets(UIEdgeInsetsZero, resizingMode: .Stretch)
            accessoryButton?.titleLabel?.text = nil
            accessoryButton?.setImage(scaledImage, forState: .Normal)
            accessoryButton?.tintColor = numberInputTextField?.textColor
        }
    }
    
    // MARK: - View lifecycle
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let secondaryView = cardInfoView {
            if secondaryView.superview != superview {
                superview?.addSubview(secondaryView)
            }
        }
        
        cardInfoView?.frame = bounds
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        moveNumberFieldRight()
    }
    
    // MARK: - View customization
    
    /**
    You can override this function to provide your own Nib. If you do so, please override 'getNibBundle' as well to provide the right NSBundle to load the nib file.
    */
    public func getNibName() -> String {
        return "CardView"
    }
    
    /**
     You can override this function to provide the NSBundle for your own Nib. If you do so, please override 'getNibName' as well to provide the right Nib to load the nib file.
     */
    public func getNibBundle() -> NSBundle {
        return NSBundle(forClass: CardTextField.self)
    }
    
    // MARK: - CardNumberInputTextFieldDelegate
    
    /**
     Notifies `CardTextFieldDelegate` about changes to the entered card information.
     */
    internal func notifyDelegate() {
        let result: CardValidationResult = {
            guard let cardType = self.cardType else {
                return .UnknownType
            }

            return cardType.validateNumber(self.card.bankCardNumber)
                .union(cardType.validateCVC(self.card.cardVerificationCode))
                .union(cardType.validateExpiry(self.card.expiryDate))
        }()

        cardTextFieldDelegate?.cardTextField(self,
                                             didEnterCardInformation: card,
                                             withValidationResult: result)
    }
    
    @objc public func numberInputTextFieldDidChangeText(CardTextField: NumberInputTextField) {
        showCardImage()
        notifyDelegate()
    }
    
    public func numberInputTextFieldDidComplete(CardTextField: NumberInputTextField) {
        moveNumberFieldLeftAnimated()
        
        notifyDelegate()
        monthTextField?.becomeFirstResponder()
    }
    
    // MARK: - Card 
    
    internal func showCardImage() {
        let cardType = cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber)
        let cardTypeImage = cardTypeImageStore.imageForCardType(cardType)

        cardImageView?.image = cardTypeImage
    }
    
    internal func showCVCImage() {
        let cardType = cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber)
        let cvcImage = cardTypeImageStore.cvcImageForCardType(cardType)
        
        cardImageView?.image = cvcImage
        cvcTextField?.cardType = cardType
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // If moving to a larger screen size and not showing the detail view, make sure that it is outside the view.
        if let transform = cardInfoView?.transform where !CGAffineTransformIsIdentity(transform) {
            moveNumberFieldRight()
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Detect touches in card number text field as long as the detail view is on top of it
        touches.forEach({ touch -> () in
            let point = touch.locationInView(self)
            if (numberInputTextField?.pointInside(point, withEvent: event) ?? false) && [monthTextField,yearTextField,cvcTextField, slashLabel].reduce(true, combine: { (currentValue: Bool, view: UIView?) -> Bool in
                let pointInView = touch.locationInView(view)
                return currentValue && !(view?.pointInside(pointInView, withEvent: event) ?? false)
            }) {
                numberInputTextField?.becomeFirstResponder()
            }
        })
    }
    
    public override func becomeFirstResponder() -> Bool {
        // Return false, since this text view is only for background style purposes
        return false
    }
}
