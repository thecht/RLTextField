


import UIKit

public class RLTextField: UIView {
    
    fileprivate var stateManager: RLTextFieldStateManager!
    
    fileprivate var placeholderLabel        = UILabel()
    fileprivate var internalTextField       = UITextField()
    fileprivate var cancelTextButton        = UIButton()
    
    fileprivate var validationHandlers      = [RLValidationHandler]()
    
    fileprivate var padding: CGFloat        = 20
    fileprivate var placeholderLabelFocusedConstraints: [NSLayoutConstraint] = []
    fileprivate var placeholderLabelDefocusedConstraints: [NSLayoutConstraint] = []
    fileprivate var textFieldFocusedConstraints: [NSLayoutConstraint] = []
    fileprivate var textFieldDefocusedConstraints: [NSLayoutConstraint] = []
    
    // MARK: Properties
    public var delegate: UITextFieldDelegate? {
        get { return self.internalTextField.delegate }
        set { self.internalTextField.delegate = newValue }
    }
    
    public var isSecureTextEntry: Bool {
        get { return internalTextField.isSecureTextEntry }
        set { internalTextField.isSecureTextEntry = newValue }
    }
    
    public var enableSuccessColors: Bool = true
    
    public var useValidation: Bool = true
    
    public var text: String {
        get { return internalTextField.text != nil ? internalTextField.text! : "" }
        set { internalTextField.text = newValue }
    }
    
    public var placeholderText: String = ""
    
    public var state: RLTextFieldViewState {
        return stateManager.viewState
    }
    
    public var textState: RLTextFieldTextState {
        return stateManager.textState
    }
    
    private var _primaryBorderColor: UIColor = .black
    public var primaryBorderColor: UIColor {
        get {
            if _primaryBorderColor == .black {
                return traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : UIColor.black
            } else {
                return _primaryBorderColor
            }
        }
        set {
            _primaryBorderColor = newValue
            if stateManager.viewState != .completed {
                layer.borderColor = _primaryBorderColor.cgColor
            }
        }
    }
    
    private var _secondaryBorderColor: UIColor = .tertiaryLabel
    public var secondaryBorderColor: UIColor {
        get { return _secondaryBorderColor }
        set {
            _secondaryBorderColor = newValue
            if stateManager.viewState == .completed {
                layer.borderColor = _secondaryBorderColor.cgColor
            }
        }
    }
    
    private var _errorColor: UIColor = .systemRed
    public var errorColor: UIColor {
        get { return _errorColor }
        set {
            _errorColor = newValue
            if stateManager.textState == .error {
                layer.borderColor = _errorColor.cgColor
            }
        }
    }
    
    private var _successColor: UIColor = .systemGreen
    public var successColor: UIColor {
        get { return _successColor }
        set {
            _successColor = newValue
            if stateManager.textState == .success {
                layer.borderColor = _successColor.cgColor
            }
        }
    }
    
    private var _primaryBackgroundColor: UIColor = .systemBackground
    public var primaryBackgroundColor: UIColor {
        get { return _primaryBackgroundColor }
        set {
            _primaryBackgroundColor = newValue
            if stateManager.viewState != .empty {
                backgroundColor = _primaryBackgroundColor
            }
        }
    }
    
    private var _secondaryBackgroundColor: UIColor = UIColor.secondarySystemBackground.withAlphaComponent(0.75)
    public var secondaryBackgroundColor: UIColor {
        get { return _secondaryBackgroundColor }
        set {
            _secondaryBackgroundColor = newValue
            if stateManager.viewState == .empty {
                backgroundColor = _secondaryBackgroundColor
            }
        }
    }
    
    private var _primaryTextColor: UIColor = .label
    public var primaryTextColor: UIColor {
        get { return _primaryTextColor }
        set {
            _primaryTextColor = newValue
            internalTextField.textColor = _primaryTextColor
            if stateManager.viewState == .editing {
                placeholderLabel.textColor = _primaryTextColor
            }
        }
    }
    
