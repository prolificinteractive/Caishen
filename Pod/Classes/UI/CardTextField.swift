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
    public var cardTypeImageStore: CardTypeImageStore = Bundle(for: CardTextField.self)

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
    @IBInspectable public var viewAnimationDuration: Double = 0.3
    
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
    
    /**
     The label which is used as separator inbetween the text fields for month and year of the card expiry.
     */
    @IBOutlet weak var slashLabel: UILabel!
    
    /**
     The view constraint which insets the card image view from its superview's leading edge.
     */
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
     The view constraint which insets the card image view from the card number text field.
     */
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint?
    
    /**
     Inset after the card type image view. Defaults to 4.0.
     */
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
    public var cardTypeRegister: CardTypeRegister = CardTypeRegister.sharedCardTypeRegister {
        didSet {
            numberInputTextField.cardTypeRegister = cardTypeRegister
        }
    }

    #if !TARGET_INTERFACE_BUILDER
    public override var placeholder: String? {
        didSet {
            numberInputTextField?.placeholder = placeholder
            super.placeholder = nil
        }
    }
    #endif
    
    public override var attributedPlaceholder: AttributedString? {
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
    
    internal var hideExpiryTextFields: Bool = false {
        didSet {
            monthTextField.isHidden = hideExpiryTextFields
            yearTextField.isHidden = hideExpiryTextFields
            slashLabel.isHidden = hideExpiryTextFields
        }
    }
    
    internal var hideCVCTextField: Bool = false {
        didSet {
            cvcTextField.isHidden = hideCVCTextField
        }
    }
    
    /// Computed variable that returns whether or not the view should use right to left layout design. On iOS 9 and newer, this will be based on the interface layout of `self`, whereas this property is not available on older versions of iOS and therefor uses the character direction of the device language.
    internal var isRightToLeftLanguage: Bool {
        if #available(iOS 9.0, *) {
            return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        } else {
            let isoCode = Locale.autoupdatingCurrent.object(forKey: Locale.Key.languageCode) as? String ?? ""
            return Locale.characterDirection(forLanguage: isoCode) == Locale.LanguageDirection.rightToLeft
        }
    }
    
    // MARK: - Initializers & view setup
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.localeDidChange), name: Locale.currentLocaleDidChangeNotification, object: nil)
        #if !TARGET_INTERFACE_BUILDER
            setupView()
        #endif
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(self.localeDidChange), name: Locale.currentLocaleDidChangeNotification, object: nil)
        #if !TARGET_INTERFACE_BUILDER
            setupView()
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Locale.currentLocaleDidChangeNotification, object: nil)
    }
    
    /**
     Updates the view after the locale did change to potentially switch between left to right and right to left reading style.
     */
    internal func localeDidChange() {
        setupView()
    }
    
    /**
     Sets up the view by loading subviews from the given Nib in the specified bundle.
     */
    private func setupView() {
        guard let nib = getNibBundle().loadNibNamed(getNibName(), owner: self, options: nil), let firstObjectInNib = nib.first as? UIView else {
            fatalError("The nib is expected to contain a UIView as root element.")
        }
        
        numberInputTextField.contentMode = UIViewContentMode.redraw
        
        clipsToBounds = true
        
        firstObjectInNib.autoresizesSubviews = true
        firstObjectInNib.translatesAutoresizingMaskIntoConstraints = true
        firstObjectInNib.frame = bounds
        addSubview(firstObjectInNib)
        
        cardImageView?.image = cardTypeImageStore.imageForCardType(UnknownCardType())
        cardImageView?.layer.cornerRadius = 5.0
        cardImageView?.layer.shadowColor = UIColor.black().cgColor
        cardImageView?.layer.shadowRadius = 2
        cardImageView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardImageView?.layer.shadowOpacity = 0.2
        
        imageViewLeadingConstraint?.constant = imageViewLeadingInset
        imageViewTrailingConstraint?.constant = imageViewTrailingInset
        accessoryButtonLeadingConstraint?.constant = accessoryButtonLeadingInset
        accessoryButtonTrailingConstraint?.constant = accessoryButtonTrailingInset
        
        // Reset gesture recognizers
        [firstObjectInNib, cardInfoView].forEach({$0?.gestureRecognizers = []})
        
        let hideCardNumberSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(moveCardNumberOutAnimated))
        hideCardNumberSwipeRecognizer.direction = isRightToLeftLanguage ? .right : .left
        firstObjectInNib.addGestureRecognizer(hideCardNumberSwipeRecognizer)
        
        [firstObjectInNib, cardInfoView].forEach({
            let showCardNumberSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(moveCardNumberInAnimated))
            showCardNumberSwipeRecognizer.direction = isRightToLeftLanguage ? .left : .right
            $0?.addGestureRecognizer(showCardNumberSwipeRecognizer)
        })
        
        setupTextFieldDelegates()
        setupTextFieldAttributes()
        setupTargetsForEditinBegin()
        setupAccessoryButton()
        setupAccessibilityLabels()
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
        
        cvcTextField?.deleteBackwardCallback = {_ -> Void in
            if self.hideExpiryTextFields {
                self.numberInputTextField.becomeFirstResponder()
            } else {
                self.yearTextField?.becomeFirstResponder()
            }
        }
        monthTextField?.deleteBackwardCallback = {_ -> Void in
            self.numberInputTextField?.becomeFirstResponder()
        }
        yearTextField?.deleteBackwardCallback = {_ -> Void in
            if self.hideExpiryTextFields {
                self.numberInputTextField.becomeFirstResponder()
            } else {
                self.monthTextField?.becomeFirstResponder()
            }
        }
        
        // Set the text alignment of cvc and month text field manually, as there is no
        // counterpart to `right` (in a left-to-right script) that changes based on localization
        // and can be set in a Nib.
        if isRightToLeftLanguage {
            cvcTextField.textAlignment = .left
            monthTextField.textAlignment = .left
        } else {
            cvcTextField.textAlignment = .right
            monthTextField.textAlignment = .right
        }
        
        let textFields: [UITextField?] = [numberInputTextField, cvcTextField, monthTextField, yearTextField]
        textFields.forEach({
            $0?.keyboardType = .numberPad
            $0?.textColor = textColor
            $0?.font = font
            $0?.keyboardAppearance = keyboardAppearance
            $0?.isSecureTextEntry = isSecureTextEntry
        })
        
        super.textColor = UIColor.clear()
        super.placeholder = nil
    }
    
    /**
     Adds voice over accessibility support for all text fields
     */
    private func setupAccessibilityLabels() {
        setupAccessibilityLabelForTextField(numberInputTextField)
        setupAccessibilityLabelForTextField(cvcTextField)
        setupAccessibilityLabelForTextField(monthTextField)
        setupAccessibilityLabelForTextField(yearTextField)
    }
    
    /**
     Adds voice over accessibility support for a particular text fields
     
     - parameter textField: a text field that needs support for voice over accessibility
     */
    private func setupAccessibilityLabelForTextField(_ textField: UITextField) {
        textField.accessibilityLabel = Localization.accessibilityLabelForTextField(textField,
                                                                                   comment: "Accessibility label for \(String(textField))")
    }
    
    /**
     Adds a callback to `numberInputTextField`, `monthTextField` and `yearTextField` to show the card type image in `cardImageView` when editing on any of these text fields began. Adds a callback to cvcTextField to show the CVC image in this view in this case.
     */
    private func setupTargetsForEditinBegin() {
        // Show the full number text field, if editing began on it
        numberInputTextField?.addTarget(self, action: #selector(moveCardNumberInAnimated), for: UIControlEvents.editingDidBegin)
        
        // Show CVC image if the cvcTextField is selected, show card image otherwise
        let nonCVCTextFields: [UITextField?] = [numberInputTextField, monthTextField, yearTextField]
        nonCVCTextFields.forEach({$0?.addTarget(self, action: #selector(showCardImage), for: .editingDidBegin)})
        cvcTextField?.addTarget(self, action: #selector(showCVCImage), for: .editingDidBegin)
    }
    
    /**
     Function that is called when the user tapped on the optionally provided accessory button and performs its designated action.
     */
    internal func buttonReceivedAction() {
        cardTextFieldDelegate?.cardTextFieldShouldProvideAccessoryAction(self)?()
    }
    
    /**
     Sets up the card text field's accessory button if one is provided.
     */
    private func setupAccessoryButton() {
        guard let _ = cardTextFieldDelegate?.cardTextFieldShouldProvideAccessoryAction(self) else {
            accessoryButton?.alpha = 0
            return
        }
        accessoryButton?.addTarget(self, action: #selector(buttonReceivedAction), for: .touchUpInside)
        accessoryButton?.alpha = 1.0
        accessoryButton?.imageView?.contentMode = .scaleAspectFit
        
        if let buttonImage = cardTextFieldDelegate?.cardTextFieldShouldShowAccessoryImage(self) {
            let scaledImage = buttonImage.resizableImage(withCapInsets: UIEdgeInsetsZero, resizingMode: .stretch)
            accessoryButton?.titleLabel?.text = nil
            accessoryButton?.setImage(scaledImage, for: UIControlState())
            accessoryButton?.tintColor = numberInputTextField?.textColor
        }
        
        accessoryButton?.accessibilityLabel = cardTextFieldDelegate?.cardTextFieldShouldProvideAccessoryButtonAccessibilityLabel(self)
    }
    
    // MARK: - View lifecycle
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let secondaryView = cardInfoView {
            if secondaryView.superview != superview {
                superview?.addSubview(secondaryView)
            }
        }
        
        cardInfoView?.frame = bounds
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        translateCardNumberIn()
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
    public func getNibBundle() -> Bundle {
        return Bundle(for: CardTextField.self)
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
    
    @objc public func numberInputTextFieldDidChangeText(_ numberInputTextField: NumberInputTextField) {
        showCardImage()
        notifyDelegate()
        hideExpiryTextFields = !cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber).requiresExpiry
        hideCVCTextField = !cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber).requiresCVC
    }
    
    public func numberInputTextFieldDidComplete(_ numberInputTextField: NumberInputTextField) {
        moveCardNumberOutAnimated()
        
        notifyDelegate()
        hideExpiryTextFields = !cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber).requiresExpiry
        hideCVCTextField = !cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber).requiresCVC
        if hideExpiryTextFields && hideCVCTextField {
            return
        } else if hideExpiryTextFields {
            cvcTextField.becomeFirstResponder()
        } else {
            monthTextField?.becomeFirstResponder()
        }
    }
    
    // MARK: - Card 
    
    /**
     Displays the card image for the currently detected card type in the card text field's `cardImageView`.
     */
    internal func showCardImage() {
        let cardType = cardTypeRegister.cardTypeForNumber(numberInputTextField.cardNumber)
        let cardTypeImage = cardTypeImageStore.imageForCardType(cardType)

        cardImageView?.image = cardTypeImage
    }
    
    /**
     Displays the CVC image for the currently detected card type in the card text field's `cardImageView`.
     */
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
        if let transform = cardInfoView?.transform where !transform.isIdentity {
            translateCardNumberIn()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Detect touches in card number text field as long as the detail view is on top of it
        touches.forEach({ touch -> () in
            let point = touch.location(in: numberInputTextField)
            if (numberInputTextField?.point(inside: point, with: event) ?? false) && [monthTextField,yearTextField,cvcTextField, slashLabel].reduce(true, combine: { (currentValue: Bool, view: UIView?) -> Bool in
                let pointInView = touch.location(in: view)
                return currentValue && !(view?.point(inside: pointInView, with: event) ?? false)
            }) {
                numberInputTextField?.becomeFirstResponder()
            }
        })
    }
    
    // MARK: Accessibility
    
    /**
     There are 5 elements that enables accessibility in a CardTextField.
     They are numberInputTextField, monthTextField, yearTextField, cvcTextField and accessoryButton.
     They should be focused when user click on one of them when accessibility is on.
     
     - returns: total number accessibility elements in the container CardTextField
     */
    public override func accessibilityElementCount() -> Int {
        return 5
    }
    
    /**
     Returns the accessibility element at the specified index
     
     - parameter index: The index of the accessibility element
     
     - returns: The accessibility element at the specified index, or nil if none exists
     */
    public override func accessibilityElement(at index: Int) -> AnyObject? {
        switch index {
        case 0:
            return numberInputTextField
        case 1:
            return monthTextField
        case 2:
            return yearTextField
        case 3:
            return cvcTextField
        case 4:
            return accessoryButton
        default:
            return nil
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        // Return false if any of this text field's subviews is already first responder. 
        // Otherwise let `numberInputTextField` become the first responder.
        if [numberInputTextField,monthTextField,yearTextField,cvcTextField]
            .flatMap({return $0.isFirstResponder()})
            .reduce(true, combine: {$0 && $1}) {
            return false
        }
        return numberInputTextField.becomeFirstResponder()
    }
    
    public override func isFirstResponder() -> Bool {
        // Return true if any of `self`'s subviews is the current first responder.
        // Needs to unwrap the IBOutlets otherwise IBInspectable is crashing when using CardTextField because IBOutlets
        // are not initialized yet when IBInspectable engine runs.
        guard let numberInputTextField = numberInputTextField, monthTextField = monthTextField, yearTextField = yearTextField, cvcTextField = cvcTextField else {
            return false
        }

        return [numberInputTextField, monthTextField, yearTextField, cvcTextField]
            .filter({$0.isFirstResponder()})
            .isEmpty == false
    }
    
    public override func resignFirstResponder() -> Bool {
        // If any of `self`'s subviews is first responder, resign first responder status.
        return [numberInputTextField,monthTextField,yearTextField,cvcTextField]
            .filter({$0.isFirstResponder()})
            .first?
            .resignFirstResponder() ?? true
    }
}