    private var _secondaryTextColor: UIColor = .tertiaryLabel
    public var secondaryTextColor: UIColor {
        get { return _secondaryTextColor }
        set {
            _secondaryTextColor = newValue
            if stateManager.viewState != .editing {
                placeholderLabel.textColor = _secondaryTextColor
            }
        }
    }
    
    public var cancelButtonColor: UIColor {
        get { return cancelTextButton.tintColor }
        set {
            cancelTextButton.tintColor = newValue
        }
    }
    
    // MARK: Object Creation
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureAnimationHelper()
        configureTapHandler()
        configurePlaceholderLabel()
        configureCancelButton()
        configureUITextField()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience public init(placeholderText: String) {
        self.init(frame: .zero)
        self.placeholderText = placeholderText
        placeholderLabel.text = placeholderText
    }
    
    // MARK: Object Configuration
    private func configure() {
        backgroundColor = secondaryBackgroundColor
        layer.cornerRadius = 5
    }
    
    private func configureAnimationHelper() {
        stateManager = RLTextFieldStateManager(with: self)
        stateManager.textField = self
    }
    
    private func configureTapHandler() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textFieldtapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configurePlaceholderLabel() {
        addSubview(placeholderLabel)
        
        placeholderLabel.textColor                   = .tertiaryLabel
        placeholderLabel.adjustsFontSizeToFitWidth   = true
        placeholderLabel.lineBreakMode               = .byTruncatingTail
        placeholderLabel.textAlignment               = .left
        placeholderLabel.minimumScaleFactor          = 0.1
        placeholderLabel.numberOfLines               = 0
        placeholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabelFocusedConstraints = [
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            placeholderLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.33)
        ]
        
        placeholderLabelDefocusedConstraints = [
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding/2),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding/2),
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            placeholderLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.33)
        ]
        
        NSLayoutConstraint.activate(placeholderLabelFocusedConstraints)
    }
    
    private func configureUITextField() {
        addSubview(internalTextField)
        internalTextField.translatesAutoresizingMaskIntoConstraints = false
        internalTextField.autocorrectionType    = .no
        internalTextField.returnKeyType         = .done
        internalTextField.font                  = UIFont.systemFont(ofSize: 16, weight: .heavy)
        internalTextField.textColor             = .label
        
        textFieldDefocusedConstraints = [
            internalTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            internalTextField.trailingAnchor.constraint(equalTo: self.cancelTextButton.leadingAnchor, constant: -padding),
            internalTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            internalTextField.heightAnchor.constraint(equalToConstant: 0)
        ]
        
        textFieldFocusedConstraints = [
            internalTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding/2),
            internalTextField.trailingAnchor.constraint(equalTo: self.cancelTextButton.leadingAnchor, constant: -padding/2),
            internalTextField.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor),
            internalTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ]
        
        NSLayoutConstraint.activate(textFieldDefocusedConstraints)
    }
    
    private func configureCancelButton() {
        addSubview(cancelTextButton)
        cancelTextButton.translatesAutoresizingMaskIntoConstraints = false
        cancelTextButton.setImage(UIImage(systemName: "clear"), for: .normal)
        cancelTextButton.addTarget(self, action: #selector(clearTextButtonTapped), for: .touchUpInside)
        cancelTextButton.tintColor   = .tertiaryLabel
        cancelTextButton.isHidden    = true
        cancelTextButton.isEnabled   = false
        
        NSLayoutConstraint.activate([
            cancelTextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            cancelTextButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cancelTextButton.heightAnchor.constraint(equalToConstant: 25),
            cancelTextButton.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    // MARK: Object manipulation
    public func endEditing() {
        if internalTextField.text?.count == 0 {
            stateManager.viewState = .empty
        } else {
            stateManager.viewState = .completed
            validateText()
        }
    }
    
    private func validateText() {
        guard useValidation else { return }
        var hasError = false
        
        for validationHandler in validationHandlers {
            if !validationHandler.isValidText(text) {
                stateManager.textState = .error
                placeholderLabel.text = validationHandler.errorMessage
                
                hasError = true
                break
            }
        }
        
        if !hasError {
            placeholderLabel.text = placeholderText
            if validationHandlers.count > 0 {
                stateManager.textState = .success
            } else {
                stateManager.textState = .normal
            }
        }
    }
    
    // MARK: Misc. Utility
    public static func getRLTextField(from textFields: [RLTextField], containingInternalUITextField textField: UITextField) -> RLTextField? {
        var returnField: RLTextField?
        for field in textFields {
            if textField === field.internalTextField {
                returnField = field
            }
        }
        return returnField
    }
    
    public func addValidation(errorMessage: String, validationHandler: @escaping (String) -> Bool) {
        validationHandlers.append(RLValidationHandler(errorMessage: errorMessage, isValidText: validationHandler))
    }
    
    public func removeValidation() {
        validationHandlers.removeAll()
    }
    
    @objc func textFieldtapped() {
        internalTextField.isUserInteractionEnabled = true
        if stateManager.viewState != .editing {
            stateManager.viewState = .editing
        }
    }
    
    @objc func clearTextButtonTapped() {
        if internalTextField.text?.count == 0 && stateManager.viewState == .editing {
            stateManager.viewState = .empty
        } else {
            internalTextField.text = ""
            stateManager.textState = .normal
            if stateManager.viewState != .editing {
                stateManager.viewState = .empty
            }
        }
    }
    
}

private struct RLValidationHandler {
    var errorMessage: String
    var isValidText: (String) -> Bool
}

public enum RLTextFieldViewState {
    case empty
    case editing
    case completed
}

public enum RLTextFieldTextState {
    case normal
    case error
    case success
}

// MARK: Animation State Manager
fileprivate class RLTextFieldStateManager {
    
    weak var textField: RLTextField!
    
    private var _viewState: RLTextFieldViewState = .empty
    var viewState: RLTextFieldViewState {
        get { return _viewState }
        set {
            if newValue != _viewState {
                _viewState = newValue
                transitionViewState(to: _viewState)
            }
        }
    }
    
    private var _textState: RLTextFieldTextState = .normal
    var textState: RLTextFieldTextState {
        get { return _textState }
        set {
            if newValue != _textState {
                _textState = newValue
                transitionTextState(to: _textState)
            }
        }
    }
    
    init(with delegate: RLTextField) {
        self.textField = delegate
    }
    
    private func transitionViewState(to state: RLTextFieldViewState) {
        switch state {
        case .empty:
            activateEmptyState()
        case .editing:
            activateEditingState()
        case .completed:
            activateCompletedState()
        }
    }
    
    private func transitionTextState(to state: RLTextFieldTextState) {
        animateBorderColor(of: textField, withColor: borderColorForCurrentState())
        animateTextColor(of: textField.placeholderLabel, with: labelColorForCurrentState())
        if state == .normal {
            textField.placeholderLabel.text = textField.placeholderText
        }
    }
    
    private func activateEmptyState() {
        textField.internalTextField.isUserInteractionEnabled = false
        textField.internalTextField.resignFirstResponder()
        
        textState = .normal
        
        animatePlaceholderLabelToPrimaryPosition()
        animateUITextFieldToInactivePosition()
        setCancelTextButton(toActive: false)
        
        animateTextColor(of: textField.placeholderLabel, with: labelColorForCurrentState())
        animateBorderColor(of: textField, withColor: borderColorForCurrentState())
        if textState == .normal {
            animateBorderWidth(of: textField, withWidth: 0)
        }
    }
    
    private func activateEditingState() {
        textField.internalTextField.becomeFirstResponder()
        setCancelTextButton(toActive: true)
        
        animateUITextFieldToActivePosition()
        animatePlaceholderLabelToSecondaryPosition()

        animateTextColor(of: textField.placeholderLabel, with: labelColorForCurrentState())
        animateBorderWidth(of: textField, withWidth: 2.0)
        animateBorderColor(of: textField, withColor: borderColorForCurrentState())
    }
    
    private func activateCompletedState() {
        textField.internalTextField.isUserInteractionEnabled = false
        textField.internalTextField.resignFirstResponder()
        
        animateTextColor(of: textField.placeholderLabel, with: labelColorForCurrentState())
        animateBorderColor(of: textField, withColor: borderColorForCurrentState())
    }
    
    private func setCancelTextButton(toActive: Bool) {
        if toActive {
            textField.cancelTextButton.isHidden = false
            textField.cancelTextButton.isEnabled = true
        } else {
            textField.cancelTextButton.isEnabled = false
            textField.cancelTextButton.isHidden = true
        }
    }
    
    private func animatePlaceholderLabelToPrimaryPosition() {
        textField.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.textField.placeholderLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0).translatedBy(x: 0, y: 0)
            NSLayoutConstraint.deactivate(self.textField.placeholderLabelDefocusedConstraints)
            NSLayoutConstraint.activate(self.textField.placeholderLabelFocusedConstraints)
            self.textField.backgroundColor = self.textField.secondaryBackgroundColor
            self.textField.layoutIfNeeded()
        }
    }
    
    private func animatePlaceholderLabelToSecondaryPosition() {
        self.textField.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            NSLayoutConstraint.deactivate(self.textField.placeholderLabelFocusedConstraints)
            NSLayoutConstraint.activate(self.textField.placeholderLabelDefocusedConstraints)
            
            let translationConstant = (self.textField.bounds.width - self.textField.padding) * 0.175
            self.textField.placeholderLabel.transform = CGAffineTransform.identity.translatedBy(x: -translationConstant, y: 0).scaledBy(x: 0.65, y: 0.65)
            
            self.textField.backgroundColor = self.textField.primaryBackgroundColor
            self.textField.layoutIfNeeded()
        }
    }
    
    private func animateUITextFieldToActivePosition() {
        self.textField.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            NSLayoutConstraint.deactivate(self.textField.textFieldDefocusedConstraints)
            NSLayoutConstraint.activate(self.textField.textFieldFocusedConstraints)
            self.textField.layoutIfNeeded()
        }) { [weak self] (completion) in
            guard let self = self else { return }
            self.textField.internalTextField.becomeFirstResponder()
        }
    }
    
    private func animateUITextFieldToInactivePosition() {
        self.textField.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            NSLayoutConstraint.deactivate(self.textField.textFieldFocusedConstraints)
            NSLayoutConstraint.activate(self.textField.textFieldDefocusedConstraints)
            self.textField.layoutIfNeeded()
        }
    }
    
    private func animateTextColor(of label: UILabel, with color: UIColor) {
        coreAnimate(view: label, duration: 0.2) {
            label.textColor = color
        }
    }

    private func animateBorderWidth(of view: UIView, withWidth width: CGFloat) {
        coreAnimate(view: view, duration: 0.2) {
            view.layer.borderWidth = width
        }
    }

    private func animateBorderColor(of view: UIView, withColor color: UIColor) {
        coreAnimate(view: view, duration: 0.2) {
            view.layer.borderColor = color.cgColor
        }
    }
    
    private func coreAnimate(view: UIView, duration: CFTimeInterval, animationBlock: @escaping () -> Void) {
        let animationTransition = CATransition()
        animationTransition.duration = duration
        CATransaction.setCompletionBlock {
            view.layer.add(animationTransition, forKey: nil)
            animationBlock()
        }
        CATransaction.commit()
    }
    
    private func labelColorForCurrentState() -> UIColor {
        if textState == .error {
            return textField.errorColor
        }
        else if textState == .success {
            if textField.enableSuccessColors {
                return textField.successColor
            } else {
                return textField.secondaryTextColor
            }
        }
        else if viewState == .completed || viewState == .empty {
            return textField.secondaryTextColor
        }
        else {
            return textField.primaryTextColor
        }
    }
    
    private func borderColorForCurrentState() -> UIColor {
        if textState == .error {
            return textField.errorColor
        }
        else if textState == .success && textField.enableSuccessColors {
            return textField.successColor
        }
        else if viewState == .editing {
            return textField.primaryBorderColor
        }
        else {
            return textField.secondaryBorderColor
        }
    }
}
